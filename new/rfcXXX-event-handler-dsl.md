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

Currently chef client includes coupld of default handlers (doc, base) during
initialization setup. An additional empty event handler (i.e. just subclass
of base handler without any custom logic) can be added along side the
existing hanlder which will used as a space holder for user specific hooks.
A recipe DSL method will be intrduced, which will allow user to tap into any of the events and execute custom logic.

Following is an example of sending hipchat notification on chef run failure.

```ruby
on :run_failed do |exception|
  hipchat_notify exception.message
end
```

Following is another example of taking a distributed lock via etcd, to 
prevent concurrent chef runs in different nodes

```ruby
lock_key = "#{node.chef_environment}/#{node.name}"

on :converge_start do |run_context|
  Etcd.lock_acquire(lock_key)
end

on :converge_complete do
  Etcd.lock_release(lock_key)
end
```

Following is another example of sending a hipchat alert on a key config change

```ruby
on :resource_updated do |resource, action|
  if resource.to_s == 'template[/etc/nginx/nginx.conf]'
    Helper.hipchat_message("#{resource} was updated by chef")
  end
end
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
