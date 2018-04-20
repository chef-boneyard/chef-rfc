---
RFC: 96
Title: Improved Log Levels
Author: Thom May <thom@chef.io>
Status: Final
Type: Standards Track
Tracking: https://github.com/chef/chef/pull/6910
---

# Improved Log Levels

Presently, the only way to debug a failing chef run is to enable debug
logging, which is intended more for the maintainers of Chef than for a
systems engineer. We would like to move to a structured metadata model
that allows us to slice and dice log messages.

## Motivation

    As a Chef maintainer,
    I want to know exactly what chef is doing,
    so that I can maintain and develop chef.

    As a cookbook author,
    I want to ensure that my cookbook is interacting with the system as
    I expect,
    so that I can write cookbooks efficiently.

    As a systems engineer,
    I want to see the output of running commands,
    so that I can debug chef failures.

## Specification

We propose to move the chef client, and related libraries, to a
structured logging format. This would allow us to tag individual log
messages with extended metadata, such as the resource/subsystem, the
cookbook we're running in, the log level and so on.

We would then update the logging commands to allow the user to specify a
set of tags that they're interested in, allowing a user to only get log
output from the resources associated with a single cookbook.

## Downstream Impact

Any libraries that Chef includes (such as Ohai, mixlib-authentication
and so on) would need to be updated to use structured logging.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
