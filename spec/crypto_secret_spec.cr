require "./spec_helper"
require "../src/crypto-secret/test"
require "../src/crypto-secret"

test_secret_class Crypto::Secret::Not
test_secret_class Crypto::Secret::Bidet
test_secret_class Crypto::Secret::Guarded

describe Crypto::Secret do
  it ".for" do
    [:kgk, :secret_key, :public_key, :data, :not].each do |sym|
      secret = Crypto::Secret.for 2, sym
      secret.bytesize.should eq 2
    end
  end

  it ".for fallback" do
    secret = Crypto::Secret.for 2, :a, :b, :not
    secret.bytesize.should eq 2
  end

  it ".for missing" do
    expect_raises(KeyError) do
      Crypto::Secret.for 2, :a
    end
  end

  it ".random" do
    secret = Crypto::Secret.random 2, :a, :b, :not
    secret.bytesize.should eq 2
  end
end
