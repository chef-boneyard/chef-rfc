---
RFC: 103
Title: Disable Passwd and Sessions Ohai plugins
Author: Thom May <thom@chef.io>
Status: Accepted
Type: Informational
---

# Disable the Passwd and Sessions Ohai plugins

We get a large number of user reports that these two plugins can cause a
huge amount of unwanted storage use, especially in large enterprises
with nodes hooked up to an AD tree. We should disable them by default
in Chef 14, and provide appropriate notifications.

## Motivation

    As an Operations Engineer,
    I want to run my Chef Server efficiently,
    so that I can concentrate on providing value to my employers.

## Specification

By default, make the `passwd` and `sessions` plugins disabled by
default.

## Downstream Impact

Any cookbooks that require these plugins will need to ensure that they
document this, and operators will need to re-enable them.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
