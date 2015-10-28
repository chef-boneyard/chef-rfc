---
RFC: 47
Author: Jay Mundrawala <jmundrawala@chef.io>
Author: Bryan McLellan <btm@chef.io>
Status: Accepted
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

We generally adhere to the Semantic Version scheme published [here](http://semver.org/), with noted exceptions.

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
Given a version number MAJOR.MINOR.BUILD:

Increment the MAJOR version when the release will break existing functionality
Increment the MINOR version when you add any new features
The BUILD version is increased automatically by the build system
```

#### Continuous Integration / Continuous Delivery (build system)

The BUILD version is numeric and must be increased for each build.

The build system may consume unreleased BUILD versions. For example, a build which is successful but does not pass integration testing may not have its version reused.

It is left to the build system as to when to reset the BUILD version to zero, provided that newer versions will always compare greater than older versions.

##### Channels

The build system provides at least these repositories of builds, designated as channels:

stable: Official releases
current: Builds that has passed all automated testing

#### Caveats

We do not consistently and clearly delineate which public methods are also part of the public API and guaranteed to only change with major version releases. Public methods may change in minor releases based on the likelihood of that method being used by other projects or cookbooks.

#### Examples

MAJOR: When changing the load order of any cookbook segments (e.g. attributes, templates), the major version number shall be incremented.

MINOR: When adding support to the mount provider for special filesystem types that were previously unsupported, the minor version number shall be incremented.

BUILD: Automatically when a build is started in the build system. 

Changes that require the MINOR version number to be increased may be included in a release that increases the MAJOR and allow the MINOR to be reset to zero. That is, new features that do not exist in version 1.1.0 may be released in 2.0.0 without any intermediary releases.

### Releasing

#### Release Candidates

Official releases are made by promoting builds from the current channel to the stable channel. We no longer use the addition of a two-part alphanumeric suffix to describe prereleases. The stability of a build is now indicated by the release channel, e.g. current or stable, that the build is available from.

An announcement should be made to the Chef mailing list at least three business days prior to the release of a build with an increase of either the MAJOR or MINOR versions over the last release. 

Releases which do not increase MAJOR or MINOR versions are expected to have only bug/regression fixes which have been extensively tested, and thus may be released without prior notification.

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

