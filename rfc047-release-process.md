---
RFC: 47
Author: Jay Mundrawala <jmundrawala@chef.io>
Author: Bryan McLellan <btm@chef.io>
Status: Accepted
Type: Process
---

# Chef Client Release Process

This RFC describes the steps involved in building and releasing the Chef Client, project versioning, and release contingencies.

## Motivation

As a Chef maintainer,
I need an established release process,
so I can make my release consistent.

As a Chef maintainer,
I want to be able to release the exact build I have tested,
so I do not need to make an additional release build.

As a Chef user,
I want to know what the release process is,
so I can install appropriate version.

As a Chef user,
I want to know the project versioning system,
so I can decide when to upgrade.

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
The BUILD version is the same as PATCH, but is increased automatically by the build system
```

* When MINOR increases, BUILD must be reset to zero.
* When MAJOR increases, MINOR and BUILD must be reset to zero.
* Changes that require the MINOR version number to be increased may be included in a release that increases the MAJOR and allow the MINOR to be reset to zero. That is, new features that do not exist in version 1.1.0 may be released in 2.0.0 without any intermediary releases.

Versions are always displayed in the MAJOR.MINOR.BUILD format. For example, `knife -v` prints `Chef: 12.5.1`. When contextually appropriate a version may be referred to by only the MAJOR or MAJOR and MINOR versions. Examples include:
* a breaking change: "This behaviour will change in the Chef 13" which would be referring to the first release in the 13.MINOR.BUILD series
* a future feature release: "We expect to release Chef 12.6 this month" which would refer to the highest 12.6.BUILD release.

#### Caveats

We do not consistently and clearly delineate which public methods are also part of the public API and guaranteed to only change with major version releases. Public methods may change in minor releases based on the likelihood of that method being used by other projects or cookbooks.

#### Examples

MAJOR: When changing the load order of any cookbook segments (e.g. attributes, templates), the major version number shall be incremented.

MINOR: When adding support to the mount provider for special filesystem types that were previously unsupported, the minor version number shall be incremented.

BUILD: Automatically when a build is started in the build system.

### Continuous Integration / Continuous Delivery (build system)

The BUILD version is numeric and must be increased for each build.

The build system may consume unreleased BUILD versions. For example, a build which is successful but does not pass integration testing must not have its version reused.

Therefore, a released build is unlikely to have BUILD be zero because these numbers are now consumed during pre-release testing.

#### Build Repeatability

There is a large set of dependencies for Chef (rubygems) and the packaging (omnibus). Many rubygems dependencies are allowed to float to facilitate other projects that use Chef as a library. This allows other projects to not match dependencies in lock-step, which helps prevent ecosystem failure when one project upgrades before another.

The matrix of platforms and platform versions that Chef supports (see RFC 21) is extensive. The build for each system is expected to be consistent across all platforms. This is achieved by building all platforms at roughly the same time.

Thus, a later build of the same Chef commit is not guaranteed to produce the same package.

Currently the omnibus packaging configuration is shared between multiple projects in the omnibus-chef repository, which causes subsequent builds to change due to updated omnibus dependencies. This will be mitigated in the future by moving the omnibus packaging configuration into each projects repository.

#### Version Configuration

A text file named VERSION exists at the top of chef git repository which contains the current MAJOR.MINOR version. If BUILD is included, it is ignored. Maintainers are responsible for increasing MAJOR and MINOR as necessary based on the above specification when merging code to the master branch.

The VERSION constants, Chef::VERSION and ChefConfig::VERSION are automatically updated by the processes below. The full version, i.e. MAJOR.MINOR.BUILD, is stored as annotated git tags.

The following steps will be automated:

 * Github Bot
 1. Blocks merge on Github with a 'required status check'
 1. Waits for a comment indicating the PR is accepted, e.g. "@shipment approve"
 1. Examines the VERSION file on master to determine MAJOR.MINOR
 1. Uses existing tags to determine the next incremental BUILD
 1. Checks out the branch
 1. Update the VERSION constants for the build and commits locally
 1. Merges the branch with the version commit to master
 1. Pushes master to Github

 * Build Tool
 1. Monitors the repository for commits using Github web hooks or git polling
 1. Builds the project using Omnibus
 1. Places a successful build in the internal 'unstable' channel
 1. Runs the build through automated acceptance tests
 1. Places a successful build in the external 'current' channel

The above process is intended to happen only after successful unit tests. This verification is currently provided by Travis/Appveyor. This will help catch regressions before a build version and build resources are consumed.

To facilitate local development and testing, a modified process is used when built outside of CI/CD:
 1. Examine the VERSION file to determine MAJOR.MINOR
 1. Use the existing tags to determine the most recent BUILD and use it with a `.dev` suffix, e.g. `1.2.3.dev`
 1. Does not create or push tags
 1. Updates the VERSION constants for the build

This process is automated by using the `rake FIXME-TBD` task.

The development version may be committed and pushed to development branches as necessary for working with bundler and other tools, but must not be merged to the `master` branch, e.g. drop the commit with an interactive rebase.

#### Channels

The build system moves builds through multiple repositories, designated as channels. The channels publicly exposed to Omnitruck are:

* unstable: Builds that have completed successfully, pending testing. Internal to the build system.
* stable: Builds that have been manually promoted from current and are considered a releases.
* current: Builds that has passed all automated testing.

### Releasing

A release is a build that is available in the `stable` channel.

Releases must be announced on the Chef Discourse (mailing list, see RFC 28) and should be cross-posted on the Chef Software blog.

#### Release Candidates

Official releases are made by promoting builds from the current channel to the stable channel. We no longer use the addition of a two-part alphanumeric suffix (e.g. X.Y.Z.rc.0) to describe prereleases. The stability of a build is now indicated by the release channel, e.g. current or stable, that the build is available from. All builds in the current channel are potential release candidates.

An announcement should be made to the Chef Discourse (mailing list) at least three business days prior to the release of a build with an increase of either the MAJOR or MINOR versions over the last release. The announcement should specify the version of the build which is currently being tested if available.

Releases which do not increase MAJOR or MINOR versions are expected to have only bug/regression fixes which have been extensively tested, and thus may be released without pre-notification.

#### Chef Client Release Process

* Verify the CHANGELOG.md is accurate for the current release
* Update ```lib/chef/version.rb``` to the appropriate next version
* Create an annotated git tag for the version
* Trigger a build in CI (chef-trigger-release)
* Write the release announcement and share a public draft (e.g. a gist)

Once the CI pipeline completes successfully:

* Locally build and release the gems
* Public the release notes in the chef category on Discourse (mailing list)
* Cross-post the release notes on the Chef Software blog
* Tweet the blog post

### Critical Regression Handling

If an issue is filed against the project that is triaged as a critical regression:

1) Communicate the regression
    - Post in the chef category on Discourse (mailing list)
    - Update the Chef Software blog post for the release with a message at the top regarding the regression
    - Post a message in the #chef irc channel linking to the Discourse post

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

