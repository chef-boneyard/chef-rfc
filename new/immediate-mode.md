---
RFC: unassigned
Author: John Keiser <jkeiser@chef.io>
Status: Draft
Type: Standards Track
<Replaces: RFCxxx>
---

# Immediate Action Mode

Add the ability to run resources immediately after declaration (compile time) in Chef.

## Motivation

    As a <<user_profile>>,
    I want to <<functionality>>,
    so that <<benefit>>.

## Specification

### resource.run_actions `:immediately`

A new property is added to all resources: `run_actions`.  This can be set to either `:delayed` (the default) or `:immediately`.

When `run_actions` is set to `:immediately`, the resource's actions are run immediately following its declaration, and the recipe does not resume compiling until all its actions and immediate notifications have run.

When `run_actions` is set to `:delayed`, the resource's actions run after all compilation has completed, and in order of declaration. (This is not a change.)

```ruby
package 'apt' do
  action :upgrade
  run_actions :immediately
end
```

#### run_resources `:immediately`

This recipe DSL method causes all resources within that particular recipe or provider to be set to `run_resources :immediately`. No other recipes or providers are affected. When called with a `do ... end` block, it will only affect resources created in that block.

```ruby
run_resources :immediately do
  file '/blah.txt'
  # Prints true
  puts File.exist?('/blah.txt')
end
```

#### metadata.rb: run_resources `:immediately`

The `metadata.rb` file for a cookbook now has a setting `run_resources :immediately` that will apply to any recipe in the cookbook.

```ruby
name 'mycookbook'
version '1.0.0'
run_resources :immediately
```

#### include_recipe

`run_resources :immediately` is not infectious. If a recipe with `run_resources :immediately` includes a recipe without it, the other recipe will compile normally and will *not* converge until all compilation completes.

```ruby
run_resources :immediately do
  include_recipe 'creates_blah_txt'
  # This returns false (assuming the other recipe has a file resource)
  File.exist?('/blah.txt')
end
```

#### Chef::Resource.action defaults to immediate

Actions defined in a Resource default to immediate-run mode:

```ruby
action :create do
  file '/x/y.txt' do
    content 'Hello World'
  end
  # This prints Hello World
  puts IO.read('/x/y.txt')
end
```

`run_resources :delayed` can be called to flip it back off.

### run_recipe

Because some recipes want immediate execution, they will expect some way to call *other* recipes and have them execute immediately.  Since we guarantee that a recipe owns its own execution model, we can't just set `run_resources :immediately` on the other recipe; they may be *relying* on forward :immediate notifications.

Instead, we introduce `run_recipe`, which compiles and then converges a recipe or set of recipes as a self-contained unit.  The included recipes cannot notify resources outside of themselves and cannot be notified from outside.

```ruby
run_recipe 'mycookbook::create_blah_txt'
# This prints true
puts File.exist?('/blah.txt')
```

### Notifications

Notifications to and from `:immediate` resources work identically to other notifications: `:immediate` notifications always run immediately after the converging resource updates; and `:delayed` notifications are always put at the end of the queue after the converging resource updates.  The two implications of this that might not be apparent are:

- An `:immediate` resource can send an `:immediate` notification to a `:delayed` resource and cause it to execute *earlier* than it might otherwise (during the compile phase).
- An `:immediate` resource *cannot* send an `:immediate` notification to a resource that has not yet been compiled.


```ruby
execute 'already compiled, yay' do
  command 'ls'
  # This works
  subscribes :immediately, 'file[/x/y.txt]'
end

run_resources :immediately do
  file '/x/y.txt' do
    content 'Hello World'
    # This runs before 'not compile yet' compiles
    notifies :immediately, 'execute[already compiled, yay]'
    # This works and runs after everything runs:
    notifies :delayed,     'execute[not compiled yet]'
    # This FAILS:
    notified :immediately, 'execute[not compiled yet]'
  end
end

execute 'not compiled yet' do
  command 'ls'
end
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
