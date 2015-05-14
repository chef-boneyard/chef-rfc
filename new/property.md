---
RFC: unassigned
Author: John Keiser <jkeiser@chef.io>
Status: Draft
Type: Standards Track
---

# Resource Properties

We rename `attribute` to `property` on resource, with a few differences.

There are no backwards compatibility issues with this proposal, as all modified functionality hangs off of a new keyword.

## Motivation

    As a Chef user,
    I want resource attributes and node attributes to use different words,
    so that they don't lead me to conflate them as concepts.

## Specification

### Defining properties

Resource class definitions may now call `property` to create a resource property.  This works similarly to LWRP attribute, but with some important additions and differences.

```ruby
class MyResource < Chef::Resource
  property :path, Path, name_attribute: true
  property :content, String
end
```

This calls MyResource.properties[name] = <property type>.

When a property is defined this way:
- `my_resource.<name>` will get the property value.
- `my_resource.<name> = <value>` will set the property value.
- `my_resource.<name> <value>` will set the property value.
- `MyResource.state_attrs` will include the property name.
- `MyResource.properties` will contain the property type.
- The setter and getter manipulate the class variable `@<name>`.

#### Use `property` instead of `attribute` in documentation

`attribute` will continue to be supported; there are simply too many things in the world to deprecate it. However, any generic documentation that talks about attributes will be renamed to talk about properties. `attribute` itself will still be documented.

### Setting properties

### nil

In order to allow for `nil` as a potential explicit value, property setters accept `nil` and set the value of the property to `nil`.  This differs from `attribute`, which considers `property(nil)` to be a get.

#### lazy values

Properties may be set to lazy values, which work the same as in attributes: they are treated as computed values, popped open and validated each time you access them.

```ruby
file '/x.txt' do
  content lazy { IO.read("/otherfile.txt") }
end
```

### Validation

There are a number of validation parameters to `property` that affect its behavior. If multiple of these are specified, they must *all* succeed.

#### callbacks, kind_of, respond_to, cannot_be, regex, equal_to, required

These function identically to the equivalent functionality on `attribute`.

##### RSpec matchers

`must` allows for rspec 3 matchers to be passed, and will validate them and print failures.

```ruby
include RSpec::Matchers
property :path, String, must: start_with('/')
```

#### must_match

This new option takes an array of values which use Ruby's universal matching
operator, `===`.  This means that you can type this:

```ruby
property :x, must_match: [String, :a, :b, nil]
```

### Other options

#### coerce

`coerce` is a proc run when the user sets a non-lazy value, or reads a lazy or default value. It allows normalization of input, which makes it simple to create expressive interfaces while preserving a simple programming model that knows what to expect:

```ruby
class File < Chef::Resource
  attribute :mode, coerce: proc { |v| mode.is_a?(String) ? mode.to_s(8) : mode }
end
```

`coerce` procs are run in the context of the instance, so that they have access to other attributes and methods.

#### default

This works similarly to `attribute`, except that:

1. Default values are *sticky*: they are dup'd and stored in the class the first time they are retrieved. The reason: if a class has a property and the user wants to start with the default value and change it, we support that. This does *not* apply to lazy defaults, which do not generally have the same problem.
   TODO still need to decide if this is a good solution to the problem. The idea that every class has its own thing is good; but there may well be situations where users want to default to a particular instance of a thing.
   ```ruby
   class MyResource < Chef::Resource
     property :children, Array, default: []
   end

   my_resource 'blah' do
     children << 'yet_another_child'
   end
   ```
2. `lazy` values are automatically run in the context of the *instance*:
   ```ruby
   class MysqlInstall < Chef::Resource
     property :root_path, String, default: '/'
     property :config_path, String, default: lazy { File.join(root_path, 'config') }
   end
   ```

Additionally, non-lazy default values are automatically dup'd before assigning to the instance.

#### name_attribute

Same as before. This is exactly equivalent to default: lazy { name }.

### Property type

Properties with a single type are common enough that we support a primary "type" for a property, specifiable after its name.

```ruby
class MyResource < Chef::Resource
  property :content, String
end
```

#### Reusing types

The type of a property is represented by `Chef::Resource::PropertyType`, and contains accessors for all the properties of a type (`must_be`, `name_attribute`, `kind_of`, etc.).

When you declare `property :name, <type>, <options>`, one of two things happens:

- If the type is a PropertyType instance, it is dup'd and any <option>s are set on the new type.
- If the type is a Class, a new PropertyType instance is created with `kind_of` set to [Class] and any options are set on the new type.
- If type is not passed, a new PropertyType instance is created, and any options are set on the new type.

### Property Inheritance

Subclasses get properties from their parent.

```ruby
class A < Chef::Resource
  property :a, String
end
class B < Chef::Resource
  property :b, String
end
B.state_attrs -> [ :a, :b ]
```

#### Overriding Properties

When a property is overridden, the override is *complete*: that is, the parent
type is not extended or mixed in any way.

```ruby
class A < Chef::Resource
  property :a, String, default: 'Hello'
end
class B < Chef::Resource
  property :a
end
A.properties[:a].default #=> 'Hello'
B.properties[:a].default #=> nil
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
