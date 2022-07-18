require "./lib"
require "./class_methods"
require "./crystal"

# Interface to hold sensitive information (often cryptographic keys)
#
# ## Which class should I use?
# * `Crypto::Secret::Todo` - Use with small (<= 4096 bytes) keys
# * `Crypto::Secret::Guarded` - Use for decrypted data that may stress mlock limits
# * `Crypto::Secret::Bidet` - Wipe only with no other protection.  General use and fast.
# * `Crypto::Secret::Not` - Only use when you're sure the data isn't secret.  0 overhead.  No wiping.
#
# Other shards may provide additional `Secret` types ([sodium.cr](https://github.com/didactic-drunk/sodium.cr))
@[Experimental]
abstract class Crypto::Secret
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

  macro inherited
    extend ClassMethods
  end

  def self.new(size : Int32)
    raise NotImplementedError.new("workaround for lack of `abstract def self.new`")
  end

  #  def self.random(size : Int32, *uses : Symbol, *, random = Random::Secure) : Crypto::Secret
  def self.random(size : Int32, *uses : Symbol, **options) : Crypto::Secret
    rand = options[:random]? || Random::Secure
    for(size, *uses).random(random: rand)
  end

  def self.for(size : Int32, *uses : Symbol) : Crypto::Secret
    for(*uses).new(size)
  end

  def self.for(size : Int32, secret : Crypto::Secret) : Crypto::Secret
    raise ArgumentError.new("") unless size == secret.bytesize
    secret
  end

  def self.for(*uses : Symbol) : Crypto::Secret.class
    uses.each do |use|
      if klass = Config::USES[use]?
        return klass
      end
    end
    raise KeyError.new("missing #{uses}, have #{Config::USES.keys}")
  end

  # For debugging.  Leaks the secret
  #
  # Returned String **not** tracked or wiped
  def hexstring : String
    readonly &.hexstring
  end

  # Copies then wipes *data*
  #
  # Prefer this method over `#copy_from`
  def move_from(data : Bytes) : Nil
    copy_from data
  ensure
    data.wipe
  end

  # Copies then wipes *data*
  #
  # Prefer this method over `#copy_from`
  def move_from(data : Crypto::Secret) : Nil
    data.readonly { |dslice| move_from dslice }
  end

  # Copies from *data*
  def copy_from(data : Bytes) : Nil
    readwrite do |slice|
      slice.copy_from data
    end
  end

  # Copies from *data*
  def copy_from(data : Crypto::Secret) : Nil
    data.readonly { |dslice| copy_from dslice }
  end

  # Fills `Secret` with secure random data
  def random(random = Random::Secure) : self
    readwrite do |slice|
      random.random_bytes slice
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

  # Wipes data & makes this object available for reuse
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

  # Marks a region as read & write depending on implementation.
  abstract def readwrite : self
  # Marks a region as read-only depending on implementation.
  abstract def readonly : self
  # Makes a region inaccessible depending on implementation. It cannot be read or written, but the data are preserved.
  abstract def noaccess : self

  # Temporarily marks a region as read & write depending on implementation and yields `Bytes`
  abstract def readwrite(& : Bytes -> U) forall U
  # Temporarily marks a region as readonly depending on implementation and yields `Bytes`
  abstract def readonly(& : Bytes -> U) forall U

  protected abstract def to_slice(& : Bytes -> U) forall U
  abstract def buffer_bytesize : Int32

  def bytesize : Int32
    buffer_bytesize
  end

  macro delegate_to_slice(to object)
    def to_slice(& : Bytes -> U) forall U
      yield {{object.id}}.to_slice
    end
  end

  macro delegate_buffer_bytesize_to(to object)
    def buffer_bytesize : Int32
      {{object.id}}
    end
  end

  protected def wipe_impl(slice : Bytes) : Nil
    slice.wipe
  end
end

require "./config"
