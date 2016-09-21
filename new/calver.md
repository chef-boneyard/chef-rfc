---
RFC: unassigned
Title: Calender Versioning for Chef
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Standards Track
---

# Calender Versioning for Chef

Since its inception, Chef has followed the structure of [Semantic Versioning](http://semver.org/)
(SemVer). This way of expressing API compatibility has been
popular in the software world for many years, and is a widely understood and
well-liked standard. Unfortunately as Chef has grown both in scope and user
base, this is increasingly difficult to manage. This RFC proposes migrating to
a [Calender Versioning](http://calver.org/) (CalVer) standard instead.

## Motivation

    As a Chef maintainer,
    I want to improve Chef over time,
    so that previous design decisions do not cause an undue burden on maintainers.

    As a Chef user,
    I want to upgrade Chef,
    so that new features and bug fixes can be used.

## What Is CalVer?

The likely-biggest user of CalVer is the Ubuntu project. Here we can see some
of the defining characteristics of CalVer. They release on a relatively fixed
schedule (twice a year) and feature deprecation plans are expressed in terms of
timelines instead of major version bumps. Ubuntu also uses the timestamp of the
release to form the version number, though other CalVer projects forgo this in
favor of a more traditional-looking version number.

## Why CalVer?

SemVer is based on the idea that a release is either "compatible" or
"incompatible" with the prior release. If it's compatible then it's a minor or
patch bump, otherwise it's a major bump. Major bumps are generally scary because
they mean a user may need to do some kind of porting work before upgrading. The
root problem is that as a project grows, it is increasingly hard to say what is
an API change and what isn't. The surface area of a project grows rapidly,
especially in something like Chef with a mix of DSLs, internal APIs, and command
line tools (without even starting in on the Chef Server APIs). Major version
bumps and the ensuing porting work make users unhappy, so as a project we try
to minimize compatibility breaks.

## The Chef 13 Problem

While all the decisions Chef has made with respect to versioning and compatibility
have come from the best of intentions and I would stand behind all of it as the
right move for the time, we now have a looming issue: Chef 13 _(cue spooky music)_.
Chef 12.0.0 was released in December 2014, meaning at the time of writing it is
rapidly approaching two years old. In those two years we have made many improvements
to the codebase and moved to deprecate numerous old mis-features and bad APIs.
We are now faced with the prospect of Chef 13 representing an even bigger
compatibility break than Chef 12 was, and that was a long slog to get the
community to upgrade. While it may be too late to avert this Chef 13 calamity,
if something isn't done it is likely the cycle will repeat and Chef 14 will have
all the same problems.

## How Does CalVer Help?

Chef has already largely moved to a calendar-based release cycle, specifically
monthly releases. Currently all deprecation warnings are phrased that we will
drop the hammer in the next major version in accordance with SemVer. With a
CalVer standard we could instead create a timeline for deprecations, where a
given feature will be maintained for X releases (months) and then removed along
with a slowly ratcheting warning scheme (passive warning, active warning, error).
This would help spread the workload of upgrades out over a longer period of time,
avoiding the "major version cliff" we are currently facing. The downside is,
unfortunately, the same as the upside; this would mean that moving from one
monthly release to another would involve more risk than it currently does. I
think this can be reduced with good testing tools which I'll cover below, but
not every Chef user writes tests and this will bite a non-zero number of them
no matter how much we advertise deprecations.

### Date-Based Versions

While not required to follow a CalVer-style deprecation workflow, date-based
version numbers provide a lot of useful information in an otherwise-opaque
integer field. The most common form for date-based version numbers is to use
`year.month` as the prefix, often expanded to `year.month.patch` to allow for
more than one release in a month if a bug fix is needed. This allows clear
understanding of how old any given release is, as well as knowing when a
specific future release will happen. This also aids in planning deprecation
cycles.

### LTS Releases

A possible side benefit of CalVer would be the ability to designate certain
releases as "long term support" in a similar way to the Ubuntu and RedHat projects.
This would help cookbook authors by providing a much more limited set of
releases that we expect community cookbooks to support while not leaving users
who need to be able to go longer between upgrades in the dark. Currently most
cookbooks either only test with the latest version of Chef or test with every
minor release. This either leads to sad users in the former case, or stressed
maintainers in the latter. Having a support policy like this wouldn't preclude
cookbooks from defining their own policy, but it would be a good starting point
for most community authors. If combined with date-based version numbers above,
it can make it very easy to tell if a release is LTS (eg. `x.0` or `x.6`).

The specifics of what constitutes "long term support" is left to another RFC.

## Upgrade Testing

As CalVer will make upgrades a more involved process for users, we will need to
address this with at least some level of tools and guidelines. Test Kitchen
already serves as a great nexus for integration and functional testing for Chef,
and is a natural fit for this kind of upgrade testing. The simplest option is
to offer a `kitchen` command line option or configuration flag to enable the
existing `treat_deprecation_warnings_as_errors` mode. As more deprecation
warnings are annotated with what version they will fire at, we can refine this
option to allow testing for future compatibility with a specific release.

## Specification

Starting with the next major release (i.e. Chef 13) we will
change Chef version numbers to a `year.month.build` format. The `year.month` for
a release is the date it is released, not when work is begun. If a monthly release
is missed, we will move on to the next version number. The `build` number retains
the same auto-bump semantics as it currently has.

Feature deprecations will be classified as either high-impact or low-impact.
High-impact deprecations will take place over 6 months, low-impact over 2 months.
The `Chef.log_deprecation` API will be amended to allow listing the target
version for a deprecation. The `treat_deprecation_warnings_as_errors` mode will
be amended to allow for a target release.

## Downstream Impact

This will have wide-reaching and likely-incalculable effects. By making this
switch with a "major version change" (even if that no longer caries the same
meaning), we will at least limit damage to existing gems and projects that
depend on `~> 12.0` or similar.

## Prior Art

As mentioned before, the biggest example is Ubuntu. As an OS, they don't have
the same concept of compatibility and deprecation as we do, but the overall
release structure is a good example.

In the Python world, Twisted and Django are examples of projects that have
segued from SemVer to CalVer with minimal community disruption. Both follow the
same concept of calendar-based deprecation cycles rather than using SemVer-major
releases. Twisted currently uses `year-2000.minor.patch` but will be moving to
`year.month.patch` shortly. Django uses a more tradition SemVer-y version number
but with a CalVer-based process underneath it.

As prior art specifically for the "major version cliff" problem, Python 3 is a
good example of how long it can take a community to re-stabilize. Fortunately
none of the deprecations we have encountered in Chef are at a similar scale to
Python 3, but the lesson is still there.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
