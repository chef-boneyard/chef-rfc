---
RFC: unassigned
Title: Attributes v2.7182818284
Author: Lamont Granquist <lamont@chef.io>
Status: Draft
Type: <Standards Track>
---

# Title

Description and rationale.

## Motivation

    As a Chef User,
    I want Attributes to be Less Confusing.

    As a Chef User,
    I dislike NoMethodError for NilClass Errors.

    As a Chef Developer,
    The monolithic Node attributes API tries to do too much with a shared namespace.

    As a Maintainer of Existing Cookbooks,
    I need a slow and backwards compatibile transition to any new API.

    As a Ohai Plugin Developer,
    I want to be able to add ohai attributes without clobbering someone's cookbook attributes.

## Overall Design

Migration Strategy:

- Existing APIs remain unchanged
- Deprecation warnings will be emitted for edge cases where the APIs differ
- Ater fixing the deprecation warnings, autofixing from the old APIs to the new APIs should be possible

Three Separated Namespaces:

- Ohai attributes
- Default and override attributes
- Normal/storage attributes

Deprecated Behavior:

- Array deep merging is removed (must be manually replaced with hash-key merging)
- Deep merging of normal values with default and override is removed (users who were incorrectly using normal
  as a third precedence level will need to manually fix)
- Deep merging of automatic values with default/normal/override is removed (this is likely just namespace
  collision mistakes and stright-up bugs?)
- The force_default/force_override levels are now the standard behavior of setting attributes in recipe code, the
  "force" behavior becomes the standard behavior.
- Environment files consistently have a higher priority / later merge order than roles.

Merged Precedence Levels Before:

| level | lowest  |  | | highest |
| ---- | ------ | ------ | ---- | ---- |
| default       | attribute | recipe | environment | role |
| force_default | attribute | recipe | | |
| normal | attribute | recipe | | |
| override | attribute | recipe | role | environment |
| force_override | attribute | recipe | | |
| automatic| node |

Merged Precedence Levels After:

| level | lowest  |  | | highest |
| ---- | ------ | ------ | ---- | ---- |
| default       | attribute | role | environment | recipe
| override | attribute | role | environment | recipe

## New Syntax for Ohai Attributes

A new sugar for ohai attributes will be introduced:

```ruby
ohai("platform")
ohai("cloud_v2", "public_ipv4_addrs", 0)
```

This will literally be sugar for the `node.automatic.read("platform")` API that has already been
shipped.

Write access to ohai data will continue through the existing `node.automatic` API.  In a future RFC
that will be replaced.

## New Syntax for Merged Default and Override Attributes

```ruby
attr("foo", "bar", "baz")
```

This is a reader-only that only reads values merged from default and override levels, with hash-only merging.

It is not intended to be identical to the existing `node["foo"]["bar"]["baz"]` although once deprecation warnings
against the node object are fixed (see below) they should converge to the same semantics.

The order of merging of the hashes will be:

- default (attribute files)
- role_default
- env_default
- force_default (recipe files)
- override (attribute files)
- role_override
- env_override
- force_override (recipe files)

Note (below) that attributes written in recipe files will go into the force_default/force_override hashes and will not
mix with the default/override hashes written in attribute files.  Also note that env_default and role_default have been
swapped for consistency (the ordering will consistently be attributes/roles/environments/recipes).

# New Syntax for Accessing Default and Override Levels

The writer uses `default_set` and `override_set` while the reader uses simply `default` and `override`.

```ruby
default_set("foo", "bar", "baz").to("quux")
default_set("foo", "bar") do |n|
  n["baz"] = "quux"
end
default("foo", "bar", "baz")
```

In attribute files default and override will be applied to the default and override VividMashes (lowest priority).

In recipe files default and override will be applied to the `force_default` and `force_override` VividMashes.  Setting
default-level attributes in recipe code will not be supported by the new API.

## New Syntax for Normal Attributes

Since normal attributes have different semantics they will be changed to use `store` and will not deep merge with anything:

```ruby
store_set("wordpress", "passwd").to("sekret1")
store_set("wordpress") do |s|
  s["passwd"] = "sekret1"
end
store("wordpress", "passwd")
```

## Note on why the New Syntax has split setter/getters

It isn't possible to have a fused setter/getter and to use method chaining.  This API does not work with ruby:

```
default("foo", "bar", "baz").to("quux")
default("foo", "bar", "baz")
 => "quux"
```

The problem is going to be values like nil and false which would need to be wrapped to implement `#to` methods in
a decorator to allow writing which would be a truthy return value for the getter and not falsey.

## Removal of Method Missing Syntax

A deprecation warning for method missing syntax access to the node attribute has already been added
to Chef 12.  In Chef 13, method missing syntax will result in NoMethodError.

## Deprecation of Array Merging

Before the node.save the chef-client will walk the node object and warn on any array objects that are
being merged with array merging.  Users who are actually using array merging will be encourage to replace
array merging with hash keys instead.

## Deprecation of Deep Merging with Normal Attributes

Before the node.save the chef-client will walk the node object and warn on any normal attribute which
also have default, override or automatic attributes set and are being merged.

## Deprecation of Deep Merging with Automatic Attributes

Before the node.save the chef-client will walk the node object and warn on any automatic attribute which
also have default, normal or override attributes set and are being merged.

## Deprecation of role_default overriding env_default

Before the node.save the chef-client will walk the node object and warn on any env_default attribute which
also has a role_default attribute set and are being merged.

## Deprecate Access to Automatic Attributes to the Node Object

Rubocop rules will be added to cookstyle to warn when common automatic node attributes are being accessed
through (e.g.) `node["platform"]` and will have an autofix rule to change them to (e.g.) `ohai("platform")`.

On access the chef-client will issue deprecation warnings to any access to automatic attributes through the
deep-merged view of the node object.

## Deprecate Access to Normal Attributes to the Node Object

Rubocop rules will be added to cookstyle to warn when common automatic node attributes are being accessed
through (e.g.) `node["wordpress"]["passwd"]` and will have an autofix rule to change them to (e.g.)
`store("wordpress", "passwd")`.

On access the chef-client will issue deprecation warnings to any access to normal attributes through the
deep-merged view of the node object.

## Future:  Deprecate Access to Attributes Through the Node Object

In Chef > 13 access to default and override objects through the node object APIs will be deprecated completely
in favor of the new APIs.

## NOTE: Favoring Strings Over Symbols

Symbols as keys or values will not be deprecated, however, canonically the preferred syntax will
be strings.  The internal representation of attributes will remain VividMash (autovivifying and
converting-to-strings).

## NOTE: Favoring Splat-Argument Syntax over Bracket Method Chaining

Attribute APIs will favor splat-args syntax over method chaining because of the trainwreck issues that
method chaining produces, which inevitably leads to the "NoMethodError on NilClass" error messages that
are deeply tied to the ruby language.  The root cause being that all user created objects in the ruby
language are truthy and that nil and false are the only objects which can be false and we cannot construct
wrapper objects which are falsey.  As a result in order to give useful error messages, we need to call
a method which is passed the entire path the user is requesting, and cannot support method chaining.

We will favor this shape:

```ruby
something("foo, "bar", "baz")
```

Over this shape:

```ruby
something["foo"]["bar"]["baz"]
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
