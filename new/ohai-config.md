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

## Current State

Previously Ohai has not had a configuration file. A small number of Ohai configuration settings do exist that can be specified in the chef-client client.rb file, which are then passed to Ohai during a chef-client run. For example, additional locations on the file system can be searched for plugins by adding paths to the Ohai::Config[:plugin_path] array. This file is only loaded by Chef and does not affect Ohai when being run on the command line nor any other programs loading Ohai as a library, causing inconsistent Ohai results.

## Specification


Ohai::Config will use the new ChefConfig library that is bundled with the Chef client. Configuration will be set using a Mixlib::Config config_context named 'ohai'. Here is an example client.rb file that would configure both the client and Ohai.

```
log_level        :info
log_location     STDOUT
chef_server_url  "https://api.chef.io/organizations/oneofus"
ohai.plugin_path = "/etc/chef/ohai/plugins.local"
ohai.plugin[:hostname][:fqdn_using] = [ :hostname, :nis, :dns ]
```

Because at the top level (outside of a config_context) Ohai::Config will be the same as ChefConfig and Chef::Config, existing top level configuration options like Ohai::Config[:disabled_plugins] will be deprecated in favor of new settings within the config_context, i.e. Ohai::Config.ohai.disabled_plugins. Until support for those top-level settings is removed, their values will be set inside the config_context.

For example:

```
# Old Syntax
Ohai::Config[:plugin_path] << "/usr/local/lib/ohai/plugins"

# New Syntax
Ohai::Config.ohai.plugin_path
=> ["/opt/chefdk/embedded/apps/ohai/lib/ohai/plugins", "/usr/local/lib/ohai/plugins"]
```

For convenience, a config method will be added to the Ohai class to access Ohai::Config.ohai, allowing the use of Ohai.config[:plugin_path] instead of Ohai::Config.ohai[:plugin_path] throughout the code. All existing uses of Ohai::Config in Ohai will need to be updated accordingly.

### Configuration File

When run from the command line, Ohai should load the config.rb and then the client.rb files from the appropriate platform specific path, unless an alternate configuration file is provided as a command line argument. This provides similar behavior to knife which loads config.rb and then knife.rb. This facilitates reducing the number of separate configuration files to maintain for command line behavior.

When loaded as a library, Ohai must not load a configuration file and will expect to be provided any necessary configuration options. For example, when loaded by the Chef client, configuration values will be located in the client.rb file, or the file passed to the Chef client as the configuration file. Using the same file for configuration simplifies configuration file creation during bootstrap for the client.

### Namespacing

To reduce the risk of built-in and custom plugins using the same configuration setting for conflicting purposes, it is recommended that all plugins prefix their configuration settings with [:plugin] and the snake-case name of the plugin consuming the setting, as set in the plugin itself. The exposed overlap is intended, to facilitate passing a configuration option to the same plugin for multiple platforms but only specifying it once.

For example:

```
Ohai::Config.ohai[:plugin][:memory][:unit] = "mb"
Ohai::Config.ohai[:plugin][:dmi][:all_ids] = true
Ohai::Config.ohai[:plugin][:ec2][:silly_magic_arp] = "de:ad:de:ad:de:ad"
Ohai::Config.ohai[:plugin][:platform][:amazon_is_amazon] = true
```

Note that the filename on disk does not always match the plugin name. In the case of the darwin/system_profiler.rb file, the plugin name is SystemProfile, and the correct plugin namespace would be Ohai::Config.ohai[:plugin][:system_profile].

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

