---
RFC: unassigned
Title: Tray App for Chef Workstation
Author: 
Michael Chiang <mchiang@chef.io> 
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

## Alternatives

Users using package managers,such as homebrew, to check for and perform updates. We will not limit users who want to continue using their package managers. 

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

