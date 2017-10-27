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

When the ```chef update``` command is used to apply any changes to a policyfile containing the ```include_policy``` directive, any cookbook locks, attributes and runlists from the lockfile of the included policyfile will be pulled into the parent policy before its own .lock file is computed. Please see the "Merges and Conflicts" section for how duplicate or conflicting items in any of these categories are handled.

When included policies come from a ```git``` source, the SHA of the commit at the time the included lockfile was first pulled into the parent will be stored in the parent lockfile and used when the included Lockfile must be reprocessed. This ensures that only the policyfile for which the update command was called has changed. Similarly, when included policies come from a ```server``` source, the revision id of the included lockfile will be stored in the parent lockfile. In the event of policy files being included from a ```local``` source, this guarantee cannot be given and the latest Lockfile for the included policy will be used.

Essentially what this means is that the parent .lock file is computed from the merging of the following:

* Data contained in the parent policyfile's .rb file
* Computed cookbook locks from the lock files for all policies specified with an ```include_policy``` directive.

The single fused lockfile produced by the above would then be uploaded to the Chef server as normal, and would function as a single Policy.

## Problems

The principal potential issue with this approach is that because we are pulling Policyfile elements from a number of included cookbooks, it is necessary for all included policy Lockfiles to be re-scanned upon regeneration of the parent Policyfile, so that the full set of Policyfile elements can be examined and merged. Although using the ```git``` source to include Policies will mean that the same commit SHA is used every time to rescan the included Lockfile and the ```server``` source will always ensure the same revision ID is used, when the ```local``` source is used we have to use whatever the current Lockfile present on disk is. This means that we cannot guarantee it has not changed since the last time it was scanned.

A secondary problem with this approach is the question of how to handle conflicting cookbook locks, runlists or attributes, and the merging of non-conflicting items with the same name. The approach taken to solving this problem is detailed in the next section "Merges and Conflicts".

## Merges and Conflicts

Because the approach taken in this RFC permits one of more levels of policy includes, we must expliclty address the behaviour to be implemented in two cases:

* Merge - When a Policyfile element must be merged with another but *no* conflict is present
* Conflict - When a Policyfile element must be merged with another but a conflict *is* present.

In approaching this problem, I have  taken from the original intent of Policyfiles, which is very much that what you specify in a policyfile is what you should expect to get on your node.

For that reason, this RFC recommends a very simple approach to merging policyfile elements and resolving conflicts.

If the necessary elements (for example several runlists from a base policy and policies that it includes) can be merged without any conflicts occuring, the merge will be done additively starting from the furthest "branch" policy. Ie, all elements of a particular type in included policies will be merged with elements of the same time in the base policy which includes them.

In the event that merging runlists from multiple Policyfiles results in duplicate entries, these will be left in place and deduplicated by Chef client as is currently the case with runlists from other sources such as roles.

In the event of any conflicts occuring, this RFC makes it explicitly clear that we will *not* attempt to resolve them. When a conflict occurs, this will be surfaced as an error at Policyfile compilation time, and an error message showing the conflicting elements and their locations will be shown.

There are several foreseeable potential conflicts I will highlight here explicitly where we will not attempt to resolve the conflict, but will rather return an error (please note, this list is illustrative and not exclusive):

* Conflicting dependant cookbook versions (ie one Policyfile depends on version 1.2.4 and another on 1.2.5)
* Conflicting values for Policyfile attributes
* In the case of Policyfile attributes which have an array as their value, the arrays will not be merged but rather one array will overwrite the other (whichever was included last will win, essentially)
* An include loop where a policy includes a second policy which in turn includes the first policy.

Essentially, we will only merge elements from Policyfiles where we can be sure that we are not overriding something specified in another Policyfile (ie we can safely combine two sets of cookbook locks if the dependencies do not clash). My approach to this RFC is that you should never have to be surprised by the effect of including another Policy, and it should not be able to change the behavior of a Policyfile which includes it. Please see the "Example" section following this one for an example of a policy including another, and the resulting merged policy.
 
In an ideal world, "Base" policies which include other policies would be absolutely minimal and only contain ``include_policy`` statements, but in the event that this is not the case, the principle of least surprise should still apply. 

## Example

This section demonstrates a base Policyfile which includes another simple Policyfile, and shows the resulting merged lockfile.

Here we have our base policy, Myapp.rb, where we're using an internal supermarket to specify that we want one cookbook called ```mycookbook``` in our runlist, we're specifying an attribute, and we're including a policy called ```base```
```ruby
name "myapp"

default_source :supermarket, "https://mysupermarket.mycompany.com"

run_list "mycookbook::default"

cookbook "mycookbook"

default["mycookbook"]["version"] = '1.7.0'

include_policy "base", git: "github.com/myorg/policies.git", path: "policies/base.lock.json"
```

Next, here we have the ```base.lock.json``` file we're including with the ```include_policy``` directive above. This policy has one cookbook, called ```base``` in its runlist, which in then depends on the ```users``` and ```sudo``` cookbooks. It also specifies some attributes.:

```
{
  "revision_id": "abc1234abc1234abc1234abc1234abc1234abc1234abc1234",
  "name": "base",
  "run_list": [
    "recipe[base::default]"
  ],
  "cookbook_locks": {
    "base": {
      "version": "0.1.0",
      "identifier": "abc1234",
      "dotted_decimal_identifier": "1234.1234.1234.1234",
      "cache_key": "base-0.1.0-mysupermarket.mycompany.com",
       "origin": "https://mysupermarket.mycompany.com:443/api/v1/cookbooks/base/versions/0.1.0/download",
       "source_options": {
          "artifactserver": "https://mysupermarket.mycompany.com:443/api/v1/cookbooks/base/versions/0.1.0/download",
          "version": "0.1.s"
        }
      }
    }   
  },
  "default_attributes": {
    "base_config": {
      "config_a": "12345",
      "config_b": "abc123"
    }
  },
  "override_attributes": {

  },
  "solution_dependencies": {
    "Policyfile": [
      [
        "base",
        "= 0.1.0"
      ],
      [
        "sudo",
        "= 3.5.3"
      ],
      [
        "users",
        "= 5.1.0"
      ],
      "base (0.1.0)": [
        [
          "users",
          ">= 0.0.0"
        ],
        [
          "sudo",
          ">= 0.0.0"
        ]
      ]
    }
  }
}
```

Finally, after we've run ```chef update Myapp.rb```, here is the resulting merged ```Myapp.json.lock``` that would be uploaded to the Chef server:

```
{
  "revision_id": "xyz12345xyz12345xyz12345xyz12345xyz12345xyz12345",
  "name": "myapp",
  "run_list": [
    "recipe[base::default,cookbook::default]"
  ],
  "cookbook_locks": {
    "base": {
      "version": "0.1.0",
      "identifier": "abc1234",
      "dotted_decimal_identifier": "1234.1234.1234.1234",
      "cache_key": "base-0.1.0-mysupermarket.mycompany.com",
       "origin": "https://mysupermarket.mycompany.com:443/api/v1/cookbooks/base/versions/0.1.0/download",
       "source_options": {
          "artifactserver": "https://mysupermarket.mycompany.com:443/api/v1/cookbooks/base/versions/0.1.0/download",
          "version": "0.1.0"
        }
      }
    },
    "mycookbook": {
      "version": "1.7.0",
      "identifier": "qrst5678",
      "dotted_decimal_identifier": "5678.5678.5678.5678",
      "cache_key": "mycookbook-1.7.0-mysupermarket.mycompany.com",
       "origin": "https://mysupermarket.mycompany.com:443/api/v1/cookbooks/mycookbook/versions/1.7.0/download",
       "source_options": {
          "artifactserver": "https://mysupermarket.mycompany.com:443/api/v1/cookbooks/mycookbook/versions/1.7.0/download",
          "version": "1.7.0"
        }
      }
    }   
  },
  "default_attributes": {
    "base_config": {
      "config_a": "12345",
      "config_b": "abc123"
    },
    "mycookbook": {
      "version": "1.7.0"
    }
  },
  "override_attributes": {

  },
  "solution_dependencies": {
    "Policyfile": [
      [
        "base",
        "= 0.1.0"
      ],
	  [
	    "sudo",
	    "= 3.5.3"
	  ],
	  [
	    "users",
	    "= 5.1.0"
	  ],
      "base (0.1.0)": [
        [
          "users",
          ">= 0.0.0"
        ],
        [
          "sudo",
          ">= 0.0.0"
        ]
      ],
	  "mycookbook (1.7.0)": [

	  ],
    }
  }
}
```

## Downstream Impact

This solution would ideally not affect any tools which use existing policyfile behaviour, as the use of a single policyfile and all API calls and tools surrounding it would be unaffected - the changes here would be to how Policyfiles are compiled and updated.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
