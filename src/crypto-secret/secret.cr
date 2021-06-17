require "./lib"
require "./class_methods"

# Interface to hold sensitive information (often cryptographic keys)
#
# **Only for direct use by cryptographic library authors**
#
# For all other applications use a preexisting class that includes `Crypto::Secret`
#
# ## Which class should I use?
# * `Crypto::Secret::Key` - Use with small (<= 4096 bytes) keys
# * `Crypto::Secret::Large` - Use for decrypted data that may stress mlock limits
# * `Crypto::Secret::Not` - Only use when you're sure the data isn't secret.  0 overhead.  No wiping.
#
# Other shards may provide additional `Secret` types ([sodium.cr](https://github.com/didactic-drunk/sodium.cr))
@[Experimental]
module Crypto::Secret
  class Error < Exception
    class KeyWiped < Error
    end

    class InvalidStateTransition < Error
    end

    # Check RLIMIT_MEMLOCK if you receive this
    class OutOfMemory < Error
    end
  end

  enum State
    Cloning
    Wiped
    Noaccess
    Readonly
    Readwrite
  end

  extend ClassMethods

  # For debugging.
  # Returned String **not** tracked or wiped
  def hexstring : String
    readonly &.hexstring
  end

  def random : self
    readwrite do |slice|
      Random::Secure.random_bytes slice
    end
    self
  end

  # Zeroes data
  #
  # Secret is unavailable (readonly/readwrite may fail) until reset
  def wipe
    readwrite do |slice|
      wipe_impl slice
    end
  end

  # Secret is wiped after exiting the block
  def wipe
    yield
  ensure
    wipe
  end

  def reset
    wipe
  end

  def finalize
    wipe
  end

  # Timing safe memory compare
  def ==(other : Secret) : Bool
    readonly do |s1|
      other.readonly do |s2|
        Crypto::Subtle.constant_time_compare s1, s2
      end
    end
  end

  # Timing safe memory compare
  def ==(other : Bytes) : Bool
    readonly do |s1|
      Crypto::Subtle.constant_time_compare s1, other
    end
  end

  # Hide internal state to prevent leaking in to logs
  def inspect(io : IO) : Nil
    io << self.class.to_s << "(***SECRET***)"
  end

  def dup
    readonly do |sslice|
      obj = self.class.new sslice.bytesize
      obj.readwrite do |dslice|
        sslice.copy_to dslice
      end
      # TODO: copy state if possible
      obj
    end
  end


  # Marks a region allocated using as read & write depending on implementation.
  abstract def readwrite : self
  # Marks a region allocated using as read-only depending on implementation.
  abstract def readonly : self
  # Makes a region allocated inaccessible depending on implementation. It cannot be read or written, but the data are preserved.
  abstract def noaccess : self

  protected abstract def to_slice(& : Bytes -> Nil)
  abstract def bytesize : Int32

  macro delegate_to_slice(to object)
    def to_slice(& : Bytes -> Nil)
      yield {{object.id}}.to_slice
    end
  end

  macro delegate_to_bytesize(to object)
    def bytesize : Int32
      {{object.id}}
    end
  end

  protected def wipe_impl(slice : Bytes) : Nil
    slice.wipe
  end
end
