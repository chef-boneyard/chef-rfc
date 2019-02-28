---
RFC: 76
Title: Change Ohai version numbers to match Chef
Author: Thom May <thom@may.lt>
Status: Accepted
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

Ohai will be renumbered to 12.x.y, where x and y are the current development
minor and patch versions of Chef. Chef would then have a equality version
pin to Ohai of "= 12.x.y", and Ohai would have a similar equality
pin to ChefConfig.

The version bot currently used to automatically change version numbers
for Chef would also be used to update Ohai's version number when Chef is
bumped.

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
