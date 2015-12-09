---
RFC: unassigned
Author: Nell Shamrell-Harrington <nshamrell@chef.com>
Status: Draft
Type: Process
---

# Cookbook Abandonment On Supermarket

The Chef community needs a process for handling cookbooks on Supermarket that have become abandoned.  This occurs when a cookbook owner does not respond to requests to adopt the cookbook or the cookbook has not been updated in some time and has untriaged pull requests/issues/etc (other criteria to be decided by the Chef Community).

## Motivation

```
    As a supermarket user,
    When I find a cookbook,
    And the cookbook is up for adoption,
    And I want to adopt the cookbook,
    And I request to adopt the cookbook, but get no response from the cookbook owner,
    I want the ability to have ownership transferred to me,
    So that I can update the cookbook

    As a supermarket user,
    When I find a cookbook that has not been updated in some time,
    And the cookbook is not up for adoption,
    And no response comes from the owner when I or the Supermarket team attempt to contact them,
    I want a process that is fair to the current cookbook owner, myself, and the larger Chef community,
    To allow me to take ownership of the cookbook
```

## Specification

### When the Cookbook is available for adoption

When a cookbook owner puts the cookbook up for adoption, that means they no longer wish to be the owner and maintainer of the cookbook.  When the owner puts the cookbook up for adoption, anyone who visits the cookbook's page on Supermarket will see a blue button that says "Adopt me!"  When a user clicks this button, an email is sent to the cookbook's current owner.  Occasionally, however, the cookbook's current owner does not respond to the email requests for adoption.

If a user has requested to adopt a cookbook and has not received a response from the cookbook's current owner within a week, they should reach out to the Supermarket team via email (currently nshamrell@chef.io and rkidd@chef.io).  The Supermarket team will then email the current owner directly.  If the Supermarket team does not receive a response from the current owner within an additional week, the Supermarket team will transfer ownership to the user who wishes to adopt the cookbok.

### When the Cookbook is not available for adoption

When a cookbook owner has NOT put a cookbook up for adoption, there is no concrete indication that they wish to transfer ownership of the cookbook.  However, occasionally cookbooks are abandoned and there is no current way to arbitrate transferring ownership to someone else.

If a cookbook has not been updated in some time/has many open and untriaged pull request and issues (plus any other criteria the community wishes to add) and a user is interested in taking ownership of the cookbook, they should reach out to the Supermarket team via email (currently nshamrell@chef.io and rkidd@chef.io).  The Supermarket team will then make every reasonable effort (including but not limited to email) to contact the cookbook's current owner.  If no response comes from the cookbook's current owner within a designated time period (time period to be decided by the Chef community)  of the Supermarket team attempting to contact them, the Supermarket team will try to contact them again.  If no response is received, the Supermarket team will transfer ownership to the user who wishes to take ownership of the cookbook.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
