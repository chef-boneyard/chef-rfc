---
RFC: 85
Title: Remove unused cookbook metadata
Author: Thom May <thom@chef.io>
Status: Final
Type: Standards Track
---

# Remove Unused Cookbook Metadata

There are a set of metadata fields that have never been really supported
by Chef, and so we should remove them.

## Motivation

    As a community advocate,
    I want to ensure that cookbook maintainers focus on the things that
    matter,
    so that they can write better cookbooks.

    As a chef developer,
    I like removing code,
    so that there are fewer bugs.

## Specification

Mark as deprecated and subsequently remove the `recommends`, `suggests`,
`conflicts`, `replaces` and `grouping` metadata fields.

## Downstream Impact

Chef Server should be updated to not serve this metadata, docs need to
be updated. Also, generators such as `chef generate`, `berks cookbook`
need to be updated to ensure they do not create metadata files with
those fields.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
