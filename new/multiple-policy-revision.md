---
RFC: unassigned
Title: Multiple Policyfiles and Teams - New Proposal
Author: Jon Cowie <jcowie@chef.io>
Status: Draft
Type: Standards Track
Replaces: RFC075
---

# Multiple Policyfiles and Teams - New Proposal

This RFC proposal aims to replace RFC075 (Multiple Policyfiles and Teams) with a new RFC which solves some of the blocking issues encountered with the original RFC.

The underlying motivation of this proposal will be identical to RFC075 (and full credit goes to Noah Kantrowitz for those), but the proposed implementation and functionality will differ significantly.


Policyfiles allow powerful new workflows around cookbook management, but one
area they are currently lacking is in dealing with multi-team organizations.

Currently each node can be attached to exactly one policy and one policy group.
The organizational manifestation of this is generally that there needs to be a
single "owner" for the policy of that node. This might be a CI tool like Jenkins
or Chef Delivery, but in a lot of cases in the current workflow this will be the
team within the company that uses the machine most.

This works great for the "owner" team, they can use all the power and
flexibility of the Policyfile workflow to its fullest. For other groups
managing software on the node, the picture is less clear. As an example, take a
database server owned by an application team. On this server we have a mix of
software, the MySQL install and configuration is manage by the DBA team while
ntpd and rsyslog are managed by a core infrastructure team. These live in
different cookbooks so for the most part things are copacetic. When the DBA
team wants to roll out a new MySQL configuration entry they update the cookbook,
recompile the policyfile, `chef push` that compiled policy to the QA policy
group, and then follow the usual Policyfile roll-out procedure. For the core
team, things are more complex. They could follow the same process, but this
would require careful coordination with the DBA team to ensure they don't have
a roll-out in progress (see https://yolover.poise.io/#21). They could also
release their cookbook changes either to a git branch or Supermarket server,
and then notify the DBA team that they should run a roll-out. Neither of these
are wonderful options.

## Motivation

   As a maintainer of core, company-level cookbooks,
    I want to release cookbook updates,
    so that I can deploy changes quickly.

With that said, a more specific case that isn't currently handled well:

The Database team owns MySQL and uses Chef to deploy it along with related configs
and tools. The Monitoring team owns Collectd, which is deployed to every server
in the organization, and they are responsible for configuring collectd and deploying
new versions of it as needed. The core team owns ntpd and is responsible for its
configuration.

All teams want to follow the snapshot-based approach where they have a mono-repo
of their own cookbooks with a few shared cookbooks pulled in via dependencies.
When a team wants to do a release they run `chef update` to recompile their
policy, and then use `chef push` to roll it out to each environment in sequence
(with time in-between for testing et al). The teams also do not want to have to
ask permission from any other team when deploying new versions of a service they
are responsible for.

This combination of a snapshot-based workflow without explicit team coordination
is not currently an easy thing to do with the policy systems.


## Specification

The proposed solution to the motivation described above is to allow a more composable form of policy which would be able to optionally include other policies inside it.

This could be done with the addition of a ```include_policy``` directive, an example of which is shown below:

```ruby
include_policy "base", git: "github.com/myorg/policies.git", path: "foo/bar/baz.lock.json"
```

The ```include_policy``` directive will support three sources for policies: 

* ```git```, with the following parameter being the URL to a Git repository and a path parameter specifying the location of the file within the repository
* ```server```, with the following paramater being set to a Chef server URL, a policy_name paramter and a policy_revision_id parameter.
* ```local```, with the following parameter being a path to a file on disk.

When the ```chef update``` command is used to apply any changes to a policyfile containing the ```include_policy``` directive, any cookbook locks from the lockfile of the included policyfile will be pulled into the parent policy before its own .lock file is computed.

When included policies come from a ```git``` source, the SHA of the commit at the time the included lockfile was first pulled into the parent will be stored in the parent lockfile and used when the included Lockfile must be reprocessed. This ensures that only the policyfile for which the update command was called has changed. Similarly, when included policies come from a ```server``` source, the revision id of the included lockfile will be stored in the parent lockfile. In the event of policy files being included from a ```local``` source, this guarantee cannot be given and the latest Lockfile for the included policy will be used.

Essentially what this means is that the parent .lock file is computed from the merging of the following:

* Data contained in the parent policyfile's .rb file
* Computed cookbook locks from the lock files for all policies specified with an ```include_policy``` directive.

The single fused lockfile produced by the above would then be uploaded to the Chef server as normal, and would function as a single Policy.


## Problems

The principal potential issue with this approach is that because we are pulling cookbook locks from a number of included cookbooks, it is necessary for all included policy Lockfiles to be re-scanned upon regeneration of the parent Policyfile, so that the full set of cookbook locks and constraints can be examined and merged. Although using the ```git``` source to include Policies will mean that the same commit SHA is used every time to rescan the included Lockfile and the ```server``` source will always ensure the same revision ID is used, when the ```local``` source is used we have to use whatever the current Lockfile present on disk is. This means that we cannot guarantee it has not changed since the last time it was scanned.

## Downstream Impact

This solution would ideally not affect any tools which use existing policyfile behaviour, as the use of a single policyfile and all API calls and tools surrounding it would be unaffected - the changes here would be to how Policyfiles are compiled and updated.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
