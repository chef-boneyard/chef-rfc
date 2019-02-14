---
RFC: 80
Title: Developer Certificate of Origin (DCO) for Contributions
Author: Nathen Harvey <nathenharvey@google.com>
Status: Accepted
Type: Process
---

# Developer Certificate of Origin (DCO) for Contributions

Chef's open source projects will no longer require a contributor license agreement (CLA) or corporate contributor license agreement (CCLA).  A developer certificate of origin (DCO) will be required for each contribution to the projects.  The DCO accomplishes the same purpose as the CLAs by indicating that developers are responsible for the code that they contribute and that they understand that the contribution is under the terms of the Apache License. This simple process is familiar to developers and more and more legal departments are willing to consider this approach as well.

## Motivation

    As a potential contributor to Chef's open source projects,
    I do not want to read, understand, and sign a contributor license agreement,
    so that contributing does not require unnecessary burdens.

    As a contributor to Chef's open source projects,
    I want to attest that each contribution is under the terms of the Apache License,
    so that it is clear that I am able to make the contribution.

    As a maintainer of Chef's open source projects,
    I want to see a developer certificate of origin in every contribution,
    so that it is clear that the contribution is allowed.

## Specification

Effective October 1, 2016 ("the cutover date"), Chef will no longer require CLAs or CCLAs for contributions to its open source projects.  Rather, Chef is adopting the developer certificate of origin ("DCO") used by several other projects and overall smart people.  All commits prior to the cutover date shall fall under the CLA process and will require a signed contributor license agreement.

The DCO is an attestation attached to every contribution made by every developer. In the commit message of the contribution, the developer simply adds a Signed-off-by statement and thereby agrees to the DCO, which you can find below or at [http://developercertificate.org/](http://developercertificate.org/).

    Developer's Certificate of Origin 1.1

    By making a contribution to this project, I certify that:

    (a) The contribution was created in whole or in part by me and I
        have the right to submit it under the open source license
        indicated in the file; or

    (b) The contribution is based upon previous work that, to the
        best of my knowledge, is covered under an appropriate open
        source license and I have the right under that license to
        submit that work with modifications, whether created in whole
        or in part by me, under the same open source license (unless
        I am permitted to submit under a different license), as
        Indicated in the file; or

    (c) The contribution was provided directly to me by some other
        person who certified (a), (b) or (c) and I have not modified
        it.

    (d) I understand and agree that this project and the contribution
        are public and that a record of the contribution (including
        all personal information I submit with it, including my
        sign-off) is maintained indefinitely and may be redistributed
        consistent with this project or the open source license(s)
        involved.

## Downstream Impact

* Currybot, part of the Supermarket, will no longer be necessary.
* The DCO sign-off process must be clearly documented in the contributing documents.
* A small DCO bot will need to be added to each of Chef's open-source repositories.
  * The bot must include instructions for how to edit commits adding a `Signed-off-by` line.
* A blog post and mailing list announcement will be made before the cutover.
* This will have *no* impact on [the "obvious fix" rule](https://docs.chef.io/community_contributions.html#the-obvious-fix-rule).  Contributions that meet these criteria will not need a DCO but should include "obvious fix" in the commit message as outlined in [the "obvious fix" policy](https://docs.chef.io/community_contributions.html#the-obvious-fix-rule).
* DCO sign-off will not be required for contributions to documentation repositories (such as `chef/chef-web-docs`) or contributions that only affect documentation embedded within project repositories (such as the `docs` directory in `chef/inspec`).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
