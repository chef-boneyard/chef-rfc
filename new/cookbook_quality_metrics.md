---
RFC: unassigned
Author: Nathen Harvey <nharvey@chef.io>
Status: Draft
Type: Informational
<Replaces: RFCxxx>
<Tracking:>
<  - https://github.com/chef/chef/issues/X>
---

# Cookbook Quality Metrics

The question of what makes a good cookbook has been asked since the dawn of Chef.  As a community we've struggled with answering this in part because each recipe is unique to the specific requirements it is trying to meet.  Allowing Supermarket users to rate cookbooks is one thing that we've tried in the past.  This did not work because you simply do not have enough knowledge about the quality of a cookbook when you discover and download it from the Supermarket.  Similarly, download counts cannot be trusted because of [the way some older versions of the berkshelf-api server work].

The Supermarket should make it easy for anyone to find quality cookbooks.  In order to do so, we must agree on some qualities that indicate whether or not a cookbook is considered to have high quality.  Ideally, these qualities are objective and able to be determined automatically.

## Motivation

    As a cookbook author,
    I want to write cookbooks that can be shared with and easily used by the community
    so that it is easier to get going with Chef.

    As a Supermarket user,
    I want to identify the relative quality of a given cookbook,
    so that I can spend less time looking for a good cookbook and more time automating.

## Specification

The metrics that determine the relative quality of a cookbook are listed below.

* It converges without error.

    ```
    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
    ```

* It converges without error using Fauxhai data for each supported platform.

* It links to the source.

    ```
    # metadata.rb
    source_url 'http://github.com/chef-cookbooks/mysql'
    ```

* It links to the issue tracker.

    ```
    # metadata.rb
    issues_url 'https://github.com/chef-cookbooks/mysql/issues'
    ```


* It is updated and released on a regular basis
  * time since last release
  * time since last change in source code repository
  * number of commits not released
* It includes a README.md with more than the boilerplate copy.
* It includes a MAINTAINERS.md with contact information for each authorized MAINTAINER and Supermarket Collaborator.
* It includes a version number the conforms to the [SemVer specification](http://semver.org/), e.g., X.Y.Z
* It includes a .kitchen.yml which includes a platform declaration for each of the platforms listed as a `supports` in the cookbook's metadata.
* `kitchen test` completes successfully.
* It includes an open-source license (LICENSE.md).
* It includes rspec-based unit tests that pass.
* It passes Foodcritic and Rubocop, with allowances for custom rule specifications.
  * Should the Foodcritic and Rubocop standards be agreed?
* The README includes a badge indicating status of Code Climate and TravisCI tests.
  * Code Climate for Foodcritic and Rubocop
  * TravisCI for ChefSpec
* It includes a `name` in the metadata.
* It includes a `version` in the metadata.
* It includes a `Berksfile` that lists all dependencies.
* It includes a CHANGELOG.md that is updated with each release.
* It is published to the [Supermarket](https://supermarket.chef.io).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
