require "./spec_helper"
require "../src/crypto-secret/not"

describe Crypto::Secret::Not do
  it "works" do
    ksize = 32
    key = Bytes.new ksize
    key[1] = 1_u8

    secret1 = Crypto::Secret::Not.new key.dup
    secret1.to_slice { |s| s.should eq key }

    secret2 = Crypto::Secret::Not.new key.dup

    (secret1 == secret2).should be_true
    secret1.to_slice do |s1|
      secret2.to_slice do |s2|
        (s1 == s2).should be_true
      end
    end
  end

  it "doesn't leak key material" do
    secret = Crypto::Secret::Not.new 5
    secret.to_s.should match /\(\*\*\*SECRET\*\*\*\)$/
    secret.inspect.should match /\(\*\*\*SECRET\*\*\*\)$/
    secret.to_s.should_not match /Bytes|Slice/
    secret.inspect.should_not match /Bytes|Slice/
  end

  it "returns a random secret" do
    secret1 = Crypto::Secret::Not.new 8
    secret2 = Crypto::Secret::Not.random 8
    secret1.should_not eq secret2
  end
end
