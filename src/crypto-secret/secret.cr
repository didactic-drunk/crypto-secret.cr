# Interface to hold sensitive information (often cryptographic keys)
#
# **Only for direct use by cryptographic library authors**
#
# For all other applications use a preexisting class that include `Crypto::Secret`
@[Experimental]
module Crypto::Secret
  abstract def to_slice : Bytes

  def readwrite
  end

  def readwrite
    yield
  end

  def readonly
  end

  def readonly
    yield
  end

  def noaccess
  end

  def noaccess
    yield
  end

  def wipe
    # Todo: implement wiping.  Needs crystal support
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
