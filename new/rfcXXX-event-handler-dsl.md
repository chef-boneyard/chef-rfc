---
RFC: unassigned
Author: Ranjib Dey (ranjib@linux.com)
Status: Draft
Type: Standards Track
---


# Recipe DSL method for event handler hooks

Allow cookbook authors easily add custom logic on Chef events.


## Motivation

Chef has an extensive event handler mechanism, but incorporating
some custom logic with any of the events is onerous process which involves
subclassing the based evant handler and adding it via the config. This RFC
proposes a recipe DSL method to ease this. For new chef users this increases
the entry barrier, while for experienced chef users this amounts to writing
boilerplate code.

## Specificatiin

Currently chef client sets up couple of default handlers (doc, base) during
initialization. An additional empty event handler (i.e. just subclass
of base handler without any custom logic) can be added along side the
existing hanlder which will used as a space holder for user specific hooks.

A top level (::Chef) method will be introduced (`event_handler`) along side the
main event handler DSL (`on`). Users can tap into one of the event types
(as specified in base dispatcher) using this DSL to execute their business logic.

The additional top level method will allow the handler DSL usage in and outside
of recipes, and also ease writing backward compatible changes in the actual `on`
method.

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
