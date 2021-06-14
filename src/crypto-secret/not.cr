require "./stateless"

# A not very secret secret
#
# Not locked in memory
# Not access protected
# No guard pages
# Doesn't wipe
module Crypto::Secret
  struct Not
    include Stateless

    def self.new(size)
      new Bytes.new(size)
    end

    def initialize(@bytes : Bytes)
    end

    delegate_to_slice @bytes
    delegate_to_bytesize @bytes.bytesize

    def wipe
    end
  end
end
