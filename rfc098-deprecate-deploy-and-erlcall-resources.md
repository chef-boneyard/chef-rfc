---
RFC: 98
Title: Deprecate deploy and erl_call
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Accepted
Type: Standards Track
---

# Deprecate `deploy` and `erl_call`

Two resources in Chef core that cause a lot of user confusion and issues are
the `deploy` and `erl_call` resources.

With the `deploy` resource, the confusion is mostly inherent in the very large
number of moving pieces in the resource. The Capistrano-style deployment logic
makes sense when a deployment tool is expecting to co-exist with manual management,
but this is not usually the case with Chef recipes. Most users would be better
served by a simpler `git` resource for deployment.

`erl_call` is more debatable, it doesn't tend to cause a lot of user confusion
and the maintenance burden isn't really a problem, but if we're already doing
some cleanups we kind of might as well. The use case for this resource is so
vanishingly small that it doesn't make much sense to keep in Chef core.

## Motivation

    As a Chef user,
    I want Chef core resources to match my expectations,
    so that using Chef is easier.

## Specification

The deprecation phase would start from now until Chef 14 in April 2018. The
resources would emit a deprecation warning if used.

Because the `deploy` resource has been around for so long, we recognize that
even 6 months of deprecation warnings may not be sufficient time to port off it.
As an aid to migration, we will copy the code for the `deploy` resource to a
cookbook which can be included for backwards compatibility even after the release
of Chef 14. This does not obligate us to continue supporting this resource or
cookbook beyond basic compatibility fixes (i.e. this should not be construed as
a permanent thing, nor should any improvements be counted upon beyond what
already exists in Chef).

With Chef 14, both resources would be removed from Chef.

## Downstream Impact

Any cookbook using `deploy` would have either have to migrate to another file
deployment solution (probably a simple `git` resource) or use the compatibility
cookbook. Any cookbook using `erl_call` will be broken, however we are unable
to find any public cookbooks at this time, and if there is community demand,
someone could make a compatibility cookbook as with `deploy`.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
