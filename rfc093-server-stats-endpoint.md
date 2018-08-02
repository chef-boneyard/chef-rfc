---
RFC: 93
Title: Stats Endpoint for Chef Server
Author: Jay Mundrawala <jmundrawala@chef.io>
Status: Accepted
Type: Standards Track
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

This RFC adds a `/_stats` endpoint to Chef Server. This endpoint will respond with
statistics about the Chef Server instance, along with any services that are both required
by Chef Server and colocated with that instance. It takes one optional parameter `format`,
which is assumed to be `json` by default. There may be other formats supported in the future.

### Supported Metric Primitives
The endpoints can provide metrics of following types, as defined by [Prometheus](https://prometheus.io/docs/concepts/metric_types/):
- Counter - Monotonic cumulative metric. For example, number of requests served.
- Gauge - Numeric measurement at a given point in time. For example, number of inflight requests.
- Histogram - Distributes values into buckets. For example, response times.
- Summary - Provides summary statistics for a value in a sliding window.

### JSON Response Format
The stats endpoint must respond to `format=json`. The schema is defined below.

#### JSON
The JSON response schema will be based on that defined by
[Prometheus 0.0.4](https://prometheus.io/docs/instrumenting/exposition_formats), but modified to fit a
JSON serialization format. We will return a list of metrics families, each with a name,
type, help doc string, and a list of metrics. Each individual metric in the family will have a set of
labels, and optionally a label. Other data will be based on the type of metric. All numbers will be formated as strings so that
we may represent things like NaN and infinity. This format will be based on
[prom2json](https://github.com/prometheus/prom2json). Below is an example of taking metrics from the
prometheus text format to JSON:

```
# HELP http_requests_total The total number of HTTP requests.
# TYPE http_requests_total counter
http_requests_total{method="post",code="200"} 1027 1395066363000
http_requests_total{method="post",code="400"}    3 1395066363000

# A weird metric from before the epoch:
something_weird{problem="division by zero"} +Inf -3982045

# A histogram, which has a pretty complex representation in the text format:
# HELP http_request_duration_seconds A histogram of the request duration.
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.05"} 24054
http_request_duration_seconds_bucket{le="0.1"} 33444
http_request_duration_seconds_bucket{le="0.2"} 100392
http_request_duration_seconds_bucket{le="0.5"} 129389
http_request_duration_seconds_bucket{le="1"} 133988
http_request_duration_seconds_bucket{le="+Inf"} 144320
http_request_duration_seconds_sum 53423
http_request_duration_seconds_count 144320

# Finally a summary, which has a complex representation, too:
# HELP rpc_duration_seconds A summary of the RPC duration in seconds.
# TYPE rpc_duration_seconds summary
rpc_duration_seconds{quantile="0.01"} 3102
rpc_duration_seconds{quantile="0.05"} 3272
rpc_duration_seconds{quantile="0.5"} 4773
rpc_duration_seconds{quantile="0.9"} 9001
rpc_duration_seconds{quantile="0.99"} 76656
rpc_duration_seconds_sum 1.7560473e+07
rpc_duration_seconds_count 2693

# HELP available_workers The number of available workers
# TYPE available_workers gauge
available_workers 10
```

```
[
  {
    "help": "A summary of the RPC duration in seconds.",
    "metrics": [
      {
        "count": "2693",
        "quantiles": {
          "0.01": "3102",
          "0.05": "3272",
          "0.5": "4773",
          "0.9": "9001",
          "0.99": "76656"
        },
        "sum": "1.7560473e+07"
      }
    ],
    "name": "rpc_duration_seconds",
    "type": "SUMMARY"
  },
  {
    "help": "The number of available workers",
    "metrics": [
      {
        "value": "10"
      }
    ],
    "name": "available_workers",
    "type": "GAUGE"
  },
  {
    "help": "The total number of HTTP requests.",
    "metrics": [
      {
        "labels": {
          "code": "200",
          "method": "post"
        },
        "timestamp": "1395066363000",
        "value": "1027"
      },
      {
        "labels": {
          "code": "400",
          "method": "post"
        },
        "timestamp": "1395066363000",
        "value": "3"
      }
    ],
    "name": "http_requests_total",
    "type": "COUNTER"
  },
  {
    "help": "",
    "metrics": [
      {
        "labels": {
          "problem": "division by zero"
        },
        "timestamp": "-3982045",
        "value": "+Inf"
      }
    ],
    "name": "something_weird",
    "type": "UNTYPED"
  },
  {
    "help": "A histogram of the request duration.",
    "metrics": [
      {
        "buckets": {
          "+Inf": "144320",
          "0.05": "24054",
          "0.1": "33444",
          "0.2": "100392",
          "0.5": "129389",
          "1": "133988"
        },
        "count": "144320",
        "sum": "0"
      }
    ],
    "name": "http_request_duration_seconds",
    "type": "HISTOGRAM"
  }
]
```

## Authentication
The `_stats` endpoint could potentially provide information useful in compromising aspects of the Chef
Server. For this reason, there should be an option to protect this endpoint with basic access authentication
for operators who do not want this endpoint accessible to all. A username and password will be generated if
it not provided. By using basic authentication, we provide some level of access control to this endpoint
while still making useable to metrics systems, as most will provide a way to access endpoints that have
basic auth.

## Yet Another Way to Get Metrics
This introduces yet another way to get metrics for the Chef Server. All metrics that were previously
available through statsd or Folsom will be available from the stats endpoint. This means that other
methods should be deprecated and removed in the next major version bump of Chef Server. Those who
wish to push to Graphite may still do so by polling. Doing the same for statsd may no longer make sense
as the stats endpoint will have already aggregated the metric data. That being said, those who wish to
still use statsd can get the data from the request logs.

## Resources
 * https://getchef.zendesk.com/hc/en-us/articles/207577106-Monitoring-Your-Chef-Server
 * https://github.com/facebook/chef-utils/blob/master/chef-server-stats/chef-server-stats

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
