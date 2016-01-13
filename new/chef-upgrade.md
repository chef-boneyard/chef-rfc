---
RFC: unassigned
Author: Thom May <thom@chef.io>
Status: Draft
Type: Standards Track
---

# Chef should be able to upgrade itself

Users should be able to automatically upgrade to the desired version of chef without having to use third party cookbooks. The upgrade should occur without affecting the normal chef client run, ensuring that a consistent state is preserved.

## Motivation

```
  As an operator, I want chef versions to be consistent across my infrastructure,
  so that I can ensure my code works correctly
```
```
  As an operator, I want to easily and safely upgrade chef to my desired version,
  so that I can easily roll out new versions.
```
```
  As a developer, I want our users to get new features and bug fixes in a timely and safe manner,
  so that everyone's happy.
```

## Specification

At the beginning of each chef run, the client should decide whether or not to upgrade, based on configuration supplied by the administrator.

If the administrator has specified a version of chef different to the one currently running, the chef client should check with an update service to ensure the specified version is available. If so, the client will download the specified version, and install it appropriately. The client run should then exit, using an appropriate exit code to signal an upgrade.

### Determining the desired chef version

The desired chef version should be provided to the node through a new first class environment or node attribute tree, named `__chef_version__`. Once RFC 45 is completed, that attribute tree will be marked as desired state, and not mutable by the node.

The attribute tree will contain one mandatory attribute, `version`, and
some additional attributes. Currently, we intend to support `channel`
to allow the administrator to specify that they would like to consume
unreleased builds. Channels are documented in [RFC 47](https://github.com/chef/chef-rfc/blob/master/rfc047-release-process.md#channels)

The `version` attribute shall contain either MAJOR, MAJOR.MINOR, or
MAJOR.MINOR.BUILD as documented in [RFC 47](https://github.com/chef/chef-rfc/blob/master/rfc047-release-process.md#versioning).
It can also be the special string "latest", signifying that the node
should always upgrade to the latest available version.

### Checking for an upgrade

Currently, Chef provides an omnitruck API service that allows one to query
for versions of packages. The API is [documented](https://docs.chef.io/api_omnitruck.html),
and provides the ability to request various groups of versions. In
future it may be desirable to provide a similar API in the Chef
Server, to provide upgrades to nodes that have no external connectivity.

### Installing the upgrade

The chef client will use the most appropriate mechanism to install the
latest version of chef. The chef client will then exit with an appropriate
error code, allowing the parent process to restart gracefully.

### Example scenario

Given the environment below:
```json
{
  "name": "production",
  "__chef_version__": {
    "version": 12.5"
  }
}
```
A chef client on an ubuntu node in the `production` environment, will make a request to omnitruck:
```
http://www.chef.io/chef/metadata?p=ubuntu&pv=14.04&m=x86_64&v=12.5
```
and receive metadata containing the latest package in the `12.5` series.
Should that package be newer than the current version, chef will download
the deb package, install it via `dpkg`, and end the chef run with a suitable
exit code.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
