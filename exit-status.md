---
RFC: unassigned
Author: Nicholas Carpenter <ncarpenter@ebsco.com>
Status: Draft
Type: Standards Track
---

# Title

Signal outside tools of specific Chef-Client exit status. 

## Motivation

    As a Chef user,
    I want to be able to determine when a chef-client run is rebooting the node,
    so that Test-Kitchen/Vagrant/any outside tool can wait for node to reboot, and continue converging.
    
    As a Chef user,
    I want to be able to determine when a chef-client run succeeds but fails Audit mode,
    so I can tell if converge failed and/or auditing failed.
    
    As a Chef user,
    I want to know which stage of a chef-client run failed (Compile, Converge, etc),
    so that I can limit my debugging of failed chef-client runs

## Specification

Chef-apply, Chef-client, Chef-Solo should honor the below exit codes.  
### Use Exit codes
Enumeration      | Exit Code    |Description
-------------    | -------------| -----
Success          | 0            | When Chef executes with a successful convergence and Audit Success
Generic Failure  | 1            | When Chef executes and fails at convergence
Compile Failure  | 50           | When Chef executes and Compile time phase fails
Reboot           | 51           | When Chef executes and reboot is scheduled
Audit Failure    | 52           | When Chef executes and chef succeeds but Audit fails

This list should be able to be expanded.  We should be conscious of typical exit codes that are used.  Example, Windows exit code 5 is commonly used for access denied.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
