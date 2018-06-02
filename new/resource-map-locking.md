---
RFC: unassigned
Title: Resource Map Locking
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Standards Track
---

# Resource Map Locking

To improve the migration process of resources from cookbooks to core, as well
as prevent user confusion, resources in cookbooks will no longer be allowed to
override resources in Chef core by default.

The overall goal is enable the RFC100 resource adoption process to run more
smoothly by allowing us to enforce that the version of a resource in Chef core
will win priority even with an old version of the cookbook still active, but
only when we want to (on Chef major version boundaries).

## Motivation

    As a Chef developer,
    I want to migrate resources to core,
    so that users can use them.

## Current State

As of this writing, the way resource and provider mappings work is that every
class providing a given name is ranked based on how "tightly" they bind to the
name, and then within equal "tightness", the last class to load wins. In
practical terms, this means that if both Chef core and a cookbook declare a
resource with identical `provides` lines, the cookbook will win priority.

## Specification

The main new concept would be introducing a "mode" to the resource and provider
`NodeMap` instances, locked and unlocked. They would start in unlocked mode,
allowing Chef core to register all its resources and providers as normal. It would
then be switched into locked mode, where attempting to `provides` on a name
that is already in use will result in a deprecation warning and the resource or
provider *not* being mapped. This process is modulated in two ways, both via
`provides` option flags. The first is `allow_cookbook_override: true`, which
makes a resource or provider name always behave as if it is unlocked. This is
used in Chef core as part of the RFC100 adoption process. The second is
`__core_override__: true`, which allows intentionally remapping over a locked
name in the map. This can be used by advanced users for things like pointing all
`package` resources at some new code or other very edge case things.

Any resource which has `allow_cookbook_override: true` set should be marked as
"preview" in the documentation. This will help communicate that between
the minor version where a resource is added and the following major release when
it takes over from cookbooks forcibly is a trial run and we may continue to
improve the resource (which should be coordinated with the cookbook).

Cookbooks adding new providers to core resources is less problematic, but for
consistency will work the same way so it will generally require the use of the
`__core_override__` option. We may want to revisit this in the future for core
resources which are most commonly extended like `package` and `service`, but
this is still rare enough to be called out as a special case.

In order to not disrupt the Chef 14 cycle, we can either change the behavior so
that during Chef 14 when you `provides` over an existing name, it logs the
deprecation warning but still adds the name, or we could add `allow_cookbook_override`
to every core resource.

## Downstream Impact

It is possible some users are already mapping over core resources on purpose.
This proposal does preserve compatibility during Chef 14, though someone is
going to complain about the deprecation warnings anyway. And come Chef 15, we
would be changing the default behavior which will almost certainly get some
complaints.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
