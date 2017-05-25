---
RFC: unassigned
Author: Thom May <tmay@chef.io>
Status: Draft
Type: Standards Track
---

# Add a resource to manage package repositories

Provide a core resource to allow a user to add a package repository to
their system.

## Motivation

    As a cookbook author,
    I want to write cookbooks that rely only on core resources,
    so that I can minimise my dependencies.

## Specification

Create a new `package_repo` resource, similar to 
```
package_repo "foo" do
  description "A descriptive string"
  base_url "https://some/url"
  gpgkey "https://some/other/url"
end
```
Providers are free to add additional platform specific attributes, but
must attempt to standardize where practical.

## Rationale

Currently, to add a package repository in a cookbook, one must depend on
the relevant cookbook for that repository type. Supporting multiple
package types greatly increases the dependency footprint of a cookbook,
whilst simultaneously requiring the author learn the details of many
disparate resources.

ie, the `yum` cookbook provides the `yum_repository` resource
```
yum_repository 'zenoss' do
  description "Zenoss Stable repo"
  baseurl "http://dev.zenoss.com/yum/stable/"
  gpgkey 'http://dev.zenoss.com/yum/RPM-GPG-KEY-zenoss'
  action :create
end
```
while the `apt` cookbook provides the following
```
apt_repository 'cloudera' do
  uri          'http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh'
  arch         'amd64'
  distribution 'precise-cdh4'
  components   ['contrib']
  key          'http://archive.cloudera.com/debian/archive.key'
end
```

Providing a single `package_repo` resource with standardised
attribute naming would decrease the cognitive burden of writing cross
platform cookbooks

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.


