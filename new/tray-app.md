---
RFC: unassigned
Title: Tray App for Chef Workstation
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

# Building a Tray App for Chef Workstation 

The goal of the Chef Workstation tray application is to provide a greater user experience on the desktop for Chef users.

Initially, we want to start with automatic updates as the first feature to address a problem we’ve heard for a long time from our community members and customers - the process of checking and updating versions of ChefDK and Chef Workstation isn’t as a smooth of an experience as the team wanted. Often users are left in the dark when new features or bug fixes that addressed a particular concern are made available. With automatic updates, the tray application will notify the user about new versions with a clear changelog, and facilitate the update if accepted by the user. 

This will set a great foundation for the team to focus on features that will provide improved cohesion of the current Chef tooling and what’s to come. 

## Motivation

As a Chef user,
I want to have an application that notifies me if there is an update available,
so that I can keep my Chef Workstation up-to-date.

As an Enterprise Chef user, 
I want to ensure a specific major version of Chef Workstation is used, 
so that there won’t be any backwards compatibility issues while still receiving updates.

## Specification

1. A desktop tray application that automatically checks for updates, and notifies the user if there is an update available with change logs. 

2. The application will only perform the update if the end-user elects to update. 

3. A Preferences pane to allow setting changes for Chef Workstation (e.g.,. Opt-in/out of telemetry, switch between current/stable channels of the tooling.) 

4. Target OSes: MacOS, Microsoft Windows and Linux distros with GUI 

## Design
We have started the process of designing the experience in MacOS and are including a video of those designs to give you a chance to comment on the design as well.

For design feedback we are interested in (1) What actions or information is missing that you expected to be there, (2) Screen flows that you find confusing or difficult to understand, (3) General feature requests.

We are not looking for feedback related to color choices or individual word choices because we are very much still working through iterating on those before we arrive at our final design.

https://youtu.be/CMO3AcFL-q4

## Implementation Description

### Update Checking Specification

#### Update Checks
The update checks will occur in a daemon that runs in the background. By default this will be configured to start on user login, and may be started by chef-workstation tooling if it’s not running when chef-workstation commands are executed

This daemon may provide additional functionality beyond update checking n the future. The prompt for installation will occur from the Tray Application that Chef Workstation ships with.

#### When Update Checks Run 

Unless disabled, update checks will run automatically in the background of any workstation with Chef Workstation installed, no more frequently than once per (hour? day? week?) 

#### How the Need for Update is Determined

The updater will be configured to one of Chef’s product channels. At this time that is the ‘current’ channel and the ‘stable’ channel. The updater will periodically make calls to the omnitruck.chef.io service to check for a newer version within the configured channel.

#### When Updates Prompt

The user will be prompted for all updates if update checks are not disabled
 
For new major releases the user can choose to skip the major release and instead update from the stable channel of their current release.

##### Repeat Prompts

The system will not notify the operator again for the same version of Chef Workstation after the operator declines to install an available upgrade, though the option to install will remain available. 

Subsequent releases of Chef Workstation to the configured update channel will trigger a new prompt. 

#### How Updates are Installed

At this time, updates will be installed via the operating system’s default package manager.  

#### Disabling Update Checks

Users and administrators will have multiple methods to disable updates if necessary. 

From the tray application preferences
From the Chef Workstation command line
From the Chef Workstation configuration file

The user will still be able to manually check for updates. 

## Alternatives

Users using package managers,such as homebrew, to check for and perform updates. We will not limit users who want to continue using their package managers. 

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

