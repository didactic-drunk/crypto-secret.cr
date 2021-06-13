require "./spec_helper"
require "../src/crypto-secret/not"

describe Crypto::Secret::Not do
  it "works" do
    ksize = 32
    secret = Crypto::Secret::Not.new ksize
    secret.to_slice.should eq Bytes.new ksize
  end
end
