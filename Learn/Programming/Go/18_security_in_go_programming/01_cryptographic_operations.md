## Cryptographic Operations


Go's `crypto` package provides extensive cryptographic functionality with implementations that follow established security standards.

**Hash Functions** Go supports multiple hash algorithms including SHA-256, SHA-512, and Blake2b. The `crypto/sha256` package provides secure hashing:

```go
import (
    "crypto/sha256"
    "fmt"
)

func hashData(data []byte) []byte {
    hash := sha256.Sum256(data)
    return hash[:]
}
```

**Symmetric Encryption** AES encryption is available through `crypto/aes` and cipher modes through `crypto/cipher`:

```go
import (
    "crypto/aes"
    "crypto/cipher"
    "crypto/rand"
)

func encryptAES(key, plaintext []byte) ([]byte, error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return nil, err
    }
    
    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return nil, err
    }
    
    nonce := make([]byte, gcm.NonceSize())
    rand.Read(nonce)
    
    ciphertext := gcm.Seal(nonce, nonce, plaintext, nil)
    return ciphertext, nil
}
```

**Asymmetric Cryptography** RSA and ECDSA operations are supported through dedicated packages:

```go
import (
    "crypto/rsa"
    "crypto/rand"
    "crypto/x509"
)

func generateRSAKeyPair(bits int) (*rsa.PrivateKey, error) {
    privateKey, err := rsa.GenerateKey(rand.Reader, bits)
    return privateKey, err
}
```

**Digital Signatures** Go provides signature creation and verification capabilities:

```go
import (
    "crypto"
    "crypto/rsa"
    "crypto/sha256"
)

func signData(privateKey *rsa.PrivateKey, data []byte) ([]byte, error) {
    hashed := sha256.Sum256(data)
    signature, err := rsa.SignPKCS1v15(rand.Reader, privateKey, 
        crypto.SHA256, hashed[:])
    return signature, err
}
```

