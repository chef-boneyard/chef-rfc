---
RFC: 21
Author: Julian Dunn <jdunn@chef.io>, Tim Smith <tsmith@chef.io>
Title: Chef Platform Support Policy
Status: Accepted
Type: Informational
---

# Chef Platform Policy

The purpose of this RFC is to clarify which platforms the Chef community chooses to work on, and how those platforms are maintained.

The [chef docs site](https://docs.chef.io/) has [details of the platforms Chef Software, Inc validates for release](https://docs.chef.io/platforms.html).

# Types of Support

This RFC outlines the process for community support of a platforms on Chef, but it's worth noting the distinction between community supported and Chef Software Inc. supported:

- Commercial Support consists of the platforms that are supported as part of a paid commercial support contract with Chef Software Inc. For a complete list of commercially supported platforms see the [Chef Platform Support Docs ](https://docs.chef.io/platforms.html).
- Community Support is made up of platforms for which support is only available through the Chef community on a best effort basis.

# Adding a new platform

Community maintenance of a platform requires that core chef resources,
including `package`, `file`, and `service`, MUST have working providers
for the platform. For example, on Debian the package provider supports both
`dpkg` and `apt`. Ohai SHOULD also be able to gather relevant
information on the platform.

In addition to support in code, there SHOULD be a Lieutenant for the
platform, per RFC 30. There MAY also be one or more Maintainers for the
platform. The Lieutenant and any Maintainers are responsible for
reviewing RFCs and code that affects the platform, and SHOULD be
responsible for ensuring that new versions of the platform are
supported.

# Currently supported platforms

Platform | Architectures | Package Format
 ---- | --- | ---
 AIX  | ppc64 | bff
 Arch Linux | x86_64 | pacman
 CentOS | i386, x86_64 | rpm
 Debian | i386, x86_64 | deb
 Fedora  | x86_64 | rpm
 FreeBSD  | i386, amd64 | pkg
 Gentoo Linux | x86_64 |
 macOS | x86_64 | dmg
 OmniOS | x86_64 | ips
 OpenSUSE | x86_64 | rpm
 Oracle Enterprise Linux | i386, x86_64 | rpm
 Red Hat Enterprise Linux | x86_64, s390x, ppc64le (7.x), ppc64 (7.x) | rpm
 Scientific Linux | i386, x86_64	| rpm
 Solaris | sparc, x86 | shar
 SUSE Linux Enterprise Server  | x86_64, s390x, ppc64le, ppc64 | rpm
 Ubuntu Linux | x86, x86_64 | deb
 Windows | x86, x86_64 | msi

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
