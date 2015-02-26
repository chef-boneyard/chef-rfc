---
RFC: unassigned
Author: Matt Ray <matt@chef.io>
Status: Draft
Type: Standards Track
---

# Title

`remote_file` Resource `cache` attribute

## Motivation

    As a Chef user with many large files requested by multiple nodes with the remote_file Resource, I would like to speed up the downloads in my chef-client runs.

## Specification

The [remote_file](https://docs.chef.io/resources.html#remote-file) Resource will add a new attribute `cache` to request that the Chef Server to provide a local mirror. `cache` will default to to `false` and is not required. If it is set to `true` and caching is enabled, the Chef Server will store a local copy for more efficient file transfers. This will be transparent to the Chef client, it does not know if the file is actually cached on the Chef Server.

When the Chef client connects, the Chef Server indicates that caching is available in the response. The `remote_file` Resource would pass the Chef Server as a proxy URL when making the file request if it knows caching is enabled.

The Chef Server uses (nginx)[http://nginx.org/], which may act as a proxy server. By default, the Chef Server will not be configured to cache files because they may take inordinate amounts of space (CI environments for example). [Hosted Chef](https://manage.chef.io) will not cache files. The Chef Server may need configuration settings for the cached file path, duration for expiring cached content, and a port for the caching proxy.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
