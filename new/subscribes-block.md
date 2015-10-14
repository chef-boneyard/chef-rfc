---
RFC: unassigned
Author: John Keiser <jkeiser@chef.io>
Status: Draft
Type: Standards Track
Tracking:
  - https://github.com/chef/chef/issues/X
---

# Subscribe Blocks

Add the ability to run a block instead of an action in subscribes and notifies.

## Motivation

    As a Chef user,
    I want a pattern allowing me to avoid the service restart problem,
    So that my services don't get restarted the first time I run a new machine.

    As a Chef user,
    I want a pattern allowing me to accumulate desired state in one resource before it is executed,
    So that I can let many different resources update at once in a batch.

    As a Chef user,
    I want update patterns that don't actually converge anything directly,
    So that I can accomplish these patterns without showing a confusing new action in the Chef log.

## Specification

notifies and subscribes each have a new form, taking a block instead of an action, which will call the block when the notification occurs rather than running an action. The block is evaluated in the context of the subscribing resource.

The old forms all still work; the new form is additive.

## Uses

### Accumulating desired state

```ruby
# When the templates with the list of packages changes, make sure and install the packages.
template '/my-packages.txt' do
  notifies('package[all_the_things]', :immediately) { packages.push *current_value.content.split(",") }
end
template '/chef-packages.txt' do
  notifies('package[all_the_things]', :immediately) { packages.push *current_value.content.split(",") }
end
package 'all_the_things' do
  package_name []
end
```

### Avoiding multiple destructive operations

```ruby
file '/etc/config-file.txt' do
  content 'config!'
end
file '/etc/init.d/x/start.sh' do
end
# The service will only be processed once; if the configuration is updated, we
# upgrade the action to :reload; if the configuration is started, we upgrade
# the action to :restart.
service 'x' do
  subscribes('file[/etc/config-file.txt]', :immediately) { action :reload }
  subscribes('file[/etc/init.d/start.sh]', :immediately) { action :restart }
end
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
