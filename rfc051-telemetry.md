---
RFC: 51
Title: Chef Telemetry
Author: Ranjib Dey <ranjib@linux.com>
Status: Accepted
Type: Standards Track
---

# Chef telemetry

## Motivation

  As a chef user and developer
  I want an easy way to get chef run performance data
  so that I can identify areas that can be optimized

As we automate more things with chef and control more system resources,
chef run time increases, and the chef client process consumes more memory and cpu.
As a configuration management system, it is important that a chef run
does not impact the underlying host performance. Over the last few years
Chef community has shared a number of optimization techniques. Aim of this
RFC is to facilitate some of those common patterns by providing a robust
telemetry system in core chef. If configured, the telemetry system will give users fine
grained metrics about chef run that can be used to find out
performance hiccups. This will also help users quantify how a chef
run impacts the underlying system.

## Specification

Telemetry module will provide following metrics:

- Time spent on key chef run milestones: How long does the chef run take for each stage? Telemetry system
  will declare  a subset of the current events as major milestones, these are: run_start,
  ohai_completed, node_load_completed, cookbook_resolution_complete, converge_start,
  converge_complete, run_completed/failed. Metrics will be captured during these milestones via event handlers.
  This can be used to estimate time spent on cookbook sync, compilation
  convergence phase etc.

- Time spent on individual resource & recipe convergence. This information is already available
  using the API, telemetry system will just consolidate them, along side the other metrics.

- GC related data. Ruby's internal memory usage obtained from
  GC.stat, captured during the chef run milestones.

Telemetry system will also let users define their custom metrics that can be computed
during these milestones (like total chef client process memory consumption from /proc/PID),
This will be offered via Chef class DSL. This will also be the recommended way to implement platform
specific metrics. Example:

```ruby
require 'sys/proctable'

Chef.telemetry do |telemetry|
  telemetry.add_metric 'vsize' do
    Sys::ProcTable.ps(Process.pid).vsize
  end
end
```

In addition to capturing these metrics, telemetry system will also provide publishing
API for metrics. Telemetry system will provide two publishing mechanism out of the box.
They are
  - node attributes: metrics will be saved as node attribute itself
  - statsd : To publish metrics via statsd endpoints

Telemetry system can be configured via the standard chef config file or using a dedicated
CLI flag for chef-client and chef-solo. It will be disabled by default.
Following is an example of configuring the telemetry subsystem

```ruby

enable_telemetry true

config_context(:telemetry) do
  resource true # captures per resource execution time taken
  recipe true # captures per recipe execution time taken
  gc true # captures GC stats during main chef events
  process true  # captures process memroy stats from /proc during main chef events
  client_run true # captures time spent on major chef run milstones
  publish_using(
   Chef::Telemetry::Publisher::Statsd.new(host: '192.168.2.11', port: 7676), # emit data to statsd
   Chef::Telemetry::Publisher::NodeAttribute.new('chef-metrics') # save all metrics under node['chef-metrics'] attribute
  )
end

```
Example of enabling telemetry using the CLI flag

```sh
chef-client --enable-telemetry
chef-solo --enable-telemetry
```

Telemetry publishing API will be a single method named #publish that accept a hash that
represents the metrics. `publish_using` method is used to register a metrics publisher
with the telemetry system.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
