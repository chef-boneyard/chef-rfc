---
RFC: unassigned
Author: Nicholas Carpenter <ncarpenter@ebsco.com>
Status: Draft
Type: Standards Track
---

# Title

Signal outside tools of specific Chef-Client run status.  Ability to determine different results of a Chef-Client run.

## Motivation

    As a Chef user,
    I want to be able to determine when a chef-client run is rebooting the node,
    so that Test-Kitchen/Vagrant/any outside tool can wait for node to reboot, and continue converging.
    
    As a Chef user,
    I want to be able to determine when a chef-client run succeeds but fails Audit mode,
    so I can tell if converge failed and/or auditing failed.
    
    As a Chef user/support engineer,
    I want to know which stage of a chef-client run failed (Compile, Converge, etc),
    so that I can limit my debugging of failed chef-client runs
    

## Specification
* Chef-apply, Chef-client, Chef-Solo should honor the below exit chef run exit codes
* Knife bootstrap and Knife windows bootstrap should honor bootstrap exit codes

### Exit Code Ranges
Multiple exit code ranges should be supported.  This allows reasoning of which components are trying to signal the external tools.  Also this will allow future expansion of this Spec to include additional codes.  
 * Example - additonal phases of Chef-client run.

### Exit code ranges/codes to exclude
* Windows - [1 - 16000](https://msdn.microsoft.com/en-us/library/windows/desktop/ms681381(v=vs.85).aspx)
* Linux 1 - 255 - [Sysexits](http://www.freebsd.org/cgi/man.cgi?query=sysexits&apropos=0&sektion=0&manpath=FreeBSD+4.3-RELEASE&format=html), [Bash Scripting](http://tldp.org/LDP/abs/html/exitcodes.html), Linux generally supports this range
 
### Ranges
Exit Code Range      | Enumeration Meaning                  |Details
-------------       | -------------|                        -----
20000-20999          | Chef Phase Failures                  | Any Chef specific Phase failure. Compile, Converge, Audit, etc  Further subdivide into smaller subsets.
24000-24999         | Reboot, or other user requirement    | Any exit code for rebooting, reboot pending, etc.
25000-25999         | Bootstrap Failures                    | Specific reasons why bootstrap failed.  i.e. Download of chef-client installer failed, Install failed, Authentication, 

#### Precedence
* Chef-Client order of precendence (highest on top):
    1. Reboot, any other use interactions 
    2. Chef Phase Failures

#### Chef Phase Failures
Exit Code           | Phase                             |Details
-------------       | -------------|                    -----
20001               | Get configuration data            | [See here](https://docs.chef.io/chef_client.html)
20002               | Authenticate to the Chef Server   | [See here](https://docs.chef.io/chef_client.html)
20003               | Get, rebuild the node object      | [See here](https://docs.chef.io/chef_client.html)
20004               | Expand the run-list               | [See here](https://docs.chef.io/chef_client.html)
20005               | Synchronize cookbooks             | [See here](https://docs.chef.io/chef_client.html)
20006               | Reset node attributes             | [See here](https://docs.chef.io/chef_client.html)
20007               | Compile the resource collection   | [See here](https://docs.chef.io/chef_client.html)
20008               | Converge the node                 | [See here](https://docs.chef.io/chef_client.html)
20009               | Update the node object            | [See here](https://docs.chef.io/chef_client.html)
20010               | Process exception/report handlers | [See here](https://docs.chef.io/chef_client.html)
20011               | Audit Mode                        | [See here](https://docs.chef.io/chef_client.html)

#### Reboot or other User Requirement
Exit Code           | Phase                 |Details
-------------       | -------------|        -----
24001               | Reboot Scheduled      | Reboot has been scheduled in the run state
20002               | Reboot Pending        | Reboot needs to be completed 
20003               | Reboot Now            | Reboot being scheduled means it might run eventually.  Forced means its rebooting now
20004               | Reboot Failed         | Initiated Reboot failed - due to permissions or any other reason




## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.