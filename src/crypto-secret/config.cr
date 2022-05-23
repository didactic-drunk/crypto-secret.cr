require "./not"
require "./bidet"
require "./guarded"

{% if @type.has_constant?("Sodium") %}
  CRYPTO_SECRET_KEY_CLASS = Sodium::SecureBuffer
{% else %}
  CRYPTO_SECRET_KEY_CLASS = Crypto::Secret::Guarded
{% end %}

module Crypto::Secret::Config
  # :nodoc:
  USES = Hash(Symbol, Secret.class).new

  enum SecurityLevel
    # mlocks everything (including data)
    Paranoid
    # wipes everything
    Strong
    # balance between performance and wiping
    Default
    # performance
    Lax
    #    None
  end

  def self.setup(level : SecurityLevel = :default) : Nil
    register_use Not, :not, :public_key

    case level
    in SecurityLevel::Paranoid
      register_use Bidet, :not
      register_use Guarded, :public_key
      register_use CRYPTO_SECRET_KEY_CLASS, :kgk, :secret_key, :data
    in SecurityLevel::Strong
      register_use Bidet, :not, :public_key
      register_use Crypto::Secret::Guarded, :data
      register_use CRYPTO_SECRET_KEY_CLASS, :kgk, :secret_key
    in SecurityLevel::Default
      register_use Crypto::Secret::Bidet, :data
      register_use CRYPTO_SECRET_KEY_CLASS, :kgk, :secret_key
    in SecurityLevel::Lax
      register_use Bidet, :kgk, :secret_key, :data
    end
  end

  setup # Safe defaults

  def self.register_use(klass, *uses) : Nil
    uses.each do |use|
      USES[use] = klass
    end
  end
end
