---
RFC: unassigned
Title: In-Repo Draft Guides for Chef
Author:
- Noah Kantrowitz <noah@coderanger.net>
- Kimberly Garmoe <kgarmoe@chef.io>
Status: Draft
Type: Process
---

# In-Repo Draft Guides for Chef

Chef community members are skilled practitioners and valuable contributors. Chef
practitioners have experience and skills, but lack a stable process for composing
and sharing long-format information.

The community has requested two changes:

1. A place in the `chef/chef` repository for storing community guides
2. The ability to write in Markdown

## Motivation

    As a Chef contributor,
    I want to write guides for specific procedures or problems
    so that we can capture changes to Chef.

## Specification

To this end, we will create a `guides-drafts/` folder in the `chef/chef` repository.
This folder will contain documentation files so that the maintainer team can
work on and update them. No content in this folder will be considered ready for
end-user use, and will not be displayed on any documentation website (docs.chef.io
or whatever comes in the future in the same vein). At the discretion of the Chef
documentation team, some content may be reviewed and prepared for end-user
distribution, however that process is not covered here.

A `README.md` file in this folder will emphasize that the documentation here is
not for end-user consumption and encourage them to consult docs.chef.io.

As more draft guides are added, it will be the general policy of the Chef
maintainer team to only allow merges that include the relevant updates to any
existing guides, or the creation of a new guide if appropriate.

## Downstream Impact

This will eventually be made obsolete by planned overall improvements to the documentation
workflow, but until this this work will have to be periodically manually integrated
into user-facing documents.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
