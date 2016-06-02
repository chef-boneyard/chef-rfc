---
RFC: 21
Author: Julian Dunn <jdunn@chef.io>
Status: Accepted
Type: Informational
---


# Chef Platform Policy

The purpose of this RFC is to clarify:

* What specific operating system platforms and platform versions will work with the software produced by Chef Software, Inc.
* What are the meanings of "foundational platform", "secondary platform", and "other platforms"

## Chef Client

To be included as either a Foundational Platform or a Secondary Platform, the following must be true for that specific platform and version:

* Omnitruck won't fail when confronted with the platform and version
* The most important core resources (package, service, template) work out of the box
* Ohai attributes for ```platform```, ```platform_family```, ```platform_version``` and ```kernel.machine``` are correct

These policies also apply to Ohai, since that is a dependency.

### Foundational Platforms

Foundational platforms are those for which native binary "Omnibus" (full-stack installer) packages are built and available via Omnitruck for every release. For each platform, Chef performs some post-build verification on them or their equivalents. For example, we may elect to do post-build verification for Oracle Enterprise Linux using the same test results as Red Hat Enterprise Linux, since they are so similar. Only platform versions that receive automated post-build verification are listed here, even when newer or intermediate versions may be known to work. A platform must have a Lieutenant as defined in RFC 030 before being added to this tier.

Platform | Versions | Architectures | Package Format | Built on
--- | --- | --- | --- | ---
AIX | 6.1, 7.1 | ppc64 | bff | AIX 6.1
CentOS | 5, 6, 7 | i386, x86_64 | rpm | RHEL 5
Cisco IOS XR | 6 | x86_64 | rpm | Cisco IOS XR 6 Developer Image
Cisco NX-OS | 7 | x86_64 | rpm | Cisco NX-OX 7 Developer Image
Debian | 7, 8 | i386, x86_64 | deb | Debian 6
FreeBSD | 9, 10 | i386, amd64 | pkg_add pkg | FreeBSD 9
Mac OS X | 10.9, 10.10, 10.11 | x86_64 | dmg | Mac OS 10.9
Oracle Enterprise Linux | 5, 6, 7 | i386, x86_64 | rpm | RHEL 5
Red Hat Enterprise Linux | 5, 6, 7 | i386, x86_64 | rpm | RHEL 5
Solaris | 10, 11 | sparc, x86 | shar | Solaris 10
Windows | 7, 8, 8.1, 2008, 2008R2, 2012, 2012R2 | x86, x86_64 | msi | Windows 2008R2
Ubuntu Linux | 12.04, 14.04 | x86, x86_64 | deb | Ubuntu 12.04

### Secondary Platforms

Secondary platforms are those on which native packages are available from Omnitruck, but those packages may not have been built on that OS variant. Additionally, we may or may not do post-build verification on these platforms. A platform must have at least one Maintainer before being added to this tier.

* SUSE Linux Enterprise Server 11, 12
* Scientific Linux 5.x, 6.x and 7.x (i386 and x86-64)
* Fedora (current non-EOL revisions)
* OpenSUSE 13.1/13.2/42.1
* OmniOS stable and LTS releases

### Other Platforms

"Other" means there may be code in-tree, but we don't build packages for or test on those platforms. At our discretion, we may take patches that don't break any tier 1 or tier 2 platforms, but we have no way of testing these.

* Solaris < 10
* AIX 5.1L
* FreeBSD 8
* NetBSD
* OpenBSD (i386 and amd64)
* Windows 2003R2, Windows 2003, Windows 2000
* RHEL/CentOS/Oracle/Scientific 4.x or older
* RHEL or SLES on POWER (ppc64) or System/z
* HP-UX
* Mac OS X < 10.9, anything ppc
* Debian < 7.0, anything ppc or arm
* Gentoo Linux (rolling release)
* Arch Linux (rolling release)

## Chef Server

Includes any of the add-ons (webui2/manage, push, etc.)

### Foundational

* Ubuntu 12.04LTS, 14.04LTS
* RHEL 5.x, 6.x, 7.x
* CentOS 5.x, 6.x, 7.x
* Oracle Enterprise Linux 5.x, 6.x, 7.x

### Other or non-viable

* Any other Linux or UNIX distributions
* Windows

## ChefDK

### Foundational

* Windows 7, 8, 8.1
* Fedora (current non-EOL releases)
* RHEL 6.x, 7.x
* Mac OS X 10.9, 10.10, 10.11
* Ubuntu 12.04, 14.04


###  Other or non-viable

* Windows Vista, XP, 2000
* Mac OS X < 10.9, anything ppc

## Appendix 1: Guiding Principles for Operating System Version Adoption

Once Chef Software, Inc. decides to adopt an operating system, we will also develop rules to determine under what upstream vendor lifecycle we will continue to build and/or test on our products on that platform, and they will be documented in this section. Vendors have various terminology to describe support lifecycles ('standard support', 'extended support', etc.) and it is useful to clarify what those mean in the context of Chef's products.

Platform | Support Until | References
--- | --- | ---
AIX | End of Support Date | https://www-01.ibm.com/software/support/aix/lifecycle/
Debian | Current Version, plus previous version whilst security supported (stable and oldstable) | https://wiki.debian.org/DebianReleases
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
Ubuntu 10.04LTS | Moved to Tier 2 May 2015 | https://wiki.ubuntu.com/LTS
Windows 2003R2 | Removed July 2015 | https://support.microsoft.com/en-us/lifecycle/search/default.aspx?alpha=Windows%20Server%202003%20R2
Mac OS X 10.11 | Added January 2016 |
Debian 6 | Removed February 2016 | https://www.debian.org/News/2014/20140424
openSUSE 12.3 | Removed February 2016 | http://lists.opensuse.org/opensuse-security-announce/2015-02/msg00003.html
OpenBSD 5.8 | Added February 2016
openSuse 13.2 | Added February 2016
Ubuntu 10.04LTS | Removed February 2016 | https://wiki.ubuntu.com/LTS
Mac OS X 10.8 | Removed February 2016 |
SUSE Linux Enterprise Server 10 | Removed May 2016 |
Gentoo Linux | Moved to Tier 3 May 2016 | This was never supported by the Tier 2 definition
Arch Linux | Moved to Tier 3 May 2016 | This was never supported by the Tier 2 definition
OpenSUSE 42.1 | Added to Tier 2 May 2016 |
OpenBSD 5.7/5.8 | Moved to Tier 3 May 2016 | This was never supported by the Tier 2 definition

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.