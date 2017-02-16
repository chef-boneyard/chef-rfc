---
RFC: 81
Title: Chef Release Cadence
Author: Tim Smith <tsmith@chef.io>
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Accepted
Type: Informational
---

# Chef Release Cadence

Chef follows [Semantic Versioning](https://semver.org/) for releases. Major
versions (eg. 11.x -> 12.x) will include backwards-incompatible changes, minor
versions (eg 12.1 -> 12.2) will include new features and bug fixes but will be
backwards-compatible to the best of our ability. Patch versions are governed
by [RFC 47](rfc047-release-process.md).

Chef feature releases are promoted to the stable channel once per month. It is
expected that this occur during the second week of the month unless
circumstances intervene. Additional patch releases for a given feature release
may be promoted if critical issues are found.

ChefDK is released once per month. It is expected that this occur during the
fourth week of the month unless circumstances intervene.

Both Chef and ChefDK will prepare a release candidate before the target release
date, usually in the week before but at least three business days before release.

The Chef release in April of each year is a major version release, which will
contain backwards-incompatible changes. A reminder notice will be sent via
Discourse and Slack in March that will summarize the changes slated for the release.

## Rationale

Monthly releases help ensure we get new features and minor bug fixes out to Chef
users in a timely fashion while not overloading the maintainer teams.
Similarly, offsetting the Chef and ChefDK releases allows the full attention of
the Chef development team on each of those releases and leaves time for any
potential hot fixes or follow-up.

Major releases in April avoids releasing during winter holidays, summer
vacations, ChefConf and Chef Summits.

## Cookbook Support

The latest version of community cookbooks are required to support only the latest 6
months of chef-client versions.  This window does not reset on a major version release
so that the prior major version track is supported for a 6 month window.

As an example, in May we will typically drop 14.1.0 and both 14.0 and 14.1 will be
supported.  The version of 13 release 6 months prior should be 13.8 and will still
be supported so that 6 versions will be considered current (13.8 through 13.11 plus
14.0 and 14.1).  At that point community cookbooks may choose to start using 13.8
features and drop support for versions prior to 13.7

## Ruby Cadence

Since the ruby language itself releases new minor versions over the Christmas holidays,
the April major release of Chef Client should include the minor revision of ruby which
landed the prior Christmas.  Combined with the 6 month sliding window for cookbook
support that also implies that when the prior major release of the client falls off
of community cookbook support that the prior minor release of ruby will also fall
off of community cookbook support (including the cookstyle gem and related tooling).

The release of the new major version may be delayed if there are show stopping bugs
in the released version of ruby (we assume that 4 months will be enough time for
major regressions in the core language to be addressed, but that is an external
dependency).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
