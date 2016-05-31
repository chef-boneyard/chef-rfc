---
RFC: 30
Author: Adam Jacob <adam@chef.io>
Status: Accepted
Type: Process
---

# Maintenance Policy

The Maintenance Policy defines how we make decisions about what happens with Chef, and associated software projects. It provides the process by which:

* Roadmaps are decided
* Patches are merged
* Disputes are resolved

It is intended to be short, flexible, and clear.

This file is related to the MAINTAINERS and ROADMAP files in Chef.

# How the project is maintained

This file is the canonical source for how the Chef project is maintained.

# Roles

## Project Lead

* Resolves disputes
* Provides vision and roadmap
* Has universal veto power
* There can be only one

## Lieutenant

* Each component in the project may have at most one Lieutenant
* Provides guidance on future direction for their component
* Provides a release calendar for code outside of chef client/chef server
* Resolves disputes within their component
* Has localized veto power
* Plus all the responsibilities of a Maintainer

## Maintainer

* Each component may have multiple Maintainers
* Handles contributions on GitHub - first response to a PR within 48 hours
* Is available on IRC
* Attends the developers meeting (do not miss more than 3 in a row - special dispensation can be made for difficult time zones)
* Is available to answer mailing list questions within 48 hours
* Weekends and local holidays in the Maintainer’s jurisdiction are not counted for timeliness requirements. Absences for reasonable causes such as vacations, illness, etc. are also acceptable; Maintainers should notice of absences via the development mailing list whenever possible.
* Committed to 100% tests passing for your component
* Has full commit/merge access to the relevant repositories
* Has ops on IRC

# Roadmap

All project roles should work together to determine the best opportunities for the improvement of the project. This should produce direction for the project, which should be highlighted in the ROADMAP.

As a project role does not necessarily control resources other than their own labor, they should encourage contributors to participate in furthering development of the project toward the goals of the ROADMAP.

Releases should not block on features on the roadmap, rather they should happen as features are completed. The ROADMAP should be organized by general time periods, not by versions
## Example Roadmap entries

```
# 2015 Q2
* Component - Roadmap Item
  Description

# 2015 Q4
* Core - Support for Drone Automation
  Significant time could be saved in enterprise datacenters by using drones to stack and rack servers

# 2016 Q1
* Core - Support Internet of Things
  As a Chef user, I look forward to the singularity
```

# Contributing Patches

## How a patch gets merged

* Open Pull Request (anyone)
* Sign a CLA on Supermarket, tied to your github account.
* Code reviewed by a Maintainer, Lieutenant, or Project Lead. Approval is indicated by :+1: on the pull request.
* Merged after :+1: votes by at least two Maintainers for the component(s) affected by your patch.

In the event that a component lacks two Maintainers, the vote of one or more Maintainers from Chef Core may be substituted.

Any Maintainer may vote :-1: on a patch, which increases the requirement for a patch to be merged to an absolute majority of Maintainers for the affected component(s), unless that Maintainer later changes their vote.

## Patch Appeals Process

There may be cases where someone wishes to appeal a Maintainer decision. In this event, the "chain of command" for the appeals process is as follows.

* In the event that the actions of a Maintainer are to be appealed, the appeal should be directed to the Lieutenant for that component. As stated above, a Lt retains veto power for the component(s) for which they are responsible.

* In the event that the actions of a Lieutenant are to be appealed, the appeal should be directed to the Project Lead. As stated above, the Project Lead retains universal veto power over all components.

Although Lieutenants and the Project Lead retain veto powers over certain components, use of this veto power is not guaranteed by the submission of an appeal to that person. It is expected that the majority decisions of component Maintainers and Lieutenants will be respected in all but the most exceptional circumstances.

# How to become a...

## Maintainer

* Have patches merged into the relevant component
* Be willing to perform the duties of a Maintainer
* Issue a pull request adding yourself to the MAINTAINERS file for your component
* Receive an absolute majority of existing Maintainers and Lieutenants for your component :+1:
* No veto from the component Lieutenant
* No veto from the current Project Lead

## Lieutenant

* Issue a pull request to the MAINTAINERS file making yourself the Lieutenant
* Be willing to perform the duties of a Lieutenant
* Receive an absolute majority of existing Lieutenants :+1:
* No veto from the current Project Lead

## Project Lead

* Issue a pull request to the MAINTAINERS file making yourself the Project Lead
* Be willing to perform the duties of the Project Lead
* Receive an absolute majority of existing Lieutenants :+1:
* No veto from Chef Software, Inc, as held by their current Chief Executive Officer.

# Removing a Maintainer, Lieutenant or Project Lead

If a Maintainer, Lieutenant or Project Lead consistently fails to maintain their responsibilities or becomes disruptive, they can be removed by:

* Issue a pull request removing them from the MAINTAINERS file
* Receive an absolute majority of existing Lieutenants :+1:
* No veto from the current Project Lead

OR

* Issue a pull request removing them from the MAINTAINERS file
* The current Project Lead unilaterally decides to merge pull request

# How to add a component

* Issue a pull request to the MAINTAINERS file describing the component, and making yourself Lieutenant
* Be willing to perform the duties of a Lieutenant
* Receive an absolute majority of existing Lieutenants :+1:
* No veto from the current Project Lead

# How to change the rules by which the project is maintained

* Issue a pull request to this file.
* Receive an absolute majority of existing Lieutenants from the Chef repository MAINTAINERS file :+1:
* No veto from the current Project Lead

# Where can I find the community?

The broader Chef community gathers in a small number of designated places. Participants in these places should be considered as operating on their own opinion, and representing nothing further than their own point of view. While some members of the community may be participating via their employment at Chef Software, when in these spaces, their authority and voice is equal to any other participant based on the guidelines in this file.

## IRC

You can find a large set of community members in IRC, within the #chef channel on irc.freenode.net. Development updates and conversations also happen on #chef-hacking. In both channels, those with “ops” are the Maintainers, Lieutenants, the Project Lead, and Community Advocates. Those with “voice” are MVPs for Chef releases.

## Mailing Lists

* [Chef Mailing List](http://discourse.chef.io)
  * The `chef` category is the primary async communications channel for all users of Chef, regardless of how they participate.
  * The `chef-dev` is the primary async communications channel for those concerned with developing Chef.

# Where can I find Chef Software Inc?

[The history of the Chef Project](http://www.chef.io/blog/2014/07/03/chef-as-a-community/) is linked to the existence of a for-profit company, [Chef Software](http://www.chef.io). Many employees of the company are active members of the community. When they participate in the community, they do so as individuals subject to the guidelines in this file.

If you would like to speak to, or understand the position of, someone at Chef Software - feel free to drop a line to [info@chef.io](mailto:info@chef.io) - and we’ll get back to you. Or simply ask for the company's official perspective in any of the community spaces, and a representative will get back to you in that space.

# The MAINTAINERS file in Chef

The current [MAINTAINERS](https://github.com/chef/chef/blob/master/MAINTAINERS.md) file resides in the [Chef](https://github.com/chef/chef) repository on GitHub.
