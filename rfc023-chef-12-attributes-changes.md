---
RFC: 23
Author: Phil Dibowitz <phil@ipom.com>
Status: Accepted
Type: Standards Track
Chef-Version: 12
---

# Chef 12 Attributes Changes

Chef 11 added a variety of features and abilities to the Attributes ecosystem within Chef. Unfortunately certain abilities were also lost.

This proposal is the result of copious discussion between Daniel DeLeo, Adam Jacob, and myself on how to add the following in a consistent and clean way that preserves the goals behind the Chef 11 Attributes changes.

While these are mostly backwards compatible there are some minor breaking changes and as such these are intended to be put into Chef 12.

The desired abilities are:
* To be able to safely delete a key in the Attribute at a given precedence level
* To be able to safely delete a key in the Attribute at all precedence levels
* To be able to assign into a precedence level in a way that overwrites the
entire nested value of a key at that precedence level, ala Chef 10.

## Motivation

### Precedence Key Deletion
Due to the fact that a precedence levels in Chef 11 are made up of multiple components, simple deletes no longer work as they once did. However, it is important to be able to delete a key at a given precendence level as one once could. One may be doing a safety check and realize an entry in a hash is dangerous or bad.

#### What's wrong?

You can no longer call `node['foo'].delete('bar')` because writing without a precedence is forbidden in Chef 11, there is no functional delete.

Further, you cannot delete at a precedence level because `node.default['foo'].delete('bar')` will end up acting on the cookbook_default sub-Mash inside the default precedence and not effect role defaults.

And for the same reason there is no way to overwrite a key at a precedence - you end up merging.

### Global Key Deletion
For the same reasons as above, being able to delete a key globally is important.

### To be able to assign with overwrite
As a side-effect of the changes in Chef 11, this code:

    node.default['foo']['bar']['baz'] = 12
    node.role_default['foo']['bar']['baz'] = 52
    node.default['foo']['bar'] = {'thing' => 'stuff'}

No longer overwrites the 'bar' key with a new hash-like structure, but instead merges these new entries into the existing Attribute. While this is desired for a variety of use-cases, having a way to fully assign the value of a key is important.

## Specification

We propose 2 additions and one change to accomplish these goals.

### Precedence Level Removals

#### Syntax

```ruby
node.rm_default('foo', 'bar')
node.rm_normal('foo', 'bar')
node.rm_override('foo', 'bar')
```

This will be aliased to `node.remove_default`, `node.delete_default`, `node.remove_normal`, `node.delete_normal`, `node.remove_override`, and `node.delete_override` respectively.

This function would return the computed value of the key being deleted for the
specified precedence level.

#### Examples

Delete a default value when only defaults exist

```ruby
# Given this structure under 'foo'
node.default['foo'] = {
  'bar' => {
    'baz' => 52,
    'thing' => 'stuff',
  },
  'bat' => {
    'things' => [5, 6],
  },
}

# Given also some role attrs
# Please don't ever do this in real code :)
node.role_default['foo']['bar']['thing'] = 'otherstuff'

# And a force attr
node.force_default['foo']['bar']['thing'] = 'allthestuff'

# When we remove default precedence of node['foo']['bar']
node.rm_default('foo', 'bar') #=> {'baz' => 52, 'thing' => 'allthestuff'}

# What's left under 'foo' is only 'bat'
node.attributes.combined_default['foo'] #=> {'bat' => { 'things' => [5,6] } }
```

Delete a default value when higher precedences exists, doesn't touch them

```ruby
# Given the same structure as before:
node.default['foo'] = {
  'bar' => {
    'baz' => 52,
    'thing' => 'stuff',
  },
  'bat' => {
    'things' => [5, 6],
  },
}

# Given also some role attrs
# Please don't ever do this in real code :)
node.role_default['foo']['bar']['thing'] = 'otherstuff'

# And a force attr
node.force_default['foo']['bar']['thing'] = 'allthestuff'

# And also some overrides:
node.override['foo']['bar']['baz'] = 99

# The same delete as before
node.rm_default('foo', 'bar') #=> { 'baz' => 52, 'thing' => 'allthestuff' }

# But the other precedences are unaffected:
node.attributes.combined_override['foo'] #=> { 'bar' => {'baz' => 99} }
node['foo'] #=> { 'bar' => {'baz' => 99}, 'bat' => { 'things' => [5,6] }
```

Deletes an override when lower-precedence exists without touching them

```ruby
# Given the same structure as before - but as an override
node.override['foo'] = {
  'bar' => {
    'baz' => 52,
    'thing' => 'stuff',
  },
  'bat' => {
    'things' => [5, 6],
  },
}

# And having a single default value
node.default['foo']['bar']['baz'] = 11

# And a force at each precedence
node.force_default['foo']['bar']['baz'] = 55
node.force_override['foo']['bar']['baz'] = 99

# Delete the override
node.rm_override('foo', 'bar') #=> { 'baz' => 99, 'thing' => 'stuff' }

# But the other precedences are unaffected:
node.attributes.combined_default['foo'] #=> { 'bar' => {'baz' => 55} }
```

Non-existent key deletes return nil:

```ruby
# Delete Non-Existent Key
node.rm_default("no", "such", "thing") #=> nil
```

### Global Level Removals

#### Syntax

```ruby
node.rm('foo', 'bar')
```

This will be aliased as `node.remove` and `node.delete`.

The syntax `node['foo'].delete('bar')` will throw an exception pointing you to
the new API.

#### Examples

```ruby
# Given a similar structure to before
node.default['foo'] = {
  'bar' => {
    'baz' => 52,
    'thing' => 'stuff',
  },
  'bat' => {
    'things' => [5, 6],
  },
}

# With overrides
node.override['foo']['bar']['baz'] = 999

# Removing the 'bar' key returns the computed value
node.rm('foo', 'bar') #=> {'baz' => 999, 'thing' => 'stuff'}

# Looking at foo, all that's left is the 'bat' entry
node['foo'] #=> {'bat' => { 'things' => [5,6] } }
```

Deleting a non-existent key returns nil

```ruby
# Delete Non-Existent Key
node.rm_default("no", "such", "thing") #=> nil
```

### Full Assignment

We propose we stop making `!` an alias for `force_`, and use `!` as a modifier
to functions to indicate this behavior.

We propose that adding ! to a precedence-component-write function will clear out
the key for that precedent for all "components" that merge earlier than it, and
then complete the write.

#### Syntax

```ruby
node.default!['foo']['bar'] = {...}
node.force_default!['foo']['bar'] = {...}
node.normal!['foo']['bar'] = {...}
node.override!['foo']['bar'] = {...}
node.force_override!['foo']['bar'] = {...}
```

Since `node.role_default`, `node.env_default`, and their override equivalents
are considered private APIs, the `!` syntax will not be implemented for them,
but the desire is that the `!` operator is defined clearly enough that such an
implementation has a clear specification. For example, `node.role_default!`
would clear the value for default, env_default, role_default before assignment,
but not force_default.

#### Examples

Example 1: Just one component

```ruby
node.default['foo']['bar'] = {'a' => 'b'}
node.default!['foo']['bar'] = {'c' => 'd'}

# The '!' caused the entire 'bar' key to be overwritten
node['foo'] #=> {'bar' => {'c' => 'd'}
```

Example 2: Multiple components; one "after" us:

```ruby
node.default['foo']['bar'] = {'a' => 'b'}
# Please don't ever do this in real code :)
node.role_default['foo']['bar'] = {'c' => 'd'}
node.default!['foo']['bar'] = {'d' => 'e'}

# The '!' write overwrote the "cookbook-default" value of 'bar',
# but since role data is later in the resolution list, it was unaffected
node['foo'] #=> {'bar' => {'c' => 'd', 'd' => 'e'}
```

Example 3: Multiple components; all "before" us:

```ruby
node.default['foo']['bar'] = {'a' => 'b'}
# Please don't ever do this in real code :)
node.role_default['foo']['bar'] = {'c' => 'd'}
node.force_default!['foo']['bar'] = {'d' => 'e'}

# Given a force_default!, there is no other data under 'bar' than
# what we wrote
node['foo'] #=> {'bar' => {'d' => 'e'}
```

Example 4: With multiple precedences

```ruby
# Given a similar structure to before
node.default['foo'] = {
  'bar' => {
    'baz' => 52,
    'thing' => 'stuff',
  },
  'bat' => {
    'things' => [5, 6],
  },
}

# Please don't ever do this in real code :)
node.role_default['foo']['bar']['baz'] = 55
node.force_default['foo']['bar']['baz'] = 66

# And other precedences
node.normal['foo']['bar']['baz'] = 88
node.override['foo']['bar']['baz'] = 99

# And we do a full assignment
node.default!['foo']['bar'] = {}

# Now we have role-default and force-default left in default
# plus other precedences
node.attributes.combined_default['foo'] #=> {'bar' => {'baz' => 66}, "bat"=>{"things"=>[5, 6]}}
node.attributes.combined_normal['foo'] #=> {'bar' => {'baz' => 88}}
node.attributes.combined_override['foo'] #=> {'bar' => {'baz' => 99}}
node['foo']['bar'] #=> {'baz' => 99}

# If we then write with force_default!
node.force_default!['foo']['bar'] => {}

# We see the difference
node.attributes.combined_default['foo'] #=> {'bar' => {}}
node.attributes.combined_normal['foo'] #=> {'bar' => {'baz' => 88}}
node.attributes.combined_override['foo'] #=> {'bar' => {'baz' => 99}}
node['foo']['bar'] #=> {'baz' => 99}
```

NOTE: This also requires that `!` functions no longer functions as a reader.

## Rationale

As stated above this provides much-needed abilities currently lacking in the Chef 11 model.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
