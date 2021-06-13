require "./spec_helper"
require "../src/crypto-secret/not"

describe Crypto::Secret::Not do
  it "works" do
    ksize = 32
    key = Bytes.new ksize
    key[1] = 1_u8

    secret1 = Crypto::Secret::Not.new key.dup
    secret1.to_slice.should eq key

    secret2 = Crypto::Secret::Not.new key.dup

    (secret1 == secret2).should be_true
    (secret1 == secret2.to_slice).should be_true
  end
end
