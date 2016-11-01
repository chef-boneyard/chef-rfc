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
    I dislike NoMethodError for NilClass Errors,
    Because those are confusing and unhelpful.

    As a Chef Developer,
    The monolithic Node attributes API tries to do too much.

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

# New Syntax for Accessing Default and Override Levels

The writer uses `default_set` and `override_set` while the reader uses simply `default` and `override`.

```ruby
default_set("foo", "bar", "baz").to("quux")
default_set("foo", "bar") do |n|
  n["baz"] = "quux"
end
default("foo", "bar", "baz")
```

## New Syntax for Normal Attributes

Since normal attributes have different semantics they will be changed to use `store` and will not deep merge with anything:

```ruby
store_set("wordpress", "passwd").to("sekret1")
store("wordpress", "passwd")
```

## Removal of Method Missing Syntax

A deprecation warning for method missing syntax access to the node attribute has already been added
to Chef 12.  In Chef 13, method missing syntax will result in NoMethodError.

## Deprecation of Array Merging

Before the node.save the chef-client will walk the node object and warn on any array objects that are
being merged with array merging.  Users who are actually using array merging will be encourage to replace
array merging with hash keys instead.

## Deprecation of Deep Merging with Normal Attributes

Before the node.save the chef-client will walk the node object and warn on any normal attribute which
also have default, override or automatic attributes set and are being merged.  In a future major release this
deep merging will be removed.

## Deprecation of Deep Merging with Automatic Attributes

Before the node.save the chef-client will walk the node object and warn on any automatic attribute which
also have default, normal or override attributes set and are being merged.  In a future major release this
deep merging will be removed.

## Deprecate Access to Automatic Attributes to the Node Object

Rubocop rules will be added to cookstyle to warn when common automatic node attributes are being accessed
through (e.g.) `node["platform"]` and will have an autofix rule to change them to (e.g.) `ohai("platform")`.

On access the chef-client will issue deprecation warnings to any access to the node object through the
deep-merged view of the node object.

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
