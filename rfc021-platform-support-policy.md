---
RFC: 21
Author: Julian Dunn <jdunn@chef.io>
Status: Accepted
Type: Informational
---

# Chef Platform Policy

The purpose of this RFC is to clarify which platforms the chef community chooses to work on, and how those platforms are maintained.

This RFC does *not* address "What is the product lifecycle of Chef Software, Inc.'s software".

The [chef docs site](https://docs.chef.io/) has [details of the platforms Chef Software, Inc validates for release](https://docs.chef.io/platforms.html).

# Adding a new platform

Community maintenance of a platform requires that core chef resources,
such as `package`, MUST have support for the platform. For example, on Debian
the package provider supports both `dpkg` and `apt`. Ohai SHOULD also be
able to gather relevant information on the platform.

In addition to support in code, there SHOULD be a Lieutenant for the
platform, per RFC 30. There MAY also be one or more Maintainers for the
platform. The Lieutenant and any Maintainers are responsible for
reviewing RFCs and code that affects the platform, and SHOULD be
responsible for ensuring that new versions of the platform are
supported.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
