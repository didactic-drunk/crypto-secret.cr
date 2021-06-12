# crypto_secret.cr
[![Crystal CI](https://github.com/didactic-drunk/crypto_secret.cr/actions/workflows/crystal.yml/badge.svg)](https://github.com/didactic-drunk/crypto_secret.cr/actions/workflows/crystal.yml)
[![GitHub release](https://img.shields.io/github/release/didactic-drunk/crypto_secret.cr.svg)](https://github.com/didactic-drunk/crypto_secret.cr/releases)
![GitHub commits since latest release (by date) for a branch](https://img.shields.io/github/commits-since/didactic-drunk/crypto_secret.cr/latest)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://didactic-drunk.github.io/crypto_secret.cr/master)

Interface intended to hold sensitive information.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crypto_secret:
       github: didactic-drunk/crypto_secret
   ```

2. Run `shards install`

## Usage

```crystal
require "crypto_secret/not"

not_secret = Crypto::Secret::Not.new 32
```

## Implementing a new Secret holding class

**Intended for use by crypto library authors**

```
class MySecret
  include Crypto::Secret

  def initialize(size)
    # allocate storage
    # optionally mlock
  end

  def to_slice : Bytes
    # Return a slice
    # Slice.new pointer, size
  end

  # optionally override [noaccess, readonly, readwrite]
end

```

## Contributing

1. Fork it (<https://github.com/your-github-user/crypto_secret/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [simple](https://github.com/your-github-user) - creator and maintainer
- [didactic-drunk](https://github.com/didactic-drunk) - current maintainer
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://didactic-drunk.github.io/sodium.cr/master)
# sodium.cr
