---
RFC: unassigned
Title: Collapse Mixlib Install Code Paths in Test Kitchen
Author: Patrick Wright <patrick@chef.io>
Status: Draft
Type: Standards Track
---

# Collapse Mixlib Install Code Paths in Test Kitchen
Test Kitchen currently supports two code paths for configuring, downloading and installing Chef and ChefDK on test instances. Both code paths use Mixlib Install but are implemented differently. In the past year, significant effort has been put into Mixlib Install's new API to establish a canonical mechanism for interacting with Chef Software Inc's release infrastructure and generating bootstrap installation scripts (install.sh and install.ps1).

Mixlib Install's new API is currently used for downloads.chef.io and omnitruck.chef.io. It's also used for the chef-ingredient cookbook. Chef transparently implemented the new API and selected config options in Kitchen for testing purposes. It has proven valuable and easy to use. The feature set is limited at this time.

## Motivation

    As a Kitchen User, 
    I want to separate which product version to install from how the product is installed, 
    so that I can easily control how an instance is bootstrapped with a specified product version.

    As a Kitchen User,
    I want to use options for selecting which product from a specified channel to install,
    so that I can bootstrap an instance with Chef or ChefDK from a supported channel without using script argument syntax.

    As a Kitchen User,
    I want the application to manage settings automatically where applicable,
    so that I can focus on only setting pertinent options.

    As a Kitchen Developer,
    I want to maintain a single Mixlib Install code path,
    so that I can benefit from the latest API changes and consolidate support efforts.

The current Mixlib Install code path used in Kitchen was developed specifically for Kitchen and is tightly coupled with Kitchen's provisioner options. It's referred to as the `ScriptGenerator`. The new API was developed to be used by any project that needs to query Chef product meta-data or generate an installation script. The new API takes into account the specifics of interacting with Chef Software Inc's release infrastructure (packages.chef.io).

## Specification
This work is separated into 3 phases.

##### Phase 1 - Incrementally add new transparent configuration options
* All existing configuration options behave as expected
* Build feature parity with the new options to match existing functionality
* Setting `product_name` will trigger the new options use cases
* Maintain both Mixlib Install code paths
* Document new options in the Kitchen repo

##### Phase 2 - Provide option deprecation warnings and "how-tos"
* All existing configuration options still behave as expected
* User is clearly warned when using options that will be deprecated
* Deprecation warnings include explanations and resolution instructions
* Inform the community of the upcoming Kitchen changes and reasoning (Chef blog, Community Slack)

##### Phase 3 - Make the switch
* Raise errors along with instructions when using deprecated options 
* `ScriptGenerator` code path removed from Kitchen
* docs.chef.io and kitchen.ci documentation updates
* Inform the community when Kitchen is released

### Phase 1 Details
The following describes our proposal to replace `require_chef_omnibus` with the new options `product_version` and `install_strategy`. It outlines requirements to maintain feature parity with Kitchen's current configuration options. Since `require_chef_omnibus` is a complex option it warranted this level of detail.

#### Provisioner setting require_chef_omnibus use cases
These are the current values for `require_chef_omnibus` and their intent.
* `true`: If "chef" is installed don't install anything, otherwise install latest
* `false`: Don't install anything
* `latest`: Always install latest version
* `<version>`: If "chef" is installed don't install anything, otherwise install specified version. Accepts partial versions.

#### Replacement settings for feature parity
To improve the user experience and align more closely with the new mixlib-install API I am proposing we replace `require_chef_omnibus` with two new settings: `product_version` and `install_strategy`. `product_version` has already been implemented along with `product_name` and `channel`.

##### New Settings
* `product_version`: Manage `latest` and `<version>` values.  Supports partial versions.
* `install_strategy`: `once`, `skip`, `always`. Default: `once`
  * `once`: Behaves similar to true. Install `product_name` `product_version` once. Don't install `product_name` if detected.
  * `skip`: Behaves similar to false. Do not install `product_name`.
  * `always`: Behaves similar to latest. Always install specified/latest `product_name` `product_version`.

###### Examples
```
require_chef_omnibus: true
```
equivalent to:
```
product_version: latest
install_strategy: once
```
_Default settings_

----

```
require_chef_omnibus: false
```
equivalent to:
```
install_strategy: skip
```

----

```
require_chef_omnibus: latest
```
equivalent to:
```
product_version: latest
install_strategy: always
```

----

```
require_chef_omnibus: 12
```
equivalent to:
```
product_version: 12
install_strategy: once
```

###### Additional Flexibility
```
product_version: 12
install_strategy: always
```

##### Future
We could add an upgrade install strategy which only installs the package if a newer package is available.

###### Examples
```
product_version: latest
install_strategy: upgrade
```

----

```
product_version: 12.19
install_strategy: upgrade
```

#### Opportunity for improvement
Although adding `install_strategy` will provide feature parity, we should consider what features we really need in Kitchen moving forward. We may not need this option if we come up with the use cases we feel Kitchen should support moving forward.
Does Kitchen need to support the same `require_chef_omnibus` configurability with the new API?

By simplifying the use cases, can we automate the install and upgrade paths without introducing a new setting?

Note, this is not a requirement for this work, but definitely something to think about.

#### Mixlib Install changes
A new script param, `install_strategy`, will be added to `install.sh` and `install.ps1`. The option will determine how the install functions will install the package. TThe default params will be set to maintain the current behavior of always installing the specified package.

Adding `install_strategy` to the install scripts moves all responsibility for determining how to install packages to a canonical source. This also decouples the logic in Kitchen for determining installs and upgrades from Mixlib Install's ScriptGenerator.

----

The experimental [branch](https://github.com/test-kitchen/test-kitchen/compare/master...wrightp:pw/config-deprecations) illustrates how other existing provisioning options could be deprecated. See examples for `chef_omnibus_install_options`, `chef_omnibus_url`, `chef_metadata_url`, `chef_omnibus_root`, and `ruby_bindir`.

Distinct option names and code paths will be maintained separately for the current functionality and the new. We will discuss any exceptions as they arise. `product_name` will act as the pivot point between which code path to follow (`ScriptGenerator` or the new API).

As new options are added a markdown file in the Kitchen repo will be maintained with descriptions along with deprecation information.

### New Settings
| New Setting Name | Description | Default | Current Setting Name |
|------------------|-------------|---------|----------------------|
| product_name | bootstrap Chef or ChefDK | chef | chef_omnibus_install_options |
| product_version | version number | latest |require_chef_omnibus |
| channel | repository stable, current or unstable | stable | chef_omnibus_install_options |
| platform | override platform | auto-detected | |
| platform_version | override platform version| auto-detected | |
| architecture | override platform architecture | auto-detected | |
| install_strategy | install once, always or skip | once |require_chef_omnibus |
| download_url_override | direct package url | | install_msi_url (not currently supported in bourne script) |

### Phase 2 Details
The config option deprecations will be enabled. Users will start receiving deprecation warnings and begin resolving issues. At this phase we expect to be feature complete, however, there will likely be use cases or configuration combinations that are missed. Any detected deprecation warnings will also instruct the user to create issues if the resolutions don't work or don't meet their requirements. This phase is primarily focused on communication and quick turnarounds on issues. We can determine the best method for informing users at this time. (Chef blog, Community Slack, etc.)

### Phase 3 Details
The deprecation warnings will be updated to raise errors. The code will be cleaned up of the old code paths. This phase is technically the most simple. Again, communication, availability, and responsiveness are the keys to this phase. Before releasing, all documentation sources will need to be prepared and ready to be published. The Kitchen major version release will coincide with all documentation publishing.

## Documentation
Sources that will require updates:
* docs.chef.io
* kitchen.ci
* github.com/test-kitchen

## Copyright
This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
