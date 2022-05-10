require "./stateless"

module Crypto::Secret
  # Leaves less sh** around if you forget to wipe.  A safer default for large secrets that may stress mlock limits or low confidentiality secrets.
  #
  # * Not locked in memory
  # * Not access protected
  # * No guard pages
  # * Hours of fun
  class Bidet < Base
    include Stateless

    def self.new(size : Int32)
      new references: Bytes.new(size)
    end

    def initialize(*, references : Bytes)
      @bytes = references
    end

    delegate_to_slice @bytes
    delegate_to_bytesize @bytes.bytesize
  end
end
