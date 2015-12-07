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

At the end of each chef run, just before the reboot handler, the chef client should check with an update service to discern whether there is a new version of chef. If there is, the client should decide whether or not to upgrade, based on configuration supplied by the administrator.
Should the decision to upgrade be made, the client will download the new version, and install it appropriately. If a reboot is not triggered, the client run should exit using an appropriate exit code to signal an upgrade.

### Determining the desired chef version

The desired chef version should be provided to the node through a new first class environment or node attribute, named `chef_version`. Once RFC 45 is completed, that attribute will be marked as desired state, and not mutable by the node. The `chef_version` attribute must contain a SemVer parseable version string. A version always takes the form x.y.z, where x, y, and z are decimal numbers that are used to represent major (x), minor (y), and patch (z) versions. One-part (x) and two-part (x.y) versions are allowed.

Chef will also add a `chef_upgrade` resource to help administrators control the upgrade process, for example by selectively enabling upgrades based on search results or custom attributes. The `chef_upgrade` resource will expose a `version` attribute, allowing one to override the `chef_version` attribute. It will expose one action, `upgrade`.


### Checking for an upgrade

Currently, Chef provides an omnitruck API service that allows one to query for versions of packages. https://docs.chef.io/api_omnitruck.html describes the API, which provides the ability to request various groups of versions. In future it may be desirable to provide a similar API in the Chef Server, to provide upgrades to nodes that have no external connectivity.

### Installing the upgrade

The chef client will use the most appropriate mechanism to install the latest version of chef. The chef client will then exit with an appropriate error code, allowing the parent process to restart gracefully.

### Example scenario

Given the environment below:
```json
{
  "name": "production",
  "chef_version": "12.5"
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
