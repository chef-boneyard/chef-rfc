---
RFC: unassigned
Title: Server Enforced Recipe
Author: Daniel DeLeo <dan@chef.io>
Status: Draft
Type: Standards Track
<Tracking:>
<  - https://github.com/chef/chef/issues/X>
---

# Server Enforced Recipe

## Description

Chef Server will provide an endpoint that MAY serve a Chef recipe file. Chef
Client will attempt to fetch the recipe during run context setup. If
no user action is taken to configure the feature, the endpoint returns 404
and Client behavior will be unaffected. When the feature is enabled, the
endpoint returns the configured recipe file. Chef Client will evaluate and
converge the recipe.

## Rationale

The motivation for this feature is to allow the operator of the Chef Server to
enforce desired client-side configuration using Chef. Intended use cases include:

* Allow cloud-based vendors to install an agent necessary for correct operation
  of the service
* Allow Chef Customer Development Partners to efficiently install experimental
  client-side software during feature development
* Allow organizations that operate as internal service providers to enforce
  standard configurations

Currently the only way to achieve these goals with Chef is to enforce the
inclusion of recipes on a node's run list, which is not feasible in many cases.

The enforced policy is limited to a single recipe instead of a full cookbook or
secondary run list for several reasons:

* Cookbooks are Chef Server objects that are organization-scoped and subject to
  authorization restrictions. Allowing some cookbooks to be global requires
  additional complexity which is not needed for the intended uses.
* Cookbooks have versions and dependencies, which have to be solved. There are
  several ways this could be addressed, but all options introduce unneeded
  complexity into the solution.

## Motivation

    As a Chef Server Service Provider,
    I want to enforce a recipe to run on client systems,
    so that I can ensure client systems are correctly configured.

## Specification

### Enforced Recipe Endpoint

Chef Server shall expose an organization-scoped endpoint for the enforced
recipe. If the feature has not been configured by the Chef Server
administrator, the endpoint shall return a 404 response. If the feature is
enabled by the Chef Server administrator, the endpoint shall return a 200
response with the recipe content as the response body.

The endpoint shall authenticate the request via Chef Server's usual
authentication mechanism.

No authorization mechanism is provided. Any user or client with API access to
any organization on the Chef Server will have read-only access to the enforced
recipe.

The URL path of the endpoint relative to the organization base path will be
determined at a future time.

### Chef Server Configuration

The interface for configuring the feature is to be determined.

Though the initial implementation will likely only support a standalone Chef
Server deployment, the configuration interface will be written such that it can
be extended to support tiered and HA configurations.

### Chef Run

During the setup phase of the Chef Client run, Chef Client shall make a HTTP
GET request to the enforced recipe endpoint. If the Chef Server returns a 404
response, Chef Client will continue the Chef Client run normally. If the Chef
Server returns a 200 response, Chef Client will store the recipe file in its
cache directory. Chef Client will then evaluate and converge the recipe using a
mechanism to be decided.

One possible implementation is to add the recipe to the list of
`specific_recipes` which is currently populated only via CLI arguments to
`chef-client --local-mode`. In this case, enforced recipes would be evaluated
and converged after the primary run list.

## Downstream Impact

No downstream impacts are expected.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
