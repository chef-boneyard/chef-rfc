---
RFC: 65
Title: Chef Authentication Signing Protocol v1.3
Author: Jay Mundrawala <jdm@chef.io>
Status: Final
Type: Standards Track
Tracking:
 - https://github.com/chef/chef_authn/pull/23
 - https://github.com/chef/mixlib-authentication/pull/10
---

# Chef Authentication Signing Protocol v1.3

The current Chef signing protocols force users to use SHA1 based algorithms. This RFC proposes a new signing protocol which uses methods approved in [NIST.SP.800](http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-131Ar1.pdf) for digital signatures.

## Background

The Chef Server currently supports 3 different signing protocols: v1.0, v1.1, and v1.2. All of these protocols use a RSA private key to sign a message, which is verified by the server using the public key. Once a signature is created and Base64 encoded, it is broken up into lines of no more than 60 characters and placed into the `X-Ops-Authorization-1`, `X-Ops-Authorization-2`, ..., `X-Ops-Authorization-N` headers.

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
Path:PATH
X-Ops-Content-Hash:HASHED_BODY
X-Ops-Sign:version=1.3
X-Ops-Timestamp:TIME
X-Ops-UserId:USERID
X-Ops-Server-API-Version:HEADER_X_OPS_SERVER_API_VERSION
```

where:
  - `PROTOCOL_VERSION` is the signing protocol that will be used.
  - `HTTP_METHOD` is the method used in the HTTP request. It should be all upper case (`POST`, `GET`, `PUT`, etc)
  - `PATH` us a canonicalized representation of the path. This path must not have repeated forward slashes (`/`), must not end in a forward slash (unless the path is `/`), and must not include a query string.
  - `HASHED_BODY` is the Base64 encoded value of `Hash(SHA256, Body)`
  - `TIME` is the timestamp in ISO-8601 format and with UTC indicated by a trailing `Z` and separated by the character `T`. For example: `2013-03-10T14:14:44Z`.
  - `USERID` is the user id, for example the client name
  - `HEADER_X_OPS_SERVER_API_VERSION` is the value of `X-Ops-Server-API-Version` passed to the Chef server.

There is a new line character(`\n`\) after each line in this message **except the last line**.

### v1.3 Signing Protocol
Signing protocol v1.3 signs message format v1.3 messages using the `RSASSA-PKCS1-v1_5` signature scheme as described in [PKCS#1 v2.2 RSA Cryptography Standard](https://www.emc.com/collateral/white-papers/h11300-pkcs-1v2-2-rsa-cryptography-standard-wp.pdf). v1.3 will use SHA256 as the hashing algorithm.

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

For this example, assume the following intent:

|key                 |value                   |
|--------------------|------------------------|
| Http Method        | POST                   |
| Path               | /organizations/clownco |
| Body               | Spec Body              |
| Timestamp          | 2009-01-01T12:00:00Z   |
| User               | spec-user              |
| Server Api Version | 1                      |
| Sign Protocol      | v1.3                   |

Using this information, we can generate the following message:

```
Method:POST
Path:/organizations/clownco
X-Ops-Content-Hash:hDlKNZhIhgso3Fs0S0pZwJ0xyBWtR1RBaeHs1DrzOho=
X-Ops-Sign:version=1.3
X-Ops-Timestamp:2009-01-01T12:00:00Z
X-Ops-UserId:spec-user
X-Ops-Server-API-Version:1
```

Note the line endings are `\n`, and there is no newline character after `X-Ops-Server-API-Version:1`.

This message can now be signed, with the expected Base64 representation being:

```
FZOmXAyOBAZQV/uw188iBljBJXOm+m8xQ/8KTGLkgGwZNcRFxk1m953XjE3W
VGy1dFT76KeaNWmPCNtDmprfH2na5UZFtfLIKrPv7xm80V+lzEzTd9WBwsfP
42dZ9N+V9I5SVfcL/lWrrlpdybfceJC5jOcP5tzfJXWUITwb6Z3Erg3DU3Uh
H9h9E0qWlYGqmiNCVrBnpe6Si1gU/Jl+rXlRSNbLJ4GlArAPuL976iTYJTzE
MmbLUIm3JRYi00Yb01IUCCKdI90vUq1HHNtlTEu93YZfQaJwRxXlGkCNwIJe
fy49QzaCIEu1XiOx5Jn+4GmkrZch/RrK9VzQWXgs+w==
```

The Chef server should expect the following headers to be passed along:

| name                  | value                                                        |
|-----------------------|--------------------------------------------------------------|
| X-Ops-Authorization-1 | FZOmXAyOBAZQV/uw188iBljBJXOm+m8xQ/8KTGLkgGwZNcRFxk1m953XjE3W |
| X-Ops-Authorization-2 | VGy1dFT76KeaNWmPCNtDmprfH2na5UZFtfLIKrPv7xm80V+lzEzTd9WBwsfP |
| X-Ops-Authorization-3 | 42dZ9N+V9I5SVfcL/lWrrlpdybfceJC5jOcP5tzfJXWUITwb6Z3Erg3DU3Uh |
| X-Ops-Authorization-4 | H9h9E0qWlYGqmiNCVrBnpe6Si1gU/Jl+rXlRSNbLJ4GlArAPuL976iTYJTzE |
| X-Ops-Authorization-5 | MmbLUIm3JRYi00Yb01IUCCKdI90vUq1HHNtlTEu93YZfQaJwRxXlGkCNwIJe |
| X-Ops-Authorization-6 | fy49QzaCIEu1XiOx5Jn+4GmkrZch/RrK9VzQWXgs+w==                 |

## Compatibility
The Chef server currently returns the supported protocol versions when failing to authenticate. This information is returned in the `WWW-Authenticate` header of the response along with a response code of `401`. An example of a value that is returned that header is `X-Ops-Sign version="1.0" version="1.1"`, with a  response body of `{"error":["Invalid signature for user or client 'foo'"]}`. The response provides no information as to why the authentication failed.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
