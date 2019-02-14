---
RFC: 14
Title: Universe Endpoint for Chef Server
Author: Daniel DeLeo <dan@chef.io>
Status: Final
Type: Standards Track
Tracking:
  - https://github.com/chef/chef-server/pulls/645
---

# Universe Endpoint for Chef Server

## Use Case

Users would like to host their cookbook artifacts on their chef-server
and use these artifacts with an external dependency solver. There are a
variety of motivations for hosting cookbooks internally:

* User wants to control the availability of the service they fetch
cookbooks from.
* User wants to publish closed source cookbooks to a centralized
artifact server for internal distribution within their organization.
* User wants to vet third party cookbooks before other users in their
organization access them for compliance and/or stability reasons.

Users can currently publish cookbooks to a chef server using `knife` or
any other tool that implements the server's HTTP API. If the user wants
to find a version compatible set of cookbooks and dependencies, however,
they currently must recursively query the chef server, making a request
for the list of cookbook names, the list of versions of each cookbook,
and the dependencies of each version. The large number of round trips
involved would make this operation prohibitively time-consuming.
Currently, working around this limitation requires caching the
dependency information and refreshing it periodically, which implies
running a separate service that periodically polls the chef server for
updates to the dependency information. This workaround is suboptimal
because it requires the overhead of managing a separate service and adds
latency to the dissemination of cookbooks after publishing.

## Universe Endpoint

This proposal addresses the described use case by adding a dependency
API to the chef server. The endpoint is accessed by making an HTTP GET
request to BASE_SERVER_URL/universe; in Enterprise Chef a full URL may
look like 

  https://chef-server.example.org/organizations/org_name/universe

Assuming the request meets all authentication and authorization
requirements, the server responds with a JSON document containing the
list of all cookbooks, their available versions, and the dependencies of
each. The format of this document is mostly identical to the format of
the response given by the supermarket universe API, which is documented
here: http://docs.opscode.com/api_cookbooks_site.html#universe The
response given by the chef server differs from the supermarket API in
that the `location_type` field in the response is set to "chef_server".

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
