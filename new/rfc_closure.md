---
RFC: unassigned
Title: Close out the RFC process
Author: Tim Smithh <tsmith@chef.io>
Status: Draft
Type: Process
---

# Close out the RFC process

This policy RFC serves to close out the Chef RFC Process as it has been superceded by the guidelines outlined in the [Chef-OSS-Practices](https://github.com/chef/chef-oss-practices) repository and the governance model outlined there.

## Motivation

    As a community member,
    I want to a single governance system for all Chef projects,
    so that I don't have to learn unique per project standards.

    As a Chef employee,
    I want to a simpler system to collaborate on design ideas,
    so that I can take feedback and concerns for even minor changes.

    As a contributor,
    I want to a system with tiered levels of commitment,
    so that I can take on the level of commitment right for me.

    As a user,
    I want to know the state of a repository and the response time I should expect,
    so that I can decide if it's appropriate to use.

## Specification

This PR closes out the Chef RFC process in favor of the processes outlined in our [Chef-OSS-Practices](https://github.com/chef/chef-oss-practices) repository. Those processes apply to not only Chef, but also InSpec, Habitat, and now Automate, which gives a single governance and community contract to all projects maintained by Chef Software.

Once this RFC is accepted teams will begin the process of implementing the guidelines, which occurs at the project level and also the repository level within projects.

**Project level:**
  - Establishing which repositories are included in a project
  - Adding the initial list of owners, approvers, and reviewers
  - Creating a development channel in community Slack
  - Establishing office hours for triage of issues / PRs

**Reposistory level:**
  - Adding the appropriate teams to the repos and removing existing teams
  - Adding repos status, project, and SLAs to the readme.md
  - Adding base documents such as the contributing guide and code of conduct.
  - Adding or updating GitHub CODEOWNERS files to use the new project teams
  - Adding Github issue templates for enhancements and design proposals
  - Migrating to standardized issue labels and adding auto label assignment to existing GitHub issue templates

The final steps will be merging all relevant RFCs into the Chef developer documentation as design documents (https://github.com/chef/chef/pull/8350) and then moving this repository to the chef-boneyard, where it will remain as a historical reference.

## Downstream Impact

The main impact of this change is that all Chef Software OSS repos will need to implement the processes outlined in the https://github.com/chef/chef-oss-practices and existing maintainers will need to open PRs to add themselves to one of the new roles in the new teams.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
