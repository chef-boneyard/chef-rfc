---
RFC: 100
Title: Establish Core Resource Lifecycle
Author: Jennifer Davis <sigje@chef.io>
Status: Accepted
Type: Process
---

# Core Resource Lifecycle

This RFC describes the support lifecycle of [core resources](https://docs.chef.io/resources.html) provided in Chef.

## Motivation

    As a Chef user,
    I want core resources to be usable, reasonable and supported,
    so that using Chef is a quality experience.

    As a Chef user,
    I want to understand the current state of documented resources,
    so that I implement resources correctly.

    As a Chef developer,
    I want to develop useful resources and reduce complexity by eliminating unhelpful resources,
    so that I improve the usability of Chef.

## Guiding Principles

Core resources ...

1. Should be reasonable. Actions should reflect expected behaviors.
2. Should be usable. Resource can be used in multiple contexts.
3. Should be well-designed and self contained.
4. Should be tested.
5. Should be maintained on [supported platforms](https://github.com/chef/chef-rfc/blob/master/rfc021-platform-support-policy.md) as relevant.
6. Should minimize surprises.

At any given time current resources have an implicit state. To clarify and be explicit about these states, it is proposed that resources have the following states:

#### Analysis

Resources in analysis state are being evaluated to identify who, what, when, and why a resource is (still) needed. A resource could be in this state whether it's a popular widely used resource in a community cookbook or a gap in common infrastructure element. A resource could re-enter this state when it has been identified as a problematic resource that needs to be evaluated for continued support.

#### Development

Resources in development state are in active development. The value of adding the resource is understood. The number of impacted users has been estimated.

#### Supported

Resources in supported state have been added to Chef, work on relevant platforms, and are tested.

#### Deprecated

Resources in deprecated state have been identified as having significant issues that can not or will not be resolved. Use of the resource will emit a deprecation warning. A compatible cookbook(s) for the deprecated resource may be created or updated to allow use of the deprecated resource.

#### Retired

Resources in retired state have been in deprecated state and emitting warnings and on the next major release of Chef removed from code.

## Specification

### Criteria for adopting resources

Factors that influence and inform the decision to adopt a resource include:

* widespread use of a resource based on analysis of publicly available supermarket cookbooks,
* well tested and supported cookbook resources,
* percentage of supported platforms,
* impact of implementing as a primitive that can be built upon.

### Criteria for deprecating resources

Factors that influence and inform the decision to deprecate a resource include:

* limited use based on analysis of publicly available supermarket cookbooks,
* outdated code or lack of support based on quality of resource and its usability,
* security implications,
* complex implementation that lacks clarity of consequences of use.
* impact of using the resource incorrectly.

### Process for adopting resources

* Identify resources for adoption.
* Create an RFC following the [Chef RFC](https://github.com/chef/chef-rfc) process.
* Announce on Chef mailing list and Chef Community Slack.
* Any proposed changes to the interfaces must be implemented in the cookbook prior to adoption.
  * If there are fundamental issues with the resource whether due to naming standards or interface implementation, a new cookbook should be created implementing the resource as intended.
* Any bugs discovered must be repaired in the cookbook and released prior to adoption.
* During the next major release cycle, the resource is added to core chef and documentation is updated.
* Add deprecated cookbook warnings for conflicting cookbooks.

### Process for deprecating resources

* Identify resources for deprecation.
* Create an RFC following the [Chef RFC](https://github.com/chef/chef-rfc) process.
* Announce on Chef mailing list and Chef Community Slack.
* Add deprecation warnings in the client and on the docs site.
* Add foodcritic rule to detect usage.
* Deprecate resource.

## Downstream Impact

Cookbooks that use deprecated resources will need to be modified to depend on the relevant compatibility cookbooks in order to continue using the resources or break on the release of the next version of Chef.

For resources that are adopted into Chef Core, individuals will receive warnings for using conflicting cookbooks.

## References

https://docs.chef.io/resources.html
https://docs.chef.io/chef_deprecations_client.html
https://github.com/chef-cookbooks
https://supermarket.chef.io/users/chef


## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
