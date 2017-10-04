---
RFC: unassigned
Title: Required Ohai Plugins
Author: Thom May <thom@chef.io>
Status: Draft
Type: Standards Track
---

# Required Ohai Plugins

Ohai allows us to gather a lot of data about the systems we manage.
However, often that data is unused, and sometimes it can be very large,
causing storage concerns in our infrastructure. We would like to ensure
that we collect and store the information we need, while dropping some
information that we don't.

## Motivation

    As an operations engineer,
    I want to only run the ohai plugins that I need,
    so that I send less data to the chef server.

    As a cookbook author,
    I want to ensure that my cookbook has the system data it needs,
    so that it correctly configures the system.

## Specification

This RFC proposes the addition of two fields to cookbook metadata:
 * `required_ohai_plugins`: A list of ohai plugins that are critical to
   the operation of the cookbook. If any of the listed plugins are not
   available or fail to run, the chef client run is aborted.
 * `suggested_ohai_plugins`: A list of ohai plugins that enhance the
   cookbook. Absence or failure of these plugins do not cause the chef
   client run to fail.

These fields are additive to any site wide configuration of critical
ohai plugins.

The chef client run would be altered to use a minimal set of ohai
plugins by default, supplemented by the set of plugins requested by
cookbooks and site wide configuration.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
