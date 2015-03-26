---
RFC: unassigned
Author: John Keiser <jkeiser@chef.io>
Status: Draft
Type: Process
---

# Tracking for Standards Track RFCs

Standards Track RFCs are intended for implementation.  This proposal aims to
make it easier to tell when an RFC is implemented or orphaned, or what its
implementation status is.

## Motivation

    As a Chef Contributor,
    I want to know whether an RFC is actually being worked on,
    so that I can decide whether to wait, write it myself, or write a replacement RFC.

    As a Chef Contributor,
    I want to know whether an RFC has become orphaned,
    So that I can decide whether to find a new owner for the subject.

## Specification

### Tracking Metadata Field

RFCs will now include a metadata field called Tracking, which will generally be
a list of URLs to issues or PRs where the feature is tracked, and may also link
to blog posts about relevant releases.

For example, rfc015 metadata would look like this:

```yaml
---
RFC: 34
Author: Daniel DeLeo <dan@getchef.com>
Status: Final
Type: Standards Track
Chef-Version: 12.0
Tracking:
  - https://www.chef.io/blog/2014/11/25/ruby-1-9-3-eol-and-chef-12/
---
```

And the rfc024 metadata would look like this:

```yaml
---
RFC: 24
Author: John Keiser <jkeiser@getchef.com>
Status: Accepted
Type: Standards Track
Chef-Version: 12
Tracking:
  - https://github.com/chef/chef/pull/1969
---
```

ALL accepted Standards Track RFCs will have:

- Status of Accepted or Final
- Tracking URLs (unless it is an old RFC with Final status, in which case
  Tracking URLs are optional)
- Chef-Version (if Final)

### RFC "Orphaned" status

When an RFC is orphaned--when its author is no longer willing to work on it and
no one has stepped up to do it--the RFC is updated to reflect that fact with the
Withdrawn status.  If someone else wants to step back up, they will need to
re-present the RFC and have it Accepted again.

### RFC Acceptance Process Modification

When a Standards Track RFC is accepted, we will do all the normal things we do,
*plus* file an issue for implementation (or link to the existing issue or PR),
and mark the Tracking field with that URL.

### Finalization

When the implementation issue is resolved as fixed, we mark the RFC Final (or add
other issues tracking the remaining work) and mark the Chef-Version in which it
was shipped.  Issue URLs remain on the RFCs for historical purposes.

### Existing RFCs

All existing Accepted Standards Track RFCs will either be marked Final or have
Tracking attached to them.  They may optionally be marked Withdrawn if they are Orphaned.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
