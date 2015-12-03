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

This RFC specifies a new format for the GET and PUT requests to the cookbooks/NAME/VERSION
endpoint.  This is a breaking change which will mandate a bumping of the API version to
the protocol.  The existing 'segments' will be removed out of the cookbook version and a
new 'all_files' segment will be introduced which will simply be a list of all the files in
the cookbook.

The Chef Server MUST respond to all GET requests that do not contain an appropriate API version
with the old protocol with segments.  Cookbooks that have been uploaded in the new format
MUST have their manifest information filtered so that an old style response can be constructed.
When the Chef Server sees an API version in the GET request that accepts the new style it
MUST respond only with the 'all_files' segment in the body of the response.

All new Clients MUST set their API version correctly in order to get the new behavior on
PUT or GET.  Since old Servers will not accept the new 'all_files' segment Clients MUST determine
the server version they are talking to and send their PUT requests correctly.  Clients MAY
use prior communication with the Chef Server (i.e. during the uploading of sandbox files they
MAY determine the API version of the Chef Server off of the replies and use that information) to
determine the correct API version to use and format their PUT request accordingly.  Clients
MAY also PUT with the new format and after receiving a 4xx code from the Server retry the
request in the old format and downgrade.

The implementation of this RFC must still fully support both settings of the `no_lazy_load`
config parameter.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
