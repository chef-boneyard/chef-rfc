# Resource Guards

This document proposes extending the Chef domain-specific language (DSL) to
allow the use of resource blocks from within a guard expression (i.e. "only\_if" or
"not\_if" block) in order to reduce the amount of opaque embedded
external script code in such expressions.

## Motivation
This document proposes some general solutions to the specific issue raised with
[chef-4553](https://tickets.opscode.com/browse/CHEF-4553). In particular, that
ticket posits that Windows users of the powershell\_script resource expect
that guards (i.e. the only\_if and not\_if conditionals) evaluated in the context of a powershell_script
block use the powershell\_script interpreter, not the cmd.exe (batch file)
interpreter. This is a change from the current state of affairs, since in general there is no tie between the interpreter used by a
script resource, and thus this issue also affects non-Windows users.

Further detail and motivation for changing the status quo are given in sections at the
end of this document.

## Resource guard proposal

A functional version of the proposal can be found at https://github.com/opscode/chef/tree/adamed-chef-4553-dsl-interpolated-status.

Guard expressions for all resources will be extended to include a method and
block syntax like that used within the recipe DSL to enable the invocation of
resources with, particularly script resources, to test a condition useful for
implementing idempotence for non-idempotent resources such as script
resources. The goals in doing this are:

* Address CHEF-4553 -- simplify convoluted expressions such as that below for
Windows users
```
not_if 'powershell -noninteractive -noprofile -commmand "exit [int32]((Get-ExecutionPolicy) -eq 'RemoteSigned')"'
```
* For guard expressions, allow Unix and Windows users to make use of familiar modern shells such as
  bash and PowerShell rather than ancient interpreters like sh or cmd.exe with
  limited or obscure syntax.
* Make Chef interactions with OS interfaces such as shells as natural for
  users of the OS as possible

Alternative proposals are discussed in detail at https://gist.github.com/adamedx/c263ee69172daa216674.

### Code examples
The following examples demonstrate the intended use cases enabled by the change.

#### Custom interpreter for script resources

```ruby

    # This resource will run without errors because the guard uses
    # the bash interpreter; if we had passed the same string
    # directly to the only_if, this would have failed the 
    # Chef run since that string is not valid for /bin/sh
    bash "Use bash for only_if" do
      code "echo I am $SHELL"
      only_if  do
        bash do
          code '[[ 1 == 1 ]]' # won't work outside of bash
        end
      end
    end
```

#### Inheritance is your friend

```ruby

    # This resource will run because the cwd of the guard
    # is the same as that of the parent resource
    bash "My cwd gets inherited" do
      code 'echo inherit me'
      cwd '/opt'
      only_if do
        bash do
          code '[[ $PWD == "/opt" ]]' # Glad I didn't have to add cwd
        end
      end
    end
```


#### Setting guard parameters

```ruby

    # The normal command string syntax for guards lets you
    # specify parameters like cwd, etc -- you can do the same
    # here by specifying those parameters in the guard resource
    bash "Override my guard attributes" do
      code 'echo override me'
      cwd '/var'
      only_if do
        bash do
          cwd '/opt' # Don't try to put me in my place
          code '[[ $PWD == "/opt" ]]' 
        end
      end
    end
```ruby

#### Current Guard Behavior for powershell_script

```ruby

# Yuk. Let me look up all the right cli args to powershell.exe.
    # Oh, do I have to quote my cmd -- what kind of quotes again? So much fun
    # for me. This is CHEF-4553.
    powershell_script "oldguard" do
      code 'new-smbshare systemshare $env:systemdrive'
      not_if 'powershell.exe -inputformat none -noprofile -nologo -noninteractive -command get-smbshare systemshare'
    end
```

#### New powershell_script default behaviors
The examples below are changes to the powershell\_script resource that take
advantage of resource guard support.

##### PowerShell guard interpeter default

```ruby

    # Specifically for the powershell_script resource, you can just specify
    # a command string, and it will be executed with powershell, not cmd
    powershell_script "defaultguard" do
      code 'new-smbshare systemshare $env:systemdrive\'
      not_if 'get-smbshare systemshare' # This uses powershell, not cmd
    end
```

##### powershell\_script boolean behavior

```ruby

    # What if guards evaluated powershell script code that powershell
    # evaluates as a boolean type as the actual boolean value of the guard
    # itself? You can avoid extra scirpt code to translate the boolean into
    # a process exit code that results in the right true / false behavior 
    # for the guard
    powershell_script "set execution policy" do
      code "set-executionpolicy remotesigned"
      not_if "(get-executionpolicy) -eq 'remotesigned'" # Like I barely left Ruby -- wow!
    end
```

##### powershell\_script architecture inheritance 

```ruby

    # And look, the not_if will run as an :i386 process because of the
    # :i386 attribute for the parent resource
    powershell_script "set i386 execution policy" do
      architecture :i386
      code "set-executionpolicy remotesigned"
      not_if "if ((get-executionpolicy) -ne 'remotesigned') { exit 1 }"
    end
```

### Resource guard formal description

Resource guards' ipmact on the Chef DSL can be summarized as follows:

* Within a block passed as an argument to a guard, a resource block may be specified using a syntax similar to that used to specify a resource within a recipe
* Such resource blocks may not specify an identifier
* The resource block will automatically have a specific set of attributes set
  to values inherited from the same attributes in the resource that contains
  the guard
* The resource block will cause the block passed to the guard to be
  interpreted as a boolean true if the resource executes without an exception
* If the resource block raises an exception when an action is run, the block
  passed to the guard is evaluated as false

In addition to these changes to the DSL, the following customizations are made
to the powershell\_script resources' guard implementation

* If a string rather than a block is passed to a guard attribute for a powershell\_script resource, the string will be evaluated by the the PowerShell interpreter instead of the cmd.exe interpreter
* If the last expression evaluated by PowerShell for the given string results
  in a PowerShell boolean data type, the guard will evaluate with the
  same truth as that boolean PowerShell expression, rather true.

These changes are described in further detail below.

#### Resource guard syntax

As earlier examples imply, guard resources augment only\_if and not\_if
attributes by allowing the block arguments for those attributes to contain a
block of code that resembles a resource block, except that an identifier is
not permitted. Any such identifier is superfluous, since these resources are
not part of any recipe, and thus do not require a unique identifier.

Note that the powershell\_script resource will build on these features and add
specific customizations that allow for usage of the PowerShell language via
this resource to be much more intuitive within the context of Chef's
Ruby-based syntax.

##### Guard syntax for powershell\_script

#### Conditional semantics

##### PowerShell Conditional semantics

### Questions
Here are a few questions:

* The intent behind this DSL modifications is better support for guards -- do
we foresee other side effects (positive or negative) beyond the intended
  usage?
* Should we restrict the guard behavior to script resources only?
* The interpetation of resource action execution into a boolean value is
  currently based on whether or not it returns an exception. This is somewhat
  arbitrary -- we could allow for some other other truth mapping.

### Issues with current behavior -- why change?
The existing behavior is actually by design, but it's not delightful. Current behavior is that when a
string is supplied to a guard, on Unix it is **always** evaluated with
/bin/sh, even if the guard is being executed in the context of a script
resource that executes code using something other than sh, like the bash
resource. On Windows, there is no /bin/sh, so cmd.exe is what is always used.

Both Unix and Windows experiences could be better. For Windows, cmd.exe is
guaranteed to exist on the system, but that's about as much good as you can
say for it. It's a vestigial component that still shows signs of its 1970's
CP/M heritage even in 2014, and as Windows admins turn to powershell or are
nudged toward it (often by Microsoft itself), it's asking a lot for people to know
how to use legacy cmd to accomplish tasks. Most likely, users of powershell\_script
will choose to run powershell.exe in the not\_if and only\_if blocks, and if
that's the common case, the guards should have some way to allow that, or to
provide this functionality in a more natural fashion. 

Even for Unix users, however, there is still room to be delightful since
/bin/sh, while not the antediluvian relic that is cmd.exe on Windows, is
certainly not a modern shell and thus requires users of, say, the bash resource
to use two different dialects, a modern and familiar one for the code to be
executed, and a more limited version for the guards. It's confusing behavior
for new users. And even for those who are experienced,
requires awkward workarounds like explicitly running bash or researching
workarounds for missing features in sh.
