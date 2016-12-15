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

The Sous Chefs have been maintaining for [fork](https://github.com/sous-chefs/mongodb)
of the mongodb cookbook.  The fork's master branch is currently 90 commits ahead
of the source repository for the cookbook. The Sous Chefs have been active on the issues
on the origional repository and have worked to fix them in the maintained fork.

Grant Ridder, on behalf of the Sous Chefs, has attempted on several ocasaions during
November and December of 2016 to contact Markus Korn, the current ownwer on Supermarket,
as well as Jameson Lee, a contributor on Supermarket and last committer on GitHub.
Both individuals were each contacted with 2 different methods without reponse.  At the
time of the writing of this draft, the last evidence of activity for either user, in the
context of the mongodb cookbook, is more than 2 years ago.

The Sous Chefs would therefor request that the MongoDB cookbook be transfered to the
[Sous Chefs](https://supermarket.chef.io/users/sous-chefs) on Supermarket under
provisions layed out in the `When a Cookbook is NOT Up For Adoption` section of
[RFC069](https://github.com/chef/chef-rfc/blob/master/rfc069-cookbook-adoption.md).

## Downstream Impact

Since the Sous Chef's fork is compatable with the existing cookbook on Supermarket,
no downstream impact is expected.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
