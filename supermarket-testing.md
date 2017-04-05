---
RFC: unassigned
Title: Supermarket testing indicators
Author: Aaron Kalin <akalin@martinisoftware.com>
Status: Draft
Type: Informational
---

# Supermarket testing indicators

The Chef Supermarket has many public cookbooks with varying levels of testing coverage and it would be helpful to first time or existing users to have a build status indicator. This is separate from the quality metrics indicator already in the Supermarket.

## Motivation

    As a Supermarket Cookbook Consumer,
    I want to see a visual indicator of a cookbook's build status,
    so that I can have confidence that a cookbook will run on my platform.

## Specification

For users of the chef community cookbooks on the public supermarket, we'll in the short-term implement a visual indicator of the build status of the cookbook. This will help visually indicate that the author has implmented some level of continuous integration to test their cookbook. In the future, this indicator will also display the date when it was last run because external changes can affect the confidence that a given cookbook can run on a platform.

In the very long term, there will need to be a way to display the build status per platform to imply confidence that a given platform is being actively tested by a cookbook author. The end goal being to help improve visibility of actively maintained and tested cookbooks that are publically accessible and educational.

## Downstream Impact

ChefDK would be a good avenue to help foster community driven best pratices for testing when generating new cookbooks or generating testing for existing cookbooks. The Chef Supermarket will also have to be altered to display some kind of indicator that testing exists for a given cookbook or have a way for cookbook authors to indicate testing exists and for a badge to show and/or link to it's build status.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
