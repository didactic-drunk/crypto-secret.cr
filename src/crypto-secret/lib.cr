module Crypto
end

require "crypto/subtle"

lib LibC
  fun explicit_bzero(Void*, LibC::SizeT) : Void
end

struct Slice(T)
  def wipe
    LibC.explicit_bzero to_unsafe, bytesize
  end
end
