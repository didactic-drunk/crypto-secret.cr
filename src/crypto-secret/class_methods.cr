module Crypto::Secret::ClassMethods
  # Copies `data` to the new Secret and **erases data**
  #
  # Returns a **readonly** Secret
  def move_from(data : Bytes)
    copy_from data
  ensure
    data.wipe
  end

  # Copies `data` to the new Secret
  #
  # Returns a **readonly** Secret
  def copy_from(data : Bytes)
    new(data.bytesize).tap do |obj|
      obj.copy_from data
    end
  end

  # Returns a **readonly** random Secret
  def random(size)
    buf = new(size)
    buf.random.readonly
  end
end
