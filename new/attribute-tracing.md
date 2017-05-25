---
RFC: unassigned
Author: Clinton Wolfe <clintoncwolfe@gmail.com>
Status: Draft
Type: Standards Track
---

# Robust Attribute Tracing Support

Provide a way for tracing when, where, and how node attributes 
are set during a chef client run.

Intended to inform, and occur alongside, any attribute reimplementation work in the 12.x series.

## Motivation

    As a chef user,
    when a node attribute's final value is not what I expected,
    I want to be able to see every attribute change (including details about origin and precedence level)
    so that I can pinpoint the source of the incorrect value
    and fix my infrastructure quickly

    As a chef user,
    when I want to investigate an attribute issue,
    I want to be able to enable tracing on a per-node basis
    so that tracing performance will only impact the machines that I select

    As a chef user,
    when there is no issue to investigate,
    I want attribute tracing to have almost no performance impact when disabled
    so that chef client performance remains acceptable

    As a new user of chef,
    I want to enable attribute tracing,
    so that I can learn more about attribute merging and precedence from direct experimentation

    As a developer of code that integrates with chef client code,
    I want to be able to register event listeners against the attribute mutation system
    so that I can implement unforeseen features

## Specification

Needs community input & iteration.

The suggested feature is some kind of interface, perhaps on Chef::Node::Attribute, 
that allows code to register as a listener for attribute changes (set, delete).  One 
implementation of a listener would be provided, that receives mutation events and 
immediately emits log messages.  A config option would allow enabling or disabling 
tracing, as well as possibly focusing the tracing to one particular 'path' of the 
attribute tree.

There are some spec tests included in https://github.com/opscode/chef/pull/1373, but 
that may not be what people want; and it does not address the existence of an 
real Observable interface.


## Rationale

When supporting Chef in the wild, operations engineers with limited Chef exposure
are often confronted with diagnosing problems like "how did that wrong setting 
end up in that file?".  Tracing that value back into the template and recipe 
is required, but then the engineer often is confronted with node[:something], 
which may have originated from any number of places (environments, roles, cookbook 
attribute files, command-line JSON flags, dynamic code in recipes) - and then there
are the many precedence levels to deal with.  This complexity is very hard for even an
experienced Chef specialist to reason about, and leads to a lot of frustration.  
Incidents are lengthened as engineers sort through the various possibilities, some of 
which are greppable, some of which are not.  

This originated from https://github.com/opscode/chef/pull/1373, which included a proof-of-concept
implementation of tracing against chef client 11.6 . Additionally, it was demoed live 
at ChefConf 2014, http://youtu.be/iauJ9hiAE04?t=32m20s . 


## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
