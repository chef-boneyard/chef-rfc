# Parallelization in Chef Recipes

Chef presently runs the resources in a recipe serially, one after the next.  In this proposal, groups of resources can be created which will run in parallel.

## MVP (Minimum Viable Product) Features

### resource_group

To run a group of resources in parallel, you write it this way:

```ruby
resource_group :parallel do
  remote_file '/tmp/bigfile.txt' do
    source 'https://a.com/bigfile.txt'
  end
  remote_file '/tmp/bigfile2.txt' do
    source 'https://a.com/bigfile2.txt'
  end
end
```

`resource_group` groups a set of resources together to apply a behavior to all of them.  It can take a options, including `:serial`, `:parallel`, and `:concurrency => n` (the maximum number of things to do simultaneously).

By default, a `resource_group` is `:serial`, meaning resources are executed in order, one by one.

### Declaring Parallel Safety

In order to run inside a `:parallel` group, a resource must declare that it is parallel safe.  To do this, it should override the `parallel_safe?` method and return `true`.  If the `parallel_safe?` method is missing or returns `false`, the recipe will fail to compile.

### Notifications

If a resource in a parallel group notifies another resource, behavior will depend on whether the notified resource is parallel-safe.  If it *is* parallel-safe, the notification will be queued to run as part of the existing parallel group.  If it is *not* parallel-safe, the notification will be queued to run after the entire parallel group completes.

### Failure Handling

If a resource action in a parallel group fails, the parallel group will run all other actions to completion (or failure) before exiting the recipe.

### Group notifications

When the entire group finishes, it is sometimes desirable to send a single notification.  The `subscribes` and `notifies` primitives work inside a `resource_group` (whether it is serial or parallel) and if *any* resource is changed, the group will send the notification.

resource_groups can also be given names if a string is passed as the first parameter:

```
resource_group 'hi' do
  ...
end
file '/x.txt'
  action :nothing
  subscribes 'resource_group[hi]', :create
end
```

### Output formatting: groups

Groups are a form of nested resource (whose output would be similar to that of use_inline_resources).  Nested resources currently print something like this:

```
Recipe: @recipe_files::/Users/jkeiser/oc/code/opscode/chef-rfc/blah.rb
  * compound_resource[a] action create  * file[/Users/jkeiser/x.txt] action create (up to date)
  * file[/Users/jkeiser/y.txt] action create (up to date)
 (up to date)
```

With this proposal, a resource_group or other compound resource would print like this:

```
Recipe: @recipe_files::/Users/jkeiser/oc/code/opscode/chef-rfc/blah.rb
 * compound_resource[a] action create
   * file[/Users/jkeiser/x.txt] action create (up to date)
   * file[/Users/jkeiser/y.txt] action create (up to date)
   compound_resource[a] action create (up to date)
```

### Output formatting: parallelism and batch

There are two major ways of formatting output when many things run in parallel: batched output or streamed output.  In the batch case, we queue output for each resource and print it when the resource completes.  In the streamed case, we print each piece of output as the resource goes.  By default, output is batched.  Streamed output is a future enhancement.

## Future Features

This is intended to give a flavor of the future--anything underspecified here will require a new RFC.

### Thread pool configuration

The `Chef::Config.concurrency` parameter, and `--concurrency` argument to `chef-client`, limits the number of concurrent parallel resources globally.  To limit them specifically, you add parameters to the `in_parallel` directive like so:

```ruby
resource_group :parallel, :concurrency => 10 do
  ...
end
```

### in_serial

To run a group of actions serially, but inside a parallel grouping, you write this:

```ruby
resource_group :parallel do
  resource_group do
    directory '/dir1'
    file '/dir1/blah.txt' do
      content 'hi'
    end
  end
  resource_group do
    directory '/dir2'
    file '/dir2/blah.txt' do
      content 'hi'
    end
  end
end
```

## Custom parallelization

Some resource types (such as packages) handle parallelization internally.  We will create a directive allowing multiple resources to collaborate and run a single parallel thing to handle multiple actions.  For example, if you wrote 10 package directives inside `resource_group :parallel`, they would cooperate and run a single package installation command, passing all the packages to it.

### Output formatting: parallelism and streaming

We will support streamed output from parallel groups, so that you can see when things start and when they end.  How this happens and what the output looks like will be specified later.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
