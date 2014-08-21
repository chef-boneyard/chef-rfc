---
RFC: unassigned
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Process
---

# Chef RFC Process and Guidelines

A Chef RFC is a design document describing improvements to Chef. [more here]

## RFC Types

1. A **Standards Track** RFC describes a new feature or improvement for Chef or
the Chef ecosystem.
2. An **Informational** RFC describes a standard or guideline in the Chef
community. It is not intended to be a binding requirement.
3. A **Process** RFC describes a change to development process of Chef or
related projects.

## Roles

1. The **Decider** has final say to accept or reject an RFC. The top-level
decider is [Adam Jacob](mailto:adam@getchef.com). The decider can delegate their
authority on a per-subsystem or per-RFC basis.
2. The **Editors** manage the Chef RFC repository and assist with the RFC
workflow. They are not responsible for managing the content of RFCs, only
formatting and procedure. The current editors are:
   * Noah Kantrowitz <noah@coderanger.net>
3. The **Author(s)** submit RFCs and shepherd them through the process with the
assistance of the editors. Unless otherwise specified, the author(s) of an RFC
also implement the feature or process once accepted.

## Submitting an RFC

RFCs are managed in the [chef-rfc GitHub repository](#). When creating a new
RFC, add it to the `new/` folder. A template is provided [below](#). Submit a
pull-request with your new RFC. The Editors will review your submission and when
it is formatted correctly, they will assign it an RFC number which should then
be added to the filename and metadata. [ed: do we just want to use ticket numbers?]

The community will discuss the proposed changes and when the Decider feels
consensus has been reached, they will accept or reject the RFC.

Unless otherwise stated, the RFC author is also volunteering to implement the
feature or process if accepted.

## What belongs in a successful RFC?

Each RFC will generally include the following sections:

1. **Metadata** – Yaml frontmatter including the RFC ID number, author(s),
status, and type.
2. **Description** – A short (~200 word) description of the technical issue
being addressed.
3. **Motivation** – The **why** of this change, especially if the change has an
impact on compatibility. The the greatest extent possible, realistic use cases
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
  | Draft +----+---> Accepted +---+---> Final |
  |       |    |   |          |   |   |       |
  +---+---+    |   +----------+   |   +---+---+
      |        |                  |       |
      |        |                  +-------+
      |        |                          |
      |        |                          |
+-----v-----+  |   +----------+    +------v---+
|           |  |   |          |    |          |
| Withdrawn |  +---> Rejected |    | Replaced |
|           |      |          |    |          |
+-----------+      +----------+    +----------+
```

### RFC Status Reference

* **Draft** – The RFC is under discussion by the community.
* **Accepted** – The RFC is approved for implementation.
* **Rejected** – The RFC is not approved.
* **Withdrawn** – The RFC has been voluntarily withdrawn from consideration.
* **Final** – The RFC has been implemented. *(Standards Track type only)*
* **Replaced** – The RFC has been superseded by another RFC.

## RFC Template

```markdown
---
RFC: unassigned
Author: Alan Smithee <asmithee@example.com>
Status: Draft
Type: <Standards Track, Informational, Process>
---

# Title

Description.

## Motivation

    As a <<user_profile>>,
    I want to <<functionality>>,
    so that <<benefit>>.

## Specification

## Rationale

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

```

## Influences

This document is heavily based on [PEP 1](http://legacy.python.org/dev/peps/pep-0001/).
It also draws from [Django's DEP process](#), and [OpenStack's Blueprints](#).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
