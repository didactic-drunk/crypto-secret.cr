# crypto-secret.cr
[![Crystal CI](https://github.com/didactic-drunk/crypto-secret.cr/actions/workflows/crystal.yml/badge.svg)](https://github.com/didactic-drunk/crypto-secret.cr/actions/workflows/crystal.yml)
[![GitHub release](https://img.shields.io/github/release/didactic-drunk/crypto-secret.cr.svg)](https://github.com/didactic-drunk/crypto-secret.cr/releases)
![GitHub commits since latest release (by date) for a branch](https://img.shields.io/github/commits-since/didactic-drunk/crypto-secret.cr/latest)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://didactic-drunk.github.io/crypto-secret.cr/main)

Secrets hold sensitive information

The Secret interface manages limited time access to the secret and securely erasing the secret when no longer needed.

Secret providers may implement additional protections via:
* `#noaccess`, `#readonly` or `readwrite`.
* Using [mprotect]() to control access
* Encrypting the data when not in use
* Deriving keys on demand from a HSM
* Preventing the Secret from entering swap ([mlock]())
* Preventing the Secret from entering core dumps
* Other


## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crypto-secret:
       github: didactic-drunk/crypto-secret
   ```

2. Run `shards install`

## Usage

```crystal
require "crypto-secret/not"

not_secret = Crypto::Secret::Not.new 32
not_secret.wipe do
  not_secret.readonly do |slice|
    # May only read slice
  end
  not_secret.readwrite do |slice|
    # May read or write to slice
  end
end # Secret is erased
```

## What is a Secret?

<strike>Secrets are Keys</strike>
That's complicated and specific to the application.  Some examples:

* Passwords
* A crypto key is always a Secret.  Except when used for verification (sometimes)
* A decrypted password vault (but it's not a Key)

Not secrets:

* Digest output.  Except when used for key derivation, then it's a Secret, including the Digest state
* IO::Memory or writing a file.  Except when the file is a password vault, cryptocurrency wallet, encrypted mail/messages, goat porn, maybe normal porn, sometimes scat porn, occassionally furry, not vanilla porn

## Why?

The Secret interface is designed to handle varied levels of confidentiality with a unified API for cryptography libraries.

There is no one size fits all solution.  Different applications have different security requirements.  Sometimes for the same algorithm.

A master key (kgk) may reside on a HSM and generate subkeys on demand.
Or for most applications the master key may use best effort protection using a combination of [guard pages, mlock, mprotect].
Other keys in the same application may handle a high volume of messages where [guard pages, mlock, mprotect] overhead is too high.
A key verifying a public key signature may not be Secret.


## Implementing a new Secret holding class

**Only intended for use by crypto library authors**

```
class MySecret
  include Crypto::Secret

  def initialize(size)
    # allocate storage
    # optionally mlock
  end

  def to_slice(& : Bytes -> Nil)
    # yield Slice.new(pointer, size)
  ensure
    # optionally reencrypt or signal HSM
  end

  def bytesize : Int32
    # return the size
  end

  # optionally override [noaccess, readonly, readwrite]
  # optionally override (almost) any other method with implementation specific version
end

```

## Contributing

**Open a discussion before creating PR's**

1. Fork it (<https://github.com/your-github-user/crypto-secret/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [didactic-drunk](https://github.com/didactic-drunk) - current maintainer
