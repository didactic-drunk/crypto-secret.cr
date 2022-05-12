require "./secret"

# Provides a 0 overhead implementation of [#readwrite, #readonly, #noaccess, #reset] with no protection
#
# Data is erased when (except for `Crypto::Secret::Not`):
# * #wipe(&block) goes out of scope
# * manual #wipe
# * finalized
module Crypto::Secret::Stateless
  # Not thread safe
  def readwrite : Secret
    self
  end

  # Yields a Slice that is readable and writable
  #
  # `slice` is only available within the block
  #
  # Not thread safe
  def readwrite(& : Bytes -> U) forall U
    to_slice do |slice|
      yield slice
    end
  end

  # Not thread safe
  def readonly : Secret
    self
  end

  # Yields a Slice that is readable possibly writable depending on the prior protection level and underlying implementation
  # Don't write to it
  #
  # Not thread safe
  def readonly(& : Bytes -> U) forall U
    to_slice do |slice|
      yield slice
    end
  end

  # Not thread safe
  def noaccess : Secret
    self
  end

  # Not thread safe
  def reset : Secret
    self
  end

  def finalize
    wipe
  end
end
