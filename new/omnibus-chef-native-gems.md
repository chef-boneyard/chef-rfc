---
RFC: unassigned
Author: Lamont Granquist <lamont@chef.io>
Status: Draft
Type: Standards Track
---

# Title

Omnibus Chef Native Gem Additions

## Motivation

    As a Chef User,
    I want to have omnibus-chef ship with nokogiri,
    Because that will speed up my initial converges, and ease my pain at installing it.

    As a Chef User,
    I want to have omnibus-chef ship with popular Open Source databases,
    Because that will speed up my initial converaes, and again ease my pain.

    As a Postgres Cookbook Author,
    I want to obliterate what we had to do to install Postgres client into omnibus from a cookbook,
    Because, seriously, have you look at that code?


## Specification

The supporting native libraries:

* libxml2
* libxslt
* libpq
* MariaDB Connector/C

And the following gems:

* nokogiri
* pg
* mysql2

Will be added to the omnibus-chef distribution on all Tier #1 systems.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
