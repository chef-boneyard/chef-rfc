---
RFC: 30
Author: Adam Jacob <adam@getchef.com>
Status: Accepted
Type: Process
---

# Maintenance Policy

The Maintenance Policy defines how we make decisions about what happens with Chef, and associated software projects. It provides the process by which:

* Roadmaps are decided
* Patches are merged
* Disputes are resolved

It is intended to be short, flexible, and clear.

This file is related to the MAINTAINERS file in Chef. During the draft period, the first version of that file is included in this RFC.

# How the project is maintained

This file is the canonical source for how the Chef project is maintained.

# Roles

## Project Lead

Resolves disputes
Provides vision and roadmap
Has universal veto power

## Lieutenants

Publish a roadmap (two quarters out)
Release calendar for code outside of chef client/chef server
Resolves disputes within their subsystem
Has localized veto power
Plus all responsibilities of a maintainer

## Maintainer

Handle contributions on GitHub - first response to a PR within 48 hours
Be available on IRC
Attend the developers meeting (do not miss more than 3 in a row - special dispensation can be made for difficult time zones)
Be available to answer mailing list questions within 48 hours
Weekends and local holidays in the maintainer’s jurisdiction are not counted for timeliness requirements. Absences for reasonable causes such as vacations, illness, etc. are also acceptable; Maintainers should notice of absences via the development mailing list whenever possible.
Committed to 100% tests passing for your component
Has full commit/merge access to the relevant repositories
Has ops on IRC

# Contributing Patches

##How a patch gets merged

* Open Pull Request (anyone)
* Sign a CLA on Supermarket, tied to your github account.
* Code reviewed by a maintainer, lieutenant, or project lead. Approval is indicated by :+1: on the pull request.
* Merged on :+1: by an absolute majority of maintainers for the subsystems affected by your patch with no vetoes

## Patch Appeals Process

Although the approval of a contribution requires an absolute majority of the maintainers responsible for that component to vote for it, there may be cases where someone wishes to appeal a particular decision.

In this event, the "chain of command" for the appeals process is as follows.

* In the event that the actions of a Maintainer are to be appealed, the appeal should be directed to the Lieutenant for that component. As stated above, a Lt retains veto power for the component(s) for which they are responsible.

* In the event that the actions of a Lieutenant are to be appealed, the appeal should be directed to the Project Lead. As stated above, the Project Lead retains universal veto power over all components.

Although Lieutenants and the Project Lead retain veto powers over certain components, use of this veto power is not guaranteed by the submission of an appeal to that person. It is expected that the majority decisions of component maintainers and lieutenants will be respected in all but the most exceptional circumstances.

# How to become a...

## Maintainer

* Have patches merged into the relevant subsystem
* Be willing to perform the duties of a maintainer
* Issue a pull request adding yourself to the MAINTAINERS file for your component
* Receive an absolute majority of existing maintainers and lieutenants for your component :+1:
* No veto from the component lieutenant
* No veto from the current project lead

## Lieutenant

* Issue a pull request to the MAINTAINERS file making yourself the lieutenant
* Be willing to perform the duties of a lieutenant
* Receive an absolute majority of existing lieutenants :+1:
* No veto from the current project lead

## Project Lead

* Issue a pull request to the MAINTAINERS file making yourself the project lead
* Be willing to perform the duties of the project lead
* Receive an absolute majority of existing lieutenants :+1:
* No veto from Chef Software, Inc, as held by their current Chief Executive Officer.

# Removing a Maintainer, Lieutenant or Lead

If a Maintainer, Lieutenant or Lead consistently fails to maintain their responsibilities or becomes disruptive, they can be removed by:

* Issue a pull request removing them from the MAINTAINERS file
* Receive an absolute majority of existing lieutentants :+1:
* No veto from the current project lead

OR

* Issue a pull request removing them from the MAINTAINERS file
* The current project lead unilaterally decides to merge pull request

# How to add a component

* Issue a pull request to the MAINTAINERS file describing the component, and making yourself lieutenant
* Be willing to perform the duties of a lieutenant
* Receive an absolute majority of existing lieutenants :+1:
* No veto from the current project lead

# How to change the rules by which the project is maintained

* Issue a pull request to this file.
* Receive an absolute majority of existing lieutenants from the Chef repository MAINTAINERS file :+1:
* No veto from the current project lead

# Where can I find the community?

The broader Chef community gathers in a small number of designated places. Participants in these places should be considered as operating on their own opinion, and representing nothing further than their own point of view. While some members of the community may be participating via their employment at Chef Software, when in these spaces, their authority and voice is equal to any other participant based on the guidelines in this file.

## IRC

You can find a large set of community members in IRC, within the #chef channel on irc.freenode.net. Development updates and conversations also happen on #chef-hacking. In both channels, those with “ops” are the maintainers, lieutenants, and the project lead. Those with “voice” are MVPs for Chef releases.

## Mailing Lists

* [Chef Users](http://lists.opscode.com/sympa/info/chef) - is the primary async communications channel for all users of Chef, regardless of how they participate.
* [Chef Developers](http://lists.opscode.com/sympa/info/chef-dev) - is the primary async communications channel for those concerned with developing Chef.

# Where can I find Chef Software Inc?

[The history of the Chef Project](http://www.getchef.com/blog/2014/07/03/chef-as-a-community/) is linked to the existence of a for-profit company, [Chef Software](http://www.getchef.com). Many employees of the company are active members of the community. When they participate in the community, they do so as individuals subject to the guidelines in this file.

If you would like to speak to, or understand the position of, someone at Chef Software - feel free to drop a line to [info@getchef.com](mailto:info@getchef.com) - and we’ll get back to you. Or simply ask for the companies official perspective in any of the community spaces, and a representative will get back to you in that space.

# The MAINTAINERS file in Chef

# Maintainers

This file lists how the Chef project is maintained. When making changes to the system, this
file tells you who needs to review your patch - you need a simple majority of maintainers
for the relevant subsystems to provide a :+1: on your pull request. Additionally, you need
to not receive a veto from a Lieutenant or the Project Lead.

[Check out HOW_CHEF_IS_MAINTAINED](#soon) for details on the process, how to become
a maintainer, lieutenant, or the project lead.

# Project Lead

[Adam Jacob](http://github.com/adamhjk)

# Components

## Chef Core

Handles the core parts of the Chef DSL, base resource and provider
infrastructure, and the Chef applications. Includes anything not covered by
another component.

### Lieutenant

### Maintainers

## Dev Tools

Chef Zero, Knife, Chef Apply and Chef Shell.

### Lieutenant

### Maintainers

## Test Tools

ChefSpec, Berkshelf (the chef bits), Test Kitchen (the Chef bits)

### Lieutenant

### Maintainers

## Platform Specific Components

The specific components of Chef related to a given platform - including (but not limited to) resources, providers, and the core DSL.

## Enterprise Linux

### Lieutenant

### Maintainers

## Ubuntu

### Lieutenant

### Maintainers

## Windows

### Lieutenant

### Maintainers

## Solaris

### Lieutenant

### Maintainers

## AIX

### Lieutenant

### Maintainers

## Mac OS X

### Lieutenant

### Maintainers


