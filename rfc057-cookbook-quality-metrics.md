---
RFC: 57
Title: Cookbook Quality Metrics
Author: Nathen Harvey <nharvey@chef.io>
Status: Accepted
Type: Informational
---

# Cookbook Quality Metrics

The question of what makes a good cookbook has been asked since the dawn of Chef.  As a community we've struggled with answering this in part because each recipe is unique to the specific requirements it is trying to meet.  Allowing Supermarket users to rate cookbooks is one thing that we've tried in the past.  This did not work because you simply do not have enough knowledge about the quality of a cookbook when you discover and download it from the Supermarket.  Similarly, download counts cannot be trusted because of [the way some older versions of the berkshelf-api server work](https://www.chef.io/blog/2015/01/21/those-pesky-supermarket-download-counts/).

The Supermarket should make it easy for anyone to find quality cookbooks.  In order to do so, we must agree on some qualities that indicate whether or not a cookbook is considered to have high quality.  Ideally, these qualities are objective and able to be determined automatically.  These qualities should be defined and agreed on by the community.

## Motivation

    As a cookbook author,
    I want to write cookbooks that can be shared with and easily used by the community
    so that it is easier to get going with Chef.

    As a Supermarket user,
    I want to identify the relative quality of a given cookbook,
    so that I can spend less time looking for a good cookbook and more time automating.

## Specification

A [Cookbook Quality Metrics](https://github.com/chef-cookbooks/cookbook-quality-metrics) system will be implemented to provide indicators of certain qualities for each cookbook.  These indicators will be visible on the Supermarket.

* The community will be able to collaborate on the metrics.
* The community has expressed a desire for an aggregate metric to make the quality ranking easy to consume without needing to fully understand what makes up the metric.
* Metrics should not be visible on the Supermarket by default until the community has had time to review the data associated with the implemented metrics.
* A Supermarket user should be able to easily assess a cookbook's compliance with any given metric.

We will collaborate on quality metrics in the [Cookbook Quality Metrics](https://github.com/chef-cookbooks/cookbook-quality-metrics) repository.

The lifecycle of a metric will be:

* *Draft* - this is a proposed metric, ready for community discussion and approval.
* *Accepted* - this metric has been accepted and merged into the master branch of the [Cookbook Quality Metrics repository](https://github.com/chef-cookbooks/cookbook-quality-metrics).
  * *In Progress* - data for this metric is being gathered and is visible by some mechanism but not displayed on the Supermarket by default.
* *Implemented* - this metric has been implemented and is visible on the Supermarket.
* *Closed* - this metric has not been accepted or has been removed from the system.

### Viewing Cookbook Metrics

The [Supermarket](https://supermarket.chef.io) may show some sort of aggregate score for each cookbook.

Each cookbook listed on the Supermarket will have a tab or other view showing how it adheres to each quality metric.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
