---
RFC: unassigned
Author: Thom May <thom@chef.io>
Status: Draft
Type: Process
---

# Change Ohai version numbers to match Chef

In general, Ohai and Chef are released together, and their functionality
is interdependent. It would be much simpler to reason about how
functionality added to either would affect the other if their version
numbers were aligned.

## Motivation

    As a developer,
    I want to use the correct version of Ohai,
    so that releases of Chef and Ohai work properly.

## Specification

Ohai be renumbered to 12.x.0, where x is the same as the current
development minor version of Chef. Chef would then have a pessimistic version
pin to Ohai of "~> 12.x.0", and Ohai would have a similar pessimistic
pin to ChefConfig.

When Chef or Ohai update their minor version, the other must do so in
lockstep.

The change from 8 to 12 would not be considered a
major version bump for API impact considerations, so no deprecated
functionality would be removed.

## Downstream Impact

Any library which version pins to Ohai < 9.0 would need to be updated to
be < 13.0.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
