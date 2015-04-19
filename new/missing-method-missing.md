---
RFC: unassigned
Author: John Keiser <john@johnkeiser.com>
Status: Draft
Type: Standards Track
---

# Remove magic and method_missing from Chef::Resource lookup

This proposal:

- Switches to explicit methods for Chef recipe DSL instead of method_missing
- Removes all special treatment of classes in the Chef::Resource and Chef::Provider namespaces
- Automatically adds resource DSL for all named descendants of Chef::Resource, no matter what their namespace

## Compatibility

In Chef 12, three behavior changes will be noted:

- Stack traces for resource declarations will usually no longer contain
  `method_missing` (and will instead contain the name of the resources).
- Classes outside of the Chef::Resource namespace will now be placed in recipe
  DSL automatically.
- Warnings are issued for deprecated behavior that will change in Chef 13 (see
  Deprecations section).

In Chef 13, deprecated behavior will be removed (along with method_missing).  All
of these have deprecation warnings enabled for Chef 12 (see Deprecations section).

## Motivation

    As a Chef user,
    I want resources declared in my own namespace to be in recipe DSL automatically,
    so that I don't have to write the name of the resource twice.

    As a Chef user,
    I want to declare resources in my own namespace,
    So that I get better error messages when there is a resource conflict.

    As a Chef developer,
    I want meaningful names in stack traces for methods,
    So that I can actually read the debug output.

    As a Chef developer,
    I want less if statements, case statements and metaprogramming in DSL method calls,
    So that I can debug and follow logic more easily.

## Specification

### Create explicit DSL methods for resources

When looking up resources, there is no method anywhere that corresponds to the
actual resource name.  This can lead to a lot of unnecessarily heavy thinking
when following some very typical stack traces.  It also means that the name of
the resource being declared is often not on the stack, making debugging harder.

Here we propose that all resource and definition DSL be added to
`Chef::DSL::Recipe` as actual methods, as they are created, so that they can be
subject to inspection and the stack traces can be followed.  This will happen
automatically when the user declares resources and definitions.

### Automatically add new resources and providers to DSL, regardless of namespace

Presently, when you type `my_resource` in the Chef DSL, in the absence of any
`provides` directives to direct Chef to the correct resource class, the
namespaces `Chef::Resource` is explicitly searched for
`Chef::Resource::MyResource`.

This means that if you have seen examples of classes in Chef::Resource, and want
to do the obvious thing and just move to your own namespace, it doesn't
immediately work and it is far from apparent why. The result? A massive traffic
jam of non-core resources in the `Chef::Resource` namespace and puzzling error
messages for cookbook conflicts such as "superclass mismatch for class MyResource."

Chef will now automatically call `provides` on all new, named resource classes,
using `ResourceClass.dsl_name` (a transform of the class name, i.e.
MyPackage::MyResource -> my_resource) as the provided class.

```ruby
class MyPackage::MyResource < Chef::Resource
end
# now you can type 'my_resource' in a recipe.
```

#### Explicit vs. Implicit `provides`

If you specify `provides :something_else` in a class, that will override the
auto-class-creation behavior.

```ruby
class MyPackage::MyResource < Chef::Resource
  provides :shazam
end
# Now `shazam` will work fine in a recipe, but `my_resource` will not.
```

If you want to still provide the original name, you must be explicit:

```ruby
class MyPackage::MyResource < Chef::Resource
  provides :my_resource
  provides :shazam
end
# Now both `shazam` and `my_resource` work in a recipe
```

#### `does_not_provide`

If you want to (for example) create a base class that does not have an actual
DSL method, you can specify `does_not_provide` or `does_not_provide :my_name` in
the class:

```ruby
class MyPackage::MyResourceBase < Chef::Resource
  does_not_provide
end
# my_resource_base will not exist in recipe DSL
```

### Move LWRPs out of the Chef::Resource namespace

With Chef::Resource no longer a special place for class lookup, LWRPs no longer
need to be given a namespace.  We will now make resources/x.rb and providers/x.rb
an anonymous class, with string methods to make it easy to see where they come
from.  This avoids a number of potential errors and warnings that can happen in
the case of conflicts, and gives us control over how we handle conflicts.

Users who wish to set the class of the resource can assign it directly in the
LWRP with `Namespace::MyResource = self`.

## Deprecations and Errors

Removing `method_missing` means several methods of creating resource names cannot
be caught.  These are the cases.  We will issue deprecation warnings for each one
and remove them (and method_missing) come Chef 13.

### Chef::Resource::MyResource = <resource>

When you assign an anonymous class or a resource from another namespace into
`Chef::Resource`, your new resource will currently be accessible via the DSL.
Since there is no Ruby method that lets us catch the assignment of a constant,
there is no way for us to assign an explicit DSL method to handle the resource.

```ruby
# Deprecated
Chef::Resource::Blah = Class.new(Chef::Resource)
```

We will catch this in method_missing, issue a warning letting the user know they
should use the `provides` directive on their class to get it into the DSL, and remove it come Chef 13.

```ruby
# Not deprecated (though the assignment becomes unnecessary)
Chef::Resource::Blah = Class.new(Chef::Resource) { provides :blah }
```

### Calling `method_missing` directly

If people call `method_missing` directly to invoke DSL methods, and we don't
define it anymore, it obviously won't actually invoke the methods.  We will
detect this in method_missing, issue a warning telling people to call the
actual method instead or use public_send(), and remove it come Chef 13.

### Custom `provides?` without corresponding `provides :name`

If someone creates a resource class with a custom `provides?` method, they can
currently

```ruby
class MyResource < Chef::Resource
  def provides?(node, name)
    name == :blah
  end
end
```

The implications of this are that we have to scan every single resource when
you type `blah` in a recipe, just so we can catch this one.  In Chef 12 we will
issue a warning and tell you to do this instead:

```ruby
class MyResource < Chef::Resource
  provides :blah
end
```

### Referencing Chef::Resource::MyLWRPResource

When you create an LWRP, it is presently placed in
`Chef::Resource::CookbooknameResourcename`.  In the spirit of not placing user
defined stuff into the core Chef namespace, this will no longer happen.  Any
user that calls `Chef::Resource::MyLwrpResource.new` or extends directly from
the name `Chef::Resource::MyLwrpResource` will receive a warning.

## Risks To Specific Software

While we're trying to maintain full compatibility, there's risk here, particularly for people doing metaprogramming of resources.  We will run the tests of the following packages, and make sure current versions
still work (possibly emitting deprecation warnings):

- chef-sugar
- chefspec
- chef-rewind
- Poise
- Crazytown
- Halite
- foodcritic

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
