---
RFC: unassigned
Author: John Keiser <john@johnkeiser.com>
Status: Draft
Type: Standards Track
---

# Providerless Resources

In this proposal, we allow actions to be specified as recipes, directly in resources.

## Motivation

    As a <<user_profile>>,
    I want to <<functionality>>,
    so that <<benefit>>.

## Specification

To create an action on a resource, users specify `action <action> do ... end`.
The recipe in between the do ... end block will be run when the action is
performed.

```ruby
class MyResource < Chef::Resource
  attribute :path, name_attribute: true
  attribute :content
  attribute :mode

  action :create do
    if content != IO.read(path)
      inline_block "Update content of #{path}" do
        IO.write(path, content)
      end
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

This is equivalent to `use_inline_providers` in a Provider, and in fact is
implemented that way.  We just call out the behavior here to make it clear what will happen.

#### Action composition and inheritance

The action recipes are all added to a `Provider` class which inherits from the
parent resource's provider class.  You may call `super` to call the parent
class's version of the current action.

```ruby
class MyFile < Chef::Resource::File
  action :create do
    puts "I am a file yo"
    super
  end
end
```

### Inline resource output

When `use_inline_resources` runs, the output can be much more verbose than the
user expects.  Particularly, they see a number of resources and actions that they didn't declare:

```
* x[blah] action blah
  * file[/Users/jkeiser/x.txt] action create (up to date)
   (up to date)
```

We suggest not actually showing sub-resources as separate things in output:

```
* x[blah] action blah (up to date)
```

An "update" would look like this (again, removes the extra nesting):

```
* x[blah] action blah
  - create new file /Users/jkeiser/x.txt
  - update content in file /Users/jkeiser/x.txt from none to a591a6
  --- /Users/jkeiser/x.txt	2015-04-29 08:15:14.000000000 -0700
  +++ /Users/jkeiser/.x.txt20150429-56731-6xk0lx	2015-04-29 08:15:14.000000000 -0700
  @@ -1 +1,2 @@
  +Hello World
```

The principle is: the user doesn't see resources they don't type.

### Help defining recipes

A bare recipe can do quite a lot of the work of convergence.  But there are a
few tweaks that help with this:

#### inline_recipe resource

The `inline_recipe` resource lets you write recipe code. It also has the parent
in scope (so you can still access instance variables).  The resources inside
will compile immediately and be available in `inline_recipe.resources`.  The
resources will converge when the `inline_recipe` converges.

Like recipe actions, the resources inside the `inline_recipe` are not
referenceable by `notifies` outside.  Unlike recipe actions, the resources show
up in nested output (because the user typed them in the recipe).

```ruby
inline_recipe 'Create that one file' do
  only_if { File.exist?('/please_create_that_file.txt') }

  directory '/x' do
  end
  file '/x/y.txt' do
  end
end
```

### `Resource.why_run_description`

When why run is enabled, we automatically prepend "Would" to the text of the
why run description.  This doesn't always read well.  Herein we propose adding
parameters for why-run safety to resources.

The `converge_description` and `why_run_description` methods on a resource let
you customize this if you want.  (By default, they will emit the same text as
before.)

```ruby
ruby_block 'Delete /x.txt' do
  why_run_description 'Would totally delete /x.txt'
  only_if { File.exist?('/x.txt') }
  action :run
end
```

The `why_run_description` can be lazy, and can thus be a calculated value run
in lieu of the block (for example, if the user ).

## Changes to existing things

### Resource

We add the following public API to `Resource`:

- `self.action(action, class: nil, &block)`: creates a Provider with the given
  action

And modify the following:

- `allowed_actions`: defaults to all actions in the resource's provider class(es).
- `default_action`: defaults to `allowed_actions.first`.

### Provider

We add the following public API to `Provider`:

- `use_inline_resources`: moved up from LWRPBase.

Resources in LWRP actions will no longer report as nested actions (they will do
the same thing as recipe actions).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
