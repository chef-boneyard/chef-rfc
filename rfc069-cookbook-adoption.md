---
RFC: 69
Title: Cookbook Adoption On Supermarket
Author: Nell Shamrell-Harrington <nshamrell@chef.com>
Status: Accepted
Type: Process
---

# Cookbook Adoption On Supermarket

## Motivation

### When a Cookbook is Up For Adoption
```
    As a supermarket user,
    When I find a cookbook,
    And the cookbook is up for adoption,
    And the cookbook has been up for adoption for at least 6 months,
    Then the Supermarket team should be notified,
    And ownership of the cookbook should transferred to chef-brigade
```

### When a Cookbook is NOT Up for Adoption
```
    As a supermarket user,
    When I believe a cookbook should be transferred away from the current owner,
    Only in extreme cases (i.e. death of the current owner, long outdated but a major cookbook),
    I should open an [RFC](https://github.com/chef/chef-rfc)
    And request that the cookbook ownership be transferred
```

## Specification

### When a Cookbook is Up For Adoption

When a cookbook owner puts the cookbook up for adoption, that means they no
longer wish to be the owner and maintainer of the cookbook. At anytime a user
can click on the "Adopt Me!" button on the cookbook's page on Supermarket and
the current owner of the cookbook will be notified. The owner can then transfer
ownership to the user who wants it.

However, sometimes cookbooks remain up for adoption for 6+ months.  In this
case, the cookbook ownership will be transferred the chef-brigade.  This will
be done manually at first but may be automated in the future.

The chef-brigade will then take over responsibility for the cookbook.  At their
discretion, they can transfer ownership to someone else on Supermarket at any time.

### When a Cookbook is NOT Up For Adoption

It is not the normal policy of Chef to transfer ownership of a cookbook to anyone
else, that is left to the cookbook's current owner.  See above for guidelines on
when a cookbook has been placed up for adoption.

We do recognize, however, that extreme circumstances do happen (i.e. death of the
cookbook's current owner) and that sometimes a critical cookbook goes unmaintained.
In either of these cases a community member who wishes to take ownership
of the cookbook (or see ownership transferred to someone else with their
consent) is welcome to file an [RFC](https://github.com/chef/chef-rfc).

In cases where a critical cookbook is no longer being actively maintained by the
current owner (i.e. no commits on github and releases to supermarket for at least 6
months with multple open issues and PRs), a best effort must be made to contact the
author via at least 2 methods (i.e. email, slack, twitter) before opening an RFC to
transfer ownership.  If the current owner responds at any point before the transfer
occurs, the transfer process must stop if it has been started.  It is then up to the
current owner to decide if they with to proceed with the transfer themselves or not.

The RFCs will be decided on by the Chef Community on a case by case basis.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
