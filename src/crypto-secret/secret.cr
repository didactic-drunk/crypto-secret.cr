require "./lib"
require "./class_methods"

# Interface to hold sensitive information (often cryptographic keys)
#
# **Only for direct use by cryptographic library authors**
#
# For all other applications use a preexisting class that includes `Crypto::Secret`
#
# # Which class should I use?
# * Crypto::Secret::Key - Use with small (<= 4096 bytes) keys
# * Crypto::Secret::Large - Use for decrypted data that may stress mlock limits
# * Crypto::Secret::Not - Won't get wiped but 0 overhead.  Only use when you're sure the data isn't secret
#
# Other shards may provide additional `Secret` types (sodium.cr)
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

  # For debugging.
  # Returned String **not** tracked or wiped
  def hexstring : String
    readonly &.hexstring
  end

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

  abstract def readwrite
  abstract def readonly
  abstract def noaccess

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

  def wipe_impl(slice : Bytes) : Nil
    slice.wipe
  end
end
