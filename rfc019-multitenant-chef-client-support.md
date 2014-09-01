---
RFC: unassigned
Author: John Keiser <jkeiser@getchef.com>
Status: Draft
Type: Standards Track
---

# Title

Add better support for multi-tenant Chef servers in Chef, and Hosted Chef in particular.

## Motivation

    As a multi-tenant server user (Hosted and Enterprise),
    I want to be able to run tools and resources that use multi-tenant Chef servers.
    so that I can administrate Chef.

    As a multi-tenant server user (Hosted and Enterprise),
    I want to be able to easily vary my client's organization without retyping the Chef server host,
    so that I don't screw up when I retype.

    As a Chef developer,
    I want to be able to develop and test tools that use multi-tenant Chef servers,
    so that I can support said users.

    As a Chef Metal user,
    I would like to be able to create and manage users and organizations within Chef,
    so that I can describe my entire infrastructure using Chef.

    As a Chef user,
    I would like my cookbook development cycle to use a server that is similar to the one I typically use in production,
    so that I don't start seeing errors as soon as I drop cookbooks onto the production servers.

    As a Hosted Chef user,
    I would like to be able to use Hosted Chef without knowing the exact URL to api.opscode.com,
    so that I can quickly get up and running.

## Specification

Specifying organization:
1. A new configuration parameter, `Chef::Config.organization`, be added to describe the organization the client is pointed at.
2. A new command line parameter, `-O organization`, be introduced.

Hosted Chef by default:
1. When `Chef::Config.organization` is set, `Chef::Config.chef_server_url` default to `https://api.opscode.com/organizations/#{organization}`

Multitenant root URL support:
1. A new configuration parameter, `Chef::Config.chef_server_root`, be added that points to the top of the server (above /organizations) where users and organization lists can be found.
2. When this is set, `chef_server_url` defaults to `<chef_server_root>/organizations/<organization>`.

Local multitenancy support by default:
1. Local mode use chef-zero 3.x by default, with Enterprise mode on and the default organization `chef`.
2. A new configuration parameter, `Chef::Config.chef_11_osc_compatibility`, be introduced to put chef-zero into OSC compatibility mode with no multitenancy or ACLs.

Root repo_mode:
1. `repo_mode` have a new possible value, `:root`, which assumes `chef_repo_path` is at the root of the repository and allows multiple organizations to be stored on disk.  This will affect knife list, knife download, knife upload, and other tools that use ChefFS.

## Rationale and Impact

*Specifying organization*: the organization is a part of the chef_server_url already and could have been left that way.  However, organization is a primary concept already in multitenant users' minds, even more than Chef API URL, so it is more natural to specify.  Setting `organization` as a separate parameter also allows for configurations where the user sets `chef_server_root` once in a global config file and sets `organization` in different profiles or Chef repository directories.

*Hosted Chef by default*: There's absolutely no harm doing this since it only triggers with the organization is specified without a URL, and so many users use it that it's worth saving them the trouble.

*Multitenant root URL support*: The `chef_server_root` is a new concept.  There are already resources (in Cheffish) that modify /organizations and /users, and `knife upload` and `knife download` can be modified to do it as well (allowing `knife ec backup` to become a central concept).  The addition of root url as a top level concept is worth it because of the scenarios it enables (just varying `organization`) as well as the fact that tools which manipulate the root won't have to guess that the top level is `<chef_server_url>/../..`.

We *could* just repurpose `chef_server_url` for this, but chef_server_url is so universally used that we would have no end of support calls if we changed its meaning.

*Local multitenant support by default*: chef-zero already supports this, and turning it on will have the effect of adding ACLs, groups, containers, members, invites and organization data.

Adding this capability will cause `knife download /` to download more data, possibly confusing users.  However, it will also lead to more discovery of the new features and should not cause issues.

This feature will also cause the /users endpoint to be moved to the top level instead of being under an organization, which could affect some applications that manipulate or read user data.  Since local mode is for a local development scenario, this can be rectified by the developer setting the compatibility flag when they discover it; and since it mirrors the server, it's important for the user to know.  The benefit of having development mirror the actual server outweighs the problems caused by the incompatibility of the users endpoint.

*Root repo_mode*: this has no effect on any existing configurations; it is for advanced uses where the user sets repo_mode directly.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
