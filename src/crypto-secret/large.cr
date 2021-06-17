require "./bidet"

module Crypto::Secret
  # Use this class as a default when holding possibly large amounts of data that may stress mlock limits
  #
  # Suitable uses: holding decrypted data
  #
  # no mlock
  #
  # Implementation subject to change
  class Large < Bidet
  end
end
