---
RFC: unassigned
Author: John Keiser <jkeiser@chef.io>
Status: Draft
Type: Standards Track
---

# Default Resource Name

In which resources get names and DSL by default, unless you say you don't want one.

## Motivation

    As a Chef user,
    I want convention to drive my DSL,
    So that I can concentrate on my code instead of ceremony.

## Specification

When a user declares a resource class thus:

```ruby
class MyResource < Chef::Resource
end
```

It will automatically gain a resource_name and DSL derived from the class:

```ruby
my_resource 'foo' do
end
```

This is already (currently) the case for classes declared in Chef::Resource; this extends the rule to all classes anywhere and removes the special case.

### resource_name creates automatic DSL

When a class's resource_name is set, it will always get DSL will that resource name. Thus, this will work:

```ruby
class X < Chef::Resource
  resource_name :my_resource
end
my_resource 'foo' do
end
```

#### New resource classes' resource names are set automatically

When a resource class is declared with an explicit name, its resource name is set automatically:

```ruby
class SuperAwesome < Chef::Resource
end
super_awesome 'foo' do
end
```

This will *not* apply to classes manufactured using Class.new and assigned to constants or given names later.

#### resource_name nil unsets resource name

class.resource_name nil unsets a resource name (and prevents that name from appearing in DSL).

### Backcompat: Two classes, one DSL

When there is ambiguous precedence (two resources with the same filter precedence level), we want to have a stable order with backwards compatibility.

#### Lexical order

Previously, resource matches at the same precedence level involved sorting the classes by name. We will replicate this (though priority arrays with multiple classes will not obey this rule and will be entirely last-declared).

```ruby
class X < Chef::Resource
  provides :x, os: 'linux'
  def hi
    puts 'x'
  end
end
class Y < Chef::Resource
  provides :x, os: 'linux'
  def hi
    puts 'y'
  end
end

# X wins, because X < Y
x 'foo' do
  hi #=> 'x'
end
```

#### Backcompat: Chef::Resource::X.resource_name > SomeOtherModule::X.resource_name

If Chef::Resource::X and SomeOtherModule::X are both declared, the implicit DSL from Chef::Resource will have higher precedence.  (This *only* applies to the resource_name-provided DSL.)

#### Warning when overriding DSL

When two classes have the same filters (for example, they both do provides :file, os: 'linux'), currently we let the last declared class silently override the formerwith a silent override. Now, we will emit a warning when the user declares a second class with the exact same filter as a previous one.

```

This warning can be disabled by acknowledging that an override is desired, passing override: true to provides.
