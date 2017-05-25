---
RFC: unassigned
Author: Sean OMeara <sean@chef.io>
Status: Draft
Type: <Standards Track, Informational, Process>
---

# Title

Move the resources from the yum cookbook into core Chef

## Motivation

As the author of a widely used Chef resource that is currently
distributed as a cookbook (yum), I want to add those resources to core
Chef, so that the friction required to use them is reduced.

This is meant to be an experiment that will open the door to adding
more resources from the Cookbook ecosystem into Chef.

## Specification

Add the following classes to Chef:

Chef::Resource::YumRepository
Chef::Provider::YumRepository

Chef::Resource::YumGlobalConfig
Chef::Provider::YumGlobalConfig

https://github.com/chef-cookbooks/yum/blob/master/resources/repository.rb
https://github.com/chef-cookbooks/yum/blob/master/providers/repository.rb
https://github.com/chef-cookbooks/yum/blob/master/resources/globalconfig.rb
https://github.com/chef-cookbooks/yum/blob/master/providers/globalconfig.rb

## Rationale
There are some "core" cookbooks that many people use, even if they are
not generally a consumer of Community Cookbooks. The best of these
ship resources rather than recipes. After a period of stability and
wide scale usage, it makes sense to move these resource types into
Chef core.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
