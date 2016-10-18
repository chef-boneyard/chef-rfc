---
RFC: unassigned
Title: Chef Release and Deprecation Policy
Author: Tim Smith <tsmith@chef.io>
Status: Draft
Type: <Process>
---

# Chef Release and Deprecation Policy

A policy for shipping major Chef releases on a predictable schedule along with the communication of breaking changes to users.

This RFC is two fold:

It states that Chef will ship a new major release of the chef-client on a yearly schedule.

It also sets policy for the for when breaking changes can occur, and how Chef will communicate those changes to users. Chef will provide a clear road map of upcoming compatibility breaks, including remediation steps users can take to update their codebase. This allows for the project to progress while also providing users with the information necessary to scope future upgrades. It avoids what has been called the Chef 13 problem, in which the large time between major releases creates a mass of breaking changes that hinders adoption of new major releases.

## Motivation

```
As a developer of Chef,
I want to be able to deprecate functionality
so that the development of new functionality can be unblocked.

As a user of Chef,
I want a clear path to deprecation
so that I have a predictable schedule of work to adopt new Chef releases.

As a user of Chef,
I do not want infrequent major releases with large numbers of breaking changes
so that I can more easily stay current with Chef releases.
```

## Specification

### Proposed Release schedule

Chef will release a major version of Chef (13, 14, etc) on a yearly schedule during the month of April. The avoids releasing during winter holidays, summer vacations, ChefConf and Chef Summits. A reminder notice will be sent via Discourse and Slack in March that will summarize the changes slated for the release.

### Proposed Deprecation Process

To deprecate functionality Chef developers will complete the following steps:

1. Open a PR against the Chef github repository for the proposed deprecation

  - Add a deprecation notice to the release notes of the upcoming release. This follows the example format shown below.
  - If technically feasible, add deprecation messaging in the client so that users will be notified of code changes they need to make during the client runtime. This follows the example format shown below.

2. Open a PR to the Chef Docs to add a page outlining the deprecation. This is linked to from the release notes and deprecation messaging. It provides the user with context for the deprecation and remediation steps. This allows users to easily update their code for the upcoming changes. Also add the deprecation to the main Chef Docs deprecation page so that users can easily refer to a list of past and future breaking changes.

3. If technically feasible, add a linting rule to either Foodcritic or Cookstyle that will allow us to test community cookbooks for compatibility upon uploading to Supermarket.

4. When performing the Chef release, the release announcement post to discourse will include the notice of the future deprecation as well as any deprecations that took place in the release.

### Advantages for Users

Moving to a model in which we slowly deprecate functionality avoids large breaking Chef releases which are painful to end users for two main reasons:

1. They delay functionality and the resolution of bugs that impact user workflow. There are numerous open issues and feature requests in the Chef github repository that we cannot resolve as they require a major breaking release. Chef 12 was released approximately 18 months ago. We do not currently have a plan for a Chef 13 release. Waiting multiple years for resolution of issues is less than ideal for end users.

2. Major version bump releases, which include large numbers of small breaking changes, are bound to break nearly everyone. Due to this many users avoid adoption of these releases for significant periods of time. Large numbers of users delayed their upgrade from Chef 10 to 11 and many have still delayed their upgrade from 11 to 12\. This makes it hard for the community to utilize new functionality in Chef releases since using these new features breaks the large number of users that have held back on upgrades.

### Advantages for Development

A gradual deprecation model provides the following benefits to developers of Chef (and in turn users):

1. Allows for the introduction of new functionality that benefits end users, but may break some workflows
2. Avoids the need for overly complex backwards compatibility that rarely predicts every use case of the product

### Sample chef-client deprecation messaging

```
node.set is deprecated and will be removed in Chef 12.20 scheduled for release 03/2017\. See https://docs.chef.io/deprecation_node_set.html for details. Code in question:
           - /tmp/kitchen/cache/cookbooks/monitor/recipes/_handler_deregister.rb:30:in `from_file'
```

### Sample Deprecation Release Notes Notice

This notice would appear in the release notes of the chef Github repository as well as the Chef release announcements post to Discourse.

#### Future Deprecation of node.set

**Impact**: Medium

**New deprecation warnings added**: Yes

**Deprecation Date**: March 2017

**Deprecation in Chef Release**: 12.20

**Description**: The node.set method will be removed from the chef-client. Node.set is actually an alias for node.normal which persists attribute data to the node. However, due to the "set" name, new users often see it as the correct way to set data that should not persist. This causes unexpected behavior if the node.set call is later removed from a cookbook. In order to avoid the confusion that occurs we will remove node.set.

**Remediation**: You can simply replace all occurrences of node.set with node.normal to maintain the existing behavior. We highly suggest you evaluate your usage of node.set / node.normal though to see if that is actually the attribute behavior you desire. See <https://docs.chef.io/deprecation_node_set.html> for details.

### Sample docs.chef.io Deprecation Page

Change           | Status     | Impact | Deprecation Date | Deprecation Release | Remediation Page
:--------------- | :--------- | :----- | :--------------- | :------------------ | :-----------------------------------------------------
SSL by default   | Deprecated | Medium | 12/2014          | 12.0                | <https://docs.chef.io/deprecation_ssl_by_default.html>
node.set removal | Proposed   | Medium | 03/2017          | 12.20               | <https://docs.chef.io/deprecation_node_set.html>

## To Be Determined Before Acceptance

1. How would we rate impact? Difficulty to fix or how many users are impacted? Node.set is trivial to fix, but impacts a large number of users regardless of platform.
2. Should part of our deprecation policy be to develop cookstyle with autocorrect functionality so that users could auto fix issues like node.set?
3. How long exactly should a deprecation notice be and should it be a stepped warning (nothing, warn, fail)? I used 6 months for the node.set example, but does a year make sense to make sure users have a change to upgrade and see the deprecation warnings? Does that slow development pace too much in the name of compatibility?

## Downstream Impact

Not directly by this RFC, but deprecation in general will most definitely require retooling of downstream tools

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0\. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
