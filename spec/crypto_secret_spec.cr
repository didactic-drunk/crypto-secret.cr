require "./spec_helper"
require "../src/crypto-secret/test"
require "../src/crypto-secret"
#require "../src/crypto-secret/not"
#require "../src/crypto-secret/bidet"

test_secret_class Crypto::Secret::Not
test_secret_class Crypto::Secret::Bidet

describe Crypto::Secret do
  it ".for" do
    [:kgk, :key, :data, :not].each do |sym|
      secret = Crypto::Secret.for sym, 2
      secret.bytesize.should eq 2
    end
  end
end
