---
RFC: 21
Author: Julian Dunn <jdunn@chef.io>
Title: Chef Platform Support Policy
Status: Accepted
Type: Informational
---

# Chef Platform Policy

The purpose of this RFC is to clarify which platforms the Chef community chooses to work on, and how those platforms are maintained.

The [chef docs site](https://docs.chef.io/) has [details of the platforms Chef Software, Inc validates for release](https://docs.chef.io/platforms.html).

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

If not specified, chef works with all versions of a given
platform that the manufacturer supports.

Platform | Versions | Architectures | Package Format  
 --- | --- | --- | ---  
AIX | 6.1, 7.1, 7.2 | ppc64 | bff  
CentOS | 5, 6, 7 | i386, x86_64 | rpm  
Cisco IOS XR | 6 | x86_64 | rpm  
Cisco NX-OS | 7 | x86_64 | rpm  
Debian | 7, 8 | i386, x86_64 | deb  
FreeBSD | 9, 10 | i386, amd64 | pkg_add pkg  
Mac OS X | 10.9, 10.10, 10.11 | x86_64 | dmg  
Oracle Enterprise Linux | 5, 6, 7 | i386, x86_64 | rpm  
Red Hat Enterprise Linux | 5, 6, 7 | i386, x86_64 | rpm  
Solaris | 10u11, 11 | sparc, x86 | shar  
Windows | 7, 8, 8.1, 2008, 2008R2, 2012, 2012R2 | x86, x86_64 | msi  
Ubuntu Linux | | x86, x86_64 | deb  
SUSE Linux Enterprise Server  | 11, 12 | x86_64  
Scientific Linux | 5.x, 6.x and 7.x | i386, x86_64		
Fedora  | | x86_64  
OpenSUSE | 13.1/13.2/42.1 | x86_64  
OmniOS | | x86_64  
Gentoo Linux | | x86_64  
Arch Linux | | x86_64  

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
