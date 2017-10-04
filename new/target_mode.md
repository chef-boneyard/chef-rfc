---
RFC: unassigned
Title: Chef Target Mode
Author: Thom May <thom@chef.io>
Status: Draft
Type: Standards Track
---

# Chef Target Mode

When deploying applications or systems, we frequently need to configure
appliances where Chef cannot run natively. To allow us to do so, we need
to run chef on a dedicated management node and interact with the
appliance remotely, via an API.

## Motivation

    As a site reliability engineer,
    I want to configure routers, switches and load balancers,
    so that my application functions correctly.

## Specification

The concept of a node in chef is a 1:1 mapping with a client, enabling a
single node to have several identities if needed. We can leverage this
facility to create a target mode, allowing a management node to run chef
for many appliances.
Target mode is enabled by several new configuration options:
 * `target`: The details for connectivity to the target
   system. The result of this configuration option should be a
   class instance that cookbooks can send messages to. This
   enables target mode, disabling ohai entirely.
 * `platform`: The platform that we're connecting to. Since we don't
   have ohai, this can be used to make decisions in a cookbook.

Since target mode does not affect the local node, we can run many target
mode chef client runs in parallel. Thus, a chef client run should only
block other chef client runs that affect the same target, rather than
being system wide.

For cookbook authors, target mode implies having a connection to the
node that enables RPC, via an API or using ssh or similar. Once
configured, this connection would be made available using a DSL method,
enabling cookbooks to build resources that interact with the target.

Target nodes would be assigned policies or `run_lists` as normal.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
