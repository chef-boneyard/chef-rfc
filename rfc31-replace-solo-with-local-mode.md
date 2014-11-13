---
RFC: 31
Author: Joshua Timberman <joshua@getchef.com>
Status: Accepted
Type: Standards Track
---

# Replace chef-solo with chef-client local mode

Replace chef-solo's core with chef-client "local-mode," to run chef without an external Chef Server

## Motivation

    As a Chef user,
    I want to run and use Chef without a server,
    so that I am using the same API and core features,
    and so that I can use any published cookbooks.

Case in point, the `chef-solo-search` cookbook exists to provide search-like functionality so that users of `chef-solo` can use public cookbooks unmodified.

The `knife-solo` RubyGem exists to make it easier to distribute the parts of a "chef repository" to target nodes. However, it has a completely different workflow than what users who have a Chef Server use, leading to confusion and differences in help systems such as IRC and the mailing list.

Amazon Web Services "OpsWorks" uses `chef-solo` as its implementation, which leads to issues with workflow and support similar to `knife-solo`.

There doesn't exist a clear and easy way for `chef-solo` users to migrate to a `chef-client`/Chef Server implementation and vice versa, due to the lack of "server" features.

## Specification

This RFC proposes to replace `chef-solo` with `chef-client --local-mode`. The`chef-solo` command will continue to exist, and to the extent possible, work with existing solo-specific workflows without modification.

This means that `chef-solo` using "local mode" **must** be 100% backwards-compatible with existing `chef-solo` usage.

The local mode feature of `chef-client` uses `chef-zero`, an in-memory API-complete implementation of the Chef Server. This would give "solo" users the capability of performing searches, "saving" node objects, and easily saving and retrieving data bags. The `chef-zero` server can persist data to disk, allowing that to be distributed to other nodes as necessary.

The application implementation of `chef-solo` would be changed to invoke `chef-client` with `Chef::Config[:local_mode]` set to `true` by default in the application class.

## Rationale

Chef has always had `chef-solo`, a standalone recipe execution engine that can run recipes on nodes. However, as new `chef-client`/Chef Server features are added, they slowly trickle down to `chef-solo`, if they even get implemented at all. This makes `solo` users unable to have complete consistency when consuming cookbooks from the community.

This will also simplify the codebase, as there is a great deal of duplication between `Chef::Application::Solo` and `Chef::Application::Client`. This would create a single place to go for the application config - the `Chef::Application::Client` class.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
