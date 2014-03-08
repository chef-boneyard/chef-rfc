# Anonymous resources and simplification of conditionals

Anonymous resources are a proposed extension of the Chef domain-specific language (DSL) to
allow the use of Chef resources within a guard expression (i.e. "only\_if" or
"not\_if" block). The goal is to reduce the complexity in both number of languages
and boilerplate code required to coerce interpreted script language results
into meaningful Boolean guard conditionals. Anonymous resources make the Chef DSL
delightful.

## Document status

This document is a request for discussion and suggestions for improvement of
the Chef open source project at https://github.com/opscode/chef. Please refer
to https://docs.opscode.com or https://github.com/opscode/chef for the current
and accepted specification of Chef.

## Motivation
An open source ticket for the Chef project describes part of a problem
encountered by users of Chef:
[CHEF-4553](https://tickets.opscode.com/browse/CHEF-4553). In particular, that
ticket posits that Windows users of the powershell\_script resource expect
that guards (i.e. the only\_if and not\_if conditionals) evaluated in the context of a powershell\_script
block use the powershell\_script interpreter, not the cmd.exe (batch file)
interpreter. This is a change from the current state of affairs, since in general there is no link between the interpreter used by a
script resource. This is an issue that affects both Windows and *nix users.

Further detail and motivation for changing the status quo are given in sections at the
end of the document.

## Problems addressed

Anonymous resources and related improvements discussed in the document address
the following issues:

* CHEF-4553: Users of the powershell\_script resource are forced to execute
  script guards with CMD?s batch language instead of the PowerShell
  language.
* Users of the bash resource who want to use bash in script guards must explicitly invoke bash with properly quoted
  command arguments in the guard
* Windows users of the powershell\_script resource do not have a way to use
  PowerShell in script guards in a concise, intuitive, quasi-Boolean fashion,
  while users of the script, csh, bash, and other resources have this
* On Windows, script guards are always executed with the 32-bit process architecture and
  will be affected by the absence of system state exposed only to 64-bit
  processes
* 

# Anonymous resource specification

A functional version of the specification can be found at https://github.com/opscode/chef/tree/adamed-chef-4553-dsl-interpolated-status.

## Definitions
This document assumes familiarity with the Chef resource DSL, which is
documented at http://docs.opscode.com/chef/resources.html.

These definitions are used throughout the discussion:

* **Chef resource or resource:** an element of the Chef DSL that represents configuration, system components, or any other aspect of system state to be managed by Chef.
  The resource contains attributes that define the desired state, and an
  action that can be taken by a provider evaluating the resource such as one
  that changes the actual state of the system the desired state. State such as
  files, scripts, and software packages are examples of system that that can
  be modeled as a Chef resource.
* **guard:** An expression given as an attribute of a Chef resource in the
    form of a string to be executed by a shell or a Ruby block. Such an
    expression is evaluated before running the resource's action, and
    depending on whether it results in a true or false value, will control
    whether or not the resource?s action is executed or skipped.
* **script guard:** A guard expression that is given as a string to be
    evaluated by a shell command interpreter. When the interpreter's execution
    of the script results in a successful (i.e. non-zero) process exit code, the guard's value
    is **true**. Otherwise, it is **false**.
* **block guard:** A guard to which a Ruby block is passed rather than a string.
* **guard parameter:** Any Ruby expression passed as additional information to
    the shell interpreter used to modify execution context such as the current
    working directory, environment variables, user identity, etc.
* **anonymous resource:** A Chef resource that is not part of a Chef run
    context and is expressed within a block guard's block. The anonymous
    resource is simply used to assess a true or false value (e.g. whether a
    script that tests system state in a relevant way returns a success or
    failure process status) inside of a block guard. They are anonymous
    because unlike resources that are part of the chef-client's run context,
    anonymous resources have no unique name property because they exist in
    isolation as a form of Boolean expression, not as a unique part of the
    client's execution.

## Overview
Guard expressions for all resources will be extended to include a method and
block syntax like that used within the recipe DSL to enable the invocation
of actions on any Chef resource but in particular script resources. This is
useful for test conditions to ensure idempotence for non-idempotent resources such as script
resources. The goals in doing this are:

* Address [CHEF-4553](https://tickets.opscode.com/browse/CHEF-4553) -- simplify convoluted expressions such as that below for
Windows users
```
not_if 'powershell -noninteractive -noprofile -command "exit [int32]((Get-ExecutionPolicy -scope localmachine) -eq 'RemoteSigned')"'
```
* For guard expressions, allow Unix and Windows users to make use of familiar modern shells such as
  bash and PowerShell rather than ancient interpreters like sh or cmd.exe with
  limited or obscure syntax
* Make Chef interactions with OS interfaces such as shells as natural for
  users of the OS as possible

Alternative proposals are discussed in detail at https://gist.github.com/adamedx/c263ee69172daa216674.

## Summary of proposed changes
At a high level, here are the changes proposed to simplify conditional
execution of resource actions:

* Allow the Chef resource DSL to be used within a block passed to the guard
  attribute such that an action for any Chef resource can be executed within
  the guard
* Truth or false hood of such a guard is determined by whether the guard raise
  an unexpected exception or not
* Remove the identifier attribute of resources executed within a guard, since they are not in a
  runlist and need no unique identity
* Enable inheritance of attributes from a given resource A for any resource B
  executed as part of a block passed to a guard attribute of resource
  A
* Change the interpretation of Boolean error codes for PowerShell code
  executed by the powershell\_script resource so that it returns Boolean
  values the same way that Unix shells like bash do when they evaluate
  "Boolean-like" statements
* Use the PowerShell interpreter for string commands passed to guard
  attributes of the powershell\_script resource

## Code examples
The following examples demonstrate the intended use cases enabled by the change.

### Custom interpreter for script resources

```ruby

# This resource will run without errors because the guard uses
# the bash interpreter; if we had passed the same string
# directly to the only_if, this would have failed the
# Chef run since that string is not valid for /bin/sh
bash "Use bash for only_if" do
  code "echo I am $SHELL"
  only_if do
    bash do
      code '[[ 1 == 1 ]]' # won't work outside of bash
    end
  end
end
```

### Inheritance is your friend

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

### Setting guard parameters

```ruby

# The normal command string syntax for guards lets you
# specify parameters like cwd, etc. -- you can do the same
# here by specifying those parameters in the anonymous resource
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
```

### powershell\_script default behavior examples
The examples below are changes to the powershell\_script resource that take
advantage of anonymous resource support.

#### powershell\_script guard interpeter default example

```ruby

# Specifically for the powershell_script resource, you can just specify
# a command string, and it will be executed with powershell, not cmd
powershell_script "defaultguard" do
  code 'new-smbshare systemshare $env:systemdrive\'
  not_if 'get-smbshare systemshare' # This uses powershell, not cmd
end
```

#### powershell\_script Boolean behavior

```ruby

# What if guards evaluated powershell script code that powershell
# evaluates as a boolean type as the actual boolean value of the guard
# itself? You can avoid extra script code to translate the boolean into
# a process exit code that results in the right true / false behavior 
# for the guard
powershell_script "set execution policy" do
  code "set-executionpolicy remotesigned"
  not_if "(get-executionpolicy -scope localmachine) -eq 'remotesigned'" # Like I barely left Ruby -- wow!
end
```

#### powershell\_script architecture inheritance 

```ruby

# And look, the not_if will run as an :i386 process because of the
# architecture attribute for the parent resource which powershell_script
# anonymous resources will inherit from the enclosing resource
powershell_script "set i386 execution policy" do
  architecture :i386
  code "set-executionpolicy remotesigned"
  not_if "(get-executionpolicy -scope localmachine) -eq 'remotesigned'"
end
```

## Anonymous resource formal description

Anonymous resources' impact on the Chef DSL can be summarized as follows:

* Within a block passed as an argument to a guard, a resource block may be specified using a syntax similar to that used to specify a resource within a recipe
* Such resource blocks may not specify an identifier
* The resource block will automatically have a specific set of attributes set
  to values inherited from the same attributes in the resource that contains
  the guard
* The resource block will cause the block passed to the guard to be
  interpreted as a Boolean true if the resource executes without an exception
* If the resource block raises an exception when an action is run, the block
  passed to the guard is evaluated as false

In addition to these changes to the DSL, the following customizations are made
to the powershell\_script resources' guard implementation

* If a string rather than a block is passed to a guard attribute for a powershell\_script resource, the string will be evaluated by the PowerShell interpreter instead of the cmd.exe interpreter
* If the last expression evaluated by PowerShell for the given string results
  in a PowerShell boolean data type, the guard will evaluate with the
  same truth as that Boolean PowerShell expression, rather than true.

These changes are described in further detail below.

### Anonymous resource syntax

The syntax for resources and guards in the existing Chef DSL is the following

    resource ::= <resource_type_name> resource_identifier resource_block
    resource_block ::= do LINEFEED
        [attribute_assignment_sequence]
        LINEFEED end
    attribute_assignment_sequence ::= attribute_assignment |
        attribute_assignment LINEFEED attribute_assignment_sequence
    attribute_assignment ::= <attribute_name> ruby_expression |
        guard_conditional
    ruby_block ::= do LINEFEED
        [ruby_code]
        LINEFEED end
    guard_block ::= ruby_block
    guard_conditional guard_type ruby_string | ruby_block
    guard_type not_if | only_if

Anonymous resources add additional productions to the syntax:

    guard_block ::= do LINEFEED
        anonymous_block
        LINEFEED END
    anonymous_block ::= <resource_type_name> resource_block
    anonymous_block ::= guard_block

As earlier examples imply, anonymous resources augment only\_if and not\_if
attributes by allowing the block arguments for those attributes to contain a
block of code that resembles a resource as it is expressed via the Chef
resource DSL, except that an identifier for the resource is
not permitted. Any such identifier is superfluous, since these resources are
not part of any recipe, and thus do not require a unique identifier.

Note that the powershell\_script resource will build on these features and add
specific customizations that allow for usage of the PowerShell language via
this resource to be much more intuitive within the context of Chef's
Ruby-based syntax.

### Conditional semantics

Guards are ultimately evaluated as expressions with a Ruby Boolean value, i.e.
**true** or **false** in the Ruby language. As indicated in the syntax
description, either a **string** or **block** may follow the not\_if or
only\_if terminal:

* When a string is passed to a guard, the existing implementation executes the /bin/sh interpreter on Unix or
cmd.exe on Windows with that string to be evaluated as a script by the
interpreter. If the interpreter exits with a 0 (success) code, this is
interpreted as a Boolean true, otherwise it is false.
* When a block is passed to a guard, the code in the block will be executed,
  and the value of the last line of code executed by the block will be the
  Boolean value of the block, converted to a Boolean value in a manner
  consistent with the Ruby \!\! operator.
  
The behaviors above precede this proposal and are active in Chef 11.10 and
earlier versions.  
  
Anonymous resources are an extension of the latter case, where a resource block is
defined within the block passed to the guard and an action on the resource is executed. The truth value of
that resource block is the truth value of the guard passed to the block, and
the value is defined in the following way proposed for Chef 11.12 and later:

* If the resource action executes without raising an exception, the value is **true**
* If the action raises a resource-defined set of handled exceptions during
  execution, the values is **false**
* If any other exception occurs during execution of the action, the resource
  containing the guard will fail execution with that exception, which will
  ultimately terminate the Chef run as a failure

### script resource conditional semantics
To enable the usage as guard resources of resources derived from **Chef::Resource::Script**,
known colloquially as script resources, all such resources when executed as
guard resources will handle the exception **Mixlib::Shellout::ShellCommandFailed**. 

By doing this, usage of script resources has the same conditional and
exception behavior as the case described earlier when a string is passed to a
not\_if or only\_if guard attribute since this exception is raised precisely
in the case where a string passed as a guard would have been evaluated by
/bin/sh or cmd.exe as exiting with a failure status code.

This gives any script resource, for example bash, the ability to behave
like the string argument usage for guards except that an alternative
interpreter to /bin/sh is used to execute the command. This extends the range of shell
script languages that may be used in guard expressions.

### powershell\_script conditional semantics

The powershell_\script resource receives an additional behavior change
affecting the semantics of string passed as arguments to guards:

* When a the guard attribute of a powershell\_script resource is passed a
  string as a command to execute, it is executed with the PowerShell
  interpreter instead of the cmd.exe interpreter
  
This addresses [CHEF-4553](https://tickets.opscode.com/browse/CHEF-4553) -- the current requirement for someone who needs to
use the powershell\_script resource and would like to use the same PowerShell
language in the expression passed to the guard is below:

```ruby

# Yuk. Let me look up all the right cli args to powershell.exe.
# Oh, do I have to quote my cmd -- what kind of quotes again?
# So much fun for me. This is CHEF-4553.
powershell_script "oldguard" do
  code 'new-smbshare systemshare $env:systemdrive'
  not_if 'powershell.exe -inputformat none -noprofile -nologo -noninteractive -command get-smbshare systemshare'
end
```

With the change to allow strings passed to guards in the
powershell\_script resources to be interpreted as PowerShell script, we have
the following more concise, less cumbersome, and less error-prone expression:

```ruby

# So PowerShell. Such short.
powershell_script "oldguard" do
  code 'new-smbshare systemshare $env:systemdrive'
  not_if 'get-smbshare systemshare'
end
```

### powershell\_script Boolean result code interpretation

Boolean result code interpretation allows guards that make use of the
powershell\_script resource to treat PowerShell Boolean expressions as if they
were Ruby boolean expressions as in the code below:

```ruby

powershell_script "backup-dc" do
  code "backup-domain-controller.ps1"
  only_if "[Security.Principal.WindowsIdentity]::GetCurrent().IsSystem"
end
```


More formally, the value of guard conditionals for powershell\_script gets the following
modification:

* The process exit code for a PowerShell script fragment executed by the
  powershell\_script resource will support passing a the value of a Boolean
  expression from the script through the interpreter exit code
* Boolean interpretation is only valid if the script fragment could have been
  executed as the definition of a PowerShell function with a return type of
  **bool**, a PowerShell type analogous to a typical Boolean data type.
* In this case, if the function return value is the PowerShell value **$true**,
  the exit code is 0 (overloaded with 'success'), otherwise function return
  value is **$false** and the exit code is 1.
* In cases where the hypothetical function raises an exception or returns a
  type other than **bool**, preexisting exit code rules hold.
  
Currently, script code that resulted in a type other than **bool** for the
last line executed will always return 0. This new behavior for
powershell\_script is actually functionally equivalent to the behavior of the bash shell.

#### convert\_Boolean\_return\_code attribute
The convert\_Boolean\_return\_code attribute of the powershell\_script
resource allows users to revert the
interpolation behavior to provide the same exit code behavior that preceded
the interpolation change.

The default value of convert\_Boolean\_return\_code if not specified is **true**, which means that if the
PowerShell language would have evaluated the script defined in
powershell\_script's code attribute as having a Boolean type (PowerShell, like
Ruby, is a typed language), the process exit code will be **0** if the value of
the script fragment is **true** in the PowerShell language, otherwise it will
be **1**.

#### Motivation for Boolean result code
Consider the Chef DSL fragment below where a string passed to an only\_if guard performs a
Boolean test using the sh "[" command:

```ruby

bash "systemrestart" do
  code '~/rebootnow.sh'
  only_if '[ "$USER" == "root" ]'
end
```

This results in the bash script 'rebootnow.sh' being executed only when this
code is executed with chef-client running as root. The Boolean-like expression
in the sh script passed to the guard is treated as a Boolean result for the
guard, resulting in a natural way of using the sh interpreter from within Chef
and Ruby.

A similar mapping between Boolean results for strings passed to guards on the
Windows platform does not exist. This partially due to guards always being
executed with cmd.exe. However, the behavior shown on Unix guards that
interpret script strings is actually present in the script resources
themselves when the same Boolean-like code is executed as part of the **code**
attribute. Here's an example:

```ruby

bash "myfail" do
  code '[ "$USER" == "root" ]'
end
```

If this resource is run as the root user, it will succeed and subsequent
resources in the recipe can be executed. If the user is not root, this will
result in /bin/sh returning a non-zero exit code, and the execution will fail,
terminating any chef-client run.

While the utility of translating Boolean values to interpreter exit codes is debatable within a resource executed
at recipe scope, it is consistent with the much more useful guard behavior
described in the previous example.

Contrast this to the existing powershell\_script resource, which does not interpolate
Boolean results of scripts to exit codes consistent with truth or falsity in
any context. The added interpolation for powershell\_script rectifies the
deficiency in this resource compared to bash and the other Unix shell-based resources.

##### Boolean symmetry with Unix shells
This proposed boolean behavior is similar to the bash or sh interpreters, where the
Boolean-like result of the test command causes the interpreter process to exit with 0 if
the test command resulted in a true result, 1 otherwise, assuming the test
command was the last line of the script.

This enables cases where a test that can be expressed very cleanly with
the PowerShell language can be used directly within a guard expression with no
need to try to generate a process exit code that Chef will interpret as a true
or false value. For example, the true or false value of a PowerShell
expression like 

    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).
      IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

or

    (gi WSMan:\localhost\Shell\MaxMemoryPerShellMB).value -ge 300

can be passed directly to Ruby and evaluated as true or false by the guard
without specifying any additional PowerShell code. This interpolation of
Boolean return values also happens when a string of code is passed to a guard
in a powershell\_script resource, a scenario that builds on top of the
previously described switch to the PowerShell language as the script interpreter of
strings passed to guards in the powershell\_script resource.

Since it is possible that usage of powershell\_script that predates this
feature could be affected by this conversion, the **convert\_Boolean\_return**
attribute of powershell\_script may be set to false to restore preexisting behavior.

### Attribute inheritance
A new change is that a resource used within the context of a guard may inherit
some attributes from the resource that contains the guard. 

Inheritance follows these rules:

* An attribute in an anonymous resource is inherited from the parent resource only if the
  attribute is in a set of inheritable attributes defined by the type of the
  guard resource
* To be inherited, the attribute must not have been specified in the guard
  resource.
* For all resources except for powershell\_script, inheritance occurs only
  when the guard is given a block argument, but not with a string argument.
* The Chef execute resource and all resources derived from it,
  including script, bash, and powershell\_script, can inherit the following
  attributes from the parent resource:


    :cwd
    :environment
    :group
    :path   
    :user
    :umask

* Resource types may define additional rules for inheritance -- the
  powershell\_script resource has additional behaviors described in a
  subsequent section.

In general, the utility of inheritance derives from a common case where setting system
configuration through a Chef resource requires some external state such as an
environment variable, alternate user identity, or current directory, and
testing the current state to ensure idempotence through a guard requires the
same state. Inheritance enables that state to be expressed exactly once
through the Chef DSL.

### Simplification through attribute inheritance

Consider the following example:

```ruby

script "javatooling" do
  environment {"JAVA_HOME" => '/usr/lib/java/jdk1.7/home'}
  code 'java-based-daemon-ctl.sh -start'
  not_if 'java-based-daemon-ctl.sh -test-started', :environment =>
    {"JAVA_HOME" => '/usr/lib/java/jdk1.7/home'}
end
```

In the not\_if attribute, the same hash of environment variables specified for
the resource must also be specified for the guard, both of which use a shell script
to that relies on the **JAVA_HOME** environment variable. With inheritance,
the second environment variable specification (along with the possibility of
an incorrect specification) can be eliminated with this simplified version:

```ruby

script "javatooling" do
  environment {"JAVA_HOME" => '/usr/lib/java/jdk1.7/home'}
  code 'java-based-daemon-ctl.sh -start'
  not_if 'java-based-daemon-ctl.sh -test-started'
end
```

The simplification is more pronounced in conjunction with the changes that
allow arbitrary resources to be used as guards. Consider this usage of guard resources:

```ruby

bash "javabashtooling" do
  environment {"JAVA_HOME" => '/usr/lib/java/jdk1.7/home'}
  code 'java-bashd-ctl.sh -start'
  not_if do
    bash do
      environment {"JAVA_HOME" => '/usr/lib/java/jdk1.7/home'}
      code 'java-bashd-ctl.sh -test-started'
    end
  end
end
```

Through inheritance, the second environment attribute in the fragment above
can be removed since the same environment is simply inherited:

```ruby

bash "javabashtooling" do
  environment {"JAVA_HOME" => '/usr/lib/java/jdk1.7/home'}
  code 'java-bashd-ctl.sh -start'
  not_if do
    bash do
      code 'java-bashd-ctl.sh -test-started'
    end
  end
end
```

Further simplifications are available for powershell\_script scenarios, where a
more aggressive approach is taken by extending inheritance to not just block
parameters for guards, but string parameters as well.

#### powershell\_script inheritance rules

* For the powershell\_script resource, an additional attribute is inherited
  when this resource is used as a guard resource:
  
    :architecture

* When a guard attribute of powershell\_script is given a string rather than a
  block, unlike other resources, inheritance of attributes occurs. The
  behavior of the PowerShell interpreter when executing that string is the same
  as if a powershell\_script resource has been passed instead with the
  **code** attribute set to the value of the string.
* Inherited attributes in this case may be overridden by specifying those same
  attributes as guard parameters using the existing guard parameter syntax

This results in a relatively more concise expression of the resource compared
to the situation without inheritance for string arguments. For example,
without allowing the architecture attribute to be inherited with a string
guard, here is the recipe fragment we'd need to set the PowerShell execution
policy for the x86 PowerShell interpreter:

```ruby

# This is what we'd write if we couldn't inherit the architecture
# attribute when a string is passed to a guard -- we'd use a block
# instead to set x86 PowerShell execution policy
powershell_script "set i386 execution policy" do
  architecture :i386
    code "set-executionpolicy remotesigned"
    not_if do
      powershell_script do
      architecture :i386
      code "(get-executionpolicy -scope localmachine) -eq 'remotesigned'"
    end
  end
end
```

By allowing inheritance, the expression is much more compact, requires less
up-front consideration of options, and provides the least surprising behavior:

```ruby

# Much more concise -- architecture attribute is inherited by the guard
powershell_script "set i386 execution policy" do
  architecture :i386
  code "set-executionpolicy remotesigned"
  not_if "(get-executionpolicy -scope localmachine) -eq 'remotesigned'"
end
```

# Questions
Here are a few questions:

* The intent behind this DSL modification is better support for guards -- do
  we foresee other side effects (positive or negative) beyond the intended
  usage?
* Should we restrict the guard behavior to script resources only?
* Should we restrict the frequency of resource blocks within guards to occur
  only 0 or 1 times since the use case for more than one is unclear.
* The interpretation of resource action execution into a Boolean value is
  currently based on whether or not it returns an exception. This is somewhat
  arbitrary -- we could allow for some other truth mapping.
* Should the implementation enforce that only one anonymous resource may be used
  within the block provided to the not\_if or only\_if attribute? There is no
  use case for more than one.
* Should we use the **convert\_Boolean\_return** attribute to allow for
  backward compatibility with the powershell\_script resource in Chef 11.6 -
  11.10? Or should we simply make the behavior the default and dispense with
  the new attribute?
* Should string guards for all script resources, not just powershell\_script,
  support attribute inheritance? If so, should the capability be configurable?
* Nesting of resources is also allowed -- should it be disallowed?

# Detailed motivation -- why the change?
The existing behavior is actually by design, but it's not delightful,
particularly for PowerShell users on Windows. Current behavior is that when a
string is supplied to a guard, on Unix it is **always** evaluated with
/bin/sh, even if the guard is being executed in the context of a script
resource that executes code using something other than sh, like the bash
resource. On Windows, there is no /bin/sh, so cmd.exe is what is always used.

Both Unix and Windows experiences could be better. For Windows, cmd.exe is
guaranteed to exist on the system, but that's about as much good as you can
say for it. It's a vestigial component that still shows signs of its 1970's
CP/M heritage even in 2014, and as Windows admins turn to PowerShell or are
nudged toward it (often by Microsoft itself), it's asking a lot for people to know
how to use legacy cmd to accomplish tasks. Most likely, users of powershell\_script
will choose to run powershell.exe in the not\_if and only\_if blocks, and if
that's the common case, the guards should have some way to allow that, or to
provide this functionality in a more natural fashion. 

Even for Unix users, however, there is still room to be delightful since
/bin/sh, while not the antediluvian relic that is cmd.exe on Windows, is
certainly not a modern shell. Thus the usage of requires users of, say, the bash resource,
to use two different shell dialects. The bash dialect is a modern and familiar one for the code to be
executed by the script resource, and sh is a more limited one for the guards. It's confusing behavior
for new users. And even for those who are experienced,
it requires awkward workarounds like explicitly running bash with some set of
switches and/or researching workarounds for missing features in sh. Overall,
it decreases the efficiency of using resources like bash -- one might just as
well use the generic script or execute resources if knowledge of the best way
to a given interpreter cannot be contained in the resource.

