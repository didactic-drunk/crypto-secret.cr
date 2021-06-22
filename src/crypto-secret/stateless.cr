require "./secret"

# Provides a 0 overhead implementation of [#readwrite, #readonly, #noaccess, #reset] with no protection
#
# Data is still erased when out of scope
module Crypto::Secret::Stateless
  include Crypto::Secret

  macro included
    extend ClassMethods
  end

  # Not thread safe
  def readwrite : self
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
  def readonly : self
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
  def noaccess : self
    self
  end

  # Not thread safe
  def noaccess(& : Bytes -> U) forall U
    yield
  end

  # Not thread safe
  def reset
  end

  def finalize
    wipe
  end
end
