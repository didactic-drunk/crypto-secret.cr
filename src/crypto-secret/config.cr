require "./not"
require "./bidet"

{% if @type.has_constant?("Sodium") %}
  CRYPTO_SECRET_KEY_CLASS = Sodium::SecureBuffer
{% else %}
  CRYPTO_SECRET_KEY_CLASS = Crypto::Secret::Bidet
{% end %}

module Crypto::Secret::Config
  # :nodoc:
  USES = Hash(Symbol, Secret.class).new

  enum SecurityLevel
    Paranoid
    Default
    Lax
    #    None
  end

  def self.setup(level : SecurityLevel = SecurityLevel::Default) : Nil
    register_use Not, :not

    case level
    in SecurityLevel::Paranoid
      register_use Bidet, :not
      register_use CRYPTO_SECRET_KEY_CLASS, :kgk, :key, :data
    in SecurityLevel::Default
      register_use Crypto::Secret::Bidet, :data
      register_use CRYPTO_SECRET_KEY_CLASS, :kgk, :key
    in SecurityLevel::Lax
      register_use Bidet, :kgk, :key, :data
      #      in SecurityLevel::None
      #        register_use Not, :kgk, :key, :data
    end
  end

  setup # Safe defaults

  def self.register_use(klass, *uses) : Nil
    uses.each do |use|
      USES[use] = klass
    end
  end
end
