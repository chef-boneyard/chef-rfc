---
RFC: unassigned
Author: Daniel DeLeo <dan@chef.io>
Status: Draft
Type: Standards Track
---

# New Attributes API

This RFC proposes a new API for setting and accessing attributes in
cookbooks. The goals of this new API are:

* Separate desired and observed state.
* Structure the syntax in a way that "trainwreck" errors
  (`NoMethodError` for `[]` on `nil`) can be avoided.
* Structure the syntax in a way that attribute tracing can be
  implemented simply.
* Separate node-specific persistent storage from
  cookbook/role/environment attributes.
* Structure the syntax in a way that can be implemented efficiently.

The new API is added alongside the existing API, so existing code will
work without modification.

## Motivation

There are several motivations for this change.

### Separate Desired and Observed State

In the current attributes system, system "facts" determined by Ohai are
intermixed with user attributes, which are generally used to define the
desired state of the system. For example, `node[:fqdn]` gives the
system's FQDN, as determined by Ohai at the beginning of the Chef run,
and identical syntax is used to reference a user-defined attribute, such
as `node[:mysql][:version]`. As a result, it's not possible to know
which attributes are "facts" except by committing to memory the list of
attributes provided by Ohai. Defining a new syntax where Ohai and
user-defined attributes are accessed by different methods makes cookbook
code clearer.

Additionally, separating Ohai data from user-defined attributes
eliminates the possibility of attribute name collisions. For example, a
user might wish to set the FQDN of a host with Chef and use the `fqdn`
attribute to define the desired FQDN, or create an Ohai plugin to detect
the currently installed version of MySQL, storing this as
`node[:mysql][:version]`. With the current attributes system, the user
can't use these attribute names because they conflict with existing Ohai
or cookbook attributes.

### Eliminate Trainwreck Errors

The current attribute system presents node data as a nested collection
of Hash-like objects. There are some unfortunate limitations of this
model that lead to frustrating behavior for users. In particular, code
like this:

```ruby
node[:foo][:bar][:baz]
```

May raise a `NoMethodError` with the message:

```
undefined method `[]' for nil:NilClass
```

Note that in this example, it's ambiguous as to which part of the
attribute structure is missing, as this error will occur in an identical
way if either `node[:foo]` or `node[:foo][:bar]` are `nil`.

The UX of this error case cannot be significantly improved without
abandoning the nested Hash model. If an object other than `nil` was
returned for accessing a missing key, then code like
`do_something if node[:some_attribute_present]` would break (Ruby does
not allow custom false-y types), and monkey patching `nil` is
error-prone because `nil` is an immediate object (there is only one
instance).

### Enable Attribute Tracing

A common problem when developing cookbook code is attributes containing
unexpected values, which can be frustrating to debug. The current
implementation of attributes makes implementation of a tracing feature
difficult; in particular, it requires that attribute objects have
circular references to their parent objects so that the full attribute
path is known when setting a new attribute value. It is preferable to
avoid circular references because code that blindly walks the object
graph (such as a string inspection method) may enter an infinite loop if
it does not correctly guard against this case. Additionally, edge cases
such as "reparenting" a part of the node tree may be difficult to
implement correctly.

Providing an attributes API where the full attribute path is known when
new attributes are set would greatly ease the implementation of the
tracing feature.

### Separate Node-Specific Persistent Storage from Other Attributes

So-called "normal attributes" in the current attributes API have a
unique behavior compared to other attributes in that they are persisted
between Chef Client runs. While this behavior is useful and necessary
for some use cases, it causes some frustrations for users:

* learning chef attributes is more complicated, since documentation and
  recommendations are more complicated to understand.
* "Phantom" attributes. Users remove an attribute, or modify a
  complicated data structure, but their changes are mysteriously not
  applied because the normal attributes from a previous run are not
  cleared.
* Recipes that generate node data that needs to be persisted must call
  `node.save` manually, to ensure that persisted data is not lost in the
  event that the chef-client run subsequently fails. This causes issues
  with search data consistency, increased server load, and other
  problems.

### Enable More Efficient Implementation

The current implementation has poor performance when attributes are
mutated and then read frequently. Chef 12 introduces a partial cache to
mitigate the problem, but this doesn't completely solve the performance
issues in certain degenerate cases. Due to the limitations of the
existing API, it is difficult to improve the performance further. The
proposed API should allow for straightforward implementation of a
granular merged attribute cache.

### Method Missing Method Name Collisions

The current attributes system allows attributes to be accessed via a
`method_missing` API, e.g., `node["fqdn"]` can also be accessed as
`node.fqdn`. While this makes the code appear more readable,
implementing it directly on the `node` object leads to method name
collisions which can be confusing for users. For example:

```
node.foo              # returns node['foo']

node.chef_environment # returns the environment, which is an ivar on the
                      # node object

node.class            # returns the Chef::Node symbol
```

Providing a new API where attribute access occurs via arguments to
statically defined methods eliminates this source of ambiguity.

## Specification

### Ohai Data Access

TBD

### Default and Override Attribute Set and Access

TBD

### Node-Specific Data Storage Set and Access

Syntax is TBD.

Node-specific storage will initially be implemented as a facade on top
of the existing "normal" attributes structure. In the future we may
propose additional enhancements to this API to provide pluggability,
orchestration support, and/or improved authorization behaviors.

## Rationale

### About Trainwreck Errors

Trainwreck errors are a common problem in Chef, and the appeal of making the
error more descriptive is evident. It would be advantageous to simply improve
the error message without requiring users to migrate to a new attributes API,
but there are several limitatations of Ruby that make this impossible to do
correctly.

In Ruby, `nil` and `false` are the only "falsey" values. Both of these objects
are "immediate," meaning that there is only one instance of them in the Ruby
VM. If one creates a subclass of `NilClass` or `FalseClass`, instances of that
subclass will _not_ be "falsey."  Therefore the return value for fetching a
nonexistent key must be either `nil` or `false` or else code like
`do_something if node["key_that_may_exist"]` will not function correctly.

Ruby does allow setting instance variables on immediate objects, e.g.:

```ruby
nil.instance_variable_set(:@foo, "hello")
nil.instance_variable_get(:@foo)
# => "hello"
```

Taking advantage of this, combined with monkeypatching NilClass, it's possible
to fix the simplest case of trainwreck error. For example, if `node["a"]` is
`nil`, we could set an instance variable on `nil` to note that the last
attribute we attempted to access was "a", and handle method missing such that
`node["a"]["b"]` would explain which attribute was missing in the error
message. This approach has some unfortunate drawbacks, however. Consider the
following cases:

```ruby
Hash.new["foo"]["bar"]
```

Since there is only one `nil`, this code would trigger the `method_missing`
hack. This could be mitigated by disabling the hack if the special instance
variable is not set; however, there are still cases where this approach would
produce an incorrect error. For example:

```ruby
unless node["no_value_for_this_key"]
  Hash.new["foo"]["bar"]
end
```

In this case, the first line would necessarily set the instance variable on
nil, but `nil[]` isn't called until the second line, where the custom error
handling would produce a completely incorrect error message stating that the
code failed because `node["no_value_for_this_key"]` was `nil`. Since many ruby
types implement `[]`, bizarre error messages could be produced in a wide
variety of cases, depending on what type the user expected to have.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

