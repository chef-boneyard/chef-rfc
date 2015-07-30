---
RFC: unassigned
Author: John Keiser <jkeiser@chef.io>
Status: Draft
Type: Standards Track
---

# Property Default Value Improvements

This RFC addresses some longstanding issues with `default` values on properties (attributes), and addresses how we will move core Chef resources over to use defaults and properties.

## Motivation

    As a Chef developer,
    I want the core resources to use `property`,
    So that people are cribbing off good examples.

    As a Chef user,
    I want the core resources not to actually change behavior,
    So that I can rely on things I've built on top of them.

## Specification

### Non-Sticky Defaults

Defaults are presently *sticky*, in that the first time a property is accessed, it is stored in the instance variable:

```ruby
class X < Chef::Resource::LWRPBase
  resource_name :x
  attribute :foo, default: lazy { Random.rand }
end

x 'blah' do
  puts @foo #=> nil
  puts foo  #=> 1
  puts foo  #=> 1
  puts @foo #=> 1
end
```

Once a default is assigned, it is not re-evaluated.

#### Frozen constants

Sticky defaults create a serious issue for literals (non-lazy default values): *every instance* of a resource gets the same value.

```ruby
class X < Chef::Resource::LWRPBase
  resource_name :x
  attribute :foo, default: []
end
x 'a' do
  foo << 1
  foo << 2
end
x 'b' do
  # ERROR we picked up the values that got added to 'a'
  puts foo #=> [ 1, 2 ]
end
```

To fix this, we propose freezing non-lazy default values, and not assigning them to the instance.

An alternative would have been to `dup` the default value before assigning it to the instance. We didn't go this direction because it's more error-prone: dup doesn't do a deep duplication; not all objects can be dup'd, and it's a little surprising to boot.

#### Backcompat break: writing to constant defaults

Users may rely on this behavior to *write* to `myprop`, like this:

```ruby
class Foo < Chef::Resource::LWRPBase
  resource_name :foo
  attribute :myhash, default: {}
  attribute :mylist, default: []
end
foo 'x' do
  myhash[:a] = 10
  mylist << 'hi'
end
```

This would cause `mylist << 'hi'` to fail with a message "RuntimeError: can't modify frozen Array", letting the user know that *writes* will not work. To create a mutable default value, you must use a lazy value.

This will fail to work in the new world, because we are freezing the constants. This is deliberate and a bugfix; the purpose is to avoid users setting values that affect all instances.

### Validating defaults

We propose that defaults be validated consistently: non-lazy defaults would be validated when the resource class is declared, and lazy defaults would be validated when they are retrieved.

#### Backcompat

Defaults are presently validated inconsistently: they would be validated or not validated based on the order of declaration in the property information. To wit:

```ruby
# This currently does not validate, even though 10 is not a string
property :a, kind_of: String, default: 10
# This currently validates correctly
property :b, default: 10, kind_of: String
```

For backcompat purposes, if validation of a default value fails, we will emit a deprecation warning ("you must specify defaults that pass validation").

### Move Core resources to `default` [compatbreak w/deprecation]

`default` is generally a better thing for memory pressure, and is useful for detecting whether a user has set a value or not.  Currently, core Resources tend to assign property default values to the proper instance variable during `initialize`, and it is possible that subclasses may rely on this behavior.

Resources *should* instead be using the property getter method, and in the future the instance variable may not even always be there. For Chef 12, we will grab the default values of any lazy arrays or hashes on initialize, and we will issue a deprecation warning for subclasses that directly use the initialized instance variable.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
