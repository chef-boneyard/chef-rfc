---
RFC: unassigned
Author: Bryan McLellan <btm@loftninjas.org>
Status: Draft
Type: Standards Track
---

# Ohai User Configuration

Provides a standard for passing configuration settings to Ohai to configure its behavior as well as that of plugins.

## Motivation

    As a Chef user,
    I want to easily configure Ohai,
    so that it behaves optimally on my infrastructure.

    As an Ohai user,
    I want Ohai to load configuration settings from my client.rb,
    so that it behaves the same as it does during a chef-client run.

## Specification

### Configuration File

Previously Ohai has not had a configuration file. A small number of Ohai configuration settings do exist that can be specified in the chef-client ```client.rb``` file, which are then passed to Ohai during a chef-client run. For example, additional locations on the file system can be searched for plugins by adding paths to the ```Ohai::Config[:plugin_path]``` array. This file is only loaded by Chef and does not affect Ohai when being run on the command line nor any other programs loading Ohai as a library.

When run from the command line, Ohai should load the ```client.rb``` file from the appropriate platform specific path unless an alternate configuration file is provided as a command line argument. To preserve compatibility with the existing parsing of the ```client.rb```, the Ohai configuration file syntax will be variables set on the ```Ohai::Config``` class,, and barewords will be ignored using method_missing.

For example:

```
Ohai::Config[:plugin_path] << "/usr/local/lib/ohai/plugins"
Ohai::Config[:plugin][:hostname][:fqdn_using] = [ :hostname, :nis, :dns ]

# This is ignored:
node_name "darius"
```

Using the same ```client.rb``` file used by the chef-client also allows both tools to be configured simultaneously by populating this file during bootstrap with custom local values (when that is supported in the future).

### Namespacing

To reduce the risk of built-in and custom plugins using the same configuration setting for conflicting purposes, plugins must prefix their configuration settings with ```[:plugin]``` and the name of the plugin consuming the setting. 

For example:

```
Ohai::Config[:plugin][:dmi][:all_ids] = true
Ohai::Config[:plugin][:ec2][:silly_magic_arp] = "de:ad:de:ad:de:ad"
Ohai::Config[:plugin][:platform][:amazon_is_amazon] = true
```


## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

