---
RFC: unassigned
Title: The Future of Chef Workstation
Author:
- Jon Morrow <jmorrow@chef.io>
- Noah Kantrowitz <noah@coderanger.net>
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

1. The `chef-run` command will be renamed to `chef-target` [ed: not attached to this name, suggest a better on in comments].
2. The `chef-target` gem will be split into its own repository for future development.
3. The installer currently called "ChefDK" will be renamed "Chef Workstation".
   This will require setting up documentation to explain the rename, as well as
   redirects and supporting pages in the download system to ensure users don't
   get lost.
4. The `chef-dk` gem will not be renamed at this time, as few users see the gem
   name there and we're already changing a lot of things. This may be revisited
   in the future when the dust settles.
5. The installer for `chef-dk` (now named "Chef Workstation") will be reconfigured
   to install into `/opt/chef-workstation` and use `~/.chef-workstation` as the
   primary configuration folder. A symlink for `/opt/chef-dk` (and related windows-y paths)
   should be added to ensure any scripts that hardcode paths like `/opt/chefdk/bin/chef`
   continue to function (until such time as we decide to remove them as compatbility layers).
   Gems in `~/.chefdk/gems` should be added to the gems path, and config files in
   `~/.chefdk` should work if no file in `~/.chef-workstation` takes priority.
6. Add the `chef-target` gem to the Chef Workstation installer.
7. A command stub will be added to the `chef-dk` command processor called `target` [ed: or whatever we call it],
   which will dispatch to the `chef-target` command. The Chef Workstation installer
   will map `chef-target` into `embedded/bin/` rather than `bin/` so for most users,
   this will be the UX.

Additionally, while it is out of scope for this RFC, the authors strongly encourage
future RFCs and discussions about adding additional tools to Chef Workstation/DK
that are of value to the Chef community.

## Alternatives

### Keeping the "ChefDK" Name

While "Chef Workstation" is a clearer name, there is broad community usage and
understanding of the ChefDK name and brand. We could do a similar process to the
above, but leave the installed called ChefDK in the end. This would vastly
simplify the process as we could skip all the compatibility gunk. This would
just be adding a new tool to ChefDK, as we have done many times before.

The downside is that there is some pushback against the "Developer Kit" part of
ChefDK from people that feel the "developer" label is exclusionary or at least
presents a barrier to the new user experience.

### Making a Dedicated Chef-Target Installer

Rather than including `chef-target` in the DK/Workstation installer, we could
move it to a focused installer just for the one tool, similar to the InSpec
installer. This would give the team more agility as they would have much more
freedom in shaping the UI and UX of this new workflow.

The downside is that this would split the new workflow off from the rest of the
Chef community, possibly creating friction for users experimenting with new workflows
for the first time or switching from an existing workflow.

### Using "Chef Workstation" as Its Own Brand

In this path, we would still add `chef-target` to ChefDK, but we wouldn't
rename the installer. Instead, "Chef Workstation" would become a new thing,
explicitly aimed at being a cross-product-line workstation experience, while
ChefDK stays focused on the Chef (the project) experience.

The downside here is the limitations of human language (more or less). Because
Chef Software and Chef (the project) have such overlapping names, it would be
very difficult to explain how these are two different things in the long term,
likely resulting in user confusion and frustration.

## Downstream Impact

All current users of ChefDK would need to upgrade to Chef Workstation, though
this upgrade should be transparent.

Any users of the current beta Chef Workstation installer would also need to
switch over, though that would not be a transparent upgrade process.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
