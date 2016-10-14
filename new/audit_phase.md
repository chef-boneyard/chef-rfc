---
RFC: unassigned
Title: Audit Segment
Author:
- Christoph Hartmann <chartmann@chef.io>
- Thom May <thom@chef.io>
Status: Draft
Type: Standards Track
---

# Audit Segment

Support audit and compliance checks in a technology agnostic way.

## Motivation

    As a cookbook author,
    I want to ship custom controls,
    so that I can ensure my nodes are compliant.

    As a cookbook author,
    I want to use the most suitable compliance library,
    so that I can write controls effectively.

    As an operator,
    I want to ensure that my converge happens separately from my audit,
    so that I have full control over my runs.


## Specification

We will add a new directory, `audit`, to the top level of the cookbook.
In this directory will be tests, typically but not necessarily written
in Inspec, an operator can use to inspect the state of their system.

A cookbook may depend on other gems in the usual manner to provide
functionality to audit tests.

As per RFC-35, audits will be run in the `audit` phase, which occurs
after the `converge` phase completes.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
