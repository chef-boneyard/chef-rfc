---
RFC: unassigned
Author: Thom May <thom@chef.io>
Status: Draft
Type: Standards Track
Tracking:
 - https://github.com/chef/chefstyle
---

# Chef code should have a consistent style

There is a high cognitive load involved in switching between projects
that have different or inconsistent code styles that impacts developer
productivity and happiness. Chef should produce a consistent code style
for its open source ruby code and apply it.

## Motivation

    As a developer,
    I want to be productive quickly in all Chef's projects,
    so that I can concentrate on writing code.

## Specification

https://github.com/chef/chefstyle provides a rubocop configuration that
is intended to be applied to chef/chef and related projects, such as
chef/ohai, and chef/mixlib-\*. The community should arrive, via
pull requests to `chefstyle`, at a set of style checks that can be
enforced (via travis, etc) on chef community maintained ruby projects.

Chefstyle, by default, disables all rubocop cops, providing a clean
sheet for us to build upon. PRs to enable rules should be accompanied
with a PR to chef/chef demonstrating the feasibility of enabling the
rule and to allow discussion of actual changes.

This style checker is not intended for use with cookbooks, which have
different requirements.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
