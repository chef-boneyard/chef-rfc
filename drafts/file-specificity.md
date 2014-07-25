---
RFC:
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Standards Track
Chef-Version: 12
---

# File Specificity Overhaul

The file specificity system allows overriding templates and cookbook files on
a per-platform or per-host basis. It is used relatively infrequently, but can
be invaluable when it is used. Unfortunately it adds significant mental overhead
to new users that don't understand the meaning of the `default/` folder. It is
also relatively inflexible, the lookup path is fixed to use the node name and
platform information. This can be improved on both counts, simplifying the
default case as well as improving flexibility for cases when it is needed.

## Specification

The current file specificity lookup process is governed by two things, the
lookup path and the source attribute. The current lookup path is:

1. `/host-$fqdn/$source`
1. `/$platform-$platform_version/$source`
1. `/$platform/$source`
1. `/default/$source`

The first of these paths that exists is used, or an error is raised in none
exist.

The revised default lookup path would add `/` to the end:

1. `/host-$fqdn/$source`
1. `/$platform-$platform_version/$source`
1. `/$platform/$source`
1. `/default/$source`
1. `/$source`

If the source attribute is given as an array, this will be used instead of the
default lookup path.

In a future release such as Chef 13, the default lookup path can be removed in
favor of explicit specification of a lookup path when needed.

## Motivation

The motivation for this change is two-fold; to reduce the difficulty of creating
a cookbook and improving flexibility for conditional file selection. The first
goal is addressed by removing the need for the `default/` folder when adding
templates and cookbook files. This is currently a stumbling block for new users
that don't yet know about the file specificity system and don't need the
features it provides.

The latter goal is addressed by adding support for an explicit lookup path by
giving an array for the source attribute:

```ruby
template '/test' do
  source ["#{node.chef_environment}.erb", 'default.erb']
end
```

This allows for far more flexibility in file selection while reducing the magic
of the default lookup path.

## Compatibility

This change is effectively backwards compatible. It is possible some recipe code
which currently results in an error will now converge successfully, but the
impact of this is likely to be infinitesimal. By keeping the default lookup path
for now, full compatibility with current cookbooks is maintained. The removal of
the current default lookup path in a future release will be an incompatible
change, and should have a long deprecation period.

## Copyright

To the extent possible under law, the person who associated CC0 with this work
has waived all copyright and related or neighboring rights to this work.
