---
RFC: 54
Title: Resource Attribute Improvements
Author: John Keiser <jkeiser@chef.io>
Status: Final
Type: Standards Track
---

# Resource Attribute Improvements

We add a number of enhancements to `attribute`:

- Make nil a valid value (`path nil`)
- Make a nicer type / validation syntax (`property :path, String`)
- Add lazy defaults.
- Add coercion.
- Add `property` (an alias to `attribute`) to `Chef::Resource` to make it available to all users.
- Add `property_is_set?(:property_name)`

## Motivation

    As a Chef user,
    I want to be able to use natural syntax for properties,
    So that I can spend less time writing cookbooks, and make them more readable.

    As a Chef user,
    I want resources to be more readable and ubiquitous,
    So that I can easily tell the interface to things I use.

    As a Chef user,
    I want resource attributes and node attributes to use different words,
    so that they don't lead me to conflate them as concepts.

## Specification

### `property`

`property` will be added to `Chef::Resource` as the primary way to write properties. This is to alleviate confusion around resource and node attributes.

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

(This is the same as before, except the addition of the `properties` hash.)

### Make nil a valid value

It will now be possible to set a property to `nil` by saying `my_property nil`.  (Currently, this will not change the value of `my_property`.)

In Chef 12, we will keep behavior the same, and *deprecate* the current behavior of silently doing nothing when you set a property to nil.  We will allow properties to explicitly allow `nil`, however, by specifying it explicitly as a valid value: `property :path, [ String, nil ]`.

### Make defaults lazy

`lazy` defaults are automatically run in the context of the *instance*:

```ruby
class MysqlInstall < Chef::Resource
  property :root_path, String, default: '/'
  property :config_path, String, default: lazy { File.join(root_path, 'config') }
end
```

This is a breaking change since `attribute` is the same as `property`, but it is considered a bugfix and not a backcompat feature, so backwards compatibility will not be maintained.

#### `attribute`

`attribute` will remain on LWRPs, and be an alias to `property` with no distinctions.

#### Use `property` instead of `attribute` in documentation

`attribute` will continue to be supported; there are simply too many things in the world to deprecate it. However, any generic documentation that talks about attributes will be renamed to talk about properties. `attribute` itself will still be documented.

We will need to write a comprehensive resource writing guide as well, in order to get it pumped to the top of Google, so that `attribute` comes up less and less often in searches and `property` comes up more and more.

### Property type

Properties with a single type are common enough that we support a "type" for a property, specifiable after its name.

```ruby
class MyResource < Chef::Resource
  property :content, String
end
```

This is actually an alias for `is` (described later here).

#### Reusing types

The type of a property is represented by `Chef::Resource::PropertyType`, and contains accessors for all the properties of a type (`must_be`, `name_attribute`, `kind_of`, etc.).

When you declare `property :name, <type>, <options>`, one of two things happens:

- If the type is a PropertyType instance, it is dup'd and any <option>s are set on the new type.
- If the type is a Class, a new PropertyType instance is created with `kind_of` set to [Class] and any options are set on the new type.
- If type is not passed, a new PropertyType instance is created, and any options are set on the new type.

#### Property Inheritance

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

#### `is`

`is` is a new validation parameter that uses Ruby's match operator `===` (the thing that drives `case` and `when`).

```ruby
# These are equivalent
property :x, [ :a, :b, :c ]
property :x, is: [ :a, :b, :c ]
```

It is worth noting that many existing validations can be expressed directly in terms of `is`:

Old Qualifier          | `is`
-----------------------|---------------
`kind_of: String`      | `is: String`
`equal_to: [ :a, :b ]` | `is: [ :a, :b ]`
`regex: /@chef.io/`    | `is: /@chef.io/`
`respond_to: :merge`   | `is: proc { |v| v.respond_to?(:merge) }`
`cannot_be: :empty`    | `is: proc { |v| !v.empty? }`

As well as some things that were hard to express before:

```ruby
property :path, [ String, :up, :down, nil ]
```

If both `is` and a type are specified, the values in the type are prepended to `is`.

### RSpec matchers

`is` allows for rspec 3 matchers to be passed, and will validate them and print failures.

```ruby
property :path, a_string_starting_with('/')
```

There are no current plans to actually include the matcher syntax in `Resource` by default; users will do this if they want it by doing `include RSpec::Matchers`.

### Coercion

`coerce` is a proc run when the user sets a non-lazy value, or reads a lazy or default value. It allows normalization of input, which makes it simple to create expressive interfaces while preserving a simple programming model that knows what to expect:

```ruby
class File < Chef::Resource
  attribute :mode, coerce: proc { |m| m.is_a?(String) ? m.to_s(8) : m }
end
```

`coerce` procs are run in the context of the instance, so that they have access to other attributes and methods.

### `property_is_set?`

We introduce `property_is_set?(:blah)` to determine whether a given property has been explicitly set on an instance (so you can distinguish between default and non-default values).

```ruby
class X < Chef::Resource
  provides :x
  property :a, default: 1
  property :b, default: 1
end

x 'blah' do
  a 1
  puts a                    #=> 1
  puts property_is_set?(:a) #=> true
  puts b                    #=> 1
  puts property_is_set?(:b) #=> false
end
```

## Backwards Compatibility Summary

Two things will change in Chef 13:

- Lazy defaults: `attribute :x, default: lazy { name }` will run in the context of the instance.
- `nil` is a valid value: `path nil` will set the value of path to nil (or throw a validation error if it is not a valid value).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
