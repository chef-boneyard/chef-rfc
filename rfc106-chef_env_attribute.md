---
RFC: 106
Title: Expose more settings as attributes
Author: Thom May <thom@may.lt>
Status: Final
Type: Standards Track
Tracking: https://github.com/chef/chef/pull/6967
---

# Exposing some core settings as attributes

There are a number of settings, such as the node name and the environment, that we've historically not exposed as automatic attributes.
The environment attribute is a bit more complicated in the world of
policy groups, and this RFC clarifies that situation too

## Motivation

    As a system engineer,
    I want to make decisions based on the environment or policy group of a node,
    so that I get correct behaviour in my cookbooks.

## Specification

We will expose the automatic attribute `name`, reflecting the name of
the node.

We will expose the automatic attribute `chef_environment`. In non-policy
setups, the attribute will expose the environment that the node is in.

In policy setups, it will expose the name of the policy group the node
is in. We will also ensure that `node.chef_environment` returns the same data. We'll also expose `policy_group` and `policy_name`, to go along with `policy_revision`.

## Downstream Impact

Cookbooks will have easy access to more attributes.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
