---
RFC: 109
Title: Ohai new plugins policy
Author: Phil Dibowitz <phil@ipom.com>
Status: Accepted
Type: <Standards Track, Informational, Process>
---

# Ohai new plugins policy

To allow Chef to move fast while still providing stability, this lines out a
policy for clarity.

## Motivation

    As a Chef developer,
    I want to be able to provide new functionality to the community
    so that they can use it.

    As a Chef user,
    I want to be able to leverage new functionality as quickly as possible
    with minimal work while not breaking existing features.
    
    As a Chef user,
    I also want to be able to discover available plugins.

## Specification

New Ohai plugins should be able to be added in the current version, provided
they do not change an existing namespace in a non-additive way (see below for
examples).

Further, by default we expect new plugins to *not* have `optional` set, unless
there is a reason not to (for example, we expect it to be load-heavy in some
environments).

Ohai changes to N-1 are only added to fix bugs.

Examples:

* Adding new fields to an existing plugin namespace should be allowed in
  Example: https://github.com/chef/ohai/pull/1104/
* Adding an entirely new plugin that uses a distinct top-level namespace
  Example: https://github.com/chef/ohai/pull/1170
* Fixing a bug should be allowed in `current` and `current-1`.
  Example: https://github.com/chef/ohai/pull/1084
* Changing an existing namespace should *not* be allowed in `current` or
  `current-1`
  Example: Moving `node['filesystem']` to the `filesystem2` format.

## Downstream Impact

None

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
