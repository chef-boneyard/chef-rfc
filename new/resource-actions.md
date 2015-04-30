---
RFC: unassigned
Author: John Keiser <john@johnkeiser.com>
Status: Draft
Type: Standards Track
---

# Resource Actions

In this proposal, we allow actions to be specified as recipes, directly in resources.

## Motivation

    As a Chef user,
    I want to be able to write actions in resources,
    so that I don't have to learn and reason about `Provider`s (less friction).

    As a Chef user,
    I want to be able to write actions in resources,
    so that I don't have to switch contexts to understand what resources do.

    As a Chef user,
    I want actions to be specified as recipes by default,
    so that I can use concepts I already know to create good test-and-set resources.

## Specification

To create an action on a resource, users specify `action <action> do ... end`.
The recipe in between the do ... end block will be run when the action is
performed.

```ruby
class MyResource < Chef::Resource::LWRPBase
  attribute :path, name_attribute: true
  attribute :content
  attribute :mode

  action :create do
    ruby_block "Update content of #{path}" do
      only_if { content != IO.read(path) }
      block { IO.write(path, content) }
    end

    execute "Update mode of #{path}" do
      not_if { File.stat(path).mode == mode }
      command "chmod #{mode} #{path}"
    end
  end
end
```

There is no change to providers or the way we run actions.  This is just a way
of defining a provider without having to type or think about the word.  Providers
do not go away, so much as become a secondary concept, a sort of house for the
primary concept of actions.

`action` will work for any resource extending from `Chef::Resource`.

### Action details

#### Action recipe execution

The action recipe works like a Chef run, in that it is an isolated resource
collection and runs actions and notifications the same way as a top level Chef
run.

- The entire action recipe is compiled (just like a normal recipe) before
  converging.
- This compile happens when the action is *run*, not when the parent resource
  is declared.
- Delayed and immediate notifications are local to the action.

This is equivalent to what `use_inline_resources` in an LWRP does, and we will
keep them orthogonal as much as possible.

#### Action composition and inheritance

The action recipes are all added to a `Provider` class which inherits from the
parent resource's provider class.  You may call `super` to call the parent
class's version of the current action.

```ruby
class MyFile < Chef::Resource::File
  action :create do
    puts "I am a file yo"
    super()
  end
end
```

## Changes to existing things

### Resource

We add the following public API to `Resource`:

- `self.action(action, class: nil, &block)`: creates a Provider with the given
  action

And modify the following:

- `allowed_actions`: defaults to all actions in the resource's provider class(es).
- `default_action`: defaults to `allowed_actions.first`.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
