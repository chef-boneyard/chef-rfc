# Chef Client logging framework refactor

Proposal for refactoring the way Chef Client creates, configures, and uses loggers, with the intention of allow a more modular, extensible log framework.

## Motivation

The current Chef Client logging system is confusing to configure and relatively limited in terms of adding functionality. In the past, people have attempted to extend the logging facilities with varying degrees of success. This change would allow for a simpler, documented way configure logging.

As a secondary motivation, some new logger classes will also be introduced to help with some common log frameworks. For more details on these, see below.

## Overview

In general, the idea here is to create to have fine grained control over the logs that are created, instead of having the client do it for you. (See backwards compatibility information below) Creating a new namespace `Chef::Loggers` allows anyone to easily create a new logger class and add the appropriate configuration elements needed to use it without having to navigate the existing logs.

This is an 'either/or' change, so using this (by defining one or more loggers with `add_logger`) will cause the old style logging to be ignored.

### Configuration

#### (potentially) Deprecated Configurations
Currently the Chef Client logger is configured with the following attributes:
(see [cli docs](http://docs.opscode.com/ctl_chef_client.html) and [config.rb docs](http://docs.opscode.com/config_rb_client.html) for more information)
- `--logfile` - represents the IO stream for log output, examples being `STDOUT` and `/var/log/chef` (can also be set in config.rb as `log_location)
<br/>Default - `STDOUT`
- `--force-formatter` - if true, will force anything being sent to `STDOUT` to run through a Chef Client Formatter such as the doc` or minimal` formatters.
<br/>Default - false
- `--force-logger` - if true, will show anything being sent to the logger on `STDOUT`
<br/>Default - false

#### New Configuration Method
`add_logger(log_type, args)` - new method to add and configure a logger that Chef Client will log to.

- `log_type` - represents the class name of the logger to instantiate. This assumes that the logger follows the `Chef::Loggers::LoggerName` pattern. The Chef Client will attempt to find the class, instantiate it with the `args` and add it to the list of registered loggers. **Required**
- `args` - represents a hash of key-value pairs that will be passed in when the logger class is instantiated. This will vary completely on the logger class, which ideally will have the inputs clearly documented. **Defaults to `nil`**

Example of configurations (config.rb)

```ruby
# Complicated logger -
add_logger "ComplexLogger",
            {
              :log_device => "STDOUT",
              :some_variable => "true",
              :another_var => "some kind of important log config info"
            }

# Simple logger
add_logger "MiniLogger"

# Replicate the default logger from prior to this change
add_logger "ChefLogger"


```
## Logger Information
### New Loggers
Note that these will only be enabled if you explicitly add them with the add_logger method

#### Chef::Loggers::ChefLogger
New default logger for the Chef Client (essentially the same as MonoLogger, with a new name and location to preserve backwards compatibility). The ChefLogger defaults to `STDOUT` unless you pass in a log_location in the `args`

#### Chef::Loggers::SyslogLogger
TBD - name may change - more information soon -
New logger for output to syslog

#### Chef::Loggers::WindowsEventLogger
TBD - name may change - see [Windows Logging RFC](https://github.com/opscode/chef-rfc/blob/adamed/windows-logging/rfc0002-windows-logging.md) (link may change)

### Writing a logger
Writing a logger should be as simple as creating a new class similar to the following:

```ruby
class Chef
  module Loggers
    class FreakingAwesomeLogger

    def initialize(args)
      # set arguments
    end
    # whatever else is needed
    end
  end
end

```

## Additional Information
### Current Framework
Chef Client currently has a few possible "modes" of running, depending on the situation. There are also currently two config options to help get the desired behavior (force_formatter and force_logger). This would essentially deprecate these modes in favor of highly modular, configurable loggers for whatever purpose.
### Retaining backwards compatibility
Backwards compatibility is maintained via a simple check where if you have no instances of `add_logger` in your `config.rb`, the client will operate the same as it did prior to this change, defaulting to a `STDOUT` based `MonoLogger` with log level set to :warn.
### Limitations/Unanswered Questions
- This does not allow you to override via command line in the current state, all configuration must be done via config.rb. While it would be possible to add a command line argument that can mimic the `add_logger` functionality (much like the `--format` option mimics `add_formatter`), passing all the required fields to configure a logger may be very complicated for anything but the simplest of logger classes.
