---
RFC: unassigned
Title: Improved Log Levels
Author: Thom May <thom@chef.io>
Status: Draft
Type: Standards Track
---

# Improved Log Levels

Presently, the only way to debug a failing chef run is to enable debug
logging, which is intended more for the maintainers of Chef than for a
systems engineer. We would like to introduce several levels of enhanced
logging, enabling more appropriate output for various roles.

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

We propose the addition of a number of addition log levels. `debug`
level, since it is widely documented and used, would become the level
appropriate for users of Chef to gain better understanding of why a chef
client run is failing. This would include the output from system
commands, ohai timing data, and some details from exceptions.
`author` log level would include all `debug` output, as well as full
details from exceptions.
`maintainer` log level would include all of the above, as well as full
output from Ohai plugins, debug logging of HTTP requests, and so on.

## Downstream Impact

Any libraries that Chef includes (such as Ohai, mixlib-authentication
and so on) would need to be updated to use appropriate log levels.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
