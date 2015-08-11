---
RFC: 53
Author: Bryan McLellan <btm@loftninjas.org>
Status: Accepted
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

The lack of a configuration file has been a major impediment to many improvements in Ohai and plugin behavior.

Previously Ohai has not had a configuration file. A small number of Ohai configuration settings do exist that can be specified in the Chef client 'client.rb' file which is parsed by `Mixlib::Config`. These settings are then passed to Ohai during a client run. For example, additional locations on the file system can be searched for plugins by adding paths to the `Ohai::Config[:plugin_path]` array. However, the 'client.rb' file is only loaded by the Chef client and does not affect Ohai when being run on the command line nor any other programs loading Ohai as a library, causing inconsistent Ohai results.

### Hints

The existing hints system was designed to provide facts about a system that Ohai would be unable to or have difficulty to determine on its own. The most common use case is informing a knife plugin that the system is in a particular cloud environment, enabling the plugin to collect appropriate metadata. Sometimes the plugin also passes metadata to Ohai to become attributes that Ohai would otherwise be unable to collect. For this purpose it was decided to use JSON as a data interchange format.

When a 'hint_name.json' file exists in the directory specified by `Ohai::Config[:hints_path]`, `Ohai::Hints.hint?(hint_name)` will return non-nil. If the file contains JSON data, it will be returned as a hash. If the file is empty, an empty hash will be returned.

The hints system should only be used by other tools to assist Ohai in collecting data. It should not otherwise be used to configure the behavior or Ohai or its plugins. That is the purpose of the new configuration system. The hints system may be combined with the configuration system in the future and deprecated for general ease of use of Ohai.

## Specification

The `Ohai::Config` Ruby class will use the new ChefConfig library that is currently bundled with the Chef client source but shipped separately. Configuration will be set in a configuration file using a `Mixlib::Config` config_context named 'ohai'. Here is an example 'client.rb' file that would configure both the client and Ohai.

```
log_level        :info
log_location     STDOUT
chef_server_url  "https://api.chef.io/organizations/oneofus"
ohai.plugin_path = "/etc/chef/ohai/plugins.local"
ohai.plugin[:hostname][:fqdn_using] = [ :hostname, :nis, :dns ]
```

Because at the top level (outside of a config_context) the `Ohai::Config` class will be the same as `ChefConfig` and `Chef::Config`, existing top level configuration options like `Ohai::Config[:disabled_plugins]` will be deprecated in favor of new settings within the config_context, i.e. `Ohai::Config.ohai.disabled_plugins`. Until support for those top-level settings is removed, their values will be copied as appropriate for backward compatibility.

For convenience, a config method will be added to the `Ohai` class to access `Ohai::Config.ohai`, allowing the use of `Ohai.config[:plugin_path]` instead of `Ohai::Config.ohai[:plugin_path]` throughout the code. All existing uses of `Ohai::Config` in Ohai will need to be updated accordingly.


Example accessing the disabled_plugins configuration setting:

```
Ohai::Config[:disabled_plugins] # Current pattern
Ohai::Config.ohai[:disabled_plugins] # Proposed pattern
Ohai.config[:disabled_plugins] # Proposed shortcut
```

### Configuration Files

When run from the command line, Ohai should load the workstation 'config.rb' and then the 'client.rb' files from the appropriate platform specific path, unless an alternate configuration file is provided as a command line argument. This provides similar behavior to knife which loads 'config.rb' and then 'knife.rb'. This facilitates reducing the number of separate configuration files to maintain for command line behavior.

When loaded as a library, Ohai must not load a configuration file and will expect to be provided any necessary configuration options. For example, when loaded by the Chef client, configuration values will be located in the 'client.rb' file, or the file passed to the Chef client as the configuration file. Using the same file for configuration simplifies configuration file creation during bootstrap for the client.

### Plugin Namespacing

To reduce the risk of built-in and custom plugins using the same configuration setting for conflicting purposes, it is recommended that all plugins prefix their configuration settings with `[:plugin]` and the snake-case name of the plugin consuming the setting, as set in the plugin itself. The exposed overlap is intended, to facilitate passing a configuration option to the same plugin for multiple platforms but only specifying it once.

For example, configuration file settings would look like:

```
ohai[:plugin][:memory][:unit] = "mb"
ohai[:plugin][:dmi][:all_ids] = true
ohai[:plugin][:ec2][:silly_magic_arp] = "de:ad:de:ad:de:ad"
ohai[:plugin][:platform][:amazon_is_amazon] = true
```

Settings would be read in code as:

```
Ohai.config[:plugin][:memory][:unit]
Ohai.config[:plugin][:dmi][:all_ids]
Ohai.config[:plugin][:ec2][:silly_magic_arp]
Ohai.config[:plugin][:platform][:amazon_is_amazon]
```

Note that the filename on disk does not always match the plugin name. In the case of the 'darwin/system_profiler.rb' file, the plugin name is 'SystemProfile', and the correct plugin namespace would be `Ohai::Config.ohai[:plugin][:system_profile]`.

### Configuration Hash Nesting

Plugin configuration hashes are auto-vivified. Auto-vivification can be
implemented safely, without `method_missing`:

```ruby
Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
```
[Source](http://stackoverflow.com/questions/5878529/how-to-assign-hashab-c-if-hasha-doesnt-exist#comment6760520_5878626)

Sub-keys of `Ohai.config[:plugin]` and `ohai.plugin` must be of type `Symbol`.
Values can be of any type. If the value is a `Hash`, it will be forced to
conform to the keys-are-Symbols rule. The following are disallowed:

```ruby
ohai.plugin[:plugin_name] = { "option" => true }
```

```ruby
ohai.plugin[:plugin_name] = { :option => { "sub_option" => true } }
```

```ruby
ohai.plugin[:plugin_name][:option] = {}
ohai.plugin[:plugin_name][:option]["sub_option"] = true
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
