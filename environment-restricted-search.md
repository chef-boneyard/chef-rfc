---
RFC: unassigned
Author: Thom May <tmay@chef.io>
Status: Draft
Type: Standards Track
---

# Environment Specific Search

Chef searches in recipes should be restricted to the node's current environment by default.

## Motivation

    As a sys admin,
    I want to ensure that my searches are accurate,
    so that my applications aren't confused.

## Specification

By default, searches return all possible results in an organisation.
This RFC proposes to change that so that searches are restricted to the
environment that the searching node is in.
For backwards compatability, this feature would be enabled by a config
option in Chef 12, becoming the default in a future version of Chef.

## Rationale

Essentially every search I have ever written contains:

```
"chef_environment:#{node.chef_environment} AND …"
```

This is wasteful and also introduces the possibility of nasty bugs
should one forget, probably introducing site reliability issues. Doing
this by default is both more delightful and more safe.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

