require "crypto/subtle"

lib LibC
  fun explicit_bzero(Void*, LibC::SizeT) : Int
end

struct Slice(T)
  def wipe
    r = LibC.explicit_bzero slice.to_unsafe, slice.bytesize
    raise RunTimeError.from_errno("explicit_bzero") if r != 0
  end
end

# Interface to hold sensitive information (often cryptographic keys)
#
# **Only for direct use by cryptographic library authors**
#
# For all other applications use a preexisting class that includes `Crypto::Secret`
@[Experimental]
module Crypto::Secret
  class Error < Exception
    class KeyWiped < Error
    end
  end

  def readwrite
  end

  # Yields a Slice that is readable and writable
  #
  # `slice` is only available within the block
  #
  # Not thread safe
  def readwrite
    to_slice do |slice|
      yield slice
    end
  end

  def readonly
  end

  # Yields a Slice that is readable possibly writable depending on the prior protection level and underlying implementation
  # Don't write to it
  #
  # Not thread safe
  def readonly
    to_slice do |slice|
      yield slice
    end
  end

  def noaccess
  end

  # Not thread safe
  def noaccess
    yield
  end

  # For debugging.
  # Returned String **not** tracked or wiped
  def hexstring : String
    readonly &.hexstring
  end

  def wipe
    readwrite do |slice|
      slice.wipe
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

  abstract def to_slice(& : Bytes -> Nil)
  abstract def bytesize : Int32

  macro delegate_to_slice(to object)
    def to_slice(& : Bytes -> Nil)
      yield {{object.id}}.to_slice
    end
  end

  macro delegate_to_bytesize(to object)
    def bytesize : Int32
      {{object.id}}.bytesize
    end
  end
end
