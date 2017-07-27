---
RFC: unassigned
Title: Stats Endpoint for Chef Server
Author: Jay Mundrawala <jmundrawala@chef.io>
Status: Draft
Type: <Standards Track, Informational, Process>
<Replaces: RFCxxx>
<Tracking:>
<  - https://github.com/chef/chef/issues/X>
---

# Stats Endpoint for Chef Server

Monitoring Chef Server is an involved task. There are several services that make
up a Chef Server, all of which need to be monitored. These services each have their
own set of metrics, and each has it's own way obtaining those metrics. The Chef Server
component itself has 2 ways that provide a different set of metrics: pushing to statsd 
and through Folsom, which can be set up to push to Graphite.

This RFC introduces a stats endpoint to Chef Server which is capable of providing metrics
for Chef Server and all its co-located services.


## Motivation

    As a Chef Server operator,
    I want to have a consistent way to get important Chef Server metrics,
    so that I can easily monitor the health of my Chef Server out of the box.

    As a Chef Server operator,
    I want to understand the metrics I'm given,
    so that I can easily monitor the health of my Chef Server.


## Specification

This RFC adds a series of `/_stats/$service` endpoints to Chef Server. Each service
colocated on the box will be provided an endpoint which responds to GET requests.

The response format is the one defined by [Prometheus 0.0.4](https://prometheus.io/docs/instrumenting/exposition_formats). The endpoints must respond to both content types, `text/plain; version=0.0.4` and `application/vnd.google.protobuf; proto=io.prometheus.client.MetricFamily; encoding=delimited`.
Using this gives us the ability to use a few metrics types specified below along with the ability to give
a description for any metrics which are provided.

### Supported Metric Primitives
The endpoints can provide metrics of following types, as defined by [Prometheus](https://prometheus.io/docs/concepts/metric_types/):
- Counter - Monotonic cumulative metric. For example, number of requests served.
- Gauge - Numeric measurement at a given point in time. For example, number of inflight requests.
- Histogram - Distributes values into buckets. For example, response times.
- Summary - Provides summary statistics for a value in a sliding window.

### Response Format
#### Why Use the Prometheus Format?
The format is already defined and provides metric types that are known to work with at least
one monitoring system. This format also gives us the ability to describe each metric presented,
so the end user would know what it means. The format itself is human readable and easy to parse,
making it easy to both get started with and write tooling around.

Using this format directly also could allow us to use metric exporters already written for other co-located
services such as PostgreSQL, RabbitMQ, and Solr.

#### Why Not?
This would introduce an inconsistency in that the current API uses JSON and this one route would not. We
could just as well create a JSON specification with information such as type, description, metric name, etc.


### Services
At a minimum, the Chef Server frontend service would need to provide stats. For example, `bookshelf`, `oc-id`,
`oc_bifrost`, and `erchef` should provide metrics as those are always colocated. Since these run together, these could also be grouped into a single metrics endpoint(`_stats/chef-server`) to reduce the number of calls needed to gather the metrics.

If Chef Server is configured to provide services such as RabbitMQ, Solr, Elasticsearch, PostgreSQL, Manage, Reporting, etc, an endpoint should be provided for each service.

#### Service List
Since different implementations or configurations of Chef Server could have different dependencies, 
`GET /_stats` will provide a list of services.

Example response:

```
{
  "services": [
    "chef-server",
    "solr",
    "rabbitmq"
  ]
}
```

Each one of these services must be serviceable by `_stats/$service`, for example `_stats/solr`.

## Yet Another Way to Get Metrics
This introduces yet another way to get metrics for the Chef Server. All metrics that were previously
available through statsd or Folsom will be available from the stats endpoint. This means that other
methods should be deprecated and removed in the next major version bump of Chef Server. Those who
wish to push to Graphite may still do so by polling. Doing the same for statsd may no longer make sense
as the stats endpoint will have already aggregated the metric data. That being said, those who wish to
still use statsd can get the data from the request logs.

## Unanswered Questions

- What about chef-backend?
- Do we need or should we have authn/authz?
- Versioning
- Should we provide an endpoint that lists all the metrics such as `_stats/_all`?

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

## Resources
https://getchef.zendesk.com/hc/en-us/articles/207577106-Monitoring-Your-Chef-Server
https://github.com/facebook/chef-utils/blob/master/chef-server-stats/chef-server-stats
