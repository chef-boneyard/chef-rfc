---
RFC: unassigned
Title: API HTTP HEAD support
Author: Jeremy Miller <jmiller@chef.io>
Status: Draft
Type: <Standards Track, Informational, Process>
<Replaces: RFCxxx>
<Tracking:>
<  - https://github.com/chef/chef/issues/X>
---

# API HTTP HEAD support
There is a greater resource cost than is necessary when querying the Server API named object endpoints for the existence of a single object.
Currently, if checking for an object's existence, only HTTP `GET` requests are supported by the server. This means the entire object is fetched, consuming
resources across the server, network and client. When viewed from a large scale perspective, this overhead can cause slow downs that can have
compounding effects.

## Motivation

    As a Chef developer,
    I want to be able to write code that queries the Server for the existence of a single object via a light-weight API call and response,
    so that my applications can run as efficiently and as quickly as possible.

## Specification

The HEAD method shall be identical to GET except that the server must not return a message-body in the response.

The meta-information contained in the HTTP headers in response to a HEAD request should be identical to the
information sent in response to a GET request.

The HEAD HTTP verb will be added to oc_erchef and chef-zero named object endpoints such that a client http HEAD request for
an object name will result in a http 200 response code if it exists, 404 if it does not and 401 if the requestor does not
have read authorization on the object.

example named endpoint: /nodes/NAME

## Downstream Impact

In addition to `chef-server`, `chef-zero` will need this capability added so that it remains in lock-step.

As an optimization and/or feature addition, several other downstream items could benefit including: Chef::ChefFS, Chef::Knife, knife-ec-backup.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
