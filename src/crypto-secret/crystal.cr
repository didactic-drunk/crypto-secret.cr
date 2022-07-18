abstract class Digest
  def update(data : Crypto::Secret)
    data.readonly do |slice|
      update slice
    end
  end

  def final(data : Crypto::Secret)
    data.readwrite do |slice|
      final slice
    end
  end
end
