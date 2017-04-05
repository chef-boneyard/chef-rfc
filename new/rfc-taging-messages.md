---
RFC: unassigned
Author: JJ Asghar <jj@chef.io>
Status: Draft
Type: Process
---

# Tagging Messages

In order to search and filter messages sent via email or discourse, tagging of
the subject line would be ideal. There is a standard practice in the [OpenStack
community][openstack] to use `[project]` to help filter on the project you
find interesting. I would like to take this and add this practice for projects to our
messaging system for general topics.

## Motivation

    As someone who wants to help categorize their messages in discourse or email,
    I want to add a [general topic] to the subject line of the message,
    so that the correct audience can see what I'm trying to communicate.

## Specification

We will need to write up a document or policy to help educate the public on using
subject tagging. This document should be living and be able to be added to and removed from.
It may be worth adding a second RFC to this with a listing of possible tags to help
focus on `[general topic]`s.

For instance, topics may include, but not limited to:
- `[cookbook]` - for general discussions of cookbooks and updates and announcements
- `[aws]` - for general discussions for the `aws` ecosystem
- `[openstack]` - for general discussions for the `openstack` ecosystem
- `[kitchen]` - for general discussions for `kitchen` plugins and questions
- `[knife]` - for general discussions for `knife` plugins and questions

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

[openstack]: https://wiki.openstack.org/wiki/MailingListEtiquette
