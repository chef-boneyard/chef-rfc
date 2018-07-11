Auto-update Implementation RFC 
---
RFC: unassigned
Title: Auto-update Chef Workstation
Author: 
Michael Chiang <mchiang@chef.io>
Tim Smith <tsmith@chef.io> 
Marc Paradise <marc@chef.io>
Tyler Ball <tball@chef.io> 
Seth Thomas <sthomas@chef.io> 
Susan Evans <sevans@chef.io> 

Status: Draft
Type: Informational
---

# Automatically Updating Chef Workstation 

The goal of this RFC is to discuss how the update notification process will work inside Chef Workstation through its included tray application.

## Motivation

As a Chef user,
I want to be notified if an update is available,
so that I can keep my Chef Workstation up-to-date.

As an Enterprise Chef user, 
I want to ensure a specific major version of Chef Workstation is used, 
so that there won’t be any backwards compatibility issues while still receiving updates.

## Update Checking Specification

### Update Checks
The update checks will occur in a daemon that runs in the background. By default this will be configured to start on user login, and may be started by chef-workstation tooling if it’s not running when chef-workstation commands are executed

This daemon may provide additional functionality beyond update checking n the future. The prompt for installation will occur from the Tray Application that Chef Workstation ships with.

### When Update Checks Run 

Unless disabled, update checks will run automatically in the background of any workstation with Chef Workstation installed, no more frequently than once per (hour? day? week?) 

### How the Need for Update is Determined

The updater will be configured to one of Chef’s product channels. At this time that is the ‘current’ channel and the ‘stable’ channel. The updater will periodically make calls to the omnitruck.chef.io service to check for a newer version within the configured channel.

### When Updates Prompt

The user will be prompted for all updates if update checks are not disabled
 
For new major releases the user can choose to skip the major release and instead update from the stable channel of their current release.

#### Repeat Prompts

The system will not notify the operator again for the same version of Chef Workstation after the operator declines to install an available upgrade, though the option to install will remain available. 

Subsequent releases of Chef Workstation to the configured update channel will trigger a new prompt. 

### How Updates are Installed

At this time, updates will be installed via the operating system’s default package manager.  

### Disabling Update Checks

Users and administrators will have multiple methods to disable updates if necessary. 

From the tray application preferences
From the Chef Workstation command line
From the Chef Workstation configuration file

The user will still be able to manually check for updates. 

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
