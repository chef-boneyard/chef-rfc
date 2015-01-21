---
RFC: unassigned
Author: Jon Cowie (jcowie@etsy.com)
Status: Draft
Type: Standards Track
---


# Add client_compat field to cookbook metadata

Increasingly, as momentum on Chef development continues to grow, it is necessary to release modifications to the recipe DSL or core resources which break backwards compatibility and result in cookbooks potentially breaking under old versions of chef-client. Further, it is often necessary to make these changes in minor chef-client releases rather than waiting multiple months for the next major release cycle. There is currently no way to surface this version requirement to Chef users.

This RFC proposes the addition of the "client_compat" field (name up for discussion) to cookbook metadata to indicate the required version of chef-client needed to run that cookbook. 

## Motivation

As a user of chef, I want to be able to easily determine if a specific cookbook uses any features not supported by my version of chef-client, so that I don't have to diagnose mysterious errors during a chef run.

## Specification

This change would require adding an additional field to the supported list of cookbook metadata fields. For the sake of argument, I'm proposing that this field be called "client_compat".

This change would potentially break backwards compatibility for older versions of chef-client which would not expect the presence of that field, but I propose that the benefit gained from easily being able to surface chef-client version requirements to cookbook users in all future versions makes this worthwhile.

The addition of this field would also permit this information to be easily surfaced in Chef Supermarket, and to potentially even have chef-client display a friendly warning if it tries to compile a cookbook which requires a more recent version of chef-client - that's probably a separate RFC though.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.