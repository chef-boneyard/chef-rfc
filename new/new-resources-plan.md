---
RFC: unassigned
Author: John Keiser <john@johnkeiser.com>
Status: Draft
Type: Standards Track
---

# Resources 2.0

There are a number of separable RFCs that connect into a given whole (Resources
2.0).  The intent with Resources 2.0 is to:

- Make writing good resources much easier
- Make the resource API more powerful with read, write and diff
- Make resources usable outside of Chef
- Maintain backwards compatibility

## Motivation

    As a <<user_profile>>,
    I want to <<functionality>>,
    so that <<benefit>>.

## Specification

## Stage 1: DSL

### Cookbook Scope

Aim: allow for private resources that others should not use.
```ruby
# cookbooks/mycook/libraries/myresource.rb
provides :mycook_myresource, to: :cookbook_only
attribute :myattr

# cookbooks/mycook/libraries/myresource
mycook_myresource 'blah' do
  myattr 1
end

# cookbooks/OTHER/libraries/myresource
# ERROR: resource not found
mycook_myresource 'blah' do
  myattr 1
end
```

#### Dependent Cookbook Scope

Aim: provide resources to a cookbook and *dependent* cookbooks only, to allow
for disambiguation when two cookbooks use different resources with similar
names.

```ruby
# cookbooks/mycook/libraries/myresource.rb
provides :mycook_myresource, to: :cookbook
attribute :myattr

# cookbooks/dependent/metadata.rb
name 'dependent'
version '1.0.0'
depends 'mycook'

# cookbooks/mycook/libraries/myresource
mycook_myresource 'blah' do
  myattr 1
end

# cookbooks/dependent/libraries/myresource
mycook_myresource 'blah' do
  myattr 1
end

# cookbooks/OTHER/libraries/myresource
# ERROR: resource not found
mycook_myresource 'blah' do
  myattr 1
end
```

### Defaults

Aim: allow user to create defaults.

### Aliases

Aim: allow user to create resource aliases that let you type A and use custom
code to invoke resource B.

### Custom Scope

Aim: allow user to create resources, defaults and aliases in a custom scope, to
do what things like `with_chef_server` and `with_driver` do, but in a generic
way.

#### Custom Scope Inheritance

Aim: allow user to tweak other recipes and resources by providing defaults or
changing underlying behavior of the resources they use.  (This can easily be a
part of the official interface of a recipe.)

## Stage 2: Resource Structure

Aim: reduce friction for creating resources.

First, we let you specify actions directly on resources.  Resource attributes
are in scope for the action.

```ruby
class MyResource < Chef::Resource
  attribute :path, name_attribute: true
  attribute :content
  attribute :mode

  action :create do
    if content != IO.read(path)
      unless whyrun_mode?
        IO.write(path, content)
      end
      report_update "Update content of #{path}"
    end

    if mode != File.stat(path).mode
      unless whyrun_mode?
        system("chmod #{mode} #{path}")
      end
      report_update "Run 'chmod #{mode} #{path}'"
    end
  end
end
```

### Actions as recipes.

Aim: reduce friction for creating whyrun-safe, green-text-happy resources.

Brings the recipe DSL into scope for the action.

```ruby
class MyResource < Chef::Resource
  attribute :path, name_attribute: true
  attribute :content
  attribute :mode

  action :create do
    ruby_block "Update content of #{path}" do
      not_if { content.nil? || IO.read(path) == content }
      block { IO.write(path, content) }
    end

    execute "Update mode of #{path}" do
      not_if { mode.nil? || File.stat(path).mode == mode }
      command "chmod #{mode} #{path}"
    end
  end
end
```

### `inline_block`

Aim: Make the common `ruby_block { block { ... } }` pattern easier with `inline_block { ... }`

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
      not_if { mode.nil? || File.stat(path).mode == mode }
      command "chmod #{mode} #{path}"
    end
  end
end
```


### Nested Resource Types

Aim: namespaced resource types

```ruby
class Aws < Chef::Resource
  attribute :region, name_attribute: true

  def connection
    Aws.connect
  end
end

class Aws::Instance < Chef::Resource
  provides :instance, to_parent: Aws, parent_attribute: :aws

  attribute :aws, in_scope: true
  attribute :instance_id, name_attribute: true
  attribute :description

  action :create do
    connection.instances[instance_id].description = description
  end
end

aws 'us-east-1' do
  instance 'i-13423431' do
  end
  instance 'i-45964586' do
  end
end
```

## Stage 3: Property

Aim: disambiguate resource attributes from node attributes; allow easier
specification of valid types/values.

```ruby
class MyInstance < Chef::Resource
  property :base_path,       String
  property :config_path,     String
  property :number_of_users, Integer
  property :metadata
end
```

### Null Handling

Aim: allow things to be set to `nil` and make types non-nullable by default.

```ruby
class MyInstance < Chef::Resource
  property :a, String
  property :b
  property :c, [String, nil]
end

my_instance 'blah' do
  a nil # ERROR: must be String
  b nil
  c nil
end
```

### Validation

Aim: allow easy validation of properties.  TODO rspec syntax :)

```ruby
property :size, must_be: [ :large, :medium, :small, nil ]
```

### Coercion

Aim: allow varied user input with strictly typed values for easy resource writing.

```ruby
# Allow user to specify string or symbol
property :key, Symbol, coerce: proc { |s| s.to_sym }
# Allow an in-memory key *or* a path to be set
property :value, RSA::PrivateKey,
                 coerce: proc { |s| s.is_a?(String) ? RSA::PrivateKey.read(s) : s }
```

### Composite Types

Aim: allow laziness, coercion and type checking of array and hash members.

```ruby
property :child_instances, Array[MyInstance]
class MyInstance < Chef::Resource
  property :child_instances, Array[MyInstance]
end
```

### Path Type

Aim: make common case of path easy to handle and cross-platform

```ruby
property :chef_config_dir, Path, default: '~/.chef'
property :chef_config_file, Path, default: 'config.rb', relative_to: lazy { chef_config_dir }
```

## Stage 4: Read and Write

### Read API

Aim: make resources more useful, and make updates based on current value possible.

```ruby
class MyResource < Chef::Resource
  property :path,    name_attribute: true
  property :content, default { content }
  property :mode

  load do
    content IO.read(path)
    mode File.stat(path).mode
  end
end

puts my_resource('/x.txt').content
```

### Converging Differences

Aim: Make it easy to write a good test-and-set (*neither* test *nor* set unless
you have to).

```ruby
class MyResource < Chef::Resource
  property :path, name_attribute: true
  property :content
  property :mode

  action :create do
    converge :content do
      IO.write(path, content)
    end
    converge :mode do
      execute "chmod #{path} #{mode}" do
      end
    end
  end
end

# Will print nice green text explaining exactly what is changing and why
my_resource '/x.txt' do
  content 'Hello World'
  mode '0666'
end
```

## Stage 5: Dynamism

### Value Waits and Events

Aim: allow clearer expression of dependencies; allow for change listeners outside
of Chef

### Parallelism

### Immediate Mode

## Stage 6: More

### Parameterized Actions

### Nested Resources

Aim: namespacing for resource *names*.

### Using Chef Outside Chef




### Child Resources

- Resource may have children
- Resource.parent_resource - direct parent
- Resource.containing_resource - might be several levels up
- Resource.get_child_resource(<child resource ref>)
- Resource.notify_child_resource(:create, <child resource ref>, :immediately)
- Nested resources are referenceable via %w(a[b] c[d]).
- Parents are referenceable with '..'.  %w(.. a[b] c[d]).
- References in a resource, such as `notifies` and `subscribes`, are always
  relative to `..`.
- When `notifies :create, %w(a[b] c[d]), :immediately` is triggered, it calls `get_resource('../a[b]').notify_immediately(:create, "c[d]")`.
- When `notifies :create, %w(a[b] c[d])` is triggered, it calls `get_resource('../a[b]').notify_delayed(:create, "c[d]")`

### Resource Group

- `resource_group` groups resources together, with a single `notifies`, `subscribes`
  and guard, and optional nested references.
- A ChefRun is a resource group (the root resource group, in fact).
- `child_resource(%w(a b c))`
- `notify_child(c[d], ...)` means "call c[d].run_action(...)"
- `notify_child(..., :immediately)` means "add the immediate child as the next action in my queue."
- `notify_child(..., :delayed)` means "add the immediate child to the delayed_actions queue" (unless it is already there).
- TODO if we add a delayed action *again* after it has already run, should we run it a second time?
- Groups have their own resource_collection and delayed_actions queue for child resources.  The resource_collection is run first, and delayed_actions is run second.

### Parameterized Actions

- `action` is a child resource of a resource.
- `converge` is how things are converged.
- action is a resource
- Depends on Single-File Recipes and Child Resources
- Guard stuff moves into Action (much more customizable)
- Actions pull defaults from parent resource
- `action :resource, var1: Type, var2: Type do ... end` = action recipe

## Properties

### Property

- `property`: a better `attribute`
- Can set value to `nil`
- Lazy defaults
- rspec for validation
- Defineable types
- Coercion
- Deeply lazy hashes and collections

### Read API

- `current_resource` gets a cached current resource.  Its values will be loaded
  lazily via `load_current_attributes([:attr])`.
- `dup_identity` creates a new resource with the same identity as the current one
  but no desired values filled in.
- `load [:attrs] do` defines a load recipe that triggers if any of the given
  attributes is unset in `current_resource`.  `load` is run in the context of
  `dup_identity` and can
  set @ variables.  ISSUE: we'd like recipe syntax here too, but maybe doesn't
  work if you want @ too.
- If resource.mode is unspecified, current_resource.mode is triggered.
- `file('x.txt').mode` gives you the current value of mode.

### Converge API

- `action :create` is considered the default if you use at least one `converge`.
- `desired_attributes` is a Hash of desired attributes and their old and new
  value, in Difference form.
- `converge [:attrs] do` does a create-or-update for the given set of attributes.
- `create [:attrs] do` automatically creates the given set of attributes.
- `update [:attrs] do` auto-converges the given set of attributes.
- `perform_action` and `report_progress` are the green text API.

## Execution

### Parallelism

- `parallel_group` groups resources together to run completely in parallel.
  Supports `concurrency`.
- Work is always picked up in order.
- A `parallel_group` with `concurrency 1` behaves identically to `resource_group`.

### Partial Convergence

- Resources are converged with `.converge`.
- `converged?` states whether the resource has converged.
- Resources may return early.  `converged?` is the indication of
  whether they actually completed.  If they have not been completed, they run
  parent.notify_child(self, :delayed)

### Immediate Mode

- `<resource> <name>, converge_mode: :lazy_compile do`
- `<resource> <name>, converge_mode: :immediate do`

### Events, States and Not Until

## Using It Outside





### Nouns vs. Verbs

- Resources are a *model*.  Models can converge or not.
- `converge` is how you converge a resource.
- By default, you don't call `converge` on everything, you just call *actions*.
- Actions are external to a model.  They make changes to the model.
- `converge do` creates an Action during converge, if and only if the change needs
  to be made.
- converged? tells you whether a resource has converged successfully (whether its
  desires are known to be true or not).
- updated? tells you whether a resource had to make any changes to
- updates tells you exactly what changes a resource had to make
- updated? and updates are recursive with children
- An Action is a child of a resource.  `.converge` is how you call it.


B.
   B. "converge do" defines basic converge action
      -
      - converge = <run action(s) or default action>
      - converged? true/false
      - default action for nouveau resources: :converge
      - run_action = <create action resource, call converge>
      - Resource.converge is called by main loop
  is a resource with guards)
      - Side effect: actions can be parameterized and guarded separately
  B. `recipe :action do`
  C. Scope

2. `converge [:attr] do`
   A. Defines converge as a recipe
      - You are responsible for running your own `actions` if you have them

2. ``

  - Easy converge: converge [:attributes] do

### Specify actions as recipes in resource

- `recipe [:action] do`
- Current resource in scope
- Easy converge: converge [:attributes] do

### Child resources

- Make children (and parents) notifiable and referenceable
- Control convergence of children

### Resources reading and writing

- current_resource
- load_value
- `property`.load_value
- `property` default is current_resource.x before actual "default"

### `property`: a more awesome `attribute`


### Make resources usable outside of Chef

- Chef.converge do ... end
- ResourceClass.new/get/converge(..., context=nil)
- Bring-your-own-DSL

### Alternate convergence models

- parallel
- dependencies
- partial converge
- batch

### Resource event system with `not_until`

- notifies and subscribes take more complex arguments and block
- target resource has generic not_until and a few semaphore types

## Immediate mode

- ability to converge during compile
- compile-time dependency?
