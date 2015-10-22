---
RFC: unassigned
Author: Lamont Granquist <lamont@chef.io>
Status: Draft
Type: Standards Track
---

# Title

Support a 'gem' DSL method for cookbook metadata to create a dependency on a rubygem.  The
gem will be installed via `chef_gem` after all the cookbooks are synchronized but before any
other cookbook loading is done.

## Motivation

    As a Chef User,
    I want to be able to use additional gems in libraries, attributes and resources,
    So I don't pull my hair/beard out in frustration.

## Specification

Allow users to specify additional gem dependencies like:

gem "poise"
gem "chef-sugar"

In the Chef::RunContext::CookbookCompiler#compile method a phase will be added before `compile_libraires` which will install all of the gem declarations from all of the synchronized cookbooks before any other
cookbook code is compiled.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
