require "./stateless"

abstract class Crypto::Secret
  # Leaves less sh** around if you forget to wipe.  A safer default for large secrets that may stress mlock limits or low confidentiality secrets.
  #
  # * Wipes on finalize but should not be relied on
  # * Not locked in memory
  # * Not access protected
  # * No guard pages
  # * Hours of fun
  class Bidet < Secret
    include Stateless

    def self.new(size : Int32)
      new references: Bytes.new(size)
    end

    def initialize(*, references : Bytes)
      @bytes = references
    end

    delegate_to_slice @bytes
    delegate_buffer_bytesize_to @bytes.bytesize
  end
end
