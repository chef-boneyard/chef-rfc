---
RFC: unassigned
Author: Marc Paradise <marc@chef.io>
Status: Draft
Type: <Standards Track>
---

# Chef Server API Versioning

The purpose of this RFC is to provide a graceful deprecation mechanism
for the Chef Server REST API.

As the capabilities of the Chef Server API expand, it becomes necesasry
to deprecate and desupport old API behaviors.  However, consumers of the
API such as chef-client may not yet be able to support changed API behaviors.
The version indicator is used by a client to indicate which level of
API behavior it can support.

Any given release of the Chef Server will include documentation of the current minimum
and maximum supported API versions, as well as behavior changes between any newly
introduced version and the one prior to it. It will also include, if appropriate,
which version has been deprecated, and which version has been retired.

API Versioning is independent of product versioning.

## Motivation

    As a consumer of the Chef Server API,
    I want to be able to consume significant changes at my own pace
    so that they don't break my usage of the API.

    As a user chef-client at a supported version level,
    I want to ensure that changes to the server API don't affect me until I'm ready to upgrade
    so that all my nodes continue to converge even as Chef Server API continues to mature.

    As a developer of the Chef Server API,
    I want to be able to add potentially breaking feabtures without breaking customers on supported versions
    so that the state of the Server API can continue to advance.

## Specification

The Chef Server API Version (Version from this point forward) is indicated as a whole number,
starting at zero. Zero indicates the behavior of the API at the time of this RFC's acceptance.

If a client does not indicate a version preference, it MUST receive the behavior
of the OLDEST supported API version.

If a particular endpoint does not implement versioning due to remaining unchanged, it MUST
behave in a forward-compatible way through the range of currently supported version. In
documentation these will be specified as having compatibility with versions 0+.

If a particular endpoint does implement versioning and remains unchanged, it MUST behave in a
forward-compatible way through the range of currently supported versions. In documentation
these will be specified as N+, where N is the version at which it was last modified.

For this section, "API" refers to any combination of a method and endpoint, eg `GET /users`,
`POST /organizations/$org/clients`, et al.

### Request

A client MAY request version compatibility via custom header as
follows:

`X-Ops-Server-API-Version: $version`

`$version` MUST be one of:

* the desired version number indicated by a whole integer
* `current` - indicating the behavior of the highest supported version
* `stable` - indicating the behavior of the lowest supported version
* `next` - indicating current, plus any experimental/in-development behaviors.

### Response

If a client does include this header and `$version` is...

* ... less than the minimum Version supported by the server product, the
  server MUST respond with an HTTP 406 with `application/json` body specified below.
* ... greater than the current maximum Version supported,
  the server MUST respond with an HTTP 406 and an `application/json` body specified below.
* ... of a value other than a valid version, `current`, `stable`, or `next`, the server
  MUST respond with an HTTP 406 and the body specified below.


If `$version` is valid or is not specified, the API response will contain the headers:

````
X-Ops-Server-API-Version: $actual_version
Vary: X-Ops-Server-API-Version`
````

`$actual_version` MUST indicate the API version level of the response.  The `Vary` header is included
in the event it becomes desirable to support caching of specific responses.

#### 406 Response Body

When the server provides a 406 response due to unsupported API version, the response body
will be of type `application/json` and MUST look as follows:

    { "error" : "invalid-x-ops-server-api-version",
      "message" : "Specified version $version not supported",
      "min_api_version" : $x,
      "max_api_version": $y }

`$version` indicates the requested version. `$x` and `$y` are the current minimum and
maximum supported versions, respectively.

### Server Implementation

The minimum version MUST NOT be configurable, as it indicates the level supported in the code.

The maximum version MUST be configurable, allowing an installation to explicitly
limit the introduction of new behaviors.  The configured value MUST NOT exceed the maximum
supported by the codebase; if such a value is specified, or if a value is not configured,
the supported maximum MUST be assumed.

The configured value MUST NOT be less than the supported minimum version. If such a value is specified,
the supported minimum MUST Be assumed.

Minimum and maximum values in effect MUST be logged at server startup.  Further, current API support levels
MUST be exposed through a new endpoint, `GET /server_api_version` as specified below.

The server MUST resolve and validate the version at the start of each request, and retain it in request state
for resources to make use of.

The implementation MAY require addition of version support callbacks in erchef webmachine resources.

Given no `X-Ops-Server-API-Version` header or a `null` value of version, it MUST resolve to the
minimum supported version.

Given a value of version, it MUST be resolved as follows:

* The version label `stable` shall resolve to the minimum supported version.
* The version label `current` shall resolve to the maximum supported version.
* The version label `next` shall resolve to the internal identifier `next`.  When no such behavior
is applicable, the resource MUST treat this as if it were the maximum supported version.
* A numeric version MUST be validated against current minimum and maximum versions as
specified under section "Response".
* Any other value is invalid and the server MUST respond to the client with a 406
and the associated response body specified above.

### Effects on Unmodified APIs:

APIs that are not modified are not required to support Version.  They are assumed to be
compatible and unchanged through the current range of min/max supported versions.

### Effects on Modified APIs:

Any API modified as follows MUST use `api_version` to determine which behavior to
present to the client:

* new required field on input
* change in type of an output field
* change in client-facing behavior of the API

Any API modified as follows MAY use `api_version` to determine which behavior to
present to the client:

* removal of a required input field
* addition of an output field
* change in internal behavior of the API

#### New API Implementations

Any new API MAY implement checking of `api_version` to determine its availability.

#### Deprecated API Behaviors

Any API behavior that is to be deprecated MUST have the version for both its deprecation and
its removal documented in release notes and in API documentation.

After deprecated behavior has been removed, last supported API version MUST be updated in
accordance with the published documentation.

### Documentation

When an API is modified in a way that requires support of Version, release notes and API
documentation MUST reflect this.  API documentation MUST further specify minimum/maximum
versions for each endpoint that implements support of versioning.

### New Endpoint: /server\_api\_versions

This is a new server endpoint that MUST be implemented, and  which supports only the `GET` method.
Any other method MUST respond with a 405.

The `GET` response body MUST look as follows:

````
{ "min_api_version" : $x,
  "max_api_version" : $y,
  "additional_versions", [ "stable", "current", "next" ] }
````

`$x` and `$y` refer to the current minimum and maximum supported versions, respectively.

`additional_versions` indicate the non-specific version labels which may be used by the client.

### New Endpoint: /server\_api\_versions/extended

This is a new server endpoint that MAY be implemented, and which supports only the `GET` method.
Any other method MUST respond with a 405.

If this endpoint is implemented, the `GET` response body contains supported API version data
for each endpoint that has implemented versioning, and MUST look as follows:

````
{ "endpoints" : [ { "name" : "$relative_url",
                    "versions" :
                      [ { "method" : $method,
                          "version" : $version
                          "status" : $status }, ... ] } ] }
````

* `$relative_url` is a URL relative to the server root and will not include server name
or protocol, as this value is not intended for direct use by a client in a request.
* components in the `$relative_url` prefixed with `:` indicate that this is a named value that must be
* Multiple version elements for the same method can be returned, made unique by the `version` field.
provided by the client.
* `$method` indicates the http method associated with the endpoint
* `$version` indicates the API version to which this information applies, or `"next"` if this is an
experimental feature or feature under active development.
* `$status` indicates current status of this endpoint as either:
  * `deprecated` - this version of the endpoint is deprecated and will be removed in a future revision
  * `active` - this version of the endpoint is currently active and available for use
  * `unstable` - this is under active development and the behaviors defined for it are subject to change.
  used with `version` : `next`, but it is possible to have `version` : `next` in conjunction with
 `status` : `active`

Sample output:

````
{ "endpoints" : [ { "name" : "/organizations/:orgname/clients/:client",
                    "versions" :
                      [ { "method" : "GET", "version" : 0, "status" : "deprecated" },
                        { "method" : "GET", "version" : 1, "status" : "active"},
                        { "method" : "GET", "version" : "next", "status" : "unstable" }] },
                  { "name" : "/users/:user",
                    "versions" :
                      [ { "method" : "GET", "version" : 0, "status" : "deprecated"},
                        { "method" : "GET", "version" : 1, "status" : "active" } ] }
                 ] }

````

This endpoint MAY be extended to include information about endpoints that do not
explicitly implement versioning.  The response MUST be in the same form.

The server MAY rate-limit this endpoint due to the potential cost associated with it.

Finally, the server MAY further extend this API to allow clients to query version information for
a specific method + endpoint, in which case version information for that specific endpoint is returned,
or 404 if there is no such endpoint.

To continue the example above, the request:

`GET /server_api_versions/extended/GET/organizations/:orgname/clients/:client`

Would receive the response:

````
 { "name" : "/organizations/:orgname/clients/:client",
   "versions" : [ { "method" : "GET", "version" : 0, "status" : "deprecated" },
                  { "method" : "GET", "version" : 1, "status" : "active" },
                  { "method" : "GET", "version" : "next", "status" : "unstable"}] },
````

## Rationale

We have decided on the use of a single custom header to indicate version (instead of url-based or
`Accept` header-based) for several reasons:

* Our REST model requires a specific URL to refer to a specific resource.  This resource is not
versioned, though the semantics of what the resource includes or how to create it may be
versioned.
* The URIs currently used by Chef Server are not typically shareable for access via a simple http request
outside of a given context due to authentication and authorization requirements, and so this is not
a consideration in any of the above cases.
* Our internal tooling will not always be compatible with URL-based versioning,
as it is not uncommon for a component to assemble its own URIs instead of
relying on the "uri" field returned from the server.
* There exists precedent in that we already require specific headers to be
sent from the client in order to service a request. For example, `X-Ops-User-Id`.
* A custom `Accept` header was also considered, we chose the custom `X-Ops-Server-API-Version` header
to keep our API usage patterns consistent and relatively simple.  As mentioned above
we already require custom headers, and combining those with specific `Accept` header strings
would mean introducing a new and slightly varied means of obtaining the desired behavior out of the API.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

