---
RFC: 16
Author: Joshua Timberman <joshua@chef.io>
Status: Accepted
Type: Standards Track
Chef-Version: 12
Title: Make Homebrew OS X's Default Package Provider
---

# Make Homebrew OS X's Default Package Provider

[Homebrew](http://brew.sh) is a very popular source-compile based package manager for OS X. A [cookbook](https://supermarket.chef.io/cookbooks/homebrew) providing a homebrew as the OS X default provider for Chef's package resource has existed for years. Currently in Chef, the default package provider on `mac_os_x` platforms is [Macports](http://www.macports.org/). Since the cookbook makes homebrew the default in a `libraries` file, it is automatically loaded and present on any node that has the homebrew cookbook downloaded as a dependency, even if they're not using it. Many users may not even be aware that macports is the Chef default.

## Specification

`Chef::Provider::Package::Macports` is the default for platforms `mac_os_x` and `mac_os_x_server` in Chef's [platform provider mapping](https://github.com/chef/chef/blob/master/lib/chef/platform/provider_mapping.rb).

```ruby
:mac_os_x => {
  :default => {
    :package => Chef::Provider::Package::Macports,
  }
},
:mac_os_x_server => {
  :default => {
    :package => Chef::Provider::Package::Macports,
  }
}
```

This RFC proposes to change this to:

```ruby
:mac_os_x => {
  :default => {
    :package => Chef::Provider::Package::Homebrew,
  }
},
:mac_os_x_server => {
  :default => {
    :package => Chef::Provider::Package::Homebrew,
  }
}
```

It would largely leverage the code in the homebrew cookbook's `homebrew_package.rb` [libraries](https://github.com/chef-cookbooks/homebrew/blob/master/libraries/homebrew_package.rb). We would probably need to clean some things up and modernize it to better fit with the rest of the Chef core package providers, and we would definitely need to have tests added.

Macports would still remain in Chef as an alternative for those who use it, and it could be set as default similar to what the homebrew cookbook does now, in its [own cookbook](https://supermarket/chef.io/cookbooks/macports).

## Motivation

The motivation for this change is to modernize the "sane defaults" that Chef provides as primitives. When Chef was created, Homebrew didn't exist - Macports was the "de facto" way to install software packages from source "ports-style." Ticket [CHEF-1250](https://tickets.opscode.com/browse/CHEF-1250) was opened four years ago proposing homebrew as the package provider, so interest in this has existed for a long time. The general developer community that uses OS X seems to have rallied around Homebrew (680+ watchers, 18,500+ stars, 9000+ forks on its GitHub repo) to provide this functionality. It is very comprehensive (over 2900 packages), and reuses the system libraries that OS X provides so users don't have to compile the entire world to install software.

## Rationale

Issue #28 was opened to briefly propose this change and within a week received an overwhelming ":+1" from respondents. So far I haven't found many people that are still using Macports instead of Homebrew, and no one has mentioned anything in the issue or on the mailing list.

## Compatibility

This is a backwards-incompatible change for cookbooks for users who rely on using the Macports provider. All users who have the `homebrew` cookbook already use it for the default package provider. Recipe code in cookbooks that `depends "homebrew"` won't need to be changed at all. Users will still need to have a recipe that installs Homebrew itself. This is no different than `macports` itself, which isn't installed on OS X by default either, and needs its own cookbook.

## Reference Implementation

The `homebrew` cookbook maintained by CHEF is the reference implementation. It lacks tests, but those would be added as mentioned above.

## Copyright

The code to implement this feature will come directly from CHEF's homebrew cookbook. It was originally written by Graeme Mathieson, and was licensed under the [Apache 2.0 Software License](https://github.com/chef-cookbooks/homebrew/blob/49936df5fd8cc6610262621b3c41c1e3bcbb9c62/metadata.rb#L3). The current copyrights listed in the cookbook are:

- Copyright 2011, Graeme Mathieson <mathie@woss.name>
- Copyright 2011-2013, Opscode, Inc. <legal@opscode.com>
- Copyright 2014, Chef Software, Inc <legal@chef.io>
