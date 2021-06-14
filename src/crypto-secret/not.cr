require "./stateless"

# A not very secret secret
#
# Not locked in memory
# Not access protected
# No guard pages
struct Crypto::Secret::Not
  include Crypto::Secret::Stateless

  def self.new(size)
    new Bytes.new(size)
  end

  def initialize(@bytes : Bytes)
  end

  delegate_to_slice @bytes
  delegate_to_bytesize @bytes
end
