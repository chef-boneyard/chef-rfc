---
RFC: unassigned
Author: John Keiser <jkeiser@chef.io
Status: Draft
Type: Standards Track
---

# Allow Current Value To Be Read From Resource

Resources get a `current_value` method, which discovers the current value of
the resource.

## Motivation

    As a Chef user,
    I want to read the current value of certain resources (reading AWS object ids is a prime example),
    so that I can do custom things in my recipes that the resource writers didn't think about.

    As a Chef user,
    I want to read the current value of certain resources,
    So that I can make decisions in my recipes (such as only_if) based on actual data.

    As a Chef resource developer,
    I want to be able to expose all the read code I wrote to my users,
    So I don't have to tell them to copy and paste it.

## Specification

All Resources get a method, `current_resource`, that returns the current value
as a new resource. It does not cache this value. It returns `nil` when the
resource does not exist. By default, it is implemented by creating the provider
for one of the resource's actions, calling `load_current_resource` on that.

This is additive: it is fully backwards-compatible, and even applies to old
resources (not just ones with the new DSL using `property` and
`load_current_value`).

An example use:

```ruby
# Clean up after old versions of the blarghle gem that don't clean up after
# themselves
execute 'rm -rf /var/blarghle/data' do
  only_if { g = gem_package('blarghle').current_resource; g && g.version.to_f < 2.0 }
end

gem_package 'blarghle' do
  version '>= 2.0'
end
```

### Discussion: *Should* Resource State Be Easy To Get?

There is a central concern in Chef around the compile/converge model. When you
write this:

```ruby
package 'httpd'

service 'httpd' do
  action [ :enable, :start ]
  only_if File.stat('/var/www/html').owner == 'root'
end
```

The httpd package is not installed until converge time (*after* both package and
service are defined, so the recipe fails to compile (since /var/www/html is
not yet installed), the `stat` call raises an exception. The same problem will
occur if the user writes
`only_if directory('/var/www/html').current_resource.owner == 'jkeiser'`.

This causes the users first true encounter with the compile/converge model, and
their first encounter with this is generally a frustrating and despair-inducing
one. The answer, of course, is to put the { } in a block in `only_if`, so that
it will be executed late, but the user doesn't know that when they write this
code.

Why is that an issue? The argument could be made that making state *too easy*
to access will encourage more users down this road, into heartbreak. By making
state hard to access at all, we have made it less likely they will access it in
the wrong place.

This RFC's position is that users who want to do this will find a way,
*plus* have the heartache of having to learn Ruby APIs to rewrite code that
*already exists inside a function in the Provider for the resource*. So the
cost being mitigated, the *benefit* is definitely large enough that users want
it. The Provisioning AWS driver, for example, has an `aws_object` method because
users were demanding some way to access current state. This resolution,
compile/convergey though it was, was much less burdensome than forcing them to
learn how to construct the AWS APIs and replicate the code in Provisioning that
would look up the objects.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
