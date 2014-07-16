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
prefer to use an autoincrementing integer scheme, like svn; users that
need to publish cookbooks to the server (either manually or as part of a
Ci pipeline) to run integration tests may not be ready to assign a
static version number to their content; very basic users (like
beginners) may not have a need for versioning at all (yet); and users
who have temporarily forked a third party cookbook have no way to
publish it to a server without potentially conflicting with the
upstream's version.

* In order to provide a compromise between users who do not need
versioning and those who rely on it (via the environments feature, for
example), the server allows mutating existing versions of cookbooks,
with an option to "freeze" a version. This compromise is often the worst
of both worlds, because it requires the user to be dilligent about
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
* Cookbooks uploaded to this endpoint are not visible to the
`/environments/:environment/cookbook_versions` endpoint.
* The endpoint has no concept of "freezing." Overwriting an existing
object with the same identifier is always an error.
* A GET request to `/cookbook_artifacts/:cookbook_name` should include
extra information about each version of a cookbook, such as its SemVer
version number, to facilitate tooling that provides a better user
experience when working with opaque identifiers.

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
https://github.com/opscode/chef/blob/9d277e5a4505e5e83e9c4eb30328fdc7148f15c6/lib/chef/policy_builder/policyfile.rb

### What Happens to the Existing Cookbooks API

The existing cookbooks API remains as-is, for the following purposes:

* Backwards compatibility with existing tools and workflows.
* It provides an "internal supermarket" for users to publish artifacts
within their organization.

After a sufficient period of time, we may remove the dependency solver
from the chef-server if there is a compelling reason to do so.

