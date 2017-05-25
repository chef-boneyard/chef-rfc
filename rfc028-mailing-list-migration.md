---
RFC: 28
Title: Mailing List Migration
Author: Julian C. Dunn <jdunn@aquezada.com>
Status: Completed
Type: Informational
---

# Migration Status - Complete

This RFC was accepted and the work proposed herein has been completed.  The mailing list was cutover from http://lists.opscode.com to https://discourse.chef.io on 13 October 2015.

The details below are being maintained to provide insight on motivation for the switch and for other historical purposes.

# Mailing List Migration

The Mailing Lists have been migrated to Google Groups.

* [chef@lists.chef.io](https://groups.google.com/a/lists.chef.io/forum/#!forum/chef)
* [chef-dev@lists.chef.io](https://groups.google.com/a/lists.chef.io/forum/#!forum/chef-dev)

Details about the migration can be found the blog posts about the migration:

* [Our mailing lists have moved!](https://www.chef.io/blog/2015/02/10/our-mailing-lists-have-moved/)
* [Mailing List Migration](https://www.chef.io/blog/2015/02/04/14389/)

This RFC proposes the migration of all existing Chef mailing lists
(namely, `{chef,chef-dev}@lists.opscode.com`) to 
[Discourse](http://www.discourse.org/).  Discourse is a modern web application
for discussion forums that can also be used like a mailing list with 
subscriptions and mail-in responses and posts.

## Motivation

    As a user of Chef,
    I want the Chef mailing lists on a reliable and easy-to-use platform,
    So that I can easily collaborate with others in the community.

    As a system administrator working at Chef Software, Inc.,
    I want to retire the old mailing list system & not manage one in-house,
    So that I can focus my attention on higher-priority infrastructure issues.

## Specification

This RFC proposes to migrate the existing Sympa-run mailing lists at
`lists.opscode.com` to [Discourse](http://www.discourse.org/).

There are only two mailing lists of note: `chef` and `chef-dev`. The
desired group names would be the same, but if `chef` is already taken,
we propose that the new group name become `chef-users`.

### Subscriber Migration

All existing subscribers on the current mailing list(s) would be
migrated to their counterparts on Discourse.

### Archive Migration

Chef Software, Inc. will make a reasonable attempt to migrate the
archives of each of these mailing lists out of Sympa, potentially
using a tool like 
[sympa-data-exporter](https://github.com/cdelacroix/sympa-data-extract) and into 
Discourse.

However, we recognize that this may not be feasible. If it is not,
we will simply create a static HTML site of the old Sympa archives
and publish that.

## Rationale

The existing mailing list system at 
[lists.opscode.com](http://lists.opscode.com), Sympa, is very old and fragile.
Additionally, it is not a delightful experience for end-users of
Chef, who must navigate a non-intuitive interface to subscribe to,
unsubscribe from, and view the archives of the Chef user and developer
mailing lists.

There have been [previous efforts dating to 2012](http://archive.lists.chef.io/sympa/arc/chef-dev/2012-06/msg00029.html) to 
try and migrate off Sympa, but none have succeeded thus far.

In February, 2015, we attempted a move to Google Groups.  This failed because we 
immediately exceeded the allowable number of messages for our group.  Our group 
is tied to our business google apps account which should have the limit 
increased in April of 2015 but there's no guarantee that the system will then 
support our group.  It's best not to proceed with Google Groups.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
