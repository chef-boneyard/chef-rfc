Chef Client Windows Event Log Output
==========================================

Abstract

## Document status

This Request for Comments (RFC) document contains proposals not yet
implemented in the Chef client -- comments on the proposals are welcome.

## Motivation


## Problems addressed with Windows event logging

## Definitions
This document assumes familiarity with the [Windows Event Log](http://msdn.microsoft.com/en-us/library/windows/desktop/aa385780(v=vs.85%29.aspx) and related
tools and concepts such as the [Windows Event Viewer](http://technet.microsoft.com/en-us/library/cc766042.aspx) and [PowerShell event log cmdlets](http://social.technet.microsoft.com/wiki/contents/articles/4535.windows-7-event-logs.aspx).

Key definitions include:

* **Channel**:
* **Administrative event** or **Admin event**:
* **Operational event**:
* **Anti-event**:
* **Activity ID**:

## Overview

## Detailed functional specification

### Configuration

#### Windows configuration
Chef client will configure Windows systems with the following Windows Event
log channels:

* **Chef-Client/Admin**: This is the location where notable events for a
    chef-client run are logged. Such events include the start and stop for a
    chef-client run, any errors that are logged during the run, and any log
    output indicating that a resource was updated.
* **Chef-Client/Operational**: This log is the destination for any chef-client
    output that would normally be logged to STDOUT. Output only flows to this
    channel if the `log_location` configuration value in Chef client's 
    **client.rb** file is set to `:os_log`.

#### Chef client configuration
The following configuration options will be added to **client.rb**:

* `os_event_log_level`: This option will initially be supported on Windows only.
  This option will allow the following values:
  * `:status` (default):
  * `:change`:
  * `:resource`:
  * `:none`: no logging to this channel will be performed
* `log_location`: The existing `log_location` option of **client.rb** will support
  another value initially on Windows only:
  * `:os_log`: This will cause all chef-client log output to be logged to the
  Chef channel's operational log.
  
### Behavior

## Implementation notes

Implementation may take advantage of *start*, *exception*, and *reporting* handlers as
described in [Chef documentation](http://docs.opscode.com/chef/essentials_handlers.html).

## Future Windows logging improvements


## References and further reading

* Windows Event Log API documentation: <http://msdn.microsoft.com/en-us/library/windows/desktop/aa385780(v=vs.85).aspx>
* Windows Event Log PowerShell access: <http://social.technet.microsoft.com/wiki/contents/articles/4535.windows-7-event-logs.aspx>
* Windows Event Viewer: <http://technet.microsoft.com/en-us/library/cc766042.aspx>
* Chef Handlers: <http://docs.opscode.com/chef/essentials_handlers.html>
* Chef Client open source project: <https://github.com/opscode/chef>. 
