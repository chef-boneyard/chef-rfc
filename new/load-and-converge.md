---
RFC: unassigned
Author: John Keiser <john@johnkeiser.com>
Status: Draft
Type: Standards Track
---

# Easy Resource Load And Converge

With the introduction of `action` on resources, it becomes useful to have a
blessed way to get the actual value of the resource. This proposal adds a
`load` DSL enabling:

- Low-ceremony load methods (as easy to write as we can make it)
- A super easy converge model that automatically compares current vs. desired
  values and prints green text
- A familiar read API for users (who currently either use raw API code or give up)

## Motivation

    As a Chef resource writer,
    I want to be able to read the current value of my resource at converge time,
    so that it is easy to tell the difference between current and desired value.

    As a Chef resource writer,
    I want a converge model that compares current and desired values for me,
    So that the easiest converge to write is the most correct one.

    As a Chef resource writer,
    I want to write my resource's read API code on my resource,
    So that my users can use it as well as me.

    As a Chef user,
    I want to be able to read resources with the resource interface,
    So that I don't have to learn two systems to make decisions.

## Specification

Three very closely related features are here, relating to attribute load and
converge. They make each other stronger, which is why they are all included in
this RFC.

1. **`load`**. We introduce this syntax:

   ```ruby
   class File < Chef::Resource
     load do
       if File.exist?(path)
         mode File.stat(path).mode
         content IO.read(path)
       end
     end
   end
   ```

2. `converge`. This syntax enables simple, efficient, why-run-safe test-and-set:

   ```ruby
   class File < Chef::Resource
     action :create do
       converge do
         File.chmod(mode, path)
         IO.write(content)
       end
     end
   end
   ```

3. Attribute current value: This exposes a very simple read API:

   ```ruby
   puts file('/x.txt').content
   ```

### `load do`: in-place resource load

The user `load do <block>` is entered in the class, a `current_resource` method
is created which creates a new resource, calls the block to load it, caches
and returns the resource.

The block is run inside the newly created resource, allowing for a natural
syntax without dots and without repetitive ceremony.

```ruby
  load do
    if File.exist?(path)
      # Sets "mode" on the current resource.
      mode File.stat(path).mode
    end
  end
```

The block will also be passed the original resource as a parameter, in case it
is needed.

#### Inheritance

The `current_resource` method does not call the superclass's `current_resource`
method by itself, but you may call `super()` from the block to invoke it.

#### Handling Multi-Key Resources

The new resource is created with identity values copied over (and non-identity
values left clear). Any attributes tagged with `identity: true` will be copied.
`name_attribute` implies `identity: true`, and `name` automatically has `identity: true`.

```ruby
class DataBagItem < Chef::Resource
  attribute :item_name, name_attribute: true
  attribute :data_bag_name, index: true
  attribute :data
  load do
    data Chef::DataBagItem.new(data_bag_name, item_name).data
  end
end
```

### `converge`: automatic test-and-set

The new `converge do ... end` syntax is added to actions, which enables a *lot*
of help for resource writers to make safe, effective resources.  It performs
several key tasks common to nearly every resource (which are often not done
correctly):

- Goes through all attributes on the resource and checks whether the desired
  value is different from the current value.
- If any attributes are different, prints appropriate green text.
- Honors why-run (and does not call the `converge` block if why-run is enabled).

#### Compound Resource Convergence

Some resources perform several different operations depending on what is set.
`converge :attribute1, :attribute2, ... do` allows the user to target different
groups of changes based on exactly which attributes have changed:

```ruby
class File < Chef::Resource
  action :create do
    converge :mode do
      File.chmod(mode, path)
    end
    converge :content do
      IO.write(path, content)
    end
  end
end
```

### Unspecified Attributes

The value of an attribute in a Chef resource represents a *desired value* for
the attribute. When an attribute is unspecified, the user is simply not stating
their desire. It's therefore our job to do something reasonable and sane.

To accomodate this, we add a second step to the attribute getter:

1. If `attribute` has been set to a desired value, that is returned.
2. If `current_resource.attribute` is loaded with a current value, that is returned.
3. Otherwise, the attribute's default value is returned.

This means that an unspecified attribute's desired value is its current value,
if one exists. The current attribute system (with no load method) says that an
unspecified attribute's desired value is its *default* value.

This system is biased towards these outcomes:

- When *updating* a resource with an unspecified attribute, we make no change.
- When *creating* a resource with an unspecified attribute, we choose a reasonable
  default (specified by the resource's default value).

#### Backcompat

This is 100% backwards compatible with the current system, because it depends on
`load` filling in attributes, and existing resources do not implement `load`.

## Use Cases

The below is not prescriptive, but is a discussion of some of the supported
use cases:

### Updating a resource

When you update a resource and leave an attribute unspecified, the converge
method is easy to mess up, and harder to get right.

```ruby
class File < Chef::Resource
  attribute :path, name_attribute: true
  attribute :content

  load do
    if File.exist?(path)
      content IO.read(path)
    end
  end

  action :create do
    if content != current_resource.content
      IO.write(path, content)
    end
  end
end

file '/x.txt' do
  # Note: content was not specified!
end
```

Given this (perfectly reasonable looking) code, the current system would
*truncate the file* if you didn't specify `content`.  You need to check if
`content.nil?` before you compare.  This means that the most obvious,
least-ceremony thing to do is the wrong thing. This is also not an error you are
likely to catch early: *not* specifying attributes is not among the first things
people test.

In the proposed system, When an attribute defaults to the *current* value, the
code above will not overwrite the file at all.

#### Use Case: creating a resource

When creating a resource, the above code will do the same thing in both cases:
use the default value and create an empty file. This seems like the right thing
in either case.

#### Use Case: Patchy Resources

This rule allows for "patchy resources," which are commonly desired and
intuitive but hard to write currently:

```ruby
# Must leave content alone!
file '/x.txt' do
  mode 0666
end
# Must leave mode alone!
file '/y.txt' do
  content "Hello World"
end
```

#### Use Case: Attribute Append

This also allows for appends, something that has been difficult up to this point.
This means you can say "please make sure this attribute contains X" without the
resource author having to make a specific method for you to do that:

```ruby
node 'mynode' do
  normal_attributes[:foo] = 'bar'
  run_list << 'apache2'
end
```

Even though the resource author didn't specifically mention it:

```ruby
class Node < Chef::Resource
  attribute :normal_attributes, default: {}
  attribute :run_list, default: []
  load do
    node = Chef::Node.get(name)
    normal_attributes node.normal
    run_list node.run_list
  end
  action :create do
    converge do
      node = Chef::Node.new(name)
      node.run_list = run_list.uniq
      node.normal = normal_attributes
      node.save
    end
  end
end
```

#### Use Case: Read API

Resource authors have always written code to read the current value of a
resource (in `load_current_reosurce`). What has been frustrating (for both
resource writers and users) is that this code is not available to the user, who
really does need it from time to time.

`current_resource` would be sufficient for this; but since we're doing lazy load
for these other reasons, the API gets even stronger:

```ruby
puts file('/x.txt').content
```

Since the `content` attribute is not set on this resource, it returns
`current_value.content` (or the default value, if the file does not exist).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
