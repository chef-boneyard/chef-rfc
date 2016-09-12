---
RFC: 015
Title: Chef 12
Author: Serdar Sutay <serdar@chef.io>
Status: Accepted
Type: Informational
---

# Chef 12

This document summarizes our current thinking for the next major version of Chef Client a.k.a. Chef 12 and aims to provide a starting point for discussions on the scope of Chef 12.


## Current Chef Client Versions

First some data for information purposes:

* Currently Chef Client has two major versions that are supported. The latest versions that are soon to be released are 10.34.0 & 11.14.0. Chef 10 has been around since Jun 18 2012 and Chef 11 has been around since Feb 1 2013.
* All supported versions of Chef Client supports Ruby versions `1.8.7` (End of Lifed on June  2013), `1.9.3-p484` (will End of Life on Feb 23 2015) & `2.1.2`.
* Based on the release cadence we've established around the time of [11.6.0](http://www.getchef.com/blog/2013/07/23/chef-client-11-6-0-ohai-6-18-0-and-more/) release, Chef Client ships with a minor version bump approximately every 3 months and with a major version bump approximately every year.

## Chef Support Statement

As we are getting close to the next major version bump, I think it's important to capture and clarify what "supported" really means in Chef world. Here is an attempt to codify the support statement.

**Important:** `Support` in the context of this document means the support we provide as a community to the other members of the community. The goal is to reach a consensus which can guide us as a community in the future. Chef Software Inc. can opt to use the same guidelines when talking about **support** to its paying customers or decide to extend / restrict the guidelines outlined here.

### Supported Chef Versions

At a given time:

* `Latest` and `Latest - 1` major versions of Chef Client is supported by Chef community.
* `Latest` version includes all the enhancements and bug fixes.
* Security fixes are backported to `Latest - 1`.
* Contributions to `Latest - 1` version are always welcome.
* As Chef Community, we use and strongly recommend using omnibus packages for Chef Client. We still help out to folks who are doing custom installations of Chef Client but on a 'best effort' basis.

### Supported Ruby Versions

* Chef Client omnibus packages ship with the `Latest` version of Ruby at the time of a major version bump.
* `Latest` & `Latest - 1` versions of Ruby are supported.
* Ruby version bumps only happen at the time of Chef major version bumps.

### Operating System Versions

Supported Operating Systems and versions are covered by a separate [proposed RFC](https://github.com/opscode/chef-rfc/pull/21).

## Chef 12

In the context of the above, here is how Chef 12 looks in terms of support and Ruby versions:

* Support for Chef Client 10 will be dropped when Chef 12 ships.
  * In order to give some adoption time to the folks on Chef 10, we will continue to ship Chef Client 10 with contributions and required security fixes until **12/31/2014**.
* Ruby version in Chef 12 omnibus packages will be bumped to **2.1.2**.
* Support for Ruby 1.8.7 will be dropped from Chef Client codebase for all versions when Chef 12 ships.

### Backwards Compatibility

Backwards Compatibility is a very important requirement in Chef Client since it is a critical component in our infrastructures. We adhere to the Semantic Version scheme published [here](http://semver.org/). We strive to be strict about the backwards compatibility during minor version releases. Even though we have the freedom to break backwards compatibility in major version bumps, we believe that there needs to be significant benefits in a given release for us to go through the pain of updating our cookbooks and workstations in order to migrate to a new release without breaking our existing functionality.

With this in mind, feature proposals below are categorized in terms of **Breaks Backwards Compatibility?**, **User Benefit** & **Impact**. As a community we discuss these proposals and decide if the overall backwards compatibility is worth breaking or not during a major version bump.

### Feature Proposals

#### Enable SSL Verification by Default
* https://github.com/opscode/chef/issues/1542
* **Breaks Backwards Compatibility? (Workstation):** Yes
* **Breaks Backwards Compatibility? (Cookbooks):**   No
* **User Benefit:** High
  * This change will secure the communication channels between workstation, nodes and the server by default.
* **Impact:** Low
  * Chef 11 already contains the necessary certificates and debugging tools to enable SSL verification if needed. Chef 12 will contain the necessary bootstrapping improvements to make the functionality work out of the box. Tooling around updating existing nodes with the required certificates will be available with the Chef 12 release.

#### Guard interpreter default for powershell_script set to powershell_script
* https://github.com/opscode/chef/issues/1714
* **Breaks Backwards Compatibility? (Workstation):** No
* **Breaks Backwards Compatibility? (Cookbooks):**  Yes
* **User Benefit:** Medium
  * Short description of the benefit: new users from Windows no longer have to be conscious of the guard_interpreter attribute to get the most sensible behavior for the powershell_script resource, which requires use of the legacy cmd.exe shell, increasingly deprecated on newer versions of Windows.
* **Impact:** Medium
  * Short description of the impact: powershell_script resources with guards not using guard_interpreter will return different results until guard expressions in those cookbooks are rewritten. Some scripts may execute more often than they should.

#### Guard interpreter default for batch set to :batch
* https://github.com/opscode/chef/issues/1713
* **Breaks Backwards Compatibility? (Workstation):** No
* **Breaks Backwards Compatibility? (Cookbooks):**  Yes
* **User Benefit:** Medium
  * Short description of the benefit: Guard expressions for batch will execute as 64-bit, which is almost always the right thing. Without this change, users have to discover why things don’t work as exepcted (because we run 32-bit guards which can see a different view of the OS) and use some workaround, either set guard_interpreter explicitly or use the “sysnative” path trick, which must be substituted on 32-bit systems. The current behavior is a common gotcha, particularly for new Chef users or those not used to the Windows platform.
* **Impact:** Low
  * Short description of the impact: Guard expressions for the batch resource will run as 64-bit, which could cause different behaviors for an expression that was either intentionally or unintentionally running as 32-bit. It’s unlikely that people will hit this case, largely because if they didn’t do the workaround to use 64-bit, that’s probably a case where running as 32-bit is harmless (or they would have caught the problem). If they were working around it with guard_interpreter or sysnative, there will be no impact.

#### Remove rest-client Dependency
* **DONE**
* **Breaks Backwards Compatibility? (Workstation):** (Yes)
* **Breaks Backwards Compatibility? (Cookbooks):**   (Yes)
* **User Benefit:** (Medium)
  * Any user code (cookbooks, knife plugins,
    etc.) that depends on rest-client will be able to set its own version
    requirements. Currently some use cases are broken in the version of
    rest-client that chef-client is locked to, but chef-client cannot upgrade
    because of ruby version compatibility issues (1.8). chef-client itself no
    longer depends on rest-client, so there is no reason to specify it as a
    dependency other than backwards compatibility.
* **Impact:** (Low)
  * Any user code depending on rest-client
    needs to ensure that it is installed via the appropriate mechanism.

#### Require `name` Attribute in Cookbook Metadata
* https://github.com/opscode/chef/issues/1712
* **Breaks Backwards Compatibility? (Workstation):** (Yes)
* **Breaks Backwards Compatibility? (Cookbooks):**   (Yes)
* **User Benefit:** (Medium)
  * Users and tool authors will be able to
    store cookbooks according to directory names of their choosing, for example
    `COOKBOOK_NAME-VERSION` or any other desired scheme.
* **Impact:** (Low)
  * Currently the name field is ignored
    entirely, so a user could have a cookbook with an incorrect name field that
    is working "by accident".
  * In the current implementation of cookbook
    loading, `knife cookbook upload`, etc., there is an interdependency between
    the existing behavior, the cookbook overlay feature, the performance of
    `knife cookbook upload`, and a feature where invalid cookbook data in an
    unrelated cookbook does not cause an error when uploading a different cookbook.

#### Enable client-side key generation by default
* https://github.com/opscode/chef/issues/1711
* **Breaks Backwards Compatibility? (Workstation):** (No)
* **Breaks Backwards Compatibility? (Cookbooks):**   (No)
* **User Benefit:** (Medium)
  * Reduces server load when creating a large
    number of servers concurrently; protects the client's key material from
    confidentiality failures that can be caused by catastrophic SSL bugs (like heartbleed).
* **Impact:** (Low)
  * This is *technically* a breaking change
    because it breaks support for the 10.x server API; however, that version
    becomes unsupported when 12.x is released, so it does not break
    compatibility with any supported version of the server.

#### Add simple DSL method to interact with encrypted data bags
* https://github.com/opscode/chef/issues/1710
* **Breaks Backwards Compatibility? (Workstation):** No
* **Breaks Backwards Compatibility? (Cookbooks):**  No
* **User Benefit:** Low
  * Short description of the benefit: It confused me when I was first introduced to Chef that data bags had a nice friendly DSL method (data_bag_item) and encrypted databags had to be access using Chef::EncryptedDataBagItem.load.  It seems like for consistency and helping out new users a new method encrypted_data_bag_item could be added that would simplify the code necessary to interact with encrypted data bags
* **Impact:** Medium
  * Short description of the impact: Similar to some of the changes made to the DSL in Chef 11, this would make any cookbook using the new method a Chef 12 or later cookbook.

#### Homebrew As OS X Default Package Provider

* https://github.com/opscode/chef/issues/1709
* **Breaks Backwards Compatibility? (Workstation):** No
* **Breaks Backwards Compatibility? (Cookbooks):**  Yes
* **User Benefit:** High
  * Short description of the benefit: Homebrew is commonly used by members of the Chef community as a "package system" instead of Macports.
* **Impact:** Medium
  * Short description of the impact: This is a backwards incompatible change. It's unlikely that existing cookbooks would need to be rewritten if the package names are the same.
* **Objections:** The most common objection is that the homebrew cookbook would still be required to get homebrew installed, since it doesn't come with OS X. However, the same is true of macports (it has a cookbook to install as well).

### Bug Fixes

We are keeping track of the minor things that need to be fixed or included in Chef 12 on [Github Issues](https://github.com/opscode/chef/issues) with `Milestone: Chef 12`. Feel free to check them out or file a new issue there.
