require "./stateless"

# Leaves less sh** around if you forget to wipe.  A safer default for large secrets that may stress mlock limits or low confidentiality secrets.
#
# * Not locked in memory
# * Not access protected
# * No guard pages
module Crypto::Secret
  class Bidet
    include Stateless

    def self.new(size)
      new references: Bytes.new(size)
    end

    def initialize(*, references : Bytes)
      @bytes = references
    end

    delegate_to_slice @bytes
    delegate_to_bytesize @bytes.bytesize
  end
end
