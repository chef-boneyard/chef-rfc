---
RFC: unassigned
Author: Jay Mundrawala <jmundrawala@chef.io>
Author: Bryan McLellan <btm@chef.io>
Status: Draft
Type: Process
---

# Chef Client Release Process

This RFC describes the steps involved in releasing the Chef Client and related contingencies.

## Motivation

As a Chef Releaser,
I need an established release process,
so I can make my release consistent.

As a Chef user,
I want to know what the release process is,
so I can install appropriate version.

As a Chef user,
I want to understand what happens when a critical bug is found,
so I can react accordingly.

## Specification

### Releasing

#### Release Candidates

Each major and minor release should have at least one week where a public RC is available
for Chef users to test and report feedback.

Patch releases should only include fixes for regressions of the current minor version.
These releases should mostly include small changes and should be safe to release without
a release candidate.

#### Chef's Release Process

* Verify CHANGELOG.md
* Update lib/chef/version.rb Version RFC/Semver/something in another section here?
* Create annotated git tag for the version
* Kick of CI
* Write a blog post. Make it a public draft
* push gem
* have someone push to package cloud
* have someone build AIX
* tweet the blog post
* email the chef and chef-dev lists

### Critical Regression Handling

If an issue is filed against the project that is triaged as a critical regression:

1) Communicate the regression
    - Update the blog post for the release with a message at the top regarding the regression
    - Post a message in the #chef irc channel linking to the blog post
    - Email the Chef mailing list

2) There are two paths for correction. After five hours, the second option must begin.

    A) Provide a release that resolves the regression.
    B) Revoke the release.
        * rubygems, packagecloud, omnitruck

3) Communicate the regression resolution.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

