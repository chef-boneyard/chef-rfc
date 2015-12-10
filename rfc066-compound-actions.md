---
RFC: 66
Author: John Keiser <john@johnkeiser.com>
Status: Accepted
Type: Standards Track
---

# Actions With Inline Resources

In this proposal, we change the way in which inline resources are processed
to make actions that call each other clearer.

This is a backcompat break and requires a major version bump.

## Motivation

    As a Chef user,
    I want recipes defined in my actions to execute in order,
    So that I can predict what will happen.

## Specification

At present, when inline_resources is on and one action calls another,
the inner action is converged immediately:

```ruby
class X < Chef::Resource
  resource_name :x
  action :outer do
    execute 'echo before inner'
    action_inner
    execute 'echo after inner'
  end
  action :inner do
    execute 'echo inner'
  end
end

x 'hi'
```

In Chef 12, the resources execute in this order:

```
Recipe: (chef-apply cookbook)::(chef-apply recipe)
  * x[hi] action outer
    * execute[echo inner] action run
      - execute echo inner
    * execute[echo before inner] action run
      - execute echo before inner
    * execute[echo after inner] action run
      - execute echo after inner
```

This is unintuitive any way you slice it.

We suggest that the inner action simply become part of the compile phase of the outer action, and the entire resource collection is only converged once.

When this RFC is implemented, the order of execution will be:

```
Recipe: (chef-apply cookbook)::(chef-apply recipe)
  * x[hi] action outer
    * execute[echo before inner] action run
      - execute echo before inner
    * execute[echo inner] action run
      - execute echo inner
    * execute[echo after inner] action run
      - execute echo after inner
```

## Backwards Compatibility

This will be a backwards compatibility break for all resources that call other
actions and depend on the action running immediately. Thankfully, this is not
super common.

Here's a summary of some of the more common cases that will be affected or
unaffected. None of these are *extremely* common--actions calling other actions
is not endemic throughout all code--but it's common enough that many cookbooks
will have the potential to be affected.

### Affected Patterns

Here are some of the cases which might be adversely affected:

1. Action calls mixed with immediate checks

   Sometimes you depend on the effects of called action converging immediately.
   These cases can break:

   ```ruby
   action :recreate do
     action_delete
     if !File.exist?('/the_file')
       # Do something
     end
   end
   ```

   This is generally considered an antipattern in a recipe, and it should be
   considered an antipattern in a resource with inline_resources as well.

   Note that the effect is limited to actions that declare resources; if you
   call an action that does its work immediately, the order of operations will
   not change.

### Unaffected Cases

The impact is lessened because the two most common patterns for actions calling actions will not have an issue:

1. Action aliases or call chains

   Sometimes one action is an alias of another or sets a flag before calling
   another action. In these cases, the calling action does not depend at all
   on when the called action executes, so there's no issue:

   ```ruby
   action :purge do
     @purge = true
     action_clean
   end
   ```

   Call chains--calling one action after another--will be unaffected as well.

2. Purge-then-create

   Some resources cannot be updated and need to be recreated. It is common to
   do this by calling a cleanup action before doing the rest of the job, and
   this will be unaffected as well:

   ```ruby
   action :recreate do
     action_delete
     file '/create_the_thing'
   end
   ```

   Any method calls that do the actions *before* declaring resources or calling
   other recipes will be unaffected.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
