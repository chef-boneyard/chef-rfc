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

As of Ohai 14, most plugins are disabled by default. New plugins have no effect
on the behavior of Ohai or Chef unless actively turned on.

Therefore, for any supported version of Chef/Ohai (including current-1), as long
as that version is >= 14 it is safe to add new plugins that only affect a new
namespace.

As such, the community should accept newly contributed Ohai plugins which do not
alter the namespaces of existing plugins.

## Downstream Impact

None

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
