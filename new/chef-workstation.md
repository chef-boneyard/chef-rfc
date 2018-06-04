---
RFC: unassigned
Title: The Future of Chef Workstation
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Informational
---

# The Future of Chef Workstation

ChefConf 2018 saw the unveiling of both the `chef-run` command and a Chef Workstation
installer package containing it. This has lead to user confusion on two fronts.
First, the term "Chef run" (or "Chef client run") is already in very common use
in our community, so trying to communicate about `chef-run` has been tricky.
Second, having two installers (Chef Workstation and ChefDK) has resulted in a
lack of certainty about which should be used.

## Motivation

    As a Chef user,
    I want to use the new Chef functionality,
    so that I can manage machines/resources without Chef Server.

    As a Chef community member,
    I want to communicate with other Chef community members,
    so that I can share knowledge and answer questions.

## Specification

Addressing the issues in reverse order:

While the phrasing of "Chef Workstation" is probably better than "ChefDK", the
difference is not sufficient to warrant such a massive community pivot given
how long the ChefDK name has been in use and the fact that it doesn't seem to
be a major source of confusion (at least not in a way that would be solved by
"Chef Workstation"). As such the Chef Workstation installer will be discontinued
in favor of ChefDK.

In order to both reduce the naming collision and better integrate the tool with
the existing ChefDK CLI experience, the `chef-run` command will be moved to be
a subcommand of the `chef` CLI (a part of the `chef-dk` gem) named `chef target`.

The actual implementation of the `chef target` command could still be in its own
gem (name undetermined) if that is useful to the development team to improve the
agility of releases.

## Alternatives

### Keeping the "Chef Workstation" Name

If the improved clarity of purpose of the "Chef Workstation" package name is
something we want to keep, an alternate path would be to do the same `chef-run`
to `chef target` switch but then rename the ChefDK installers to Chef Workstation.
This presents significant switching costs to the community in the form of "what
happened to ChefDK?" and general confusion about the rename, given that ChefDK
has been used as a name for quite a long time now. But this could be overcome
with sufficient documentation and redirects of existing ChefDK-related pages.

In either case, the actual software in the installer is the same, the question
is is the improved branding of "Chef Workstation" worth the hit to users as we
switch over and people learn the new term.

If we go this route, we'll need to work out an upgrade strategy for existing
ChefDK users who may have `/opt/chefdk` paths in scripts and `~/.chefdk`
for installed secondary gems. This would likely involve a symlink from `/opt/chefdk`
to the new `/opt` folder for a while (though eventually it would have to get cleaned
up so this only delays migration pain for some). Gem installs would have to
migrated from a user context, possibly with a provided script or `chef` CLI
command.

### Use "Chef Workstation" as a Different Brand

My understanding (which is very incomplete) is part of the initial reason to
split `chef-run` to its own command was, in part, concern about the growing sprawl of
commands in the `chef` CLI which could be a speedbump for new users.

Another option is to leave both "ChefDK" and "Chef Workstation" as active brands,
with ChefDK continuing as it is today while Chef Workstation becomes a focused,
single-workflow installer (i.e. remove Berkshelf and other tools not part of the
`chef-run` workflow) from it. This could mirror the focused installers built by
the InSpec team.

I feel like the very near overlap of ChefDK and Chef Workstation in this universe
would result in long-term user confusion though.

## Downstream Impact

All current users of the beta Chef Workstation installer would have to eventually
remove it and install ChefDK to get future updates.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
