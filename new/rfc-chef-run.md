---
RFC: unassigned
Title: chef run command
Author: JJ Asghar <jj@chef.io>, Edmund Haselwanter <me@ehaselwanter.com>
Status: Draft
Type: Process
---

# chef run

The ability to run "one off" recipes to remote machines would be able to empower
a system administrator to leverage Chef and a single Chef recipe to validate a state
of a machine. Having command built into the ChefDK would allow for quick adoption
of Chef's main builtin resources in turn helping with education and the "15 minute"
story of chef.

A good example recipe would be something like `install-and-stop-nginx.rb`:

```ruby
package "nginx" do
  action :install
end

service "nginx" do
  action [ :stop ]
end
```

With this recipe you can ship it off to your clients, see if Chef is installed,
if not, run the `curl -L https://chef.io/chef/install.sh | sudo bash`
then would pragmatically run `chef-client -z install-and-stop-nginx.rb` and have it
us it's idempotent way to verify than nginx is installed but down.

With this tooling the inverse would be possible with something like the following
with a `start-nginx.rb`:

```ruby
service "nginx" do
  action [ :start ]
end
```

With the same workflow, allowing you to bring up your nginx web servers.

## Motivation

    As a system administrator,
    I want to leverage chef resources in a disposable manner,
    so that I can run disposable scripts on remote machines.

## Specification

The general user experience would be the following:

```
$ chef run <ssh|winrm> <hostname> recipe.rb
$ chef run <ssh|winrm> <list-of-hostnames.txt|yml> recipe.rb
```

## Downstream Impact

- There is a `knife` plugin called `knife-solo` that does this type of work, but
having it baked into the chefdk would allow for a natural adoption.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
