---
RFC: unassigned
Author: Nicholas Carpenter <ncarpenter@ebsco.com>
Status: Draft
Type: Standards Track
---

# Title

Signal outside tools of specific Chef-Client run status.  Ability to determine results of a Chef-Client run.

## Motivation
    As a Chef user,
    I want to be able to determine when a chef-client run is rebooting the node,
    so that Test-Kitchen/Vagrant/any outside tool can wait for node to reboot, and continue converging.
    
## Specification
* Chef-apply, Chef-client, Chef-Solo should honor the below exit chef run exit codes

### Exit codes reserved across platforms
* Windows- [Link](https://msdn.microsoft.com/en-us/library/windows/desktop/ms681381(v=vs.85).aspx)
* Linux - [Sysexits](http://www.freebsd.org/cgi/man.cgi?query=sysexits&apropos=0&sektion=0&manpath=FreeBSD+4.3-RELEASE&format=html), [Bash Scripting](http://tldp.org/LDP/abs/html/exitcodes.html)
 

### Exit Codes usable across platforms
All exit codes defined should be usable on all supported Chef Platforms.  Also the exit codes used should be idential across platforms.  That limits the total range from 1-255.  Exit codes not explicitly used by Linux/Windows are listed below.  There are a total of 59 exit codes that overlap between the two platforms.
 
 * Exit Codes Available for Chef use:
     * ~~35,37,40,41,42~~,43,44,45,46,47,48,49,79,81,90,91,92,93,94,95,96,97
     * 98,99,115,116,168,169,172,175,176,177,178,179,181,184,185,204,211
     * 213,219,227,228,235,236,237,238,239,241,242,243,244,245

### Precedence
* Reboot exit codes should take precedence over Chef Execution State
* Precedence within a table should be evaluated from the top down.
    *  Example - Audit Mode Failure would only apply on a successful execution.  But if the chef-run failed for any other reason, no reason to exit with audit mode.

## Exit Codes in Use

#### Reboot Requirement
Exit Code        | Reason            | Details
-------------    | -------------     |-----
35               | Reboot Scheduled  | Reboot has been scheduled in the run state
37               | Reboot Pending    | Reboot needs to be completed 
40               | Reboot Now        | Reboot being scheduled means it might run eventually.  Forced means its rebooting now
41               | Reboot Failed     | Initiated Reboot failed - due to permissions or any other reason


#### Chef Run State
Exit Code        | Reason             | Details
-------------    | -------------      |-----
0                | Successful run     | Any successful execution of a Chef utility should return this exit code
42               | Audit Mode Failure |  Audit mode failed, but chef converged successfully.
1                | Failed execution   | Generic error during Chef execution.  
-1               | Failed execution   | Generic error during Chef execution.  



## Extend
This RFC should be able to be ammended to include additional exit code functionality at a later date

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.