---
RFC: unassigned
Title: In-Repo Draft Guides for Chef
Author:
- Noah Kantrowitz <noah@coderanger.net>
- Kimberly Garmoe <kgarmoe@chef.io>
Status: Draft
Type: Process
---

# In-Repo Draft Guides for Chef

Chef community members are skilled practitioners and valuable contributors. Chef
practitioners have experience and skills, but lack a stable process for composing
and sharing long-format information.

The community has requested two changes:

1. A place in the `chef/chef` repository for storing community guides
2. The ability to write in Markdown

## Motivation

    As a Chef contributor,
    I want to write guides for specific procedures or problems
    so that we can capture changes to Chef.

## Specification

To this end, we will create a `guides-drafts/` folder in the `chef/chef` repository.
This folder will contain documentation files so that the maintainer team can
work on and update them. No content in this folder will be considered ready for
end-user use, and will not be displayed on any documentation website (docs.chef.io
or whatever comes in the future in the same vein). At the discretion of the Chef
documentation team, some content may be reviewed and prepared for end-user
distribution, however that process is not covered here.

A `README.md` file in this folder will emphasize that the documentation here is
not for end-user consumption and encourage them to consult docs.chef.io.

As more draft guides are added, it will be the general policy of the Chef
maintainer team to only allow merges that include the relevant updates to any
existing guides, or the creation of a new guide if appropriate.

## Interim Workflow

[ed: this has not yet been reviewed by the Chef docs folks, this might be totally crazytalk]

New content will be added by the Chef maintainer team. For purely internal,
developer-facing documents, the maintainer team will own the content permanently.

For content eventually destined for users, the maintainer team will nominate
guides that the we feel are ready for review. The documentation team will, when
they have time available, do a copy-editing pass and determine if the final
destination will be `docs.chef.io` or `learn.chef.io`. The docs team will then
copy the content into the destination system for end-user consumption. When a
guide is updated in the future, it can be nominated for review again.

## Content Suggestions

None of these are specifically required (or promised), but give an idea of the
scope of the proposed structure:

### For users

* How to write a helper method
* How to write a DSL extension
* How to write a custom resource
* How to use Test Kitchen
* How to use Foodcritic/Cookstyle
* How to use node attributes
* Berks vs. Policyfiles
* How use Policyfiles in a workflow
* Upgrading from roles/envs to Policyfiles
* How to run subcommands (execute resources vs shell_out)
* How to build CI pipelines for Chef
* How to get help with Chef (community resources, etc)
* Compile time vs converge time
* How to move or copy files with Chef
* How to edit files with Chef
* How to set up Chef Server ACLs
* Chef vs. Puppet+Salt+Ansible (a la hashicorp's "versus" docs)
* Chef vs. Docker
* Chef vs. K8s
* "Getting started" guide (zero to learn-chef)
* Using Chef with a corporate proxy
* Using Chef on an air gap network
* Using secrets with Chef
* Writing wrapper cookbooks
* Deploying web applications with Chef
* How to set up new nodes (bootstrap, self-bootstrap)
* Using community cookbooks
* Publishing community cookbooks (shoutouts to souschef)
* Knife vs chef

### For Chef Developers

* How the Omnibus build system works
* How to bump dependencies
* How to release Chef
* How to backport a fix
* How to add a new resource to Chef
* How Chef is tested (and built)
* What all the mixlib gems do (also chef-config, other deps)
* Chef vs Chef Server vs ChefDK vs Chef Workstation
* What are Chef RFCs for and how to file one
* Dev-relevant chat channels

## Downstream Impact

This will eventually be made obsolete by planned overall improvements to the documentation
workflow, but until this this work will have to be periodically manually integrated
into user-facing documents.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
