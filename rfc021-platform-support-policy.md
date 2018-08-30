---
RFC: 21
Author: Julian Dunn <jdunn@chef.io>, Tim Smith <tsmith@chef.io>
Title: Chef Platform Support Policy
Status: Accepted
Type: Informational
---

# Chef Platform Policy

The purpose of this RFC is to clarify which platforms the Chef community chooses to work on, and how those platforms are maintained.

The [chef docs site](https://docs.chef.io/) has [details of the platforms Chef Software, Inc. supports commercially](https://docs.chef.io/platforms.html).

# Commercial vs. Community Support

This RFC is concerned with platforms maintained by the community within Chef OSS projects. These additional platforms are not supported by Chef Software Inc. commercially, and are maintained on a best effort basis by community members.

# Adding a new platform

Community maintenance of a platform requires that core chef resources, including `package`, `file`, and `service`, MUST have working providers for the platform. For example, on Debian the package provider supports both `dpkg` and `apt`. Ohai MUST also be able to gather relevant information on the platform such as platform information, cpu type/count, and available memory.

In addition to support in code, there SHOULD be a Lieutenant for the platform, per RFC 30. There MAY also be one or more Maintainers for the platform. The Lieutenant and any Maintainers are responsible for reviewing RFCs and code that affects the platform, and SHOULD be responsible for ensuring that new versions of the platform are supported.

# Currently supported platforms

Platform | Architectures | Package Format
 ---- | --- | ---
 Arch Linux | x86_64 | pacman
 Fedora  | x86_64 | rpm
 Debian | x86_64 | deb
 Gentoo Linux | x86_64 |
 OmniOS | x86_64 | ips
 OpenSUSE | x86_64 | rpm
 Ubuntu Linux (non-LTS) | x86, x86_64 | deb

# Platform Support EOL Policy

The Chef community will support a given platform version until the vendor's EOL
date for that platform version. Because different vendors use different
terminology, the following table clarifies when Chef products are end-of-life
according to those vendors’ terms:

Platform | Vendor End of Life
---- | ---
Debian | End of maintenance updates
Fedora | End of Life
OmniOS | End of Support
openSUSE | End of Life
Ubuntu Linux | End of maintenance updates

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
