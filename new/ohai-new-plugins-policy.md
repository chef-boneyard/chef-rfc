---
RFC: unassigned
Title: Ohai new plugins policy
Author: Phil Dibowitz <phil@ipom.com>
Status: Draft
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

## Specification

New Ohai plugins should be able to be added in the current version, provided
they do not change an existing namespace in a non-additive way (see below for
examples). Adding such a plugin to current-1 Ohai, should also be permitted,
provided `optional` is set to `true` for maximum safety.,

Examples:

* Adding new fields to an existing plugin namespace should be allowed in
  `current` and set to `optional` in `current-1`.
  Example: https://github.com/chef/ohai/pull/1104/
* Adding an entirely new plugin that uses a distinct top-level namespace
  should be allowed in `current` and `current-1`.
  Example: https://github.com/chef/ohai/pull/1170
* Fixing a bug should be allowed in `current` and `current-1`.
  Example: https://github.com/chef/ohai/pull/1084
* Changing an existing namespace should not be allowed in `current` or
  `current-1`
  Example: Moving `node['filesystem']` to the `filesystem2` format.

## Downstream Impact

None

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
