# crypto-secret.cr
[![Crystal CI](https://github.com/didactic-drunk/crypto-secret.cr/actions/workflows/crystal.yml/badge.svg)](https://github.com/didactic-drunk/crypto-secret.cr/actions/workflows/crystal.yml)
[![GitHub release](https://img.shields.io/github/release/didactic-drunk/crypto-secret.cr.svg)](https://github.com/didactic-drunk/crypto-secret.cr/releases)
![GitHub commits since latest release (by date) for a branch](https://img.shields.io/github/commits-since/didactic-drunk/crypto-secret.cr/latest)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://didactic-drunk.github.io/crypto-secret.cr/main)

Secrets hold sensitive information

The Secret interface manages limited time access to a secret and securely erases the secret when no longer needed.

Multiple `Secret` classes exist.  Most of the time you shouldn't need to change the `Secret` type - the cryptographic library should have sane defaults.
If you have a high security or high performance application see [which secret type should I choose?]()

Secret providers may implement additional protections via:
* `#noaccess`, `#readonly` or `#readwrite`
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

#### Rules:
1. Secrets should be erased (wiped) ASAP
2. Secrets are only available within a `readonly` or `readwrite` block
3. Secrets are not thread safe except for the provided `Slice` (only when reading) within a single `readonly` or `readwrite` block 


```crystal
require "crypto-secret/bidet"

# Bidet is a minimal but fast secret implementation
secret = Crypto::Secret::Bidet.new 32
# Don't forget to wipe!
secret.wipe do
  secret.readonly do |slice|
    # May only read slice
  end
  secret.readwrite do |slice|
    # May read or write to slice
  end
end # secret is erased
```

#### Breaking the rules:

If you need thread safety :
1. Switch to a Stateless Secret
2. Or switch the Secret's state to readonly or readwrite after construction and never switch it again.  [sodium.cr]() makes use of this technique to provide thread safe encryption/decryption
3. Or wrap all access in a Mutex (compatible with all Secret classes)

If you need more better performance:
* Consider 1. or 2.

If you need compatibility with any `Secret`:
* Always use a `Mutex`
* Never rely on 1. or 2.

#### Converting `Bytes` to a `Secret`
```crystal
slice = method_that_return_bytes()
secret = Crypto::Secret::Bidet.move_from slice # erases slice
# or
secret = Crypto::Secret::Bidet.copy_from slice
```

## What is a Secret?

<strike>Secrets are Keys</strike>
That's complicated and specific to the application.  Some examples:

* Passwords
* A crypto key is always a Secret.  Except when used for verification (sometimes)
* A decrypted password vault (but it's not a Key)

Not secrets:

* Digest output.  Except when used for key derivation, then it's a Secret, including the Digest state
* IO::Memory or writing a file.  Except when the file is a password vault, cryptocurrency wallet, encrypted mail/messages, goat porn, maybe "normal" porn, sometimes scat porn, occassionally furry, not people porn

## Why?

The Secret interface is designed to handle varied levels of confidentiality with a unified API for cryptography libraries.

There is no one size fits all solution.  Different applications have different security requirements.  Sometimes for the same algorithm.

A master key (kgk) may reside on a HSM and generate subkeys on demand.
Or for most applications the master key may use a best effort approach using a combination of [guard pages, mlock, mprotect].
Other keys in the same application may handle a high volume of messages where [guard pages, mlock, mprotect] overhead is too high.
A key verifying a public key signature may not be Secret (but is a Secret::Not).

## How do I use a Secret returned by a shard?

That depends on what you use it for.

#### Using a Secret key

TODO

#### Using a Secret to hold decrypted file contents:
```
key = ...another Secret...
encrypted_str = File.read("filename")
decrypted_size = encrypted_str.bytesize - mac_size
file_secret = Crypto::Secret::Default.new decrypted_size
file_secret.wipe do
  file_secrets.readwrite do |slice|
    decrypt(key: key, src: encrypted_str, dst: slice)

    # Do something with file contents in slice
  end
end # Decrypted data is erased
```

## When should I use a Secret?

When implementing an encryption class return `Secret` keys with a sane default implementation that suits the average use for your class.  Several default implementations will be provided.
Allow overriding the default returned key and/or allow users of your class to provide their own `Secret` for cases where they need more or less protection.

Example:

```
class SimplifiedEncryption
  # Allow users of your library to provide their own Secret key.  Also provide a sane default.
  def encrypt(data : Bytes | String, key : Secret? = nil) : {Secret, Bytes}
    key ||= Crypto::Secret::Default.random
    ...
    {key, encrypted_slice}
  end
end
```

## What attacks does a Secret protect against?

* Timing attacks when comparing secrets by overriding `==`
* Leaking data in to logs by overriding `inspect`
* Wiping memory when the secret is no longer in use

TODO: describe implementations


## Other languages/libraries

* rust: [secrets](https://github.com/stouset/secrets/)
* c: [libsodium](https://github.com/jedisct1/libsodium-doc/blob/master/helpers/memory_management.md#guarded_heap_allocations)
* go: [memguard](https://github.com/awnumar/memguard)
* haskell: [securemem](https://hackage.haskell.org/package/securemem)
* c#: [SecureString](https://docs.microsoft.com/en-us/dotnet/api/system.security.securestring)

## Implementing a new Secret holding class

**Only intended for use by crypto library authors**

```
class MySecret
  # Choose one
  include Crypto::Secret::Stateless
  include Crypto::Secret::Stateful

  def initialize(size)
    # allocate or reference storage
    # optionally mlock
  end

  protected def to_slice(& : Bytes -> Nil)
    # The yielded Slice only needs to be valid within the block
    # yield Slice.new(pointer, size)
  ensure
    # optionally reencrypt or signal HSM
  end

  def bytesize : Int32
    # return the size
  end

  # optionally override [noaccess, readonly, readwrite]
  # optionally override (almost) any other method with an implementation specific version
end

```

## Contributing

**Open a discussion or issue before creating PR's**

1. Fork it (<https://github.com/your-github-user/crypto-secret/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [didactic-drunk](https://github.com/didactic-drunk) - current maintainer
