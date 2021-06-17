require "./stateless"

module Crypto::Secret
  # A not very secret `Secret`, but fast
  #
  # Suitable uses:
  # * Holding decrypted data that is NOT secret
  # * Verification keys that are public (use with care)
  #
  # * 0 overhead
  # * Not locked in memory
  # * Not access protected
  # * No guard pages
  # * No wiping
  struct Not
    include Stateless

    def self.new(size : Int32)
      bytes = Bytes.new size
      new(references: bytes)
    end

    def initialize(*, references : Bytes)
      @bytes = references
    end

    delegate_to_slice @bytes
    delegate_to_bytesize @bytes.bytesize

    def wipe
    end
  end
end
