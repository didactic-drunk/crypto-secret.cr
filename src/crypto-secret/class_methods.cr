module Crypto::Secret::ClassMethods
  # Returns a **readonly** random Secret
  def random(size)
    buf = new(size)
    buf.readwrite do |slice|
      Random::Secure.random_bytes slice
    end
    buf.readonly
  end
end
