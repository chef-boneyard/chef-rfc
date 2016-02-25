---
RFC: unassigned
Author: Nell Shamrell-Harrington <nshamrell@chef.io>
Status: Draft
Type: Process
<Replaces: RFCxxx>
<Tracking:>
<  - https://github.com/chef/chef/issues/X>
---

# Title

Cookbook and Cookbook Version Yanking Policy

## Motivation

As a Supermarket User

When I download an artifact from Supermarket

And I depend on that artifact

I do NOT want that artifact to be removed from Supermarket

As a artifact author or collaborator

When I upload a bad version of an artifact to Supermarket

I want a way to hide it from the Supermarket UI

And from the /universe endpoint

## Specification

Currently, a Supermarket artifact author cannot remove a cookbook version from Supermarket without contacting the Supermarket admins.

A cookbook author CAN remove a cookbook completely from Supermarket.

The problem is when another user is depending on a cookbook version (or other future Supermarket artifact) and it is removed from Supermarket, that user's Chef setups could break.  Additionally, if someone were to accidentally upload security credentials (as happens from time to time with uploads to Supermarket) and yank the cookbook or cookbook version from Supermarket, it could provide a false sense of security.  Once a cookbook version has been uploaded to Supermarket, it can be downloaded or copied within seconds.  It is far better to invalidate the security credentials.

Here's my proposal:

When a user unshares a cookbook from Supermarket (such as through $knife cookbook site unshare), Supermarket will assign the cookbook version a flag

When a cookbook version has that flag, it will be hidden from both the Supermarket UI and the /universe endpoint

It will not, however, be completely deleted from the Supermarket artifact store.

If someone depends on the cookbook version, they will still be able to download and access it

But it will be harder for a new user of the cookbook version to find the unshared version.

## Downstream Impact

Ideally this would not affect Berkshelf...but it must be tested thoroughly before deployment.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
