---
RFC: 45
Title: Node State Separation
Author: Lamont Granquist <lamont@chef.io> 
Status: Accepted
Type: Standards Track
---

# Node State Separation

The purpose of this RFC is to logically split up the description of a node from
its "desired" state (typically what the administrator imposes - `run_list`,
`environment`, `tags`) and the "current" state (typically what the node itself
discovers -- automatic ohai variables and default and override attributes
constructed as part of the chef client run).

This proposal fixes [CHEF-4978](https://tickets.opscode.com/browse/CHEF-4978).
The major bug which constantly occurs due to this is where a chef-client run is
in flight and has done the initial GET request of the node, while a human
administrator changes the `run_list`, and then the in-flight chef-client run
finishes and POSTs the node and overwrites the administrator's changes to the
`run_list`.

The approach that will be taken is to split up the data so that the node is not
constantly overwriting its own `run_list`.  This solution does not implement
locking around the node data, so it is still open to some edge conditions that
may cause race conditions.

The proposed implementation will also support separately ACL'ing the desired
state from the current state.  This will allow locking down the desired state
so that the node will not be allowed to update its own `run_list`.  This
addresses security concerns where hostile compromised nodes could 'inject'
themselves into search results via changing their `run_list` and/or environment
which may make other infrastructure components redirect traffic at them and
could be used to compromise an environment.

Both systems of ACLs will be supported so that some customers may allow nodes
to update their `run_lists`, and other customers may restrict nodes to not be
able to update their `run_lists`.  It would also be possible to mix and match
at one site, although if any host is able to update its own `run_list` then if
it gets hacked into the security is defeated so it is not clear that mixed-mode
will be useful.

The choice of which mode should be the default (secure by default vs codeable
by default) is out of the scope of this RFC.  For backwards compatibility, we
must allow nodes to update their desired state by default to begin with as
changing that default would be a breaking change.

## Motivation

    As a user of the knife CLI I want to be able to update my node's run_list
    and have the changes not be reverted by an in-flight Chef run

    As a user of search who cares about security I want attackers to not be
    able to change my search results by controlling a single node

## Specification

### API Schema

#### `/nodes/:name/desired`

This endpoint is for manipulating desired data (`run_list`, environment, tags,
normal attributes)

##### `GET /nodes/:name/desired`

The `GET` method is used to return the desired details of the node as JSON.

This method has no parameters.

The response will be similar to:

```
{ "name": "node_name", "chef_environment": "_default", "run_list": [
"recipe[recipe_name]" ], "normal": { "tags": [ ] } }
```

Response Codes:

* 200 OK.  The request was successful
* 401 Unauthorized.  The user or client who made the request could not be
  authenticated. Verify the user/client name, and that the correct key was used
  to sign the request.
* 403 Forbidden.  The user which made the request is not authorized to perform
  the action.
* 404 Not found.  The requested object does not exist.

##### `PUT /nodes/:name/desired`

The `PUT` method is used to update the desired data on an already created node.

This method has no parameters.

The request body will be similar to:


``` { "name": "node_name", "chef_environment": "_default", "run_list": [
"recipe[recipe_name]" ], "normal": { "tags": [ ] } } ```

The response will return the updated desired data in the same format as the
request.

Response Codes:

* 200 OK.  The request was successful
* 401 Unauthorized.  The user or client who made the request could not be
  authenticated. Verify the user/client name, and that the correct key was used
  to sign the request.
* 403 Forbidden.  The user which made the request is not authorized to perform
  the action.
* 404 Not found.  The requested object does not exist.
* 413 Request entity too large. A request may not be larger than 1000000 bytes.

##### `POST /nodes/:name/desired`

This method will not be implemented, use `POST /nodes` to create a new node
object.

##### `DELETE /nodes/:name/desired`

This method will not be implemented, partial clearing of data will not be
supported.  Use `DELETE /nodes/:name`.

#### `/nodes/:name/current`

This endpoint is for storing the current data (default attributes, override
attributes, automatic attributes)

##### `GET /nodes/:name/current`

The `GET` method is used to return the current details of the node as JSON.

This method has no parameters.

The response will be similar to:

``` { "name": "node_name", "default": { [...] }, "override": { [...] },
"automatic": { [...] } } ```

Response Codes:

* 200 OK.  The request was successful
* 401 Unauthorized.  The user or client who made the request could not be
  authenticated. Verify the user/client name, and that the correct key was used
  to sign the request.
* 403 Forbidden.  The user which made the request is not authorized to perform
  the action.
* 404 Not found.  The requested object does not exist.

##### `PUT /nodes/:name/current`

The `PUT` method is used to update the current data on an already created node.

This method has no parameters.

The request body will be similar to:

``` { "name": "node_name", "default": { [...] }, "override": { [...] },
"automatic": { [...] } } ```

The response will return the updated desired data in the same format as the
request.

Response Codes:

* 200 OK.  The request was successful
* 401 Unauthorized.  The user or client who made the request could not be
  authenticated. Verify the user/client name, and that the correct key was used
  to sign the request.
* 403 Forbidden.  The user which made the request is not authorized to perform
  the action.
* 404 Not found.  The requested object does not exist.
* 413 Request entity too large. A request may not be larger than 1000000 bytes.

##### `POST /nodes/:name/current`

This method will not be implemented, use `POST /nodes` to create a new node
object.

##### `DELETE /nodes/:name/current`

This method will not be implemented, partial clearing of data will not be
supported.  Use `DELETE /nodes/:name`.

#### `/nodes/:name`

This endpoint is unchanged, and is only included here for context.

##### `GET /nodes/:name`

This method will return the combined desired and current data and its semantics
will be unchanged.

##### `PUT /nodes/:name`

This method will create a new node with the combined desired and current data
and its semantics will be unchanged.

##### `DELETE /nodes/:name`

This method will delete a node and its semantics will be unchanged.

#### `/nodes`

This endpoint is unchanged, and is only included here for context.

##### `POST /nodes`

This method will create a new node object and its semantics will be unchanged.

##### `GET /nodes`

This method returns a list of all node URIs on the server and its semantics
will be unchanged.

### Core Chef Server Changes

#### Nodes As Composed Objects

The implementation of this will break up the node object into different objects
for the current and desired state.  This will imply a migration to the new code
  which will take existing node objects in a server and will break them up into
  the new current and desired objects in the database.

The ACLs on the node will also be composed of the ACLs on the underlying
current and desired objects.  As part of the data migration on the server
upgrade the ACLs on the node objects will be copied to both the desired and the
current state (preserving the default behavior that nodes may update their own
desired state).  The ACLs on the composed endpoints (e.g. `GET /nodes/:name`)
will be composed of the ACLs on the underlying desired and current state and
will require both of those to be allowed for the operation to succeed.  There
will be no support for getting partial results back if the client has only
partial permissions to the node components.

### Core Chef Client Changes

#### Node Retrieval

The initial request from the chef-client will be changed to GET the
`nodes/:name/desired` endpoint to retrieve only the saved desired data.  This
avoids having the client retrieve all the node data, parse the JSON, inflate
the attributes and then remove the normal, override and automatic attributes --
saving time, bandwidth and memory.

A copy of the desired data will be saved so that it can later be determined if
the data has been "dirtied" during the chef-client run.

For backwards compatibility if the prior request to the desired endpoint 404s,
then the client will retrieve its node data from the old `/nodes/:name`
endpoint and will fallback to backwards compatibility mode for all further
operations.

If the node does not exist it will still be created with a POST to `/nodes`

#### Node Save

Provided the desired endpoint is supported, the Chef::Node#save method will be
updated to typically PUT its data only to the `/nodes/:name/current` endpoint.
This will affect both the final `node.save` of the chef-client run, and any
user called `node.save` in recipe code.

If it is detected that the desired data has been dirtied then `node.save` will
instead PUT to `/nodes/:name`.  On success the updated desired data will be
used as the data to compare to in order to determine if it is "re-dirtied"
again later.

If the initial GET to the `/nodes/:name/desired` endpoint failed, then
node.save will automatically fall back to PUT to `/nodes/:name` for backwards
compatibility.

The node.save API will still support falling back to `POST /node` to create the
node if it has not already been created.

### Knife Changes

All changes will hit the new endpoints and then fallback to using
`/nodes/:name` for backwards compatibility on a 404.

The `knife node run_list` commands will be updated to PUT to the
`/nodes/:name/desired` endpoint.

The `knife tag` commands will be updated to PUT to the `/nodes/:name/desired`
endpoint.

The `knife node environment set` command will be updated to PUT to the
`/nodes/:name/desired` endpoint.

The `knife node from file` command will be unchanged and will PUT/POST to
`/nodes/:name`.

The `knife node show` command will be unchanged and will GET from
`/nodes/:name`.

The `knife node edit` command will be unchanged by default and will GET from
`/nodes/:name`, it will be extended to support `--current` and `--desired`
flags, and at some point in the future `--configuation` is expected to become
the default behavior (a breaking change).

### ChefFS Changes

The ChefFS repo will be extended to support a "nodes/current" directory.

The knife download command will attempt to download the individual node data
from /nodes/:name/desired and /nodes/:name/current and place them in
`/nodes/<nodename>.json` and `/nodes/current/<nodename>.json` respectively.  If
the endpoints 404 then the `/nodes/:name` endpoint will be used and the data
will be split out into the new format.  In other words, the knife download
command will be able to talk to servers that do and do not support this API and
will always write in the new format.

The knife upload command will look for a `/nodes/current/<nodename>.json` file
and if it finds it, will assume a new repo and will attempt to use the new
endpoints to upload the data.  If the endpoints 404 then it will fall back to
using the `/nodes` and `/nodes/:name` endpoint for backwards compatibility
(which it must do anyway in the case that the node does not exist, so this
should not be much extra code).  If it does not find the current file in the
repo then it will skip to directly uploading the node to the old endpoints.  In
other words knife upload supports reading from both different repo styles and
supports writing to the new and old server APIs.

### Solr Indexing

Any change to either the desired or current state will result in the whole node
object being submitted to solr for indexing.

### Future

In order to implement the ability to make the desired state read-only there
will need to be some additional changes outside of the scope of this RFC.  The
implementation of read-only desired state will most likely require using an
adminstrative key to create both the client and the node (a form of
validatorless bootstrapping).  To have the client create both the new current
and desired state object and then drop its perms on the desired node object
would require a client to drop its own GRANT perms which is an antipattern and
should not be allowed.  Instead an admin key will need to create both the new
client and the new desired and current state node objects.  A helper API
endpoint may be written to move that logic server-side and keep it consistent.
It also may be useful to introduce per-org configuration state to control
default ACLs and other behavior of that endpoint.  Those implementation details
are well beyond the scope of this RFC.  The implementation of this node state
seperation, however, allows for all of those future implementations.

This RFC does not directly solve the problem of configuring servers so that
desired node state is read-only to the node.

## Thanks

This was liberally stolen and plagiarized from John Keiser's work:
https://gist.github.com/jkeiser/6628674

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
