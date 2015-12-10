---
RFC: unassigned
Author: Nell Shamrell-Harrington <nshamrell@chef.com>
Status: Draft
Type: Process
---

# Cookbook Adoption On Supermarket

## Motivation

```
    As a supermarket user,
    When I find a cookbook,
    And the cookbook is up for adoption,
    And I want to adopt the cookbook,
    And I request to adopt the cookbook, but get no response from the cookbook owner,
    I want the ability to have ownership transferred to me,
    So that I can update the cookbook
```

## Specification

When a cookbook owner puts the cookbook up for adoption, that means they no longer wish to be the owner and maintainer of the cookbook.  When the owner puts the cookbook up for adoption, anyone who visits the cookbook's page on Supermarket will see a blue button that says "Adopt me!"  When a user clicks this button, an email is sent to the cookbook's current owner.  Occasionally, however, the cookbook's current owner does not respond to the email requests for adoption.

If a user has requested to adopt a cookbook and has not received a response from the cookbook's current owner within 2 weeks, they should reach out to the Supermarket team via email (currently nshamrell@chef.io and rkidd@chef.io).  The Supermarket team will then email the current owner directly and make all other reasonable attempts to contact the owner.  If the Supermarket team does not receive a response from the current owner within a month, the Supermarket team will again attempt to contact the owner.  If the Supermarket team does not receive a response after attempting to contact the owner six times over six months, the Supermarket team will transfer ownership to the user who wishes to adopt the cookbok.

Once this process is adopted, automation should be investigated and presented in a later RFC.

Cookbooks that are not available for adoption on Supermarket are out of the scope of this RFC.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
