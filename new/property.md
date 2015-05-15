---
RFC: unassigned
Author: John Keiser <jkeiser@chef.io>
Status: Draft
Type: Standards Track
---

# Resource Properties

We add `property` DSL to resources, similar to (and interoperable with) LWRP `attribute`.

It works very similarly to attribute syntax.  There are no backwards compatibility issues with this proposal, as all `attribute` functionality remains the same.

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

This works similarly to `attribute`, except that `lazy` values are automatically run in the context of the *instance*:

```ruby
class MysqlInstall < Chef::Resource
  property :root_path, String, default: '/'
  property :config_path, String, default: lazy { File.join(root_path, 'config') }
end
```

#### name_attribute

Same as before. Causes the attribute to be explicitly set to the name passed to the constructor. To wit:

```ruby
class MyResource < Chef::Resource
  property :path, name_attribute: true
end

my_resource 'foo' do
  name 'bar'
  puts path #=> foo
end
```

#### patchy

Properties declare whether they are patchy (meaning resource actions will not change the on-disk value) or not patchy by specifying `patchy: true|false`. The primary effect of this is to prevent the property from being cloned during Chef's clone process (which happens when you declare a resource twice with different properties):


```ruby
file '/mystuff/x.txt' do
  mode 0666
end

<long series of actions ...>

execute 'chmod /mystuff 0777'

<long series of actions ...>

# If mode is declared `patchy: false`, we will change mode back to 0666 here.
# If mode is declared `patchy: true`, we leave mode at 0777.
file '/mystuff/x.txt' do
  content 'Hello World'
end
```

The reason being, a patchy property is one that *leaves the value alone* unless the user actually says they want to change it.  Cloning values from other resources violates that.

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
class B < A
  property :a
end
A.properties[:a].default #=> 'Hello'
B.properties[:a].default #=> nil
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
