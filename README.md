# Chef RFC

The repository for proposals for major changes to Chef, Chef Server, and related public projects.

## Usage

Read [RFC000](https://github.com/opscode/chef-rfc/blob/master/rfc000-rfc-process.md#submitting-an-rfc) for more information on how to submit an RFC and get it reviewed.

## Generating HTML Documentation

To turn the Markdown documents into HTML that can be served from a website on
the gh-pages branch. Git ≥ 2.7, Ruby, and the Bundler gem are required.

You'll need to have the gh-pages branch checked out locally:

    git fetch; git checkout -t origin/gh-pages; git checkout master

Run:

    bundle install; bundle exec rake pages:generate

After that there will be a gh-pages subdirectory that has the generated files
and is on the gh-pages branch. These can be committed and pushed to deploy the
website to https://chef.github.io/chef-rfc/.

## Copyright

Chef RFCs are in the public domain. In jurisdictions that do not allow for this, they are available under CC0. To the extent possible under law, the person who associated CC0 with their work has waived all copyright and related or neighboring rights to their work.
