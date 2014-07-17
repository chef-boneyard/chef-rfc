# Chef Client logging framework refactor

Proposal for refactoring the way Chef Client creates, configures, and uses loggers, with the intention of allow a more modular, extensible log framework.

This also will allow for the native use of syslog as a logger for chef client

## Current framework
Chef Client currently has a few possible "modes" of running, depending on the situation. There are also currently two config options to help get the desired behavior (force_formatter and force_logger). This would essentially deprecate these modes in favor of highly modular, configurable loggers for whatever purpose.

## New Loggers

### Chef::Loggers::ChefLogger
New default logger for the Chef Client (essentially the same as MonoLogger, with a new name and location to preserve backwards compatibility)

### Chef::Loggers::SyslogLogger
New logger for output to syslog

### Chef::Loggers::WindowsEventLogger
TBD - name may change.  see [Windows Logging RFC](https://github.com/opscode/chef-rfc/blob/adamed/windows-logging/rfc0002-windows-logging.md) (link may change)

## Configuration

### (potentially) Deprecated Configurations
Currently the Chef Client logger is configured with the following attributes:
(see [cli docs](http://docs.opscode.com/ctl_chef_client.html) and [config.rb docs](http://docs.opscode.com/config_rb_client.html) for more information)
- `--logfile` - represents the IO stream for log output, examples being ```STDOUT``` and ```/var/log/chef``` (can also be set in config.rb as ```log_location```)
<br/>Default - ```STDOUT```
- `--force-formatter` - if true, will force anything being sent to ```STDOUT``` to run through a Chef Client Formatter such as the ```doc``` or ```minimal``` formatters.
<br/>Default - false
- `--force-logger` - if true, will show anything being sent to the logger on ```STDOUT```
<br/>Default - false

### New Configuration Method
**client.rb style**
- ```add_logger``` - new method to add and configure a logger that Chef Client will log to.

Example of configurations (config.rb)

```ruby
# Complicated logger
add_logger "my_awesome_logger", # 'name' - name of the logger
            "ChefLogger", # 'log_type' - logger class, otherwise known as Chef::Loggers::ChefLogger
            {
              :log_location => "STDOUT",
              :log_variable => "true",
              :another_var => "some kind of important log config info"
            } # 'args' - json hash of key value pairs that are required to configure your logger
# Simple logger
add_logger "minimal", "MiniLogger"

# Replicate the default logger from prior to this change
add_logger "default", "ChefLogger", { :log_location => "STDOUT" }


```
## Writing a logger
### TBD
