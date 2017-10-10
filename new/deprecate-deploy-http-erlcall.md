---
RFC: unassigned
Title: Deprecate deploy, http_request, and erl_call
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Standards Track
---

# Deprecate `deploy`, `http_request`, and `erl_call`

Three resources in Chef core that cause a lot of user confusion and issues are
the `deploy`, `http_request`, and `erl_call` resources.

With the `deploy` resource, the confusion is mostly inherent in the very large
number of moving pieces in the resource. The Capistrano-style deployment logic
makes sense when a deployment tool is expecting to co-exist with manual management,
but this is not usually the case with Chef recipes. Most users would be better
served by a simpler `git` resource for deployment.

`http_resource` is a common stumbling block as people see it and expect they
can use it to get the value of the HTTP response in their recipe code. Given the
use case for making an HTTP request without caring about the response is incredibly
niche, this is probably no longer a good fit for Chef core.

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

In parallel we would create [ed: one cookbook or multiple?] a cookbook for each
resource to allow using them after the release of Chef 14.

With Chef 14, all three resources would be removed from Chef.

## Downstream Impact

Any cookbook using one of these three resources would need to be modified to
depend on the relevant compat cookbook or would break upon the release of Chef 14.
Because of how loaded custom resources/libraries are global, things could still
be shimmed by putting the compat cookbook as a dependency of some other cookbook
being loaded or putting them on the run list directly.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
