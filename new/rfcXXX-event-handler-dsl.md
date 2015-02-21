---
RFC: unassigned
Author: Ranjib Dey (ranjib@linux.com)
Status: Draft
Type: Standards Track
---


# Recipe DSL method for event handler hooks

Allow cookbook authors to easily add custom logic on Chef events.


## Motivation

Chef has an extensive event [disptach mechanism](https://github.com/chef/chef/blob/master/lib/chef/event_dispatch/base.rb).
But incorporating some custom logic against any of the events is an onerous process which involves
subclassing the based event handler and adding it via the config. This RFC
proposes a recipe DSL method to ease this. For new chef users this will reduce
the entry barrier.

## Specification

Currently chef client sets up couple of default handlers (doc, base) during
initialization. An additional empty event handler (a subclass
of the base handler without any custom logic) can be added alongside the
existing handlers which will used as a placeholder for user specific hooks.

A top level (::Chef) method will be introduced (`event_handler`) to wrap the
main event handler DSL (`on`). Users can tap into one of the event types
(as specified in base dispatcher) using this DSL to execute their custom logic.

The additional top level method(`Chef.event_handler`) will allow the handler
DSL usage in and outside of recipes and also ease writing backward compatible
changes for the `on` method if need be.

Following is an example of sending hipchat notification on chef run failure.

```ruby
Chef.event_handler do
  on :run_failed do |exception|
    hipchat_notify exception.message
  end
end
```

Following is another example of taking a distributed lock via etcd, to 
prevent concurrent chef runs in different nodes

```ruby
lock_key = "#{node.chef_environment}/#{node.name}"

Chef.event_handler do
  on :converge_start do |run_context|
    Etcd.lock_acquire(lock_key)
  end
end

Chef.event_handler do
  on :converge_complete do
    Etcd.lock_release(lock_key)
  end
end
```

Following is another example of sending a hipchat alert on a key config change

```ruby
Chef.event_handler do
  on :resource_updated do |resource, action|
    if resource.to_s == 'template[/etc/nginx/nginx.conf]'
      Helper.hipchat_message("#{resource} was updated by chef")
    end
  end
end
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
