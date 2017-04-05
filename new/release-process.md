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

### Versioning

We aim to adhere to the Semantic Version scheme published [here](http://semver.org/). However, there are existing exceptions. Most notably, we do not consistently and clearly delineate which public methods are also part of the public API and guaranteed to only change with major version releases.

From Semantic Versioning:

```
Given a version number MAJOR.MINOR.PATCH, increment the:

MAJOR version when you make incompatible API changes,
MINOR version when you add functionality in a backwards-compatible manner, and
PATCH version when you make backwards-compatible bug fixes.
Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.
```

Chef Client specific clarifications:

```
Given a version number MAJOR.MINOR.PATCH, increment the:

MAJOR version when the release will break existing functionality
MINOR version when you add any new features
PATCH version when you are only fixing bugs, typically regressions
```

##### Prerelease versions

Any prerelease must be versioned in the format MAJOR.MINOR.PATCH.PRETYPE.PREVER, where:

PRETYPE is the description of the prerelease that the Releaser chooses based on the state of the prerelease, e.g. alpha, beta, rc, dev.
PREVER is an incremented number starting at zero.

For example: 12.0.0.dev.0, 12.2.0.alpha.2, 12.3.0.rc.3

#### Examples

Major: When changing the load order of any cookbook segments (e.g. attributes, templates), the major version number shall be incremented.

Minor: When adding support to the mount provider for special filesystem types that were previously unsupported, the minor version number shall be incremented.

Patch: When a minor release is made that contains a new feature to a service provider that causes the service provider to no longer work for users on an older but still supported version of the platform, the patch version number shall be implemented.

Changes that require the minor or patch version number to be implemented may be included in a release that increments a higher version number without incrementing a lower version number. That is, new features that don not exist in version 1.1.0 may be released in 2.0.0 without any intermediary releases.

### Releasing

#### Release Candidates

Each major and minor release should have at least one week where a public RC is available
for Chef users to test and report feedback.

Patch releases are expected to have only small changes which are extensively tested, and thus may be safe to release without a release candidate.

#### Chef Client Release Process

* Verify the CHANGELOG.md is accurate for the current release
* Update ```lib/chef/version.rb``` to the appropriate next version
* Create an annotated git tag for the version
* Trigger a build in CI (chef-trigger-release)
* Write a blog post and share a public draft (e.g. a gist)

Once the CI pipeline completes successfully:

* Locally build and release the gems
* Ask Chef Release Engineering to build and release AIX
* Publish the blog post
* Tweet the blog post
* Email the chef and chef-dev mailing lists

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

