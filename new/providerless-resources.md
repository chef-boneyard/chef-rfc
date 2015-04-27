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

`run_action` will use the `provider` if it can't find an appropriate `action`
recipe.  There is no change to Providers; this is just a providerless way to
create a Resource.

### Action recipe execution

The action recipe works like a Chef run, in that it is an isolated resource
collection and runs actions and notifications the same way as a top level Chef run.

- The entire action recipe is compiled (just like a normal recipe) before converging.
- This compile happens when the action is *run*, not when the parent resource
  is declared.
- Delayed and immediate notifications are local to the action.
- Resources in an action are *not* reported in console output; rather, the green
  text from the resource is printed if there is an update (and nothing is printed
  otherwise).

### inline_ruby resource

Currently, Providers have a `converge_by` API which will run a block and report
green text if it succeeds (and which will *not* run the block if why-run is
enabled, but still report).  Instead of this, we propose an `inline_ruby`
*resource*, available to all:

```ruby
inline_ruby 'Delete /x.txt' do
  File.delete('/x.txt')
end
```

This will behave identically to `converge_by` in an inline recipe, and has the
advantage of being useful outside of that context, as well.

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
in lieu of the block.

## API changes

### Resource

We add the following methods to `Resource`:

- `self.action(action, class: nil, &block)`: define a new action recipe.
  By default, extends from either the superclass `action_class` (if available)
  or `ActionRecipe`.
- `self.action_classes`: Hash of available action -> recipe classes for this resource
  class (includes any superclasses).  Does *not* include Providers.  Readonly.
  Use `action()` to add actions.

And modify the following:

- `allowed_actions`: defaults to the action recipes in the class and superclasses.
- `default_action`: defaults to allowed_actions.first
- `run_action(...)`: If an action recipe is defined, creates it and calls `run`.
  Otherwise does the provider stuff.  Subclasses may override this to do whatever
  they want.

### ActionRecipe

ActionRecipes are what we hang the DSL off of and where we run the recipe from.
They act like their own Chef Run and have their own resource collection.

Interface:
- `action`: the name of the action (`:create`, etc.)
- `resource`: the resource being acted on
- `run_context`: the run context with the new resource collection.
- `run`: Run this action, including notifications, events and updates.
- `run_recipe` (protected): runs the action (called by `run`).
- `updated_resource?`: whether this action caused a resource update.

DSL:
- `report_update(description)`: report an update to the resource.
- includes Chef::DSL::Recipe
- includes the DSL from `resource` (its attributes and methods)

Creating a new ActionRecipe from scratch looks like:

```ruby
class MyAction < Chef::Resource::ActionRecipe
  def run
    file self.path do
      content 'Hello World'
    end
  end
end
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
