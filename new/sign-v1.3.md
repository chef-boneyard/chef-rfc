---
RFC: unassigned
Author: Jay Mundrawala <jdm@chef.io>
Status: Draft
Type: Standards Track
---

# Chef Authentication Signing Protocol v1.3

The current Chef signing protocols force users to use SHA1 based algorithms. This RFC proposes a new signing protocol which uses methods approved in [NIST.SP.800](http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-131Ar1.pdf) for digital signatures.

## Background

The Chef Server currently supports 3 different signing protocols: v1.0, v1.1,and v1.2. All of these protocols use a RSA private key to sign a message, which is verified by the server using the public key. Once a signature is created and Base64 encoded, it is broken up into lines of no more than 60 characters and placed into the `X-Ops-Authorization-1`, `X-Ops-Authorization-2`, ..., `X-Ops-Authorization-N` headers.

### Signing Protocol v1.0
Signing protocol v1.0 signs the following message:

```
Method:HTTP_METHOD
Hashed Path:HASHED_PATH
X-Ops-Content-Hash:HASHED_BODY
X-Ops-Timestamp:TIME
X-Ops-UserId:USERID
```

where:
  - `HTTP_METHOD` is the method used in the API request
  - `HASHED_PATH` is the path of the request: `/organizations/NAME/name_of_endpoint`. The `HASHED_PATH` must be hashed using SHA1 and encoded using Base64, must not have repeated forward slashes (`/`), must not end in a forward slash (unless the path is `/`), and must not include a query string.
  - `HASHED_BODY` is the Base64 encoded value of the SHA1 hash of the request body
  - `TIME` is the timestamp in ISO-8601 format and with UTC indicated by a trailing `Z` and separated by the character `T`. For example: `2013-03-10T14:14:44Z`.
  - `USERID` is the user id, for example the client name

This message is encrypted with the users(or nodes) RSA private key. The server verifies the message by recreating the message using the provided headers and decrypting it using the users public key.

v1.0 is the default version used by Chef Client as of version 12.5.1. However, v1.0 fails when the client name is longer that ~90 characters, so chef client will switch to the v1.1 protocol.

### Signing Protocol v1.1
Signing protocol v1.1 was introduced to support longer client names. It is almost identical to v1.0, except `USERID` is now a SHA1 hash of the user id.

### Signing Protocol v1.2
Signing protocol v1.2 signs the same message as v1.1. The signing, however, is slightly different. The motivation behind v1.2 was to use a standardized signing scheme. v1.2 uses the `RSASSA-PKCS1-v1_5` signature scheme to sign the message. The hashing algorithm used by the scheme is SHA1. More information about the `RSASSA-PKCS1-v1_5` can be found in the [PKCS#1 v2.2 RSA Cryptography Standard](https://www.emc.com/collateral/white-papers/h11300-pkcs-1v2-2-rsa-cryptography-standard-wp.pdf) document.

## Motivation

The current signing algorithms used for authentication with the Chef Server are not covered under those which are approved by the NIST.SP.800 guidelines. Chef users working with the U.S. government are often required to ensure their infrastructure meets certain security requirements, including those for cryptographic algorithms as specified in [FIPS 140-2](http://csrc.nist.gov/publications/fips/fips140-2/fips1402.pdf). The SHA-1 algorithm currently used for authentication with the Chef Server is not approved for use in digital signature generation per [NIST SP 800-131A](http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-131Ar1.pdf), thus preventing those users from using Chef in their environments.

The current signing algorithms are also vulnerable to replay attacks by changing the `X-Ops-Server-API-Version`. Since this header is not covered under the authenticated message, the request could be replayed with a different version, changing the effect the request has.

## Specification

### v1.3 Message Format
Following is the message to be signed by the v1.3 protocol.

```
Method:HTTP_METHOD
Hashed Path:HASHED_PATH
X-Ops-Content-Hash:HASHED_BODY
X-Ops-Sign:algorithm=HASH_ALGORITHM;version=PROTOCOL_VERSION
X-Ops-Timestamp:TIME
X-Ops-UserId:HASHED_USERID
X-Ops-Server-API-Version:HEADER_X_OPS_SERVER_API_VERSION
```

where:
  - `HASH_ALGORITHM` is one of the supported hashing algorithms for signing protocols supporting the v1.3 message format
  - `PROTOCOL_VERSION` is the signing protocol that will be used.
  - `HTTP_METHOD` is the method used in the HTTP request
  - `HASHED_PATH` is the Base64 encoded value of `Hash(HASH_ALGORITHM, CanonicalPath)`. A `CanonicalPath` must not have repeated forward slashes (`/`), must not end in a forward slash (unless the path is `/`), and must not include a query string.
  - `HASHED_BODY` is the Base64 encoded value of `Hash(HASH_ALGORITHM, Body)`
  - `TIME` is the timestamp in ISO-8601 format and with UTC indicated by a trailing `Z` and separated by the character `T`. For example: `2013-03-10T14:14:44Z`.
  - `HASHED_USERID` is the Base64 encoded value of `Hash(HASH_ALGORITHM, UserId)`
  - `HEADER_X_OPS_SERVER_API_VERSION` is the value of `X-Ops-Server-API-Version` passed to the Chef server.

### v1.3 Signing Protocol
Signing protocol v1.3 signs message format v1.3 messages using the `RSASSA-PKCS1-v1_5` signature scheme as described in [PKCS#1 v2.2 RSA Cryptography Standard](https://www.emc.com/collateral/white-papers/h11300-pkcs-1v2-2-rsa-cryptography-standard-wp.pdf). The following hashing algorithms will be supported:
  - sha1
  - sha256

This protocol is very similar to v1.2. The signing scheme is the same (RSASSA-PKCS1-v1_5). The message format signs a few additional pieces of information: The signing protocol version, the hashing algorithm to be used, and the `X-Ops-Server-API-Version` header.

### Example
The following is an example of how to go from the information required to make a signature to the actual signature. First, an RSA key (private_key.pem):

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA0ueqo76MXuP6XqZBILFziH/9AI7C6PaN5W0dSvkr9yInyGHS
z/IR1+4tqvP2qlfKVKI4CP6BFH251Ft9qMUBuAsnlAVQ1z0exDtIFFOyQCdR7iXm
jBIWMSS4buBwRQXwDK7id1OxtU23qVJv+xwEV0IzaaSJmaGLIbvRBD+qatfUuQJB
MU/04DdJIwvLtZBYdC2219m5dUBQaa4bimL+YN9EcsDzD9h9UxQo5ReK7b3cNMzJ
BKJWLzFBcJuePMzAnLFktr/RufX4wpXe6XJxoVPaHo72GorLkwnQ0HYMTY8rehT4
mDi1FI969LHCFFaFHSAaRnwdXaQkJmSfcxzCYQIDAQABAoIBAQCW3I4sKN5B9jOe
xq/pkeWBq4OvhW8Ys1yW0zFT8t6nHbB1XrwscQygd8gE9BPqj3e0iIEqtdphbPmj
VHqTYbC0FI6QDClifV7noTwTBjeIOlgZ0NSUN0/WgVzIOxUz2mZ2vBZUovKILPqG
TOi7J7RXMoySMdcXpP1f+PgvYNcnKsT72UcWaSXEV8/zo+Zm/qdGPVWwJonri5Mp
DVm5EQSENBiRyt028rU6ElXORNmoQpVjDVqZ1gipzXkifdjGyENw2rt4V/iKYD7V
5iqXOsvP6Cemf4gbrjunAgDG08S00kiUgvVWcdXW+dlsR2nCvH4DOEe3AYYh/aH8
DxEE7FbtAoGBAPcNO8fJ56mNw0ow4Qg38C+Zss/afhBOCfX4O/SZKv/roRn5+gRM
KRJYSVXNnsjPI1plzqR4OCyOrjAhtuvL4a0DinDzf1+fiztyNohwYsW1vYmqn3ti
EN0GhSgE7ppZjqvLQ3f3LUTxynhA0U+k9wflb4irIlViTUlCsOPkrNJDAoGBANqL
Q+vvuGSsmRLU/Cenjy+Mjj6+QENg51dz34o8JKuVKIPKU8pNnyeLa5fat0qD2MHm
OB9opeQOcw0dStodxr6DB3wi83bpjeU6BWUGITNiWEaZEBrQ0aiqNJJKrrHm8fAZ
9o4l4oHc4hI0kYVYYDuxtKuVJrzZiEapTwoOcYiLAoGBAI/EWbeIHZIj9zOjgjEA
LHvm25HtulLOtyk2jd1njQhlHNk7CW2azIPqcLLH99EwCYi/miNH+pijZ2aHGCXb
/bZrSxM0ADmrZKDxdB6uGCyp+GS2sBxjEyEsfCyvwhJ8b3Q100tqwiNO+d5FCglp
HICx2dgUjuRVUliBwOK93nx1AoGAUI8RhIEjOYkeDAESyhNMBr0LGjnLOosX+/as
qiotYkpjWuFULbibOFp+WMW41vDvD9qrSXir3fstkeIAW5KqVkO6mJnRoT3Knnra
zjiKOITCAZQeiaP8BO5o3pxE9TMqb9VCO3ffnPstIoTaN4syPg7tiGo8k1SklVeH
2S8lzq0CgYAKG2fljIYWQvGH628rp4ZcXS4hWmYohOxsnl1YrszbJ+hzR+IQOhGl
YlkUQYXhy9JixmUUKtH+NXkKX7Lyc8XYw5ETr7JBT3ifs+G7HruDjVG78EJVojbd
8uLA+DdQm5mg4vd1GTiSK65q/3EeoBlUaVor3HhLFki+i9qpT8CBsg==
-----END RSA PRIVATE KEY-----
```

For this example, assume that the following intent:

|key                 |value                   |
|--------------------|------------------------|
| Http Method        | POST                   |
| Path               | /organizations/clownco |
| Body               | Spec Body              |
| Timestamp          | 2009-01-01T12:00:00Z   |
| User               | spec-user              |
| Server Api Version | 1                      |
| Sign Protocol      | v1.3 SHA256            |

Using this information, we can generate the following message:

```
Method:POST
Hashed Path:Z3EsTMw/UBNY9n+q+WBWTJmeVg8hQFbdFzVWRxW4dOA=
X-Ops-Content-Hash:hDlKNZhIhgso3Fs0S0pZwJ0xyBWtR1RBaeHs1DrzOho=
X-Ops-Sign:algorithm=sha256;version=1.3
X-Ops-Timestamp:2009-01-01T12:00:00Z
X-Ops-UserId:/pNOhczwdkQGXD4YAOBVm38wgq2WI7vKRk9d8WBhyKA=
X-Ops-Server-API-Version:1
```

Note the line endings are `\n`, and there is no newline after `X-Ops-Server-API-Version:1`.

This message can now be signed, with the expected Base64 representation being:

```
BjR+iTK2eOgwmT2yGqLvE7Fp+VlpRGyL1dVoF2DmhUPO7EVsnxx2s32AmlOw
EpaACpav8SoB7K4rpOo3gfBm0XAYLnLLWzcec2OQG2O0wxxHiKVn4qWEe7Cs
RZ903DGM54t4uK75vx6wwoEdZqZe21npsLK+F3oAqnkgp+YXmlYv9Se5tFKB
0GWM1ibGJMjUIFAm7vxzjcuEvkkKN49MnXeMAAykfymcs74RU6xEKYzzSAyC
ygkV6xQSapDMp/aY29cVA/1FgZeVMhnFSTjtqBehchZYwXswr0A72A86gID9
h2QsUpmQJwbOK3bb1GptAnd5IiLzIxtu+vFeY6h4eA==
```

The Chef server should expect the following headers to be passed along:

| name                  | value                                                        |
|-----------------------|--------------------------------------------------------------|
| X-Ops-Authorization-1 | BjR+iTK2eOgwmT2yGqLvE7Fp+VlpRGyL1dVoF2DmhUPO7EVsnxx2s32AmlOw |
| X-Ops-Authorization-2 | EpaACpav8SoB7K4rpOo3gfBm0XAYLnLLWzcec2OQG2O0wxxHiKVn4qWEe7Cs |
| X-Ops-Authorization-3 | RZ903DGM54t4uK75vx6wwoEdZqZe21npsLK+F3oAqnkgp+YXmlYv9Se5tFKB |
| X-Ops-Authorization-4 | 0GWM1ibGJMjUIFAm7vxzjcuEvkkKN49MnXeMAAykfymcs74RU6xEKYzzSAyC |
| X-Ops-Authorization-5 | ygkV6xQSapDMp/aY29cVA/1FgZeVMhnFSTjtqBehchZYwXswr0A72A86gID9 |
| X-Ops-Authorization-6 | h2QsUpmQJwbOK3bb1GptAnd5IiLzIxtu+vFeY6h4eA==                 |

## Compatibility
The Chef server currently returns the supported protocol versions when failing to authenticate. This information is returned in the `WWW-Authenticate` header of the response along with a response code of `401`. An example of a value that is returned that header is `X-Ops-Sign version="1.0" version="1.1"`, with a  response body of `{"error":["Invalid signature for user or client 'foo'"]}`. The response provides no information as to why the authentication failed.

With servers supporting signing protocol v1.3, `WWW-Authenticate` can signal which hashing algorithms are supported for the 1.3 signing protocol. For example, a server supporting v1.3 could respond with `X-Ops-Sign version="1.0" version="1.1" version="1.3:sha1" version="1.3:sha256"`. This could be the basis of a negotiation protocol that determines which signing algorithm to use. Until such time, Chef client will continue to default to `v1.0`, and using `v1.3` will require setting `:authenticate_protocol_version` in the Chef client configuration to `"1.3"`.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
