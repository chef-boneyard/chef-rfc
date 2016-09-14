---
RFC: 42
Title: Policyfile HTTP Resource API
Author: Daniel DeLeo <dan@chef.io>
Status: Accepted
Type: Standards Track
---

# Policyfile HTTP Resource API

Policyfiles are a new feature of Chef that allow the user to specify a
`run_list` and exact set of cookbooks that `chef-client` will use to
converge a node (host) to a desired state. In contrast with the current
behaviors of Chef Client and Server, Policyfiles provide a way to
describe and manage configuration code on a whole-node basis, reducing
Chef Client's use of shared, mutable resources hosted on the server and
providing operators easier visibility into configuration code and
changes. For further description of the Policyfile feature, read the dedicated
[POLICYFILE README.](https://github.com/chef/chef-dk/blob/master/POLICYFILE_README.md)

A preview implementation of the Policyfile feature is currently available; in
this implementation, Policyfile documents are stored as data bag items.
Although this implementation works, it does not provide the baseline quality
users expect. In particular, there is no validation, no means to make any
relational queries, and documents are indexed for search as data bag items.

This RFC describes a new Policyfile HTTP Resource API that remediates these
issues.

## Motivation

    As a Chef user,
    I want Policyfiles to have a dedicated HTTP Resource API,
    so that Policyfiles will be validated upon upload
    and I can query the relationships between Policyfiles and other objects,
    and Policyfiles will not be indexed as an incorrect data type.

## Specification

### General Concepts

A Policyfile lock is a JSON document that specifies a node's run list and the
set of cookbooks a node will use to converge the node.

A Policy Group is a set of nodes defined by a single token. Nodes must be a
member of a Policy Group in order to use the Policyfile feature, and nodes may
only be a member of one policy group.

### Policyfile Lock

A Policyfile lock is a JSON document that has the following structure:

```json
{
  "revision_id": "edd40c30c4e0ebb3658abde4620597597d2e9c17",
  "name": "some_policy_name",
  "run_list": [
    "recipe[policyfile_example_cookbook::default]"
  ],
  "cookbook_locks": {
    "policyfile_example_cookbook": {
      "version": "1.0.0",
      "identifier": "f04cc40faf628253fe7d9566d66a1733fb1afbe9"
    }
  }
}

```

#### `revision_id` Field (required)

The `revision_id` field is used to distinguish revisions of a Policyfile lock
document. It is a JSON String containing a hash of the canonicalized content of
the Policyfile lock, given in hexadecimal form. A fully compliant server MUST
independently compute the `revision_id` and reject a creation request if the
submitted `revision_id` is incorrect.

The canonicalized form of the Policyfile lock is not finalized at this time,
but will be provided in a future update to this document. Note that the format
will not be based on JSON, as JSON has no canonical form.

#### `name` Field (required)

The `name` field describes the functional role that is fulfilled by a node that
applies this policy. It may contain alphanumeric characters, hyphens,
underscores, the dot character and the colon character. In regular expression
form: `/^[\-[:alnum:]_\.\:]+$/`. The name is also limited to a maximum of 255
characters. The Chef Server must reject a Policyfile lock document if the name
does not meet these criteria.

#### `run_list` Field (required)

The `run_list` field gives the ordered list of recipes that Chef client should
apply to converge a node. Each item MUST be in fully qualified form, that is,
`recipe[COOKBOOK_NAME::RECIPE_NAME]`. Roles are not valid run list items in the
Policyfile lock document, and the Chef Server MUST reject run lists that
contain roles.

#### `cookbook_locks` Field (required)

The `cookbook_locks` Field is a JSON object (Ruby Hash). The keys are cookbook
names. The Chef Server MUST validate the keys according to the same validation
rules applied to cookbook names for other APIs. The values are JSON objects
that contain information about the cookbook.  These objects MUST have a
`version` field that gives the cookbook's version number. The server must apply
the same validation rules to this field as it applies to cookbooks uploaded to
the cookbook artifacts API, described in [Chef RFC022.](https://github.com/chef/chef-rfc/blob/master/rfc022-arbitrary-cookbook-identifiers.md)
They MUST also have an `identifier` field. This gives the cookbook's
identifier, as described in Chef RFC022. The Chef Server must validate this
field according to the same rules as applied to cookbooks uploaded to the
cookbook artifacts API.  Cookbook lock objects MAY contain other fields with
arbitrary information about the cookbook. The Chef Server must accept and
persist this data. For example, ChefDK generates Policyfile lock documents that
include source URLs, version control information, and the name of the directory
where the cookbook is stored in ChefDK's cache. Cookbook lock objects MAY
contain a `dotted_decimal_identifier` field which contains a representation of
the identifier as a version number.  This field is used when cookbooks are
stored on a server that does not support the arbitrary cookbook identifier API
described in Chef RFC022.

Example cookbook locks including optional fields:

```json
    "policyfile_demo": {
      "revision_id": "edd40c30c4e0ebb3658abde4620597597d2e9c17",
      "version": "0.1.0",
      "identifier": "f04cc40faf628253fe7d9566d66a1733fb1afbe9",
      "dotted_decimal_identifier": "67638399371010690.23642238397896298.25512023620585",
      "source": "cookbooks/policyfile_demo",
      "cache_key": null,
      "scm_info": {
        "scm": "git",
        "remote": "git@github.com:danielsdeleo/policyfile-jenkins-demo.git",
        "revision": "edd40c30c4e0ebb3658abde4620597597d2e9c17",
        "working_tree_clean": false,
        "published": false,
        "synchronized_remote_branches": [

        ]
      },
      "source_options": {
        "path": "cookbooks/policyfile_demo"
      }
    },
    "apt": {
      "version": "2.6.1",
      "identifier": "5f7045a8aeaf6ccda3b3594258df9ee982b3a023",
      "dotted_decimal_identifier": "26863567272587116.57882360917678303.174725757378595",
      "cache_key": "apt-2.6.1-supermarket.chef.io",
      "origin": "https://supermarket.chef.io/api/v1/cookbooks/apt/versions/2.6.1/download",
      "source_options": {
        "artifactserver": "https://supermarket.chef.io/api/v1/cookbooks/apt/versions/2.6.1/download",
        "version": "2.6.1"
      }
    },
```

Note that a future update to Chef RFC 022 will introduce a standardized format
for cookbook identifiers based on the content of the cookbook and will
introduce strict server-side checking of the identifier field.

#### `named_run_lists` Field (Optional)

Named run lists provide a replacement for the override run list feature in Chef
Client, which is not compatible with Policyfiles because the run list and
cookbook set must be bundled together in a Policyfile lock document.

Then `named_run_lists` field is a JSON object; inside this object, the keys are
the names of the named run lists and values are JSON arrays of run list items.
As with the top-level `run_list` field, run list items for named run lists MUST
be in fully qualified recipe form, and roles are not accepted.

A named run list name may contain alphanumeric characters, hyphens,
underscores, the dot character and the colon character. In regular expression
form: `/^[\-[:alnum:]_\.\:]+$/`. It must be a least one character long and
cannot exceed 255 characters.

```json
  "named_run_lists": {
    "update_jenkins": [
      "recipe[jenkins::master]",
      "recipe[policyfile_demo::default]"
    ]
  },
```

#### Attributes Fields (Optional)

A Policyfile lock may contain default and override attributes. Chef Client will
treat these attributes the same as it currently treats role attributes. Default
and override attributes are stored in separate top-level keys:

```json
{
  "default_attributes": {},
  "override_attributes": {}
}
```

#### Other Optional Fields

A Policyfile lock can contain arbitrary information in other top-level fields.
The Chef Server MUST accept and preserve the data in these fields (though the
server MAY enforce a limit on overall document size). ChefDK currently uses a
`solution_dependencies` field to store a list of all dependencies relevant to
the cookbook set.


### API Schema

#### `/policy_groups`

Container for policy groups.

##### `GET /policy_groups`

Returns a list of policy groups that exist.

#### `/policy_groups/:policy_group_name/_acl`

Authorization endpoint for the policy group `:policy_group_name`

#### `/policy_groups/:policy_group_name/policies/`

##### `GET /policy_groups/:policy_group_name/policies/`

Returns a JSON object showing the active policy names and revision IDs for the
policy group `:policy_group_name`.

#### `/policy_groups/:policy_group_name/policies/:policy_name`

##### `GET /policy_groups/:policy_group_name/policies/:policy_name`

Returns the policyfile lock document at the revision that is currently
associated with the given policy group and policy name.

##### `PUT /policy_groups/:policy_group_name/policies/:policy_name`

Sets the active revision of `:policy_name` for the policy group
`:policy_group_name` to the policyfile lock document in the request body. The
policy group, policy name, and policyfile lock revision will be created if any
does not exist.

Policyfile lock revisions may not be updated. When the server already has a
Policyfile lock document with the same `revision_id` as given in the request
body, the effect of the request is to set the current active revision of
`:policy_name` for the given `:policy_group_name` to the revision specified in
the request body and ignore the other fields in the request body.

##### `POST /policy_groups/:policy_group_name/policies/:policy_name`

Sets the current active revision of `:policy_name` for the `:policy_group_name`
to the value given in the POST body. The revision must already exist on the
server. For example, to set the active revision of the 'appserver' policy in
the 'qa' policy group, you would POST to
`/policy_groups/qa/policies/appserver`, with a POST body like the following:

```json
{
  "revision_id": "bfec256f76a52ff707ca72e71b464a41c410b229"
}
```

#### `/policy_groups/:policy_group_name/nodes`

##### `GET /policy_groups/:policy_group_name/nodes`

Returns a list of nodes that belong to the policy group. Can be filtered for a
specific `:policy_name` with the `policy_name` query parameter, using a URL of
the form: `GET /policy_groups/:policy_group_name/nodes?policy_name=:policy_name`

#### `/policies/:policy_name`

TODO: This is where AuthZ for policies goes, does it do anything else?

#### `/policies/:policy_name/revisions/`

##### `POST /policies/:policy_name/revisions/`

Create a new Policyfile lock document. The POST body MUST be a valid Policyfile
lock document, as described above. The document can subsequently be retrieved
at the relative URL `/policies/:policy_name/revisions/:revision_id`

Policyfile lock revisions cannot be updated. If the server already has a
Policyfile lock document with the same `revision_id` as given in the body of
the request, the server MUST return 409 response.

##### `GET /policies/:policy_name/revisions/`

Returns a list of the available revisions for the given policy name

#### `/policies/:policy_name/revisions/:revision_id`

##### `GET /policies/:policy_name/revisions/:revision_id`

Returns the policyfile lock document with the given name and revision ID.

##### `DELETE /policies/:policy_name/revisions/:revision_id`

Deletes the policyfile lock document with the given name and revision ID.

#### `/policies/:policy_name/revisions/:revision_id/policy_groups`

##### `GET /policies/:policy_name/revisions/:revision_id/policy_groups`

Returns the list of policy groups that are associated with the given policy
name at the given revision ID.

### Promotion API (Optional)

In addition to the basic REST interface described above, the server may also
provide a promotion API. The promotion API facilitates defining the deployment
cycle for policies (i.e., the order in which policies move through policy
groups) and allows policies to be promoted to subsequent stages of the
deployment cycle with a single API call.

#### `/policy_groups/:policy_group_name`

#### `GET /policy_groups/:policy_group_name`

Returns the policy group configuration for `:policy_group_name`. The document
will contain the name of the next policy group in the deployment cycle. Exact
format is TBD, but it could look like:

```json
{
  "name": "development",
  "next_group_name": "qa"
}
```

#### `PUT /policy_groups/:policy_group_name`

Set the policy group configuration for `:policy_group_name`. Exact format is
TBD, but will be identical to the document format described above for `GET`.

#### `POST /policy_groups/:policy_group_name/promote`

Promotes all or some of the policyfile lock revisions currently active in
`:policy_group_name` to the next stage of the deployment cycle. POST body
format is TBD.

### End to End API Calls

The user generates a Policyfile lock document locally. When using ChefDK, the
policyfile lock document is generated by gathering requirements specified in a
Ruby DSL (e.g., the `Policyfile.rb`) and solving cookbook dependencies, but
users may create the policyfile lock document in some other way if desired.

Before the Policyfile lock document is published to the Chef Server, all
cookbooks described in the `cookbook_locks` section of the document are
uploaded to the cookbook artifacts API.

#### Policyfile Lock Document Upload

The policyfile lock document may be uploaded in a single step:

* `PUT /policy_groups/:policy_group_name/policies/:policy_name`

Or it may be uploaded in two steps:

* `POST /policies/:policy_name/revisions/`: Upload the policy to the Chef Server
* `POST /policy_groups/:policy_group_name/policies/:policy_name`: make the
  policyfile lock document revision uploaded in the previous step the active
  one for the specified policy group.

#### Chef Client Policyfile Lock Document Download

Chef Client is configured with both a desired `:policy_group_name` and
`:policy_name`. Given that information, it can retrieve the Policyfile lock
document with a single request:

* `GET /policy_groups/:policy_group_name/policies/:policy_name`: Get the policy
  document with the run list and cookbook set for the chef run.

### Authorization

The Chef Server authorizes an actor to access the Policyfile API separately for
policy groups and policy names (i.e., the set of all policyfile lock documents
with the same name). For operations that affect both policy groups and policy
names, an actor must have all relevant permissions to perform the requested
operation.

#### Policy Groups

Container-level Authorization:

* An actor must have `Create` permission on the `policy_groups` container to
  create a new group.
* An actor must have `List` permission on the `policy_groups` container to list
  groups.

Object-level Authorization:

* An actor must have `Read` permission on a specific `policy_group` to read the
  promotion configuration for that group (promotion API only)
* An actor must have `Read` permission on a specific `policy_group` to read the
  list of active policies and revisions.
* An actor must have `Update` permission to set the active revision for a given
  `policy_name` to a specific revision via `POST /policy_groups/:policy_group_name/policies/:policy_name`
* An actor must have `Update` permission to set the active revision for a given
  `policy_name` to a specific revision via the promotion API.
* An actor must have `Update` permission to modify the promotion policy for a
  given `policy_group`.
* An actor must have `Read` permission on a specific `policy_group` and `List`
  permission on the `nodes` container to list nodes in a policy group via
  `GET /policy_groups/:policy_group_name/nodes`
* An actor must have `Delete` permission on a specific `policy_group` to delete it.


#### Policy Names

Authorization for policy names is similar to cookbook versions and data bags in
that actions on individual objects are authorized based on permissions to the
collection; individual policy file lock revisions do not have independent ACLs.

Container-level Authorization:

* An actor must have `Create` permission on the `policies` container to
  create a new `policy_name`. This applies when creating a new policyfile lock
  revision via `POST /policies/:policy_name/revisions/` and no existing
  policyfile lock document with the same name exists.
* An actor must have `List` permission on the `policies` container to list
  all policy names.

Object-level Authorization:

* An actor must have `Update` to create a new policyfile lock revision. This
  applies when creating a new revision of a policy name via `POST /policies/:policy_name/revisions/`
  and there is an existing policyfile lock document with the same name.
* An actor must have `Read` to list the available revisions for a given
  `policy_name` via `GET /policies/:policy_name/revisions/`.
* An actor must have `Read` to retrieve a specific revision of a given `policy_name`
  via `GET /policies/:policy_name/revisions/:revision_id`.
* An actor must have `Delete` to delete a specific revision of a given `policy_name`.


#### Both

For convenience and to reduce HTTP round-trips, some APIs update and/or
disclose information about different object types. An actor is permitted to
perform the requested action only if authorized for all of the requested
actions individually,

* An actor must have `Read` permission on a specific `policy_group` and also
  have `Read` on a specific `policy_name` to retrieve the active policy lock
  document revision for the given group and name.
* To set the current active policy lock revision via `PUT /policy_groups/:policy_group_name/policies/:policy_name`,
  an actor must have either `Update` permission on the given `policy_group` if
  it exists, or `Create` on the `policy_groups` container to create the desired
  group, AND either `Update` permission on the given `policy_name` if it exists
  or `Create` on the `policies` containter to create the the desired policy if
  it doesn't exist. The same restrictions apply to the promotion API.
* An actor must have `Read` permission on a sepcific `policy_name` and `List`
  permission on the `policy_groups` container to list the groups associated
  with a given policy at a given revision via `GET /policies/:policy_name/revisions/:revision_id/policy_groups`

## Rationale

### Policy Groups

The means by which a node is associated to a Policyfile lock is designed such
that it is possible to have more than one revision of a Policyfile lock active
in a Chef organization at one time. That is, it must be possible to update the
Policyfile lock for only some nodes with a given functional role. For example,
a configuration code change may deploy a newer version of some important
software that must be tested in a non-production environment before production
deployment, or may cause a service restart that temporarily reduces capacity.

It is also desirable that the Policyfile lock document itself not contain any
information about which nodes it is applied to, as this simplifies the overall
design and makes it easy to create tooling to manage promotion of a Policyfile
lock through the phases of a deployment cycle.

To accommodate these two constraints, Policyfile locks are associated to a node
via both the policy name and policy group. The policy group models the phases
of a deployment cycle, such as "development", "staging" and "production."
Each policy group can have a different revision of a Policyfile lock, which
enables configuration code to be updated in one policy group without any effect
on the configuration code in other policy groups.

### HTTP Resource API Design Goals

#### Retrive the Active Policy for a Given Policy Group and Policy Name

This is how `chef-client` retrieves the policy it will apply for the current
`chef-client` run. It is also possible to compare (diff) the active policy for
two different policy groups by retrieving the active policy for each group and
computing the difference.

#### Query the List of Group Names

This enables a GUI to provide a list of groups for navigational purposes and
for list-based input (such as selecting the policy group for a new node object).

#### Query the List of Policy Names

This enables a GUI to provide a list of policy names for navigational purposes
and for list-based input.

#### List Nodes By Group And Policy Name

When the node document is updated to include the policy group and policy name
(a future change outside the scope of this RFC), this information will be
accessible via search; however, the information can be easily retrieved via a
relational database query for use in a web-based UI.

#### Data Cleanup

Although the design of Policyfile and related APIs greatly simplifies the task
of finding and deleting unused cookbook versions (cookbook artifacts in this
case), no such feature is proposed at this time.

### Authorization Design Goals and Considerations.

The authorization behaviors for Policyfiles are designed to allow the user to
limit access by either deployment phase or host's functional role.

In the first case, it may be desirable, for example, to limit access to
production policy groups to a subset of individuals or perhaps a Ci system
while still giving users access to update dev environments or create one-off
dev environments for testing.

In the second case, a business may have some types of systems where access must
be restricted to a smaller set of individuals, perhaps because those machines
store sensitive data or require expertise from other teams to vet changes
(e.g., a DBA must review changes to database nodes).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

