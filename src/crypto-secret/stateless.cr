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
  def readwrite
  end

  # Yields a Slice that is readable and writable
  #
  # `slice` is only available within the block
  #
  # Not thread safe
  def readwrite
    to_slice do |slice|
      yield slice
    end
  end

  # Not thread safe
  def readonly
  end

  # Yields a Slice that is readable possibly writable depending on the prior protection level and underlying implementation
  # Don't write to it
  #
  # Not thread safe
  def readonly
    to_slice do |slice|
      yield slice
    end
  end

  # Not thread safe
  def noaccess
  end

  # Not thread safe
  def noaccess
    yield
  end

  # Not thread safe
  def reset
  end

  def finalize
    wipe
  end
end
