require "./bidet"

# Use this class for holding small amounts of sensitive data such as crypto keys
#
# Underlying implentation subject to change
#
# Uses `Sodium::SecureBuffer` If "sodium" is required before "crypto-secret"
{% if @type.has_constant?("Sodium") %}
  class Crypto::Secret::Key < ::Sodum::SecureBuffer
  end
{% else %}
  # TODO: mlock
  # TODO: mprotect
  class Crypto::Secret::Key < ::Crypto::Secret::Bidet
  end
{% end %}
