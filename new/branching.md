---
RFC: unassigned
Title: Chef Branching
Author: Thom May <thom@chef.io>
Status: Draft
Type: Informational
---

# Branching and Development Patterns

There are serious quality of life issues with the current development
approach of Chef, especially in the chef-client repository. We are
committed to making a major version release once a year in April, and
then monthly point releases the rest of the year. We support n-1
releases of Chef, meaning that fixes must be backported when
appropriate.
Currently, the "current" release of Chef (presently 14) is built
directly from master. This has the advantage that it's very easy to
contribute quickly to the next release, and new features and bug fixes
are automatically released once a month. However, this same convenience
makes it much harder to build and verify large features or breaking
changes. There is also a rush to land features once the current release
is branched and master becomes the next major release, causing large
amounts of stress for developers.

## Specification

After the first point release of each major version of the Chef Client
is released, a new branch will be created for that version (ie.
`chef-14`). Master will then be the next major revision, and will
accept breaking changes.
The current release will still accept features, but they will be
backported from master. In the general case, we expect this to be
accomplished using automation.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
