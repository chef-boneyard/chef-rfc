---
RFC: unassigned
Author: Lamont Granquist <lamont@chef.io>
Status: Draft
Type: Standards Track
---

# Title

Cookbook Segment Deprecation

## Motivation

    As a Chef User/Developer
    I want to be able to extend the structure of cookbooks easily,
    in order to quickly adapt to new automation needs.

## Specification

This RFC will add a special `all_files` segment to cookbooks which will duplicate (initially)
all of the existing cookbook manifest along with arbitrary files outside of the current scope of
any of the cookbook segments.  The Chef Server will need to be patched in order to support this
new 'segment' and accept it since the Chef Server currently does strict enforcement of file
segments server-side.  This will also generate a version bump of the Chef Server protocol which
will be used by clients to determine if the Chef Server supports this field or not.

New knife clients that support this segment will use the Chef Server protocol version to determine
if they MUST upload cookbooks using the old segment format, or if they SHOULD upload using only
the `all_files` format.

For backwards compatibility, the Chef Server MUST serve cookbooks with both standard segments and the
new `all_files` segment unless it can determine that the client prefers one or other.  If it can
be determined then the server MUST serve cookbooks to old clients with the old format, and SHOULD
serve cookbooks to new clients with only the `all_files` segment.

New Chef Clients MUST accept either old style segments, cookbooks with the new `all_files` segment
or cookbook metadata with both styles (and SHOULD favor the `all_files` segment).

This will achieve backwards compatibility and the ability for knife, chef-client and the chef-server
to be upgraded independently of each other and run in a "dual-stack" mode.  At some point in the
future, backwards compatibility will be dropped in a major version bump.

The implementation of this RFC must still fully support both settings of the `no_lazy_load` config parameter.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
