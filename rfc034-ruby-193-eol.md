---
RFC: 34
Author: Daniel DeLeo <dan@getchef.com>
Status: Accepted
Type: Standards Track
---

# Ruby 1.9.3 EOL

Chef 12.0 will require Ruby 2.0 or greater.

## Motivation

    As a Chef User,
    I want to avoid changes to supported Ruby VMs during a release cycle,
    so that I can have a stable installation process.

## Specification

Chef's gemspec will be modified to set the minimum Ruby version to
`>= 2.0.0`.

## Rationale

Preemptively dropping support for Ruby 1.9.3 will prevent anyone from
using a Ruby VM version that will become unsupported during the Chef
12.0 lifecycle, avoiding a potential major disruption to users'
installation procedure.

When a Ruby VM version reaches EOL during a major release cycle, the
Chef development team must choose one of two options:

1. Continue to support an EOL'd version of Ruby, so users are not
   disrupted.
2. Drop support for that version. Any users relying on that Ruby version
   are forced to modify their installation procedures in order to get
   updates.

Dropping support for the EOL'd Ruby VM version has the following
benefits:

* The test matrix decreases in size, so testing is easier.
* The dev team is free to upgrade dependencies that may have dropped
  support for the EOL'd Ruby version.
* As a special-case of the above, EOL'd versions of dependencies may not
  receive security updates, so the dev team can be forced to manually
  backport security patches in order to maintain support for EOL'd Ruby
  VMs. Dropping support for that Ruby VM version eliminates this
  problem.

RFC 015 describes the support lifecycle for Ruby VM versions as follows:

> Chef Client omnibus packages ship with the Latest version of Ruby at the time of a major version bump.
> Latest & Latest - 1 versions of Ruby are supported.
> Ruby version bumps only happen at the time of Chef major version bumps.

At the time of writing, Ruby 2.1 is the latest Ruby version and 2.0 is
the "N-1" version. However, the Chef 12.0 package for Windows is likely
to ship with Ruby 2.0 because some Windows-specific dependencies have
not yet been updated with Ruby 2.1 support. In any case, dropping
support for Ruby 1.9.3 matches the letter of the RFC 015 specification.


## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

