# Attribute Consistency in Chef

This proposal has two parts:

1. Normal level attributes should not be persisted. A new API should be
   added to address the persistence use case.
2. System attributes (a.k.a. automatic or ohai) should be accessed
    by a different API than other node attributes.

## Normal Attribute Persistence

### Issues

Persisting 'normal' level attributes creates a confusing, surprising
special case in attribute behavior, which makes documentation and best
practices more complicated.

This results in the following user pain points:
* learning chef attributes is more complicated, since documentation and
  recommendations are more complicated to understand.
* "Phantom" attributes. Users remove an attribute, or modify a
  complicated data structure, but their changes are mysteriously not
  applied because the normal attributes from a previous run are not
  cleared.
* Recipes that generate node data that needs to be persisted must call
  `node.save` manually, to ensure that persisted data is not lost in the
  event that the chef-client run subsequently fails. This causes issues
  with search data consistency, increased server load, and other
  problems.

The benefit of normal attributes persistence behavior is that they are
persisted, not that they are attributes. Common use cases include
storing data generated on the node (such as auto generated passwords) or
exposing a mechanism for triggering a different behavior in a cookbook
by changing a node attribute using the server API. These use cases would
be equally well served by having a completely separate API for
persisting node-specific data.

### Node Specific Persistent Data API Design

When considering the user-facing API for persistent node data, we should
consider the following factors:

* When are updates stored on the server? We could write the feature so
that any assignment of new data triggers a save, users save changes
manually, or changes are stored in bulk at the conclusion of a
chef-client run.
* Should there be any sort of conflict detection? This may be important
if simultaneous modification of data (by both chef-client and by a human
user via HTTP API) is prevalent.
* What does search look like?

#### Swag API

```ruby
#
# Note that these are thrown together in 2 minutes, so we expect we'd
# type up a bunch of possible syntaxes in our text editors and discuss
# which ones have the best tradeoffs.
#
node.storage.fetch(:namespace1, :namespace2, ...) # => value or nil

node.storage.set[:namespace1, :namespace2, ...] = value

node.storage.clear(:namespace1, :namespace1, ...)
```

The key point here  is that the `set` API uses a single method call, which
  allows for values to be saved immediately as part of the call to the
  `[]=(*keyspace, value)` method call.

#### Interaction with normal attributes

In order not to break backwards compatibility, persistent data API will not
  replace normal attributes. However in order to prevent users (both basic
  and advanced) we will have some notifications in place.

* Basic User using normal attributes without awareness

For this scenario we will have a warning on `node.set()` letting users know
  about the correct usage of normal attributes. This warning can look like:

```
WARNING: 'normal' attributes are mostly used incorrectly leading to problems
when they are removed from code in the future. If you are using
node.set('[:my][:attribute]') for persisting data on the node consider using
'node.storage.set()'. If you are using it to override default values, consider
using override options. For more information see:
https://www.getchef.com/docs/attribute_best_practices.html
```

* Advanced User using normal attributes for persisting data

The above warning message will also cover this scenario.

* Advanced User using normal attributes for override correctly

This set of users will be a small set however what they really need is for
  normal attributes not to be persisted. For them we will have below config
  option which will be `false` by default to maintain full backwards compat.
  Depending on the adoption of persistent node data API and usage behavior
  change of normal attributes, default can be changed in Chef 13 or later.

```ruby
# When set normal attributes are not persisted on the node anymore.
# Use node.storage() to persist node specific data when set.
Chef::Config[:disable_normal_attribute_persistance] = false
```

#### Backend Storage for persistence APIs

The design for the backend storage is still in the works. Here are some of the approaches we have in mind:

* Store data in a new field on the node object.
* Have one external node storage object per node, but it's a different item in the database. Think of it like per-node data bag items.
* Make each key individually readable/writeable at the server API layer. The server could store them as a big JSON blob or as individual rows in a database (this needs research obviously).
* Implement it on the client side utilizing data bags without any server changes.

## Separation of System Attributes

### Issues

Currently node attributes set by users (via cookbooks, etc.) share a
namespace with those collected by ohai. This is problematic for several
reasons:

* Since ohai's attributes have the highest precedence level, any time a
new attribute is added (for example, adding a new plugin to core ohai),
there is risk that it may stomp on attributes users were already using
for cookbooks. Luckily we haven't had any major bugs arise from this,
but one can get a feel for the risk involved by imagining an ohai plugin
began providing a 'mysql' attribute.
* It mixes actual with desired state. Attributes set by roles,
cookbooks, etc. are "aspirational"--they reflect what the node should
become. Ohai's attributes are "informational"--they reflect data
collected from the actual system at some point in time.
* It mixes user-controlled namespace with system controlled namespace.
This is a conceptual issue as well as a potential source of bugs as
described above.

### System Attributes API Design

The goal of the design is to have separate namespaces for the System
  Attributes that represent the current state and attributes that represent
  the desired state.

```ruby
# Gives the value of kernel/machine collected by ohai
node.current[:kernel][:machine]

# Gives the value of the apache/mods attribute after it's calculated
# based on existing Chef attribute calculation logic:
# http://docs.opscode.com/chef_overview_attributes.html
node.desired[:apache][:mods]
```

This way if one writes an ohai plugin that collects information about nginx
  they can write:

```ruby
node.desired[:nginx][:version] == node.current[:nginx][:version]
```

#### Access at the `node` namespace

One obvious question is what does the user get when accessing the data
  via `node`.

**We don't want to rewrite all the cookbooks in the world
  by breaking backwards compatibility therefore they will get the value of
  the attribute collected by ohai same as the existing logic.**

However to address the issue (3) mentioned above Chef will emit a warning as
  below when user is setting an attribute that is already collected by ohai.

```
WARNING: The value you are setting for [:kernel][:machine] will not be available
with 'node[:kernel][:machine]'since this is a system attribute. You can use
'node.desired[:kernel][:machine]' to access the value you are setting.
```

**Note:** Optionally this warning can be controlled with a config setting and
  can be turned off by users who write custom Ohai plugins and use `desired` &
  `current` states correctly. Long term we can consider turning this warning
  off by default if the community adopts this pattern.

#### Delegators for easy access

To reduce repetitive typing, we can introduce delegators for `desired` and
  `current` methods on node. Using these, you can access these values like:

```ruby
desired[:kernel][:machine]
current[:fqdn]
```

## Release Timing

By maintaining 100% backwards compatibility and without talking about
deprecation, here is the full list of changes:

* Node specific persistant data API.
* Warning messages when using normal attributes.
* Config option to turn off persisting normal attributes.
* [open] Backend storage for persistence API.
* `current` to alias `automatic` method on node.
* `desired` method on node that calculates attributes without automatic ones.
* Delegators for `current` and `desired`
* Warning to notify collisions between current & desired namespaces.
* [optional] Config option to turn off attributes best practices warnings.

Since backwards compatibility is maintained 100% we can do these changes in
  Chef 11.

However since this is a major feature, we might want to introduce
  the majority of it in Chef 12 especially considering the backend changes for
  persistence APIs.
