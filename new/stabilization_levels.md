---
RFC: unassigned
Title: Stabilization Levels
Author: Thom May <thom@chef.io>
Status: Draft
Type: Standards Track
---

# Resource Stabilization Levels

As the chef client moves to a more batteries included model, it's
important for our users that they be able to reason about the stability
of a given resource. 

## Motivation

    As a core maintainer,
    I want to rapidly introduce and iterate on resources,
    so that I can provide the best possible experience for users.

    As a systems engineer,
    I want to be able to opt out of unstable resources,
    so that my chef runs work as expected.

## Specification

A number of stability levels would be introduced, and resources assigned
a stability. New resources can graduate through stability levels as
appropriate, based on criteria such as bug reports, speed of iteration,
etc.
Our users could opt in to varying levels of stability, which would
enable or disable resources or features not appropriate to that stability level.
Our documentation would also reflect the stability of resources.

## Downstream Impact

Which other tools will be impacted by this work?

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
