---
RFC: 34
Title: Ruby Version Deprecation Policy
Author: Daniel DeLeo <dan@chef.io>
Status: Accepted
Type: Standards Track
---

# Ruby Version Deprecation Policy

Establishes a rolling version policy for Chef and ChefDK and the
associated ecosystem (berkshelf, test-kitchen, etc).

## Motivation

    As a Chef User,
    I want to avoid changes to supported Ruby VMs during a release cycle,
    so that I can have a stable installation process.

## Specification

Minor version bumps of the ruby version shipping with Chef and ChefDK
will only require a minor version bump of the Chef and ChefDK package.

Raising the `required_ruby_version` floor of any associated gem by
a minor version will only require a minor version bump of the gems
and associated omnibus packages.

Ruby versions MUST be supported until they are no longer releasing
bugfixes and have entered the security maintenance phase.

Ruby versions MAY be supported after they have entered the security
maintenance phase.

## Rationale

As ruby versions enter their security release phase, many gems in the
ruby ecosystem drop support for them which creates a support burden.

To reduce that support burden, Chef and ChefDK must be flexible enough
to drop support for those old ruby versions without releasing a
new major version.

Historically, the 12.9.38 release of the chef gem dropped support for
ruby 2.0.x and this was found to not cause any customer facing issues.

## Scope

This RFC only covers how long a ruby version will be supported for, it
does not cover which supported ruby version will be shipped in Chef
and ChefDK (which is often driven by bugs and test failures that need
to be addressed before those versions are considered stable enough to
be shipped on all platforms).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

