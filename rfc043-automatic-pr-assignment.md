---
RFC: 43
Author: Thom May <tmay@chef.io>
Status: Accepted
Type: Process
---

# Automatically manage Pull Requests

We would like to automatically assign pull requests to
a suitable reviewer on submission. A reviewer would be chosen from the
group of maintainers of the project, attempting to ensure that no
reviewer becomes overloaded by Pull Requests.

Especially for community developers, providing fast feedback ensures
that the contributer stays engaged, rather than becoming discouraged by
a submission languishing for an extended period of time.

We would also like to capture metrics related to pull requests, such as
life times, conversation length, and merge/reject/abandon ratios.

## Motivation

    As a Maintainer
    I want to ensure that PRs are handled in a timely manner
    by the most suitable developer.

    As a Maintainer
    I want to learn more about how we engage with our open source projects
    so that we can improve our processes

## Specification

Each project should expose a machine readable MAINTAINERS file, allowing
for discovery of maintainers by an automated process ("bot").

For each new Pull Request, the bot will automatically assign a reviewer
based on the list retrieved from the maintainers file. It will attempt
to ensure that no-one has too many PRs assigned to them at any one time.

Any reviewer must be able to place themselves on vacation, which
would prevent the bot assigning any PRs to them.

A list of file paths will be associated with each component so that the
bot can correctly choose to use either a subsystem maintainer or a core
maintainer, prefering the most specific possible.

If the reviewer is not able to help, they can choose to ask the bot to
assign a new reviewer, or they can reassign the PR themselves.

Once a Pull Request is closed, the bot will record a set of metrics
related to the PR.

## References

* [Rust's Infrastructure](http://huonw.github.io/blog/2015/03/rust-infrastructure-can-be-your-infrastructure/)
