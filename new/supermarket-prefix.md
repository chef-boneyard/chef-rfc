---
RFC: unassigned
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Process
---

# Supermarket Prefix Reservation

While the question of explicit namespace support for Supermarket and the broader
Chef ecosystem has mostly been answered, a de facto standard has emerged over
the years to prefix cookbook names with the originating organization or team.
In most cases these are internal, but more and more of these prefixed names are
being released to the public Supermarket.

This has benefits to both cookbook authors who want to make it clear a cookbook
is part of their brand and thus meets their quality standards, as well as to
users who can use brand-level trust to find new cookbooks to use.

The downside is there is no explicit tooling built for this prefix management.
Currently any user can register any unused name, possibly causing confusion as
to if a cookbook is officially associated with the prefix name or not.

## Motivation

    As a community cookbook author,
    I want to maintain brand continuity,
    so that my cookbooks can be clearly identified.

    As a community cookbook consumer,
    I want to know when cookbooks come from trusted authors,
    so that I can feel confident in using new cookbooks.

## Specification

A group or company will have exclusive control to prefixes registered to them.
These prefixes are subject to approval by Chef Software as part of their operation
of the public Supermarket application. Private deployments of Supermarket can
define their own governance structure for allocating prefixes.

If a prefix is registered, the user or users that are responsible for it will
be the only ones allowed to register new cookbooks or tool with that prefix.
The responsible user or users can authorize other users to create cookbooks in
their prefix, but this requires explicit permission from the prefix holder.

In the short term, prefix management can be handled ad hoc via existing cookbook
rename/removal tooling in Supermarket. Established prefixes can be added to this
RFC by pull request.

In the long term, it would be good to see native functionality added to
Supermarket to enable this, though care will have to be taken at that point to
ensure abuse is not a problem.

## Prefixes

* `poise` - [coderanger](https://github.com/coderanger)

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
