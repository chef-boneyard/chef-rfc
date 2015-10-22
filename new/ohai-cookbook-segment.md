---
RFC: unassigned
Author: Lamont Granquist <lamont@chef.io>
Status: Draft
Type: Standards Track
---

# Title

Support ohai plugins under an `ohai` top level directory in cookbooks.  Load all
ohai plugins in all synchronized cookbooks after cookbook synchronization.

## Motivation

    As a Chef User,
    I want to have my custom Ohai plugins loaded on first bootstrap,
    So I don't have to run chef twice.

    As a Chef User,
    I want my Ohai plugins loaded before attributes and compile/converge mode,
    So I can use them without worrying about cookbook execution ordering.

    As a Chef User,
    I want my Ohai plugins synchronized with my cookbooks,
    So that I don't incure more unavoidable round-trips to the Chef Server.

    As a Chef Developer,
    I want Ohai plugins as a first-class object,
    So that I don't have to compile recipes to discover templates that drop plugins.

## Specification

The "segments" of a cookbook will be extended to include an "ohai" segment.  In this
segment there will be plugins which are intended to be copied to the Ohai `plugin_path`.  All files in this segment will be copied, recursively, maintaining directory
structure.

In the Chef::RunContext::CookbookCompiler#compile method a phase will be added after
`compile_libraries` and before `compile_attributes` which will copy the ohai plugins from the cookbook segment and will load all of the discovered plugins.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
