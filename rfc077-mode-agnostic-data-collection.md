---
RFC: 77
Title: Mode-Agnostic Run Data Collection
Author: Adam Leff <adamleff@chef.io>
Status: Final
Type: Standards Track
---

# Mode-Agnostic Run Data Collection

In order to provide increased clarity into a user's fleet operations, and to support Chef deployments that do not necessarily include the use of a Chef Server, this change aims to provide an easy and consistent way for the Chef Client to report run statistics to a data collection system. The initial statistics we look to collect include node state, converge start/end times, and converge details.

## Motivation

    As a Chef user who uses both Chef Client Mode and Chef Solo Mode (including the mode commonly known as "Chef Client Local Mode"),
    I want to be able to collect data about my entire fleet regardless of their client operation type,
    so that I may better understand the impacts of my changes and may better detect failures.

## Definitions

To eliminate ambiguity and confusion, the following terms are used throughout this RFC:

 * **Chef**: the tool used to automate your system.
 * **Chef Client Mode**: Chef configured in "client mode" where a Chef Server is used to provide Chef its resources and artifacts
 * **Chef Solo Mode**: Chef configured in a mode that utilizes a local Chef Zero server. Formerly known as "Chef Client Local Mode" (run as `chef-client --local-mode`) before [RFC 031](https://github.com/chef/chef-rfc/blob/master/rfc031-replace-solo-with-local-mode.md) was implemented, available in Chef version 12.10.54 and later.
 * **Chef Solo Legacy Mode**: Chef in the former Solo operational mode (run as `chef-solo`) before [RFC 031](https://github.com/chef/chef-rfc/blob/master/rfc031-replace-solo-with-local-mode.md) was implemented (in Chef versions earlier than 12.10.54), or Chef run as `chef-solo --legacy-mode` in Chef version 12.10.54 and later.

## Specification

Similar to how data is collected and reported for Chef Reporting, we expect to implement a new EventDispatch class/instance that collects data about the Chef run and reports it accordingly. Unlike Chef Reporting, the server that receives this data is **not** running on the Chef Server, allowing users to utilize this function whether they use Chef Server or not. No new data collection methods are expected to be implemented as a result of this change; this change serves to implement a generic way to report the collected data in a "webhook-like" fashion to a non-Chef-Server receiver.

The implementation must work with Chef running in any mode:

 * Chef Client Mode
 * Chef Solo Mode
 * Chef Solo Legacy Mode

### Protocol and Authentication

All payloads will be sent to the Data Collector server via HTTP POST to the URL specified in the `data_collector_server_url` configuration parameter. Users should be encouraged to use a TLS-protected endpoint.

Optionally, payloads may also be written out to multiple HTTP endpoints or JSON files on the local filesystem (of the node running chef-client) by specifying the `data_collector_output_locations` configuration parameter.

For the initial implementation, transmissions to the Data Collector server can optionally be authenticated with the use of a pre-shared token which will be sent in a HTTP header. Given that the receiver is not the Chef Server, existing methods of using a Chef `client` key to authenticate the request are unavailable.

### Configuration

The configuration required for this new functionality can be placed in the client.rb or any other `Chef::Config`-supported location (such as a client.d or solo.d directory).

#### Parameters

 * **data_collector_server_url**: required*. The full URL to the data collector server API. All messages will be POST'd to this URL. The Data Collector class will be registered and enabled if this config parameter is specified. * If the `data_collector_output_locations` configuration parameter is specified, this setting may be omitted.
 * **data_collector_token**: optional. A pre-shared token that, if present, will be passed as an HTTP header named `x-data-collector-token` to the Data Collector server. The server can choose to accept or reject the data posted based on the token or lack thereof.
 * **data_collector_mode**: The Chef mode in which the Data Collector will be enabled. For example, you may wish to only enable the Data Collector when running in Chef Solo Mode. Must be one of: `:solo`, `:client`, or `:both`. The `:solo` value is used for Chef operating in Chef Solo Mode or Chef Solo Legacy Mode. Default: `:both`.
 * **data_collector_raise_on_failure**: If true, the Chef run will fatally exit if it is unable to successfully POST to the Data Collector server. Default: `false`
 * **data_collector_output_locations**: optional. An array of URLs and/or file paths to which data collection payloads will also be written. This may be used without specifying the `data_collector_server_url` configuration parameter

### Schemas

For the initial implementation, three JSON schemas will be utilized.

#### Action Schema

The Action Schema is used to notify when a Chef object changes. In our case, the primary use will be to update the Data Collector server with the current node object.

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "description": "Data Collector - action schema",
  "properties": {
    "entity_name": {
      "description": "The name of the entity",
      "type": "string"
    },
    "entity_type": {
      "description": "The type of the entity",
      "type": "string",
      "enum": [
        "bag",
        "client",
        "cookbook",
        "environment",
        "group",
        "item",
        "node",
        "organization",
        "permission",
        "role",
        "user",
        "version"]
    },
    "entity_uuid": {
      "description": "Unique ID identifying this object, which should persist across runs and invocations",
      "type": "string",
      "pattern": "^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$"
    },
    "id": {
      "description": "Globally Unique ID for this message",
      "type": "string",
      "pattern": "^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$"
    },
    "message_version": {
      "description": "Message Version",
      "type": "string",
      "enum": [
        "1.1.0"
      ]
    },
    "message_type": {
      "description": "Message Type",
      "type": "string",
      "enum": ["action"]
    },
    "organization_name": {
      "description": "It is the name of the org on which the run took place",
      "type": ["string", "null"]
    },
    "recorded_at": {
      "description": "It is the ISO timestamp when the action happened",
      "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-5][0-9]:[0-9]{2}Z$",
      "type": "string"
    },
    "remote_hostname": {
      "description": "The remote hostname which initiated the action",
      "type": "string"
    },
    "requestor_name": {
      "description": "The name of the client or user that initiated the action",
      "type": "string"
    },
    "requestor_type": {
      "description": "Was the requestor a client or user?",
      "type": "string",
      "enum": ["client", "user"]
    },
    "run_id": {
      "description": "The run ID of the run in which this node object was updated",
      "pattern": "^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$",
      "type": "string"
    },
    "service_hostname": {
      "description": "The FQDN of the Chef server, if appropriate",
      "type": "string"
    },
    "source": {
      "description": "The tool / client mode that initiated the action. Note that 'chef_solo' includes Chef Solo Mode and Chef Solo Legacy Mode.",
      "type": "string",
      "enum": ["chef_solo", "chef_client"]
    },
    "task": {
      "description": "What action was performed?",
      "type": "string",
      "enum": ["associate", "create", "delete", "dissociate", "invite", "reject", "update"]
    },
    "user_agent": {
      "description": "The User-Agent of the requestor",
      "type": "string"
    },
    "data": {
      "description": "The payload containing the entire request data",
      "type": "object"
    }
  },
  "required": [
    "entity_name",
    "entity_type",
    "entity_uuid",
    "id",
    "message_type",
    "message_version",
    "organization_name",
    "recorded_at",
    "remote_hostname",
    "requestor_name",
    "requestor_type",
    "run_id",
    "service_hostname",
    "source",
    "task",
    "user_agent"
  ],
  "title": "ActionSchema",
  "type": "object"
}
```

The `data` field will contain the value of the object on which an action took place.

#### Run Start Schema

The Run Start Schema will be used by Chef to notify the data collection server at the start of the Chef run.

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "description": "Data Collector - Runs run_start schema",
  "properties": {
    "chef_server_fqdn": {
      "description": "It is the FQDN of the chef_server against whch current reporting instance runs",
      "type": "string"
    },
    "entity_uuid": {
      "description": "Unique ID identifying this node, which should persist across Chef runs",
      "type": "string",
      "pattern": "^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$"
    },
    "id": {
      "description": "It is the internal message id for the run",
      "pattern": "^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$",
      "type": "string"
    },
    "message_version": {
      "description": "Message Version",
      "type": "string",
      "enum": [
        "1.0.0"
      ]
    },
    "message_type": {
      "description": "It defines the type of message being sent",
      "type": "string",
      "enum": ["run_start"]
    },
    "node_name": {
      "description": "It is the name of the node on which the run took place",
      "type": "string"
    },
    "organization_name": {
      "description": "It is the name of the org on which the run took place",
      "type": "string"
    },
    "run_id": {
      "description": "It is the runid for the run",
      "pattern": "^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$",
      "type": "string"
    },
    "source": {
      "description": "The tool / client mode that initiated the action. Note that 'chef_solo' includes Chef Solo Mode and Chef Solo Legacy Mode.",
      "type": "string",
      "enum": ["chef_solo", "chef_client"]
    },
    "start_time": {
      "description": "It is the ISO timestamp of when the run started",
      "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$",
      "type": "string"
    }
  },
  "required": [
    "chef_server_fqdn",
    "entity_uuid",
    "id",
    "message_version",
    "message_type",
    "node_name",
    "organization_name",
    "run_id",
    "source",
    "start_time"
  ],
  "title": "RunStartSchema",
  "type": "object"
}
```

#### Run End Schema

The Run End Schema will be used by Chef Client to notify the data collection server at the completion of the Chef Client's converge phase and report data on the Chef Client run, including resources changed and any errors encountered.

```json
{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "description": "Data Collector - Runs run_converge schema",
    "properties": {
        "chef_server_fqdn": {
            "description": "It is the FQDN of the chef_server against whch current reporting instance runs",
            "type": "string"
        },
        "end_time": {
            "description": "It is the ISO timestamp of when the run ended",
            "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$",
            "type": "string"
        },
        "entity_uuid": {
          "description": "Unique ID identifying this node, which should persist across Chef Client/Solo runs",
          "type": "string",
          "pattern": "^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$"
        },
        "error": {
            "description": "It has the details of the error in the run if any",
            "type": "object"
        },
        "expanded_run_list": {
            "description": "The expanded run list object from the node",
            "type": "object"
        },
        "id": {
            "description": "It is the internal message id for the run",
            "pattern": "^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$",
            "type": "string"
        },
        "message_type": {
            "description": "It defines the type of message being sent",
            "type": "string",
            "enum": ["run_converge"]
        },
        "message_version": {
            "description": "Message Version",
            "type": "string",
            "enum": [
                "1.1.0"
            ]
        },
        "node": {
            "description": "The node object after the converge completed",
            "type": "object"
        },
        "node_name": {
            "description": "Node Name",
            "type": "string",
            "format": "node-name"
        },
        "organization_name": {
            "description": "Organization Name",
            "type": "string"
        },
        "resources": {
            "description": "This is the list of all resources for the run",
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "after": {
                        "description": "Final State of the resource",
                        "type": "object"
                    },
                    "before": {
                        "description": "Initial State of the resource",
                        "type": "object"
                    },
                    "cookbook_name": {
                        "description": "Name of the cookbook that initiated the change",
                        "type": "string"
                    },
                    "cookbook_version": {
                        "description": "Version of the cookbook that initiated the change",
                        "type": "string",
                        "pattern": "^[0-9]*\\.[0-9]*(\\.[0-9]*)?$"
                    },
                    "delta": {
                        "description": "Difference between initial and final value of resource",
                        "type": "string"
                    },
                    "duration": {
                        "description": "Duration of the run consumed by processing of this resource, in milliseconds",
                        "type": "string"
                    },
                    "id": {
                        "description": "Resource ID",
                        "type": "string"
                    },
                    "ignore_failure": {
                        "description": "the ignore_failure setting on a resource, indicating if a failure on this resource should be ignored",
                        "type": "boolean"
                    },
                    "name": {
                        "description": "Resource Name",
                        "type": "string"
                    },
                    "result": {
                        "description": "The action taken on the resource",
                        "type": "string"
                    },
                    "status": {
                        "description": "Status indicating how Chef processed the resource",
                        "type": "string",
                        "enum": [
                          "failed",
                          "skipped",
                          "unprocessed",
                          "up-to-date",
                          "updated"
                        ]
                    },
                    "type": {
                        "description": "Resource Type",
                        "type": "string"
                    }
                },
                "required": [
                    "after",
                    "before",
                    "delta",
                    "duration",
                    "id",
                    "ignore_failure",
                    "name",
                    "result",
                    "status",
                    "type"
                ]
            }
        },
        "run_id": {
            "description": "It is the runid for the run",
            "pattern": "^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$",
            "type": "string"
        },
        "run_list": {
            "description": "It is the runlist for the run",
            "type": "array",
            "items": {
                "type": "string"
            }
        },
        "source": {
            "description": "The tool / client mode that initiated the action. Note that 'chef_solo' includes Chef Solo Mode and Chef Solo Legacy Mode.",
            "type": "string",
            "enum": ["chef_solo", "chef_client"]
        },
        "start_time": {
            "description": "It is the ISO timestamp of when the run started",
            "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$",
            "type": "string"
        },
        "status": {
            "description": "It gives the status of the run",
            "type": "string",
            "enum": [
                "success",
                "failure"
            ]
        },
        "total_resource_count": {
            "description": "It is the total number of resources for the run",
            "type": "integer",
            "minimum": 0
        },
        "updated_resource_count": {
            "description": "It is the number of updated resources during the course of the run",
            "type": "integer",
            "minimum": 0
        }
    },
    "required": [
        "chef_server_fqdn",
        "entity_uuid",
        "id",
        "end_time",
        "expanded_run_list",
        "message_type",
        "message_version",
        "node",
        "node_name",
        "organization_name",
        "resources",
        "run_id",
        "run_list",
        "source",
        "start_time",
        "status",
        "total_resource_count",
        "updated_resource_count"
    ],
    "title": "RunEndSchema",
    "type": "object"
}
```

## Downstream Impact

No downstream impacts are expected by this work.

## Future Work

We expect to include Audit Mode results in future Data Collector payloads, upon which the schema will be published.

After Audit Mode results are included, the deprecation of the `ResourceReporter` and `AuditReporter` classes will be possible.

Enhanced authentication and authorization, such as per-client auth, is a logical next step for this feature as well.

## Notes

While it can be argued that the existing [handlers](https://docs.chef.io/handlers.html) implementation is a possible fit for this requirement, placing this logic directly in the Chef offers some advantages:

 * **ease of use**: adding one, possibly two, configuration properties to the node's client.rb is all that's required to start collecting and reporting data
 * **chicken vs. egg**: when an event handler is deployed and registered during a Chef run, the data for that run is potentially lost or incomplete

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
