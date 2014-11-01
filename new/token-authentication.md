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

The actual authentication method allows passing an authentication token as a
GET variable or HTTP header:

```
GET /path?token=<token> HTTP/1.1
Host: chef.example.com
```

```
POST /path HTTP/1.1
Host: chef.example.com
X-Chef-Token: <token>
```

In either case, this is equivalent to key-based authentication from the client
or user associated with the token.

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

{"token": "<token>"}
```

This new token is associated with the client or user that issued the request to
create it.

A new token can also be generated for a user from their username and password.
This API will be limited to the webui key as it is now. This will allow a web
interface to entirely avoid using the impersonation key behavior as it does now.

```
POST /authenticate_user HTTP/1.1
Host: chef.example.com
X-Ops-...: ...

{"username": "<username>", "password": "<password>"}
```

```
HTTP/1.1 200 OK

{"token": "<token>", "linked": "<username>"}
```

There is no support for making a token for a different client.

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

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
