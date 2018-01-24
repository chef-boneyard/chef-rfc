---
RFC: unassigned
Title: `chef_environment` as an attribute
Author: Thom May <thom@chef.io>
Status: Draft
Type: Standards Track
---

# Exposing the chef\_environment attribute

Historically we've not exposed the Chef environment as an automatic
attribute, although tools such as poise-hoist have changed that. Policy
groups make the whole situation a little more murky.

## Motivation

    As a system engineer,
    I want to make decisions based on the environment or policy group of a node,
    so that I get correct behaviour in my cookbooks.

## Specification

We will expose the automatic attribute `chef_environment`. In non-policy
setups, the attribute will expose the environment that the node is in.

In policy setups, it will expose the name of the policy group the node
is in. We will also ensure that `node.chef_environment` returns the same data.

## Downstream Impact

Cookbooks will have easy access to see which environment they're running
in.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
