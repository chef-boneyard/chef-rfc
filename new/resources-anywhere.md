---
RFC: unassigned
Author: John Keiser <john@johnkeiser.com>
Status: Draft
Type: Standards Track
---

# Allow Resources In Any Namespace, Remove Method Missing

This proposal addresses:
- Allowing users to place Chef resources and providers anywhere in their tree, not just `Chef::Resource` and `Chef::Provider`
- Eliminating the issue where resource and provider code that tries to access `File.x` actually get the File resource, having to type `::File` instead to get what they want.
- Eliminating `method_missing` as a way to look up resources, in favor of explicit DSL (which gets rid of a great deal of confusing error message).

## Motivation

    As a <<user_profile>>,
    I want to <<functionality>>,
    so that <<benefit>>.

## Specification

### Resources outside of `Chef::Resource`

Users who wish to register a resource named `my_resource` can presently do it by creating a class inside the `Chef::Resource` namespace and another in `Chef::Provider`.  Chef then uses magical namespace lookups to

```ruby
# chef/resource/
class Chef::Resource::MyResource < Chef::Resource
end
```

With this proposal, the above will still work; but users can now create resources outside of Chef::Resource with the following classes:

```ruby
class MyResource < Chef::Resource
  ...
  class Provider < Chef::Provider
    ...
  end
end
```

The mechanism is:
- An `inherited` hook on `Chef::Resource` automatically takes care of hooking up `MyResource` to all recipe DSL when the class is created.
- The provider lookup for a resource looks first for a `Provider` class inside the Resource before moving on to other things.

### Accessing `File`

Accessing top-level objects like `File` are one of the big reasons for this proposal.  Anything that extends from `Chef::Resource` *will* look up `Chef::Resource::X` before `::X` when a method types `X`.

To fix this, we will move resources and providers in `Chef::Provider::*` and `Chef::Resource::*` into `Chef::Resources` (and use the inline syntax as well).  For addressing the obvious concerns, see the Errors and Deprecations section.

### Removing `method_missing`

Presently, when you type `my_resource` in the DSL, there is no actual method by that name; we intercept `method_missing`, perform a string transformation on the method name to get `MyResource`, and then try to get the `Chef::Resource::MyResource` class.  This causes confusing stack traces when the resource cannot be looked up, and is significantly more difficult to read.

In this new world, a `Chef::Resources.my_resource` method is created, and `Chef::Resources` is mixed into the recipe DSL, so there is a real method.  `method_missing` never gets involved.  The methods generated look like this:

```ruby
def my_resource(name, created_at=nil, &block)
  created_at ||= caller[0]
  declare_resource(:my_resource, name, created_at, ::MyResource, &block)
end
```

NOTE: This does not remove *all* of method_missing; in particular, we need to make definitions do something similar.  Add that to the proposal.

### Declaring a Provider inline (Also Single-File Resources)

In order to create a Resource, you must have a corresponding Provider.  The current algorithm takes `Chef::Resource::MyResource`, lops off `Chef::Resource::` entirely, and prepends `Chef::Provider::`.  This is The new algorithm will first look for a `Chef::Resource::MyResource::Provider` class, so that declaring the provider for a class will look like this for most people:

```ruby
class MyResource < Chef::Resource
  ...

  class Provider < Chef::Provider
    ...
  end
end
```

This has several nice benefits:
- Supports the goal of resources outside of `Chef::Resource`.
- Encourages the creation of providers in the same file as the resource.
- An absolute minimum of extra typing when linking a resource to a provider.

### Creating a non-DSL resource

Some users create base resources and .  This can be accomplished by calling `chef_recipe_dsl false` in the class, which will undef the DSL for it:

```ruby
class SuperAwesomeBaseResource < Chef::Resource
  chef_recipe_dsl false

  ...
end
```

### Creating a DSL resource with a different name

Sometimes the name of your class isn't the name that you need.  In that case, you can change the DSL with `chef_recipe_dsl`.

```ruby
class SuperMountPointResource < Chef::Resource
  chef_recipe_dsl name: 'mount_point'
end
```

This will remove the `super_mount_point_resource` DSL and add `mount_point` as DSL.

### Single File LWRPs

Since HWRPs are now easily declared in a single file, it would be macabre of us not to allow single file LWRPs as well.  We propose two new syntaxes in LWRP resources to enable this:

1. `action :create do ... end` (in the resource)
   - Creates a Provider class extending LWRPBase if it does not already exist.
   - Sets `use_inline_resources` to true if not explicitly set.
   - Adds `:create` to `allowed_actions` on the resource.
   - Calls `action :create do ... end` on the Provider class.

NOTE: this does not address `load_current_resource`, as there are other proposals brewing that may address that in other ways.  Users can open up the provider class with `class Provider < Chef::Provider::LWRPBase` if they need to implement this.

### Backwards Compatibility and Deprecation

Backwards compatibility is king.

- All things that currently work in Chef 12 must continue to work in Chef 12.
- 99.99% of things that currently work in Chef 12, must continue to work in Chef 13.
- As much as possible should work in 12.X, so that people in Chef 12 have a story when we move to 13 and so people can begin converting now.

#### Accessing `Chef::Resource::File` or `Chef::Provider::File` directly

In Chef 13, core resources are simply moving out of the Resource and Provider namespaces.  However, in Chef 12, there will be resources and providers who extend from them or construct them directly.

In Chef 12, we will create classes in `Chef::Resource` extending from the real Resources which emit a deprecation warning on initialize or subclassing (`class Chef::Resource::File < Chef::Resources::File ...`).

#### Accessing `File` from a resource or provider method

Right now, when you type `File` in any resource or provider it always refers to `Chef::Resource::File` or `Chef::Provider::File`.  In Chef 13, it will refer to `::File`.

The deprecation warnings for `Chef::Resource::File` suffice for Chef 12 deprecation purposes.

Now for the reverse compatibility part: we want `File` to work.  We will allow anyone who declares a resource *outside* of Chef to type `File` normally by including Chef::Resource::TopLevelConstants directly into their resource.  Whenever a resource is created in `Chef::Resource`, we will check if there is a top level constant with the same name, and add it.  Since only resources *outside* of `Chef::Resource` get this included, anything inside `Chef::Resource` will still refer to the original thing.

LWRPs created via `resources/x.rb` in a cookbook are also exempt from `TopLevelConstants`.

#### Name Conflicts

Resources can try to take the same name in recipe DSL (such as when two cookbooks both implement a similar thing).  Fact of life.  Presently when two custom resources try to take the same name, presently they will do one of two unsatisfactory things:

- Raise a confusing "subclassing the wrong class" error on load; or
- Silently overwrite and merge with one another, with the last one winning

Now, when you are in separate namespaces, the first thing simply won't happen.

We will avoid the second thing by checking whether the method `my_resource` is already defined, and if it is, we

#### Replaced Classes

It is possible to replace a class in Ruby (you can simply go assign ).  Due to the way this is implemented, the new class will in fact be used (which is sort of what a user would expect).  However, it's janky and something we'd like to warn about.  When the user attempts to use the resource (by typing `my_resource`), we will check in `build_resource` that the class has not changed from what was originally registered, and emit a warning that the class isn't what we expect and that they should contact the author of the new class to get the warning fixed.

To *legitimately* do this, you should use `chef_recipe_dsl` instead.

#### `resources` conflicts between cookbooks

Cookbooks will now be given an official namespace, `Chef::LoadedCookbooks::NAME`, to place things in.  Resources in `resources/x.rb` (and providers in ) will be created in that namespace to avoid these conflicts.  Constant access will remain the same (since superclasses are in the constant lookup chain).

Accessing such resources directly via `Chef::Resource` is deprecated.  For backwards compatibility, these resources will also be aliased into `Chef::Resource` in Chef 12, with a deprecation warning for people who subclass or initialize from that location.

#### `require 'chef/resource/file'`

As the resources are moving, *requires* are also moving.  In Chef 12, we will emit a deprecation warning when you require 'chef/resource/x' instead of 'chef/resources/x', but it will still work.

#### Redefining `dsl_name`

Redefining `dsl_name` is deprecated and will not work in 13.  In Chef 12, the base `Chef::Resource` will include a `method_defined` hook that lets us detect this, cause the DSL to change, and emit a warning.

#### Creating anonymous resource classes

This procedure: `Chef::Resource::MyResource = Class.new(Chef::Resource) { ... }` could be used to create a resource currently and `my_resource` would work fine in recipes.  In Chef 13, that will no longer work, because we don't do anything magical for `Chef::Resource`.  In Chef 12, we will still check for `Chef::Resource::MyResource` when `method_missing(:my_resource)` is called, and if it is found, will return it and emit a deprecation warning.

#### Directly calling `method_missing`

Users who call `method_missing` directly (or override it and call super) with class names will break in Chef 13.  We will emit a deprecation warning in Chef 12 if `method_missing` is ever called for a method that is actually on the class.

#### resource_name = 'something_else'

Redefining the base DSL name in an LWRP subclass is deprecated and will not work with 13.  In 12, we catch it, emit a warning and change the DSL.

### Risks To Specific Software

While we're trying to maintain full compatibility, there's risk here, particularly for people doing metaprogramming of resources.  We will run the tests of the following packages, and make sure current versions
still work (possibly emitting deprecation warnings):

- chef-sugar
- chefspec
- chef-rewind
- Poise
- Crazytown

### Risk Management

chef-sugar, poise, berkshelf and the resource cookbook tests will all be run (and fixed, if necessary) prior to any checkin.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
