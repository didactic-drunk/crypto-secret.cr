module Crypto::Secret::ClassMethods
  # Copies `data` to the new Secret and **erases data**
  # Returns a **readonly** Secret
  def move_from(data : Bytes)
    copy_from data
  ensure
    data.wipe
  end

  # Copies `data` to the new Secret
  # Returns a **readonly** Secret
  def copy_from(data : Bytes)
    new(data.bytesize).tap do |obj|
      obj.readwrite do |slice|
        data.copy_to slice
      end
    end
  end

  # Returns a **readonly** random Secret
  def random(size)
    buf = new(size)
    buf.readwrite do |slice|
      Random::Secure.random_bytes slice
    end
    buf.readonly
  end
end
