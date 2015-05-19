---
RFC: 21
Author: Julian Dunn <jdunn@getchef.com>
Status: Accepted
Type: Informational
---


# Chef Platform Support Policy

The purpose of this RFC is to clarify:

* What specific operating system platforms and platform versions are supported by the software produced by Chef Software, Inc.
* What is the meaning of "supported platform"

This RFC does *not* address "What is the product lifecycle of Chef Software, Inc.'s software". That is covered in a separate RFC.

## Chef Client

A Chef Client supported platform means:

* Omnitruck won't fail when confronted with the platform and version
* The most important core resources (package, service, template) work out of the box
* Ohai attributes for ```platform```, ```platform_family```, ```platform_version``` and ```kernel.machine``` are correct

Chef Client support policies also apply to Ohai, since that is a dependency.

### Tier 1 Support

Tier 1 supported platforms are those for which Chef builds native binary "Omnitruck" (full-stack installer) packages. For each platform, Chef performs some post-build verification on them or their equivalents. For example, we may elect to do post-build verification for Oracle Enterprise Linux using the same test results as Red Hat Enterprise Linux, since they are so similar).

Platform | Versions | Architectures | Package Format | Built on
--- | --- | --- | --- | ---
AIX | 6.1, 7.1 | ppc64 | bff | AIX 6.1
CentOS | 5, 6, 7 | i386, x86_64 | rpm | RHEL 5
FreeBSD | 9, 10 | i386, amd64 | pkg_add pkg | FreeBSD 9
Mac OS X | 10.8, 10.9, 10.10 | x86_64 | dmg | Mac OS 10.8
Oracle Enterprise Linux | 5, 6, 7 | i386, x86_64 | rpm | RHEL 5
Red Hat Enterprise Linux | 5, 6, 7 | i386, x86_64 | rpm | RHEL 5
Solaris | 10, 11 | sparc, x86 | shar | Solaris 10
Windows | 7, 8, 8.1, 2003R2, 2008, 2008R2, 2012, 2012R2 | x86, x86_64 | msi | Windows 2008R2
Ubuntu Linux | 10.04, 12.04, 14.04 | x86, x86_64 | deb | Ubuntu 10.04

### Tier 2 Support

Tier 2 supported platforms are those on which Omnitruck will serve packages, but those packages may not have been built on that OS variant. Additionally, we may or may not do post-build verification on these platforms.

* SUSE Linux Enterprise Server 10, 11
* Scientific Linux 5.x, 6.x and 7.x (i386 and x86-64)
* Debian Linux 6.x and 7.x
* Gentoo Linux (rolling release)
* Arch Linux (rolling release)
* Fedora (current non-EOL revisions)
* OpenSUSE 12.3 (until EOL on 15 September 2014), 13.1
* OmniOS stable and LTS releases
* OpenBSD 5.7 (i386 and amd64)

### Not Supported

"Not supported" means there may be code in-tree, but we don't build for and test on those platforms. At our discretion, we may take patches that don't break any tier 1 or tier 2 platforms, but we have no way of testing these.

* Solaris < 10
* AIX 5.1L
* FreeBSD 8
* NetBSD
* Windows 2003, Windows 2000
* RHEL/CentOS/Oracle/Scientific 4.x or older
* RHEL or SLES on POWER (ppc64) or System/z
* HP-UX
* Mac OS X < 10.8, anything ppc

## Chef Server

Includes any of the add-ons (webui2/manage, push, etc.)

### Supported

* Ubuntu 10.04LTS, 12.04LTS, 14.04LTS
* RHEL 5.x, 6.x, 7.x
* CentOS 5.x, 6.x, 7.x
* Oracle Enterprise Linux 5.x, 6.x, 7.x

### Unsupported

* Any other Linux or UNIX distributions
* Windows

## ChefDK

### Supported

* Windows 7, 8, 8.1
* Fedora (current non-EOL releases)
* RHEL 6.x
* Mac OS X 10.8, 10.9, 10.10
* Ubuntu 12.04, 14.04

ChefDK bundles Chef Client. Therefore, Chef Client is supported, by extension, on the foregoing client platforms, if not already mentioned explicitly in the Chef Client support matrix.

### Unsupported

* Windows Vista, XP, 2000
* Mac OS X < 10.8, anything ppc

## Appendix 1: Guiding Principles for Operating System Version Support

Once Chef Software, Inc. decides to support an operating system, we will also develop rules to determine under what upstream vendor lifecycle we will continue to support products, and they will be documented in this section. Vendors have various terminology to describe support lifecycles ('standard support', 'extended support', etc.) and it is useful to clarify what those mean in the context of Chef's products.

Platform | Support Until | References
--- | --- | ---
Mac OS X | Current version, plus two previous versions | Apple does not clearly announce EOLs, so we have made this choice
RHEL and EL-variants | End of RedHat Production 3 Phase | https://access.redhat.com/support/policy/updates/errata/
Solaris | End of Premier Support | http://www.oracle.com/us/support/library/lifetime-support-hardware-301321.pdf
Ubuntu | End of LTS lifecycle for LTS releases, end of standard release lifecycle for non-LTS releases | https://wiki.ubuntu.com/LTS
Windows | End of Extended Support | https://support.microsoft.com/lifecycle/?c2=1163

## Appendix 2: Timeline of Platform Addition/Removal

The current Supported Platforms document is listed here: https://docs.chef.io/supported_platforms.html
As platforms are added and removed, the timeline of the changes needs to be recorded.

Platform | Change | References
--- | --- | ---
Solaris 9 | Removed October 2014 | http://www.oracle.com/us/support/library/lifetime-support-hardware-301321.pdf

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
