---
RFC: unassigned
Title: Test Kitchen Multi-Execution
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Standards Track
---

# Test Kitchen Multi-Execution

Since the very early days of Test Kitchen there has been a desire to use it to
test multi-server operations. Several attempts have been made over the years,
including `kitchen-nodes`, manual orchestration of the Vagrant plugin, and most
recently `kitchen-terraform`. All of these attempts have yielded some success,
but generally come via major caveats or restrictions. A unified path to true,
generic multi-server testing has been talked about for years, but only recently
have we all circled down on a design that seems workable over the long term.
Test Kitchen is not normally covered by the Chef RFC process, but given both
the scope and importance of the feature, an exception is being made.

## Motivation

    As an operations developer,
    I want to test multi-server interactions,
    so that I have confidence in cluster-oriented CM code.

And a more specific use case that is also rolled in here:

    As a Chef user,
    I want to test cookbook upgrades and idempotence,
    so that I have confidence in my Chef code.

## The Problems

To start with, why is this a difficult problem? This is written based on Test
Kitchen as it stands today and may become out of date in the future.

1. Test Kitchen is built around the concept that one instance equals one server,
   and that one instance equals one "thing" being tested.
2. Instances do not know about each other, either for Chef data integration or
   for things like ensuring networking is set up between instances. For some
   drivers, notably Vagrant, this can be ignored, but in the general case it is
   a factor.
3. Test Kitchen has a fairly limited state machine and most scripted control has
   to be external as plugins can't extend that level of functionality. For
   example if you want to run instances in a particular order or converge a
   specific instance twice with different parameters, that is best achieved
   through a Bash script, `Makefile`, `Rakefile`, etc.

## The Basic Design

[ed: I do not like the term "supersuite", please come up with something better
and tell me. maybe "multisuite"?]

The core of the new system is a configuration section called "supersuites". Each
supersuite contains a set of steps to be run in a particular order. For example:

```yaml
platforms:
- name: centos-7

suites:
- name: web1
  run_list:
  - role[web]
- name: web2
  run_list:
  - role[web]

supersuites:
- name: web
  steps:
  - converge web1
  - converge web2
  - verify web1
```

When you run `kitchen test web-centos-7` on this configuration, it will run the
steps in the order listed, aborting if any step fails.

This is combined with a new lifecycle phase in the Test Kitchen state machine
for instances before `create` called `gossip`. This passes the driver plugin
data about which instances will participate in the supersuite so it can set any
instance state flags it wants to be used later in the `create` phase. There will
also be an optional `late_gossip` phase added after `create` but before `converge`
that is also passed all the instance data for any post-creation fixups. Together
these phases ensure that instances will be able to see each other on the network
and will have access to any required shared resources.

## Vocabulary

### Supersuite

A supersuite is a configuration section [ed: better word?] which has a name and
a list of steps to execute. Each supersuite includes one or more suites.

### Superinstance

A superinstance is the combination of a supersuite and a platform, and represents
the collective of all the instances which correspond to the suites in the
supersuite.

## More Details

If this new `supersuites` configuration section is present, Test Kitchen switches in to
multi-server mode where the instance matrix is based on "platforms x
supersuites" (rather than platforms x suites as normal). Multiple supersuites
can be present, though a suite can only be a member of a single supersuite to
allow the existing instance state machine to remain mostly unchanged. A single
suite can also be referenced multiple times to allow for upgrade/downgrade
testing and idempotence testing.

The step syntax is built to be similar to the `kitchen` command line utility to
make it easier to get started with for experience Test Kitchen users. It consists
of a string matching `"<action> <suite_name>"`. Actions use the familiar Test
Kitchen names: `converge`, `verify`, and `destroy`. All instances that are a part
of the supersuite are created together during initialization, so this step does
not need to be explicitly stated. The `destroy` step action is present to allow
for testing cluster failover, but any existing instances will be destroyed
during a `kitchen destroy` or `kitchen test` command matching the existing
Test Kitchen semantics.

Suite names and supersuite names cannot overlap, doing so will be a configuration
error.

## Step Types

### `converge`

A `converge` step runs a provisioner plugin on an instance. With no other
options this is equivalent to running `kitchen converge <instance_name>`.
Additional configuration options can be specified in the step and will be merged
in to the instance configuration for only that `converge` action. For example:

```yaml
supersuites:
- name: web
  steps:
  - converge web1
  - step: converge web1
    attributes:
      version: 2
    run_list:
    - recipe[other]
  - step: converge web1
    provisioner_config:
      name: shell
      script: init.sh
  - verify web1
```

Driver configuration cannot be set like this as `create` runs in its own phase
outside of the `converge`.

### `verify`

A `verify` step runs a verifier plugin on an instance. With no other options
this is equivalent to running `kitchen verify <instance_name>`. Additional
configuration options can be specified in the step, in same way as the
`converge` step. Unlike normal Test Kitchen usage, this will not execute a
`converge` phase if the instance is not already converged. The `setup` phase will
be run for any instance not already in that state.

By default the supersuite name will be used in place of the suite name for
finding the test files, but this can be overridden by a configuration option:

```yaml
supersuites:
- name: web
  steps:
  - converge web1
  - step: verify web1
    name: other
```

### `destroy`

A `destroy` step runs the driver teardown on an instance. With no other options
this is equivalent to running `kitchen destroy <instance_name>`. As with
`converge` and `verify`, additional configuration options can be added to the
step if needed.

This step is intended to be used much less frequently than the other two and
is for testing things like automated failover or cluster recovery.

[ed: do we also need a step for creating an instance mid-test?]

## Commands

### `kitchen create`

The `create` action on a superinstance will run the `gossip`, `create`, and
`late_gossip` phases on all instances that are a part of the supersuite. If no
input is given, it will process all superinstances in the order specified in the
configuration. If an input string is given and does not match any
superinstances, it will be checked against normal instances and if any match
they will run a normal `create` action without the `gossip` and `late_gossip`
phases.

### `kitchen converge`

The `converge` action on a superinstance will run all `converge` supersuite
steps in the order specified in the configuration. If no input is given it will
process all superinstances in the order specified in the configuration. If an
input string is given and does not match any superinstances, it will be checked
against normal instances and if any match they will run a normal `converge`
action.

### `kitchen verify`

The `verify` action on a superinstance will run all `verify` supersuite steps in
the order specified in the configuration. If an instance is not in the
`converged` state, it will not be converged like with normal Test Kitchen
operation [ed: should verify on an unconverged instance be an error?]. If any
`destroy` action steps are present in the superinstance, this will warn that
`destroy` steps are not being processed. If no input is given it will process
all superinstances in the order specified in the configuration. If an input
string is given and does not match any superinstances, it will be checked
against normal instances and if any match they will run a normal `verify`
action.

### `kitchen test`

The `test` action on a superinstance will run all supersuite steps in the order
specified in the configuration. As with normal Test Kitchen, this will include
running the `create` action, and destroying all the instances based on the value
of the `--destroy` command line option. The destroy at the end is an all-or-
nothing, so it will either destroy all instances in the superinstance or leave
them all. A new command-line option will be added, `--no-recreate` to suppress
the `destroy` action before the `create` [ed: should this apply to non-
supersuite `kitchen test` too?]. The `--no-recreate` flag will allow for
slightly faster testing when using `destroy` step actions as this is the only
way to run those. If no input is given it will process all superinstances in the
order specified in the configuration. If an input string is given and does not
match any superinstances, it will be checked against normal instances and if any
match they will run a normal `test` action.

### `kitchen login`

The `login` action is mostly unchanged from normal Test Kitchen. Running `login`
on a superinstance will display an error message explaining that it can only be
used on specific instances, and will show the names of the instances in the
superinstance.

### `kitchen list`

By default, `kitchen list` with no input when supersuites are present will
display only the superinstances. Running `kitchen list --instances` will display
the state of the underlying instances, using the same output as normal `kitchen
list`. If an input string is given and does not match any superinstances, it
will be checked against normal instances and if any match they will be displayed
as normal.

### `kitchen package`

The `package` action on a supersuite is undefined at this time.

## Unaddressed Problems

Executing two or more supersuites concurrently is explicitly not going to be
supported for the foreseeable future. Executing multiple steps within a single
supersuite concurrently may be added, but not in the first version. A suggested
syntax for this is:

```yaml
supersuites:
- name: web
  steps:
  - concurrent:
    - converge web1
    - converge web2
  - verify web1
```

Further exploration of the completed feature will be required to assess the
impact of concurrent execution on the multi-server model, but it should be
viable.

This proposal does not explicitly address making Chef search work between
instances, this feature should be added to the `chef_solo` and `chef_zero`
provisioners in Test Kitchen but does not require any new structural elements
outside of this design.

Including both single and multi-server tests in the same Test Kitchen
configuration is possible but not easy to use as most commands will run in
"supersuite mode" if any supersuites are present in the configuration. This can
be addressed in a somewhat verbose manner by wrapping any single server tests in
a supersuite that happens to consist only of `converge <suite>` and `verify
<suite>`.

## Downstream Impact

All Test Kitchen drivers that want to support multi-server testing will need to
be updated to include an implementation of the gossip phase, even if it might be
a no-op in some cases.

As the new functionality is only activated if one or more supersuites exist in
the configuration, existing Test Kitchen users should be unaffected unless they
opt in to the new features.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
