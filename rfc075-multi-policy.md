---
RFC: 75
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Accepted
Type: Standards Track
---

# Multiple Policyfiles and Teams

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

## Implementation

The major implementation change would be altering `Chef::Client#build_node` to
yield a node object to a block rather than setting it as a singleton. This
will allow running the block (containing all the same logic as we have now for
running the converge) multiple times.

Given a Chef run like `chef-client --policy-name one,two` we would do the
following:

1. Initialize the client up until `load_node` in `Chef::Client#run` as per normal.
2. When the policy builder checks which implementation to use it would see that
   multi-policy run has been requested.
3. It would build the first node object as per normal except that the cookbook
   synchronizer would sync to `Chef::Config[:file_cache_path]/cookbooks_one` or
   similar. This may require some work on the `Chef::FileCache` code.
4. Before yielding the node out to the run block to policy builder code calls
   fork. The original process blocks, while the subprocess yields the node object
   and runs the first converge.
5. The first converge finishes, control returns from the run block. The policy
   builder would save node attributes to a file and exit.
6. Control resumes from where the original process blocked in step 4. It checks
   that the child exited with 0, reads in the saved node attributes and updates
   the node object, and then GOTO 3 to sync the next cookbooks and run the next
   converge.
7. When the last policy has finished, control flows back to the `#run` method.
   It would pick back up at `run_status.stop_clock` to do the end-of-run stuff.

If a multi-policy run has an exception we would serialize it to JSON, return
an error exit code from the sub-process, and have the main process bubble the
(fake) exception back up the chain.

## Problems

The biggest issue is that this makes no attempt to prevent teams from stepping
on each others. If one policy has `package 'foo' { version '1.0' }` and another
has `package 'foo' { version '2.0' }` it will oscillate between versions without
warning. This is probably not a big issue as today Chef will do the same thing
in similar situations (i.e. if the names don't match but `package_name` does).
Weird stomping could also occur if two policies are trying to "own" a service
like Nginx and using two different versions of the same cookbook. These are all
deemed problems out of scope for a technical solution. When using mutli-policy
workflows, external synchronization (i.e. talking to each other) will be needed
to establish some idea of who is responsible for what.

Because each converge will happen with its own (forked) copy of the run context,
resources from one policy with not be able to see those from any other. This
means cookbooks like Zap will likely be non-functional. It also doesn't help
with situations where the interface from one team to another is a resource or
helper library, those situations will still require a single policy with all
the snags that implies today.

Overall the added fork involved in multi-policy converges may produce additional
unforeseen complications, such as cookbooks that register event handlers or other
callbacks that need to "live" past the converge phase. We could ameliorate this
by saying the first (or last?) policy will be run without that extra fork and
so can interact with those pieces of the run. This still leaves that "slot" as
special though, and may just kick the can down the road as far as contention.

## Other Possibilities

The main suggestion for an alternate way to handle this would be to combine
multiple Policyfiles into a single compiled policy somehow. These solutions all
suffer from a shared flaw though, that individual teams would be unable to use
the "compile, push staging, push prod" workflow that Policyfiles support today.
This "loose-coupling" approach may be workable in some places where there are
strong release controls and tooling, but will not support the full Policyfile
workflow without extensive team coordination.

## Downstream Impact

Any tooling that consumes node data and expects `policy_name` to be a single
string would need to be updated.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
