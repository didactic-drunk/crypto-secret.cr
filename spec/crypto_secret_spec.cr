require "./spec_helper"
require "../src/crypto-secret/test"
require "../src/crypto-secret/not"
require "../src/crypto-secret/bidet"

test_secret_class Crypto::Secret::Not
test_secret_class Crypto::Secret::Bidet
