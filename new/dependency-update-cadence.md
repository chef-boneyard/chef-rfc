---
RFC: unassigned
Title: Dependency Update Cadence
Author: 
 - Lamont Granquist <lamont@chef.io> 
 - Jennifer Davis <sigje@chef.io>
Status: Draft
Type: Process
---

# Dependency Update Cadence

This RFC describes the Ruby, Cookbook and Ecosystem support cadence as an addendum to the [Chef OSS project versioning and release policies.](https://chef.github.io/chef-rfc/rfc086-chef-oss-project-policies.html) and the [cookbook release process](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/RELEASE_PROCESS.MD).

## Motivation

    As a person who writes and shares community cookbooks, 
    I want to drop old support for old client versions and use new client versions,
    so that cookbook complexity can be reduced.

    As a person who writes and shares community cookbooks,
    I want to drop support for old versions of the Ruby language,
    so that I don't have to support ruby versions that are no longer supported by the ruby community.

    As a person who uses community cookbooks in my own recipes, 
    I want to know the policy for cookbook support,
    so I can understand the impact of delaying updating underlying dependencies.

## Specification

### Cookbook and Ecosystem Tooling Support

Chef-managed community cookbooks should support at least the last 6 months of [Chef Client](https://github.com/chef/chef/blob/master/CHANGELOG.md) versions. After 6 months, Chef-managed community cookbooks may
elect to drop support for older Chef Client versions. This window does not reset on
a major version release so that the prior major version track is supported for a 6 month window. Non-Chef-managed community cookbooks are encouraged to follow this policy.

As an example, based on the [Chef OSS project versioning and release policies](https://chef.github.io/chef-rfc/rfc086-chef-oss-project-policies.html), in May if we release Chef Client 14.1.0, both 14.0 and 14.1 will be
supported.  The version of 13 release 6 months prior should be 13.8 and will still
be supported so that 6 versions will be considered current (13.8 through 13.11 plus
14.0 and 14.1).  At that point community cookbooks may choose to start using 13.8
features and drop support for versions prior to 13.7.

Tooling external to cookbooks (cookstyle, chefspec, stove, foodcritic, halite,
poise-hoist, etc) is similarly encouraged to follow this policy.

### Ruby Cadence

Since the Ruby language itself releases new minor versions over the Christmas holidays, the April major release of Chef Client should include the minor revision of Ruby which landed the prior Christmas.  Combined with the 6 month sliding window for cookbook support that also implies that when the prior major release of the client falls off of community cookbook support that the prior minor release of Ruby will also fall off of community cookbook support (including the cookstyle gem and related tooling).

The release of the new major version may be delayed if there are show stopping bugs
in the released version of Ruby. We assume that 4 months will be enough time for
major regressions in the core language to be addressed, but that is an external
dependency.

If the Ruby language version released over Christmas has a show-stopper bug then the
next major Chef Client version may be released without it.  It can then be included
in a subsequent minor version bump.  This RFC deliberately uses 'should' instead of
'must', and [RFC-034](https://github.com/chef/chef-rfc/blob/b7bd9c53bf96235f9334e65bb5848f7843c81fed/rfc034-ruby-193-eol.md#specification)
allows for a minor version bump of Ruby with a minor version
bump of Chef Client.  Show stoppers in Ruby itself will not hold up major releases
of Chef Client, and missing the major release window will not hold up bumping the
Ruby version.

### Operating System Versions

Each cookbook will define supported platforms along with version constraints through the use of the `supports` keyword in the metadata and README files within the cookbook. 

Chef-managed community cookbooks should drop support for platform versions that are no longer supported by the platform maintainers. 

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.