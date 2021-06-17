require "./bidet"

module Crypto::Secret
  # Use this class for holding small amounts of sensitive data such as encryption keys
  #
  # Underlying implentation subject to change
  #
  # TODO: mlock
  # TODO: mprotect
  class Key < Bidet
  end
end
