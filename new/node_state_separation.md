---
RFC: unassigned
Author: Lamont Granquist <lamont@chef.io>
Status: Draft
Type: <Standards Track>
---

# Node State Separation

The purpose of this RFC is to make it possible to manipulate node objects
as their desired "configuration" state and actual "runtime" state.

## Rationale

This proposal fixes [CHEF-4978](https://tickets.opscode.com/browse/CHEF-4978)
and the associated tickets and issues that have occurred over years.

## Motivation

    As a user of the knife CLI
    I want to be able to update my nodes run_list
    and have the changes not be reverted by an in-flight Chef run

## Specification

### API Schema

#### `/nodes/:name/configuration`

This endpoint is for manipulating configuration data (`run_list`, environment, tags, normal attributes)

##### `GET /nodes/:name/configuration`

The `GET` method is used to return the configuration details of the node as JSON.

This method has no parameters.

The response will be similar to:

```
{
  "name": "node_name",
  "chef_environment": "_default",
  "run_list": [
    "recipe[recipe_name]"
  ],
  "normal": {
    "tags": [ ]
  }
}
```

Response Codes:

* 200 OK.  The request was successful
* 401 Unauthorized.  The user or client who made the request could not be authenticated. Verify the user/client name, and that the correct key was used to sign the request.
* 403 Forbidden.  The user which made the request is not authorized to perform the action.
* 404 Not found.  The requested object does not exist.

##### `PUT /nodes/:name/configuration`

The `PUT` method is used to update the configuration data on an already created node.

This method has no parameters.

The request body will be similar to:


```
{
  "name": "node_name",
  "chef_environment": "_default",
  "run_list": [
    "recipe[recipe_name]"
  ],
  "normal": {
    "tags": [ ]
  }
}
```

The response will return the updated configuration data in the same format as the request.

Response Codes:

* 200 OK.  The request was successful
* 401 Unauthorized.  The user or client who made the request could not be authenticated. Verify the user/client name, and that the correct key was used to sign the request.
* 403 Forbidden.  The user which made the request is not authorized to perform the action.
* 404 Not found.  The requested object does not exist.
* 413 Request entity too large. A request may not be larger than 1000000 bytes.

##### `POST /nodes/:name/configuration`

This method will not be implemented, use `POST /nodes` to create a new node object.

##### `DELETE /nodes/:name/configuration`

This method will not be implemented, partial clearing of data will not be supported.  Use `DELETE /nodes/:name`.

#### `/nodes/:name/runtime`

This endpoint is for storing the runtime data (default attributes, override attributes, automatic attributes)

##### `GET /nodes/:name/runtime`

The `GET` method is used to return the runtime details of the node as JSON.

This method has no parameters.

The response will be similar to:

```
{
  "name": "node_name",
  "default": {
    [...]
  },
  "override": {
    [...]
  },
  "automatic": {
    [...]
  }
}
```

Response Codes:

* 200 OK.  The request was successful
* 401 Unauthorized.  The user or client who made the request could not be authenticated. Verify the user/client name, and that the correct key was used to sign the request.
* 403 Forbidden.  The user which made the request is not authorized to perform the action.
* 404 Not found.  The requested object does not exist.

##### `PUT /nodes/:name/runtime`

The `PUT` method is used to update the runtime data on an already created node.

This method has no parameters.

The request body will be similar to:

```
{
  "name": "node_name",
  "default": {
    [...]
  },
  "override": {
    [...]
  },
  "automatic": {
    [...]
  }
}
```

The response will return the updated configuration data in the same format as the request.

Response Codes:

* 200 OK.  The request was successful
* 401 Unauthorized.  The user or client who made the request could not be authenticated. Verify the user/client name, and that the correct key was used to sign the request.
* 403 Forbidden.  The user which made the request is not authorized to perform the action.
* 404 Not found.  The requested object does not exist.
* 413 Request entity too large. A request may not be larger than 1000000 bytes.

##### `POST /nodes/:name/runtime`

This method will not be implemented, use `POST /nodes` to create a new node object.

##### `DELETE /nodes/:name/runtime`

This method will not be implemented, partial clearing of data will not be supported.  Use `DELETE /nodes/:name`.

#### `/nodes/:name`

This endpoint is unchanged, and is only included here for context.

##### `GET /nodes/:name`

This method will return the combined configuration and runtime data and its semantics will be unchanged.

##### `PUT /nodes/:name`

This method will create a new node with the combined configuration and runtime data and its semantics will be unchanged.

##### `DELETE /nodes/:name`

This method will delete a node and its semantics will be unchanged.

#### `/nodes`

This endpoint is unchanged, and is only included here for context.

##### `POST /nodes`

This method will create a new node object and its semantics will be unchanged.

##### `GET /nodes`

This method returns a list of all node URIs on the server and its semantics will be unchanged.

### Core Chef Client Changes

#### Node Retrieval

The initial request from the chef-client will be changed to GET the
`nodes/:name/configuration` endpoint to retrieve only the saved configuration data.  This
avoids having the client retrieve all the node data, parse the JSON, inflate
the attributes and then remove the normal, override and automatic attributes -- saving 
time, bandwidth and memory.

A copy of the configuration data will be saved so that it can later be determined if the data has been
"dirtied" during the chef-client run.

For backwards compatibility if the prior request to the configuration endpoint
404s, then the client will retrieve its node data from the old `/nodes/:name` endpoint and
will fallback to backwards compatibility mode for all further operations.

If the node does not exist it will still be created with a POST to `/nodes`

#### Node Save

Provided the configuration endpoint is supported, the Chef::Node#save method will
be updated to typically PUT its data only to the `/nodes/:name/runtime` endpoint.  This will
affect both the final `node.save` of the chef-client run, and any user called `node.save`
in recipe code.

If it is detected that the configuration data has been dirtied then `node.save` will instead PUT
to `/nodes/:name`.  On success the updated configuration data will be used as the data to
compare to in order to determine if it is "re-dirtied" again later.

If the initial GET to the `/nodes/:name/configuration` endpoint failed, then node.save will automatically
fall back to PUT to `/nodes/:name` for backwards compatibility.

The node.save API will still support falling back to `POST /node` to create the node if it has not already
been created.

### Knife Changes

All changes will hit the new endpoints and then fallback to using `/nodes/:name` for backwards compatibility on a 404.

The `knife node run_list` commands will be updated to PUT to the `/nodes/:name/configuration` endpoint.

The `knife tag` commands will be updated to PUT to the `/nodes/:name/configuration` endpoint.

The `knife node environment set` command will be updated to PUT to the `/nodes/:name/configuration` endpoint.

The `knife node from file` command will be unchanged and will PUT/POST to `/nodes/:name`.

The `knife node show` command will be unchanged and will GET from `/nodes/:name`.

The `knife node edit` command will be unchanged by default and will GET from `/nodes/:name`, it will be extended to support
`--runtime` and `--configuration` flags, and at some point in the future `--configuation` is expected to become the default
behavior (a breaking change).

### ChefFS Changes

The ChefFS repo will be extended to support a "nodes/runtime" directory (NOTE: if anyone has a node named "runtime" they'll have
a bad day here).

The knife download command will attempt to download the individual node data from /nodes/:name/configuration
and /nodes/:name/runtime and place them in `nodes/<nodename>.json` and `/nodes/runtime/<nodename>.json` respectively.  If the
endpoints 404 then the `/nodes/:name` endpoint will be used and the data will be split out into the new format.  In other words,
the knife download command will be able to talk to servers that do and do not support this API and will always write in the
new format.

The knife upload command will look for a `/nodes/runtime/<nodename>.json` file and if it finds it, will assume a new repo and
will attempt to use the new endpoints to upload the data.  If the endpoints 404 then it will fall back to using the `/nodes` and
`/nodes/:name` endpoint for backwards compatibility (which it must do anyway in the case that the node does not exist, so this
should not be much extra code).  If it does not find the runtime file in the repo then it will skip to directly uploading the
node to the old endpoints.  In other words knife upload supports reading from both different repo styles and supports writing
to the new and old server APIs.

### Solr Indexing

Any change to the underlying node object will need to be sent to Solr for indexing.

## Thanks

This was liberally stolen and plagiarized from John Keiser's work:  https://gist.github.com/jkeiser/6628674

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
