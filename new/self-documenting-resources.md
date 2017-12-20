---
RFC: unassigned
Title: Self Documenting Resources
Author: Tim Smith <tsmith@chef.io>
Status: Draft
Type: Standards Track
---

# Self Documenting Resources

Chef has allowed organizations to embrace infrastructure as code, but with codified infrastructure comes the need for accurate documentation for that codebase. This RFC aims to improve the ability to document resources within Chef code so that we can ensure documentation is accurate and automatically generated. This is applicable to both resources within chef-client and those which ship in cookbooks.

## Motivation

```
As an author of custom resources,
I want to manage code and documentation in a single location
so that I can have up to date documentation with minimal work

As a maintainer of chef
I want docs to automatically update when new chef-client releases are made
so that manual release steps and mistakes can be reduced

As a consumer of custom resources
I want accurate and up to date documentation
so that I can easily write cookbooks utilizing custom resources
```

## Specification

We will introduce 4 new methods in custom resources in order to implement this RFC:

### description (resource level)

Description is a String value that allows the user to describe the resource and its functionality. This information would be similar to what you would expect to find in a readme or the Chef Docs site describing the usage of a resource.

### introduced (resource level)

Introduced is a String value that documents when the resource was introduced. In a cookbook this would be a particular cookbook release. In the chef-client itself this would be a chef-client release.

### examples (resource level)

Examples is a String value containing examples for how to use the resource. This allows the author to show and describe various ways the resource can be used.

### description (property level)

Description is a String value that documents the usage of the individual property. Useful information here would be allowed values, validation regexes, or input coercions.

### description (action level)

Description is a String that describes the functionality of the action.

## Example

```ruby
description 'The apparmor_policy resource is used to add or remove policy files from a cookbook file'

introduced '14.1'

property :source_cookbook,
         String,
         description: 'The cookbook to source the policy file from'
property :source_filename,
         String,
         description: 'The name of the source file if it differs from the apparmor.d file being created'

action :add do
  description 'Adds an apparmor policy'

  cookbook_file "/etc/apparmor.d/#{new_resource.name}" do
    cookbook new_resource.source_cookbook if new_resource.source_cookbook
    source new_resource.source_filename if new_resource.source_filename
    owner 'root'
    group 'root'
    mode '0644'
    notifies :reload, 'service[apparmor]', :immediately
  end

  service 'apparmor' do
    supports status: true, restart: true, reload: true
    action [:nothing]
  end
end
```

## Downstream Impact

The implementation of this RFC will enable the automatic generation of docs at docs.chef.io.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0\. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
