---
RFC: 112
Title: Chef Target Mode
Author: Bryan McLellan <btm@chef.io>
Status: Accepted
Type: Standards Track
---

# Chef Target Mode

When deploying applications or systems, we frequently need to configure
applications where Chef cannot run natively.

## Motivation
    
    As a site reliability engineer,
    I want to configure routers, switches and load balancers,
    so that my application functions correctly.

## Specification

A node is any machine - physical, virtual, cloud, network device, etc. - that
is managed by Chef. While typically the Chef client runs on the node that it is
managing, target mode would enable the client to manage a remote node.

The management node is the machine that Chef client runs on and is likely to be a
specific machine chosen for running the client against multiple target nodes.
Ad-hoc runs against target nodes are intended to be exposed to the user through
the 'chef apply' ad-hoc user experience currently associated with Chef
Workstation.

Having each target node be represented by a separate Chef node leverages
the existing functionality in the ecosystem with only minimal modification. For
example, the run list for a target node would be changed using existing
patterns, `knife node run_list add TARGET_NODE RUN_LIST_ITEM`.

Having each target node be managed by a separate Chef client run avoids
refactoring the run\_context to account for multiple node objects at once and
choosing between them.

Target mode would be enabled by setting the `target` configuration setting.
This could be either from a configuration file or a command line argument, e.g.
`chef-client --target router.local`. When in target mode, many default local
file paths would automatically change based on the target name. For example,
the lock file name could change to `chef-client-TARGET_NAME.pid` and the
cache path could have a sub-directory added based on the target name. This
allows all other settings such as `chef_server_url` and `client_key` to be
inherited from the management nodes `client.rb`. Alternatively, multiple
configuration files could be maintained, one for each target node.

Initially target mode would disable the use of Ohai in the client run until
such time as similar support is added to Ohai. Thus target mode would require
`platform` to be set on the node object (`--json-attributes`). Train's
`conn.os[:family]` and `conn.os[:release]` functionality could likely be
leveraged until that time. Otherwise, target mode would require `platform` to
be set on the node object via `--json-attributes` or a similar fashion. An
`fqdn` or `ipaddress` attribute would also have to be set in the same way.

`Chef::NodeMap` would be modified such that `Chef::Provider.provides` would
take a `target_mode` option. This ensures that only providers that support
target\_mode are available when running in target mode. For example:

```
provides :interface, platform: "cisco", target_mode: true
```

Initially only the `execute` resource would be expected to be supported but
custom resources could quickly be developed in cookbooks.  Over time some core
resources and providers may be updated or modified to support target mode
against traditional platforms. This would facilitate `chef apply` use without
having to install the chef-client on the target node and managing nodes running
on esoteric architectures that we don't build binaries for.

Train would be used as the transport library for connecting to target nodes.
Providers could use a new mixin that would use the Train connection if we were
in a target mode or otherwise shell\_out to execute a command.

### Secrets

The storage of usernames, passwords, keys, and other secrets will be
initially accomplished using the credentials file defined in
[RFC099](https://github.com/chef/chef-rfc/blob/master/rfc099-authentication-config-file.md).
We expect to later develop a secrets abstraction layer that facilitates the use
of existing secrets solutions like encrypted data bags, Chef Vault, and Hashi
Vault, without having to add support to all of these to target mode directly.

## Downstream Impact

Chef Workstation / chef-apply would be modified to use target mode when the
remote machine doesn't have a supported Chef installation.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
