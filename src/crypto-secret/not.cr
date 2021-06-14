# A not very secret secret
#
# Not locked in memory
# Not access protected
# No guard pages
struct Crypto::Secret::Not
  include Crypto::Secret

  def initialize(size)
    @bytes = Bytes.new size
  end

  def to_slice : Bytes
    @bytes
  end


  delegate_to_slice @bytes
  delegate_to_bytesize @bytes
end
