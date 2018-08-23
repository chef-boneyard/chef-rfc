---
RFC: 100
Title: Establish Core Resource Lifecycle
Author: 'Jennifer Davis <sigje@chef.io>, Tim Smith <tsmith@chef.io>'
Status: Accepted
Type: Process
---

# Core Resource Lifecycle

This RFC describes the support lifecycle of [core resources](https://docs.chef.io/resources.html) provided within the chef-client.

## Motivation

```
As a Chef user,
I want core resources to be usable, reasonable and supported,
so that using Chef is a quality experience.
```

```
As a Chef user,
I want Chef to ship with resources out of the box,
so that I can easily automate my systems without additional dependencies.
```

```
As a Chef user,
I want to understand the current state of documented resources,
so that I implement resources correctly.
```

```
As a Chef developer,
I want a process for adding new resources to Chef,
so that I improve the usability of Chef.
```

## Guiding Principles

### Resource Scope

Ideally core resources should exist to automate all components of the underlying operating system and common subsystem services. This includes components such as authentication, raid, disk partitions, firewalls, containers, or virtualization systems. This does not include specific applications that users may want to automate such as database, application servers, or web servers. Application resources are better suited within cookbooks that can be rapidly iterated upon new application releases.

### Design

Core resources should be well-designed and self contained. Resources should work as end-users would expect them to work and care should be taken to reduce surprises.

### Maturity

Users should have an expectation of stability within core resources and this requires resources to have be proven out before being shipped in Chef. In order to accomplish this resources should first be shipped in cookbooks where the resource design can be proven and refined and support added for all currently supported platforms](<https://github.com/chef/chef-rfc/blob/master/rfc021-platform-support-policy.md>).

### Testing

Initial and ongoing resource stability is a key concern of core resources. All resources should be fully integration tested within the cookbook they are adopted from. Additionally all action_class methods and and property logic should be unit tested to prevent future regressions.

### Documentation

In order for resources to meet end user needs they must be properly documented. All resources should include in-resource documentation using the `introduced` and `description` options on the resource itself, all properties, and all actions.

## Resource States

At any given time current resources have an implicit state. These states allow us to define how a resource goes from a proposal to a shipped resource and eventually how it is retired when it is no longer useful.

### Proposed

Resources in proposed state are being evaluated to identify if a resource is appropriate and necessary within the chef-client. A resource could be in this state whether it's a popular widely used resource in a community cookbook or a gap in common infrastructure element.

### Development

Resources in development state are in active development. The value of adding the resource is understood and the design for the resource has been approved.

### Supported

Resources in supported state have been added to Chef, work on relevant platforms, and are tested.

### Deprecated

Resources in deprecated state have been identified as having significant issues that can not or will not be resolved. Use of the resource will emit a deprecation warning. A compatible cookbook(s) for the deprecated resource may be created or updated to allow use of the deprecated resource.

### Retired

Resources in retired state have been in deprecated state and emitting warnings and on the next major release of Chef removed from code.

## Specification

### Criteria for adopting resources

Factors that influence and inform the decision to adopt a resource include:

- widespread use of a resource based on analysis of publicly available supermarket cookbooks,
- well tested and supported cookbook resources,
- percentage of supported platforms,
- impact of implementing as a primitive that can be built upon.

### Criteria for deprecating resources

Factors that influence and inform the decision to deprecate a resource include:

- limited use based on analysis of publicly available supermarket cookbooks,
- outdated code or lack of support based on quality of resource and its usability,
- security implications,
- complex implementation that lacks clarity of consequences of use.
- impact of using the resource incorrectly.

### Process for proposing / developing new resources

Users may propose new resources for inclusion in the chef-client by filing a resource proposal issue in the Chef GitHub repository. The chef-client maintainers will work with the user proposing the new resource to fully document the needs and the proposed design. Upon approval from two core maintainers the proposal will be marked `Status: Approved for Development` and the development phase may begin.

#### Proposal Process

- Identify resources for adoption.
- Create an issue at [https://github.com/chef/chef] outlining the reason for shipping the resource in core.
- Announce your proposal in the #chef-dev channel on Chef Community Slack.
- Chef-client maintainers will work with you to fully document the needs and the proposed design of the resource.
- Once two chef-client maintainers have approved the proposal the `Status: Approved for Development` label will be applied and development may begin.

#### Development Process

- The developer working on the resource will state so in the ticket and the ticket will be assigned to them.
- All development must take place initially in a cookbook.
  - If an existing cookbook exists for the resource the resource must be updated there to the final design before inclusion in the chef-client.
  - If writing a new resource create a cookbook just for the resource to provide backwards compatibility for users on previous chef-client versions.
- Resource is added to core chef.
- Release notes must be updated mentioning the new resource and it's usage.
- Documentation must be updated for the new resource.

#### Timeline of resource migration

While we strive to ensure the migration of a resource from a cookbook to core is 100% compatible, small issues can still arise. In order to ensure that Chef feature releases do not cause destabilization, we follow a multi-part timeline for the migration. Starting from the top:

1. A resource is added in a cookbook.
2. That resource is proposed for core inclusion (see above section).
3. The resource is added to core with an annotation of `preview_resource true`.
4. Chef releases a minor (features-only) version with the new resource. It will remain inert if the original cookbook is active until the given version.
5. The following April, as Chef prepares for the yearly major release, all pending `preview_resource` annotations will be removed.
7. If/when the user chooses to upgrade to the Chef major version, even if the old cookbook is still present in their environment, the resource from core will be used.

To summarize this timeline as a table, imagine we have a cookbook that adds a new resource in version 3.5, and then nominates it for core inclusion as part of Chef 15.3:

```
+-------------+--------+--------+-----------+
|             | old cb | new cb | future cb |
|             | (3.4)  | (3.5)  | (4.0)     |
+-------------+--------+--------+-----------+
| old chef    | none   | cb     | none      |
| (15.2)      |        |        |           |
+-------------+--------+--------+-----------+
| new chef    | core   | cb     | core      |
| (15.3)      |        |        |           |
+-------------+--------+--------+-----------+
| future chef | core   | core   | core      |
| (16.0)      |        |        |           |
+-------------+--------+--------+-----------+
```

This shows that if the resource was already in use, a change in behavior only comes from a major version of upgrade of either Chef or the cookbook, which allows fine-grained user control of the upgrade process from both sides.


### Process for deprecating resources

- Identify resources for deprecation.
- Create an RFC following the [Chef RFC](https://github.com/chef/chef-rfc) process.
- Announce on Chef mailing list and Chef Community Slack.
- Add deprecation warnings in the client and on the docs site.
- Add foodcritic rule to detect usage.
- Deprecate resource.

## Downstream Impact

Cookbooks that use deprecated resources will need to be modified to depend on the relevant compatibility cookbooks in order to continue using the resources or break on the release of the next version of Chef.

For resources that are adopted into Chef Core, individuals will receive warnings for using conflicting cookbooks.

## References

- <https://docs.chef.io/resources.html>
- <https://docs.chef.io/chef_deprecations_client.html>
- <https://github.com/chef-cookbooks>
- <https://supermarket.chef.io/users/chef>

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0\. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
