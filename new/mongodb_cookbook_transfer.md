---
RFC: unassigned
Title: Transfer mongodb cookbook on Supermarket to Sous Chefs org
Author: Grant Ridder <shortdudey123@gmail.com>
Status: Draft
Type: Informational
---

# Transfer mongodb cookbook on Supermarket to Sous Chefs org

## Motivation

    As a user of the mongodb cookbook,
    I want to have the cookbook maintained and released to Supermarket,
    so that I can get cookbook updates for non-EOS versions of MongoDB.

    As a user of the mongodb cookbook,
    I want to have the cookbook up to date on Supermarket,
    so that I can install a version of MongoDB that is getting security updates.

    As a Sous Chef member,
    I want to be able to release to Supermarket,
    so that the community at large can consume the maintained fork.

## Specification

Currently the [mongodb cookbook](https://github.com/edelight/chef-mongodb)
on [Supermarket](https://supermarket.chef.io/cookbooks/mongodb) was last released
on November 11, 2014.  The last commit on the GitHub repository was the day prior,
November 10, 2014.  At the time of the writing of this draft, the repository has
70 open issues and 35 open PRs.  The last comment on any issue or PR by any
maintainer was by [jamesonjlee](https://github.com/edelight/chef-mongodb/pull/356)
on December 9, 2014.

The Sous Chefs have been maintaining a [fork](https://github.com/sous-chefs/mongodb)
of the mongodb cookbook.  The fork's master branch is currently 90 commits ahead
of the source repository for the cookbook. The Sous Chefs have been active on the issues
on the origional repository and have worked to fix them in the maintained fork.

Grant Ridder, on behalf of the Sous Chefs, has attempted on several ocasaions during
November and December of 2016 to contact Markus Korn, the current owner on Supermarket,
as well as Jameson Lee, a contributor on Supermarket and last committer on GitHub.
Both individuals were each contacted with 2 different methods without reponse.  At the
time of the writing of this draft, the last evidence of activity for either user, in the
context of the mongodb cookbook, is more than 2 years ago.

The Sous Chefs would therefor request that the MongoDB cookbook on Supermarket be
marked deprecated in favor of [sc-mongodb](https://github.com/sous-chefs/mongodb)
on Supermarket under provisions layed out in the `When a Cookbook is NOT Up For Adoption`
section of [RFC069](https://github.com/chef/chef-rfc/blob/master/rfc069-cookbook-adoption.md).

### Deprecation Process for this RFC

1. [@nathenharvey](https://github.com/nathenharvey) will reach out to
   [@thekorn](https://github.com/thekorn) weekly asking for a decision on
   the ownership of the cookbook.
1. The Sous Chefs will publish their MongoDB cookbook to the Supermarket.
1. On, or after, March 15, 2017 (3 months after this RFC was submitted),
   a Supermarket Administrator will mark the current MongoDB cookbook
   as deprecated and offer the Sous Chefs' cookbook as a suitable replacement.
1. A message will be posted to the mailing list notifying of this change and our reasoning behind it.

Note: As the current owner of the cookbook, [@thekorn](https://github.com/thekorn) can
accelerate or stop this timeline at any time.

## Downstream Impact

Since the Sous Chef's fork is compatable with the existing cookbook on Supermarket,
no downstream impact is expected.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
