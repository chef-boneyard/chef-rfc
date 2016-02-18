---
RFC: unassigned
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Standards Track
---

# Multiple Policyfiles and Teams

Policyfiles allow powerful new workflows around cookbook management, but one
area they are currently lacking is in dealing with mutli-team organizations.

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

## Specification

A solution for this is to use multiple, decoupled policies on the same node.
This can be done today by using two different node names on the same machine,
each with their own policy. While workable, this solution is inelegant and
frustrating to manage.

This could be done more directly by allowing the `policy_name` on a node to be
set to an array, running each policy in isolation in order:

```bash
$ chef-client --policy-name one,two
Converge policy one
# ...
Converge policy two
# ...
```

Any data that is server-resident could be shared between runs (eg. node
attributes), but everything else (resource collection, cookbook collection)
would be reset between policies. An error in one policy would abort the run,
meaning later policies would never get run.

## Downstream Impact

Any tooling that consumes node data and expects `policy_name` to be a single
string would need to be updated.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
