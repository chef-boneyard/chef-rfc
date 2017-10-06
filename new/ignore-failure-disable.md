---
RFC: unassigned
Title: Option to Disable Ignore Failure
Author: Jon Cowie <jcowie@chef.io>
Status: Draft
Type: Standards Track
---

# Option to disable Ignore Failure

This RFC proposes the addition of a configuration setting to ```client.rb``` which allows the administrator of a Chef organisation to disable usage of the ```allow_failure``` resource parameter on all cookbooks executed by that node.

## Motivation

    As a Chef  administrator,
    I want the option to disable ignore_failure
    so that users cannot write recipes which fail invisibly when they should instead be fixed

## Specification

This RFC proposes the addition of two new configuration parameters to be supported in client.rb / solo.rb.

```disable_ignore_failure``` will take a ```true/false``` value (defaulting to ```false```) and when set to ```true```, will cause any instances in recipes of ```ignore_failure``` to act as if ```ignore_failure``` had not been specified, and instead output a log line stating that ```ignore_failure``` was bypassed.

```disable_ignore_failore_log_level``` will specify the log level at which any instances of the above, when ```ignore_failure``` was skipped in a recipe, will be output to the logging subsystem. By default, this parameter will be set to ```Chef::Log.debug```

## Downstream Impact

This should not impact any downstream tools.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
