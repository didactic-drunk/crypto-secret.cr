module Crypto
  abstract class Secret
    module Stateless
    end

    module Stateful
    end
  end
end

require "crypto/subtle"

lib LibC
  fun explicit_bzero(Void*, LibC::SizeT) : Void
end

struct Slice(T)
  def wipe : Nil
    LibC.explicit_bzero to_unsafe, bytesize
  end
end
