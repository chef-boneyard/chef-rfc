---
RFC: unassigned
Title: Transfer openstack user on Supermarket to Chef OpenStack team
Author: Samuel Cassiba <s@cassiba.com>
Status: Draft
Type: Informational
---

# Transfer openstack user on Supermarket to Chef OpenStack team

## Motivation

    As a user of the Chef OpenStack cookbooks,
    I want to have the cookbooks maintained and released to Supermarket,
    so that I can get cookbook updates for OpenStack.

    As a user of the Chef OpenStack cookbooks,
    I want to have the cookbooks up to date on Supermarket,
    so that I can install a release of OpenStack that is getting security updates.

    As a maintainer of the Chef OpenStack cookbooks,
    I want to be able to release to Supermarket,
    so that the community at large can consume the cookbooks.

    As a maintainer of the Chef OpenStack cookbooks,
    I want to be able to maintain OpenStack's presence on Supermarket,
    so that the community at large can consume the cookbooks.

## Specification

It has been found that the [openstack user on Supermarket](https://supermarket.chef.io/users/openstack)
is registered by someone not affiliated with the Chef OpenStack team, the
primary producers of OpenStack cookbooks. The [OpenStack Trademark Policy](https://www.openstack.org/brand/openstack-trademark-policy/)
defines the OpenStack mark as being permissible use for distributing OpenStack-specific
code. However, the user on Supermarket does not appear to be used for any such
purposes.

The Chef OpenStack team has been actively maintaining cookbooks under the
OpenStack governance model since 2015-05-26. Maintaining a "social" presence is
recently under development teams' list of responsibilities, and Supermarket
falls under the "social" category by OpenStack definition. The Chef OpenStack
maintainers are active in the OpenStack community, but have little to no
presence in the Chef community, with the primary distribution means being
Supermarket. At the time of the writing of this draft, the last evidence of
activity for the openstack Supermarket user was more than three years ago, at
registration time.

Samuel Cassiba, on behalf of the Chef OpenStack team, as a representative
maintainer, would therefore request that the openstack user on Supermarket be
transferred to the team's control, so that the Chef OpenStack team can manage
OpenStack's public presence on Supermarket.

### Deprecation Process for this RFC

1. Hosted Chef and Supermarket administrators record that the openstack user is not
   associated with any running infrastructure or published cookbooks.
   Hosted Chef administrators remove the openstack user from its existing
   organization.
1. Hosted Chef administrators change the email address on the openstack user to an
   address of the Chef OpenStack team's choosing.
   Supermarket administrators announce this change on the Chef mailing list.
1. The Chef OpenStack team receives access to Hosted Chef openstack account via
   password reset over email.
1. The Chef OpenStack team creates a new key pair for the openstack user and logs
   in to Supermarket to update account information and key cached there.
1. The Chef OpenStack team begins publishing their OpenStack cookbooks to
   Supermarket.

## Downstream Impact

Since there is no evidence of activity on Supermarket, no downstream impact is
expected.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
