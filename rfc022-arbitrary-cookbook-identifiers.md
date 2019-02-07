---
RFC: 22
Title: Arbitrary Cookbook Identifiers
Author: Daniel DeLeo <ddeleo@chef.io>
Status: Accepted
Type: Standards Track
Chef-Version: 12
---

# Arbitrary Cookbook Identifiers

## Use Case

The current implementation of cookbook storage in chef server identifies
cookbooks with a compound identifier composed of the cookbook's name and
version number, where the version number is restricted to the subset of
SemVer supported by the dependency resolver subsystem.

This identifier scheme has the following deficiencies:

* It assumes that users publish content following a similar process to
releasing end-user software, when in reality, there are many other
workflows. For example, teams that iterate and publish rapidly may
prefer to use an auto-incrementing integer scheme, like svn; users that
need to publish cookbooks to the server (either manually or as part of a
Ci pipeline) to run integration tests may not be ready to assign a
static version number to their content; and very basic users (like
beginners) may not have a need for versioning at all (yet).

* Users who have temporarily forked a third party cookbook have no way
to publish it to a server without potentially conflicting with the
upstream's version.

* In order to provide a compromise between users who do not need
versioning and those who rely on it (via the environments feature, for
example), the server allows mutating existing versions of cookbooks,
with an option to "freeze" a version. This compromise is often the worst
of both worlds, because it requires the user to be diligent about
freezing versions and has the potential for catastrophe should the user
forget.

## Arbitrary Cookbook Identifiers Proposal

This proposal addresses the use case by adding an additional set of APIs
for cookbook storage that identify cookbooks by arbitrary identifiers.
The endpoint is functionally identical the the current `/cookbooks`
endpoint, with the following exceptions:

* it is located at BASE_URL/cookbook_artifacts
* Cookbook "versions" are identified by an arbitrary identifier. This
identifier may be limited to 255 URL-safe characters, and there can be
other limitations such requiring the first character not be an
underscore (so that the server can provide "special" URLs using an
underscore in the path component). The URL for a cookbook instance would
be `BASE_URL/cookbook_artifacts/:cookbook_name/:identifier`
* There is no uniqueness constraint on cookbook name and version; this
endpoint allows there to be (e.g.,) multiple distinct Apache2 1.0.0
cookbooks as long as each one has a unique identifier.
* Cookbooks uploaded to this endpoint are not visible to the
`/environments/:environment/cookbook_versions` endpoint.
* The endpoint has no concept of "freezing." Overwriting an existing
object with the same identifier is always an error.
* A GET request to `/cookbook_artifacts/:cookbook_name` should include
extra information about each version of a cookbook, such as its SemVer
version number, to facilitate tooling that provides a better user
experience when working with opaque identifiers. Extended metadata, such
as a URL to the upstream source of this cookbook (e.g., supermarket,
github, etc.) and associated upstream identifiers (e.g., git commit ID)
may also be useful. The entry for an individual cookbook artifact could
look like:

```json
  { "name": "apache2",
    "identifier": "886757f9ae3cf2520c82b791195c27ecafd93656",
    "version": "1.10.4",
    "url": "https://chef.example.org/organizations/:org/cookbook_artifacts/apache2/886757f9ae3cf2520c82b791195c27ecafd93656",
    "origin_url": "https://supermarket.chef.io/cookbooks/apache2/versions/1.10.4/download",
    "origin_id": "1.10.4"
  }
```

* If feasible, we should relax validation on the version field of the
uploaded cookbook to allow full SemVer version numbers. This allows
users to add extra information to the version field if they choose to do
so.
* If feasible, the `cookbook_artifacts` endpoint should provide a bulk
API that allows an API consumer to request multiple cookbook objects
in a single request response cycle. The existing server-side dependency
solver endpoint at `/environments/:environment/cookbook_versions`
provides this behavior, but is not be used by chef-client when
fetching cookbooks via the new artifact-based API.

### How Chef Client Uses Cookbooks with Arbitrary IDs

`chef-client` will have a new mode of operation where it loads a
document that contains a list of cookbook artifact names and identifiers
to use for a chef-client run. The format of the document may be more
complex, but it will contain enough information to produce a list of
cookbook name and identifier pairs, e.g.,

```json
{
  "omnibus": "64b3e64306cff223206348e46af545b19032b170",
  "homebrew": "ab4ad2481e08cbb2c4874fd36a44e76f36ec91f7"
}
```

Given the above, chef-client would make requests to
`BASE_URL/cookbook_artifacts/omnibus/64b3e64306cff223206348e46af545b19032b170`
and
`BASE_URL/cookbook_artifacts/homebrew/ab4ad2481e08cbb2c4874fd36a44e76f36ec91f7`
to get cookbook objects with links to individual files it can download.

This mode is already partially implemented (using currently available
APIs) here:
https://github.com/chef/chef/blob/9d277e5a4505e5e83e9c4eb30328fdc7148f15c6/lib/chef/policy_builder/policyfile.rb

### What Happens to the Existing Cookbooks API

The existing cookbooks API remains as-is, for the following purposes:

* Backwards compatibility with existing tools and workflows.
* It provides an "internal supermarket" for users to publish artifacts
within their organization.

When both the old and new APIs are used concurrently, cookbooks uploaded
to the new end point must, by default, be invisible to the old end
point. The new end point allows multiple editions of a cookbook at the
same version number to exist simultaneously and provides an implicit
guarantee that uploading a cookbook will not interfere with any other
active cookbooks.

After a sufficient period of time (one or more major release cycles), we
may remove the dependency solver from the chef-server if there is a
compelling reason to do so.

## Discussion

Any implementation choices in this proposal are open for discussion. The
design constraints on the solution are:

* Must be able to store and fetch cookbooks according to arbitrary
identifiers (subject to reasonable constraints on identifier size and
URL-safety).
* Must not impact workflows using the older API, even if both APIs are
in use simultaneously.
* Allowing extended version numbers when using the new API is desirable
but not an absolute necessity.

