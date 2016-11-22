---
RFC: 82
Title: Chef Deprecation Policy
Author: Tim Smith <tsmith@chef.io>
Status: Accepted
Type: Process
---

# Chef Deprecation Policy

A policy for the the inclusion and communication of breaking changes.

This RFC sets policy for how and when breaking changes will be included in Chef and how they will be communicated to users. Chef will provide a clear road map of upcoming compatibility breaks, including remediation steps users can take to update their codebase. This will allow the project to progress while also providing users with the information necessary to scope future upgrades. It avoids what has been called the Chef 13 problem, in which the large time between major releases creates a mass of breaking changes that hinders adoption of new major releases.

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

Deprecations, also known as breaking changes, will be reserved for the yearly major chef-client release defined in RFC #81.

In order to schedule future deprecations Chef developers will complete the following steps:

1. Open a PR against the Chef github repository for the proposed deprecation.

  - Add a deprecation notice to the release notes of the upcoming release. This follows the example format shown below.
  - If technically feasible, add deprecation messaging in the client so that users will be notified of code changes they need to make during the client runtime. This follows the example format shown below.

2. Open a PR to the Chef Docs repository to add a page documenting the deprecation. This will be linked to from the release notes and deprecation messaging in the client. It provides the user with context for the deprecation and remediation steps. This allows users to easily update their code for the upcoming changes. Also add the deprecation to the main Chef Docs deprecation page so that users can easily refer to a list of past and future breaking changes.

3. If technically feasible, add a linting rule to either Foodcritic or Cookstyle that will allow us to test community cookbooks for compatibility upon their upload to Supermarket.

4. When performing the Chef release, the release announcement post to discourse will include the notice of the future deprecation.

### Advantages for Users

Moving to a model in which we communicate deprecations and move forward with those deprecations in major releases improves the overall user experience. It gives our users prior warning of deprecations that allows them to plan the work necessary to stay current. This avoids users either assigning last minute resources to refactor cookbooks, or avoiding new releases as the breaking changes require too much last minute work.

### Advantages for Development

A more gradual deprecation model provides the following benefits to developers of Chef (and in turn users):

1. Allows for the introduction of new functionality that benefits end users, but may break some workflows without waiting years.
2. Avoids the need for overly complex backwards compatibility that rarely predicts every use case of the product.

### Sample chef-client deprecation messaging

```
node.set is deprecated and will be removed in Chef 13.0 scheduled for release 04/2017\. See https://docs.chef.io/deprecation_node_set.html for details. Code in question:
           - /tmp/kitchen/cache/cookbooks/monitor/recipes/_handler_deregister.rb:30:in `from_file'
```

### Sample Deprecation Release Notes Notice

This notice would appear in the release notes of the chef Github repository as well as the Chef release announcements post to Discourse.

#### Future Deprecation of node.set

**Impact**: Medium

**New deprecation warnings added**: Yes

**Deprecation Date**: April 2017

**Deprecation in Chef Release**: 13.0

**Description**: The node.set method will be removed from the chef-client. Node.set is actually an alias for node.normal which persists attribute data to the node. However, due to the "set" name, new users often see it as the correct way to set data that should not persist. This causes unexpected behavior if the node.set call is later removed from a cookbook. In order to avoid the confusion that occurs we will remove node.set.

**Remediation**: You can simply replace all occurrences of node.set with node.normal to maintain the existing behavior. We highly suggest you evaluate your usage of node.set / node.normal though to see if that is actually the attribute behavior you desire. See <https://docs.chef.io/deprecation_node_set.html> for details.

### Sample docs.chef.io Deprecation Page

Change           | Status     | Impact | Deprecation Date | Deprecation Release | Remediation Page
:--------------- | :--------- | :----- | :--------------- | :------------------ | :-----------------------------------------------------
SSL by default   | Deprecated | Medium | 12/2014          | 12.0                | <https://docs.chef.io/deprecation_ssl_by_default.html>
node.set removal | Proposed   | Medium | 03/2017          | 13.0                | <https://docs.chef.io/deprecation_node_set.html>

## Implementation details that need to be worked out

1. How would we rate impact? Difficulty to fix or how many users are impacted? Node.set is trivial to fix, but impacts a large number of users regardless of platform.
2. Should part of our deprecation policy be to develop Cookstyle with autocorrect functionality so that users could auto fix issues like node.set?
3. How long exactly should a deprecation notice be and should it be a stepped warning (nothing, warn, fail)? I used 6 months for the node.set example, but does a year make sense to make sure users have a change to upgrade and see the deprecation warnings? Does that slow development pace too much in the name of compatibility?

## Downstream Impact

Not directly by this RFC, but deprecation in general will most definitely require retooling of downstream tools

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0\. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
