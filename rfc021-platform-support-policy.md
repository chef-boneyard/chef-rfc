---
RFC: 21
Author: Julian Dunn <jdunn@chef.io>
Status: Accepted
Type: Informational
---

# Chef Platform Policy

The purpose of this RFC is to clarify how Chef Software, Inc choose to adopt or remove a platform.

This RFC does *not* address "What is the product lifecycle of Chef Software, Inc.'s software". That is covered in a separate RFC.

The [chef docs site](https://docs.chef.io/) has [details of current adopted platforms](https://docs.chef.io/platforms.html).

##  Guiding Principles for Operating System Version Adoption

Once Chef Software, Inc. decides to adopt an operating system, we will also develop rules to determine under what upstream vendor lifecycle applies, and will build and/or test our products according to these rules. These rules will be documented in this section. Vendors have various terminology to describe support lifecycles ('standard support', 'extended support', etc.) and it is useful to clarify what those mean in the context of Chef's products.

Platform | Support Until | References
--- | --- | ---
AIX | End of Support Date | https://www-01.ibm.com/software/support/aix/lifecycle/
Debian | Current Version, plus previous version whilst security supported (stable and oldstable) | https://wiki.debian.org/DebianReleases
Mac OS X | Current version, plus two previous versions | Apple does not clearly announce EOLs, so we have made this choice
RHEL and EL-variants | End of RedHat Production 3 Phase | https://access.redhat.com/support/policy/updates/errata/
Solaris | End of Premier Support | http://www.oracle.com/us/support/library/lifetime-support-hardware-301321.pdf
Ubuntu | End of LTS lifecycle for LTS releases, end of standard release lifecycle for non-LTS releases | https://wiki.ubuntu.com/LTS
Windows | End of Extended Support | https://support.microsoft.com/lifecycle/?c2=1163

## Timeline of Platform Addition/Removal

The current Adopted Platforms document is listed here: https://docs.chef.io/platforms.html
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
Gentoo Linux | Moved to Tier 3 May 2016 | This was never adopted by the Tier 2 definition
Arch Linux | Moved to Tier 3 May 2016 | This was never adopted by the Tier 2 definition
OpenSUSE 42.1 | Added to Tier 2 May 2016 |
OpenBSD 5.7/5.8 | Moved to Tier 3 May 2016 | This was never adopted by the Tier 2 definition

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
