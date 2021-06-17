require "./spec_helper"
require "../src/crypto-secret/test"
require "../src/crypto-secret/not"
require "../src/crypto-secret/large"
require "../src/crypto-secret/key"

test_secret_class Crypto::Secret::Not
test_secret_class Crypto::Secret::Bidet
test_secret_class Crypto::Secret::Large
test_secret_class Crypto::Secret::Key
