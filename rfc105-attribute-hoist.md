---
RFC: 105
Title: Integrate hoisting of policy\_group attributes
Author: Thom May <thom@may.lt>
Status: Final
Type: Standards Track
---

# Integrate Hoisting in core Chef

Most users of Policies rely on "hoisting" to provide group specific
attributes. This approach was formalised in the `poise-hoist` extension,
which we'd like to move in to the Chef Client and formalise.

To hoist an attribute, the user would provide a default attribute
structure in their Policyfile similar to:
```
default['staging']['myapp']['title'] = "My Staging App"
default['production']['myapp']['title'] = "My App"
```
and would access the node attribute in their cookbook as:
```
node['myapp']['title']
```
The correct attribute would then be provided based on the `policy_group`
of the node, so with a `policy_group` of `staging` the attribute would
contain "My Staging App".


## Motivation

    As a cookbook author,
    I want to write cookbooks generically,
    so that they work in any operational context.

    As an operations engineer,
    I want to leverage policy groups to describe my estate,
    so that I can isolate environments correctly.

## Specification

Hoisting will be enabled by default for all Policyfile using chef-client
runs. We will not inherit the data bag hoisting that poise-hoist
supports.
Attributes of the form `policy_group`.`<path>` will be made available as 
`<path>`, at the level of `role_default` or `role_override`, which is where
Policyfile `default` or `override` attributes are levelled currently.

## Downstream Impact

Poise-hoist will not be required in chef client 14.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
