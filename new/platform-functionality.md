---
RFC: unassigned
Title: Platform Functionality Index
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Informational
Replaces: RFC021
---

# Platform Functionality Index

This document records the platforms that are known to "work", for various
definitions of that word. This document is correct as of 2018-08-29, though it
is possible that future development has altered the list.

It does not define what is "supported" or "maintained". For what platforms
receive formal support assistance, please consult the [Chef documentation](https://docs.chef.io/platforms.html).
All maintenance outside of Chef Software's commercial support policy is on a
"best effort" basis.

## Does Chef Work On X?

Yes, as long as it can run Ruby 2.4 or later. Some resources require specific
platform support, however Chef itself will work on any platform that we know of
which can run Ruby and at least some resources are fully cross-platform by
default (`execute`, `template`, etc).

## Core Resources

The three core resources most often used that require specific platform support
are `package`, `service`, and `user`. The following is a list of all platforms
which support these three resources or a direct analogue (eg. `windows_package`)
as of the date in the first paragraph:

TODO [ed: if people like this idea, we can write up the list]

## Chef Installers

While the Chef community is involved, final determination and vetting of the
installer packages is graciously provided by Chef Software. At this time, we
defer to [their platform policy](https://docs.chef.io/platforms.html) with regards
to installers.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
