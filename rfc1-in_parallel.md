# Parallelization in Chef Recipes

Chef presently runs the resources in a recipe serially, one after the next.  In this proposal, user-selected groups of resources will run their actions in parallel.

## MVP (Minimum Viable Product) Features

### in_parallel

To run a group of resources in parallel, you write it this way:

```ruby
in_parallel do
  remote_file '/tmp/bigfile.txt' do
    source 'https://a.com/bigfile.txt'
  end
  remote_file '/tmp/bigfile2.txt' do
    source 'https://a.com/bigfile2.txt'
  end
end
```

### Declaring Parallel Safety

In order to run inside an `in_parallel` block, a resource must declare that it is parallel safe.  To do this, it should override the `parallel_safe` method and return `true`.  If the `parallel_safe` method is missing or returns `false`, the recipe will fail to compile.

### Notifications

If a resource in a parallel group notifies another resource, behavior will depend on whether the notified resource is parallel-safe.  If it *is* parallel-safe, the notification will be queued to run as part of the existing parallel group.  If it is *not* parallel-safe, the notification will be queued to run after the entire parallel group completes.

### Failure Handling

If a resource action in a parallel group fails, the parallel group will run all other actions to completion (or failure) before exiting the recipe.

## Future Features

### Thread pool configuration

The `Chef::Config.concurrency` parameter, and `--concurrency` argument to `chef-client`, limits the number of concurrent parallel resources globally.  To limit them specifically, you add parameters to the `in_parallel` directive like so:

```ruby
in_parallel :concurrency => 10 do
  ...
end
```
### in_serial

To run a group of actions serially, but inside a parallel grouping, you write this:

```ruby
in_parallel do
  in_serial do
    directory '/dir1'
    file '/dir1/blah.txt' do
      content 'hi'
    end
  end
  in_serial do
    directory '/dir2'
    file '/dir2/blah.txt' do
      content 'hi'
    end
  end
end
```

## Custom parallelization

Some resource types (such as packages) handle parallelization internally.  We will create a directive allowing multiple resources to collaborate and run a single parallel thing to handle multiple actions.  For example, if you wrote 10 package directives inside `in_parallel`, they would cooperate and run a single package installation command, passing all the packages to it.
