---
RFC: unassigned
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Standards Track
---

# Token Authentication for Chef Server

Currently the Chef Server currently only supports a single authentication method,
using RSA signatures and key pairs. This has worked well for chef-client and
knife, but it is less convenient for some other use cases. A token-based
authentication method would allow for some additional use cases. This would
work by passing an opaque token to the Server which is associated with an
existing user or client.

## Motivation

This proposal covers two, unrelated use cases.

    As a web interface developer,
    I want to have a simpler web application,
    so that maintenance is easier.

Adding a token authentication system will allow most of the requests to go
directly to the Chef Server (once CORS support is handled). This will
drastically reduce the number of API endpoints needed for the web UI, most of
which are currently just proxies for the relevant Chef Server functionality.

    As a security engineer,
    I want to accept secure identity assertions,
    so that I can implement object-capability systems.

Token authentication provides a simple way to prove your identity to an
external system. This is the basic building block of an object-capability
system.

## Specification

### Authenticating with a token

Token authentication allows passing an opaque string token as a header in
Chef Server API requests.

```
POST /path HTTP/1.1
Host: chef.example.com
Authorization: Bearer <token>
```

The token can also be passed as a query parameter, however this is discouraged
due to the risk of inadvertently logging or otherwise exposing the token. The
Chef Server itself will not log the token, but HTTP proxies could.

```
GET /path?access_token=<token> HTTP/1.1
Host: chef.example.com
```

In either case, this is equivalent to key-based authentication from the client
or user associated with the token. If the token is invalid or expired, the
server must respond HTTP 401.

The server must ensure tokens are checked using constant-time comparisons to
avoid timing attacks.

### Generating a token

A new token can generated using the token API:

```
POST /tokens HTTP/1.1
Host: chef.example.com
X-Ops-...: ...

{}
```

```
HTTP/1.1 200 OK

{"token": "<token>", "created_at": "1970-01-01T00:00:00Z"}
```

This new token is associated with the client or user that issued the request to
create it.

Tokens must be 16 characters from the set `abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`.

A new token can also be generated for a user from their username and password.
This API will be limited to the webui key as it is now. This will allow a web
interface to entirely avoid using the impersonation key behavior as it does now.

```
POST /authenticate_user HTTP/1.1
Host: chef.example.com
X-Ops-...: ...

{"username": "<username>", "password": "<password>", "token": true}
```

```
HTTP/1.1 200 OK

{"token": "<token>", "linked": "<username>"}
```

There is no support for making a token for a different client.

Tokens can optionally have a description attached to them:

```
POST /tokens HTTP/1.1
Host: chef.example.com
X-Ops-...: ...

{"description": "objcap"}
```

```
HTTP/1.1 200 OK

{"token": "<token>", "description": "objcap", "created_at": "1970-01-01T00:00:00Z"}
```


### Other token operations

Tokens support list, read, and delete operations. At this time, tokens are
immutable so no support for update operations is required. This may be revised
in the future.

#### List

```
GET /tokens HTTP/1.1
Host: chef.example.com
X-Ops-...: ...
```

```
HTTP/1.1 200 OK

{"<token>": "https://chef.example.com/tokens/<token>"}
```

This API must be restricted such that only tokens belonging to the current
user or client are visible. This does potentially present an escalation
vulnerability whereby one compromised token could steal other tokens for the
same user. This could be mitigated through per-token permissions detailed below.

#### Read

```
GET /tokens/<token> HTTP/1.1
Host: chef.example.com
X-Ops-...: ...
```

```
HTTP/1.1 200 OK

{"token": "<token>", "description": "objcap", "created_at": "1970-01-01T00:00:00Z"}
```

#### Delete

```
DELETE /tokens/<token> HTTP/1.1
Host: chef.example.com
X-Ops-...: ...
```

```
HTTP/1.1 200 OK
```

### Token expiration

A token can have an expiration timestamp after which is cannot be used. This is
set during token creation.

```
POST /tokens HTTP/1.1
Host: chef.example.com
X-Ops-...: ...

{"expires": "1970-01-01T00:00:00Z"}
```

```
HTTP/1.1 200 OK

{"token": "<token>", "expires": "1970-01-01T00:00:00Z"}
```

After a token's expiration is passed, using it will return an error message.

### Token permissions

In a future iteration, specific permissions could be attached to a token. This
would allow creating restricted tokens with a subset of the permissions of the
requesting user or client.

This would be especially useful in an objcap system, to create a token with only
"whoami" permission so it can be used for secure, remote identity assertions.

## Rationale

The token authentication scheme is designed to be overall compatible with
OAuth2 without requiring the Chef Server to implement an Oauth2-compatible
token request/creation API. This will allow the complex bits of Oauth to stay
in oc-id, while once a token is issued it can be used directly with the Chef
Server.

As token checking can happen at the same point in the request cycle as the
current key verification, the new authentication modes will be transparent to
the rest of the Chef Server code.

The simple CRD API matches the structure of most Chef Server operations. Adding
optional token creation to the `authenticate_user` endpoint allows services
like oc-id or Manage to avoid using the impersonation key behavior.

Care will have to be taken through all token-handling code to avoid timing
attacks on the token content. This includes token authentication, token reads,
and token deletes.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
