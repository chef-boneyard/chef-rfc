---
RFC: unassigned
Title: Adding sleep to deprecation notices
Author: JJ Asghar <jj@chef.io>
Status: Draft
Type: Process
---

# Adding sleep to deprecation notices

This RFC is to add a progressively longer sleep time per `Deprecated` notice.
Most users of software don't pay attention to deprecation notices, and can
get bit by the removing resources in later versions of software. If we
something that can get progressively more and more noticeable we can gently
nudge our downstream users to move away from these resources. This has been
inspired from a [blog post][blogpost] about how a C++ library was
deprecated with a more and more progressive sleep for compile time.

## Motivation

    As a developer of Chef or downstream user of Chef,
    I want to make sure I am using the supported resources,
    so that I have the best tool for my job.

## Specification

Adding a simple sleep to the deprecation notice in ruby is straight forward:

```ruby
sleep(num_secs)
```

A suggested progression of the increases in time can be:

| Notice         | Time       |
|:--------------:|:----------:|
| First notice / 2 releases away   | 1 second   |
| Second notice / 1 release away   | 3 seconds  |
| Third notice / 0 release away    | 5 seconds  |
| Fourth notice / -1 release away  | 10 seconds |

## Downstream Impact

This will cause longer Chef runs per resource that is being used. This is the
expected behavior of this RFC. Over time seeing the Chef run to take longer
and longer using deprecated resources will nudge the Chef downstream users
to move to non-deprecated resources.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

[blogpost]: FIND THIS BLOGPOST, I THINK IT WAS ON HACKERNEWS on 2017-10-16, but I've lost the link.
