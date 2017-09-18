---
RFC: 000
Title: Chef RFC Process and Guidelines
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Accepted
Type: Process
---

# Chef RFC Process and Guidelines

A Chef RFC is a design document describing improvements to Chef. We as a
community use RFCs to document, discuss, and plan improvements to Chef and
other Chef ecosystem tools. You can always find the list of accepted RFCs at
https://github.com/chef/chef-rfc.

The specific projects covered by this process are detailed in RFC002 (Scope).

## RFC Types

* A **Standards Track** RFC describes a new feature or improvement for Chef or
the Chef ecosystem.
* An **Informational** RFC describes a standard or guideline in the Chef
community. It is not intended to be a binding requirement.
* A **Process** RFC describes a change to development process of Chef or
related projects.

## Roles

* The **Decider** has final say to accept or reject an RFC. The top-level
decider is [Adam Jacob](mailto:adam@chef.io). The decider can delegate their
authority on a per-subsystem or per-RFC basis.
* The **Editors** manage the Chef RFC repository and assist with the RFC
workflow. They are not responsible for managing the content of RFCs, only
formatting and procedure. To volunteer as an editor please create a pull
request against this document that adds your name to the list. The existing
editors will vote on the request, with the Decider retaining veto power. The
current editors are:
  * Noah Kantrowitz \<noah@coderanger.net\>
  * Jon Cowie \<jcowie@chef.io\>
  * Bryan McLellan \<btm@loftninjas.org\>
  * Adam Leff \<adam@leff.co\>
  * Thom May \<tmay@chef.io\>
* The **Author(s)** submit RFCs and shepherd them through the process with the
assistance of the editors. Unless otherwise specified, the author(s) of an RFC
also implement the feature or process once accepted.

## Submitting an RFC

RFCs are managed in the [chef-rfc GitHub repository](#). When creating a new
RFC, add it to the `new/` folder. A template is provided [below](#). Submit a
pull-request with your new RFC. The Editors will review your submission to
ensure it is formatted correctly.

The community will discuss the proposed changes on the pull-request and during
regular community meetings (see RFC001). When the Decider feels consensus has
been reached, they will accept or reject the RFC.

The Editors will then assign it an RFC number which will be added to the
filename and metadata.

Unless otherwise stated, the RFC author is also volunteering to implement the
feature or process if accepted.

## When should I submit an RFC?

There's no rule by which to determine the need for a RFC. Some examples to
consider are:

* Adding a new feature that would impact multiple parts of the project,
  e.g. audit mode.
* Establishing or changing a public API, e.g. mixlib-authentication.
* A policy or process for the project, e.g. platform support policy.

## What belongs in a successful RFC?

Each RFC will generally include the following sections:

1. **Metadata** – Yaml frontmatter including the RFC ID number, author(s),
status, and type.
2. **Description** – A short (~200 word) description of the technical issue
being addressed.
3. **Motivation** – The **why** of this change, especially if the change has an
impact on compatibility. To the greatest extent possible, realistic use cases
should be cited. This generally includes an agile user story.
4. **Specification** – The **what** of this change. The technical specification
should describe the new feature or enhancement being proposed. This includes any
DSL or server API changes.
5. **Rationale** – The **how** of this change. The rationale fleshes out the
specification by describing what motivated the design and why particular design
decisions were made. It should describe alternate designs that were considered
and related work, e.g. how the feature is supported in other tools. The
rationale should provide evidence of consensus within the community and discuss
important objections or concerns raised during discussion.
6. **Copyright** – All RFCs must be placed in the public domain.

This is neither an exhaustive list nor a set of requirements, but it is a good
place to start.

## RFC Review and Workflow

All new RFCs start off as drafts. At any point the author(s) can withdraw the
RFC if they feel it doesn't merit further discussion. Once consensus is reached,
the Decider for the RFC will accept or reject the RFC. For Standards Track RFCs,
once the feature is implemented in a released version of the relevant software
the RFC is marked as Final, indicating discussion of further changes to the
feature should take place in a new RFC. If an RFC is superseded by a later RFC,
the original one should be marked as Replaced.

```
  +-------+        +----------+       +-------+
  |       |        |          |       |       |
  | Draft +--------> Accepted +---+---> Final |
  |       |        |          |   |   |       |
  +---+---+        +----+-----+   |   +---+---+
      |                 |         |       |
      |                 |         +-------+
      |                 |                 |
      |                 |                 |
+-----v-----+      +----v-----+    +------v---+
|           |      |          |    |          |
| Withdrawn |      | On Hold  |    | Replaced |
|           |      |          |    |          |
+-----------+      +----------+    +----------+
```

### RFC Status Reference

* **Draft** – The RFC is under discussion by the community.
* **Accepted** – The RFC is approved for implementation.
* **On Hold** – The RFC is approved but not currently under development.
* **Withdrawn** – The RFC has been voluntarily withdrawn from consideration.
* **Final** – The RFC has been implemented. *(Standards Track type only)*
* **Replaced** – The RFC has been superseded by another RFC.

### Changing an Accepted RFC

An accepted RFC may be modified in two ways, depending on the type of RFC:

1) Most RFCs can be updated by opening a pull request against them with the
proposed changes. Once the changes are approved by the Decider, the pull
request is merged and considered Accepted.

2) To support software implementations meeting the specifications of an RFC,
Standards Track RFCs that are Final must be replaced by a new RFC. The Author
should specify the RFC that is being replaced using the Replaces header in the
metadata of the new RFC. Once Accepted, the replaced RFC with have its status
updated to Replaced by an Editor.

## RFC Template

```markdown
---
RFC: unassigned
Title: Title Goes Here
Author: Alan Smithee <asmithee@example.com>
Status: Draft
Type: <Standards Track, Informational, Process>
<Replaces: RFCxxx>
<Tracking:>
<  - https://github.com/chef/chef/issues/X>
---

# Title

Description and rationale.

## Motivation

    As a <<user_profile>>,
    I want to <<functionality>>,
    so that <<benefit>>.

## Specification

A detailed description of the planned implementation, which the RFC author agrees to execute.

## Downstream Impact

Which other tools will be impacted by this work?

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
```

## Influences

This document is heavily based on [PEP 1](http://legacy.python.org/dev/peps/pep-0001/).
It also draws from [Django's DEP process](https://github.com/django/deps/blob/master/final/0001-dep-process.rst),
and [OpenStack's Blueprints](https://wiki.openstack.org/wiki/Blueprints).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
