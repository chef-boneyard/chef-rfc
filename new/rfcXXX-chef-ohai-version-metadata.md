---
RFC: unassigned
Author: Jon Cowie (jcowie@etsy.com)
Status: Draft
Type: Standards Track
---


# Add chef_version and ohai_version fields to cookbook metadata

Increasingly, as momentum on Chef development continues to grow, it is necessary to release modifications to the recipe DSL or core resources which can result in backwards incompatible cookbook code that may result in cookbooks using those features breaking under old versions of chef-client. Further, it is often necessary to make these changes in minor chef-client releases rather than waiting multiple months for the next major release cycle. There is currently no way to surface this version requirement to Chef users.

This RFC proposes the addition of the "chef_version" and "ohai_version" fields to cookbook metadata to indicate the required versions of chef-client and ohai needed to run that cookbook. 

## Motivation

As a user of chef, I want to be able to easily determine if a specific cookbook uses any features not supported by my version of chef-client or ohai, so that I don't have to diagnose mysterious errors during a chef run.

## Specification

This change would require adding two additional fields to the supported list of cookbook metadata fields. These fields will be called "chef_version" and "ohai_version"

This change would potentially break backwards compatibility for older versions of chef-client which would not expect the presence of that field, but I propose that the benefit gained from easily being able to surface chef-client and ohai version requirements to cookbook users in all future versions makes this worthwhile. It may also be possible to implement the addition of these fields in a backwards compatible manner.

During a chef-client run, it will check these fields in all cookbooks against the currently running version of chef-client and ohai. In the event that a version requirement is not satisfied at any level of the dependency tree, the Chef run will fail with a meaningful error, for example:

```FATAL: Cookbook 'apache' depends on chef-client version >= 12.0.4, but the running chef-client version is 12.0.3. Exiting.```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.