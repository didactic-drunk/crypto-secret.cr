# Interface to hold sensitive information (often cryptographic keys)
#
#
@[Experimental]
module Crypto::Secret
  abstract def to_slice : Bytes

  def readwrite
  end

  def readonly
  end

  def noaccess
  end

  def wipe
    # Todo: implement wiping
  end

  def wipe
    yield
  ensure
    wipe
  end

  def finalize
    wipe
  end
end
