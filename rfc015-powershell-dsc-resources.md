Chef resources for PowerShell Desired State Configuration
=========================================================

Chef language and conceptual artifacts share direct analogs with the PowerShell Desired State Configuration (DSC) platform
introduced with PowerShell 4.0. DSC is becoming a popular automation standard for the Microsoft Windows operating system. By
exposing DSC analogs in the Chef domain specific language, users of Chef gain all the *Delightful(tm)* benefits of DSC's wide scope of configuration capabilities.

## Document status

This Request for Comments (RFC) document proposes modifications to Chef Client and related components and is currently open for comments.

Specifically, the document specifies the new resources and other changes related to surfacing capabilities of PowerShell 4.0
Desired State Configuration (DSC).

## Motivation

PowerShell DSC, like Chef, presents an interface and implementation for managing the state of an operating system
instance. Entities such as files, environment variables, system services, and even applications such as database or web servers,
can be managed through DSC in the same manner as they can through Chef. Because DSC today exposes many resources not currently
available to the same degree, if at all, in Chef on windows, a natural question arises as to the utility of "mapping" resources
between the two systems. Specifically, can Chef take advantage of its similarity to DSC such that Chef can also manage those
resources for which only DSC, and not Chef itself, has a management implementation, and do so seamlessly in the eyes of Chef
users and toolsets?

To get a sense of what might be possible when integrating these systems, it is useful to look at the aforementioned similarities
which are listed in the table below:

| DSC Concept / Characteristic | Chef Analog | Area of concern |
|------------------------------|-------------|----------------|
| Configuration as code | Same | User intent | 
| DSC DSL | Chef DSL | User intent |
| DSL language substrate -- PowerShell | DSL substrate -- Ruby | User intent |
| Resource                     | Resource    | User intent |
| Resource idempotence | Same | Resource |
| Property | Attribute | Resource |
| `set` method of resource | Converge actions | Resource |
| `test` method of resource | LoadCurrentResource / whyrun | Resource |

The areas of sameness suggest integration points for which there is likely to be the most direct translation between systems and
thus the most natural experience for Chef users when such a translation is invoked. These areas are:

* Language expression: Both systems expression configuration as domain specific languages embedded within a general-purpose
  scripting language. Additionally, they share the same concept of *resource*, which is named both named identically in each
  system and has essentially the exact same semantic meaning in terms of the desired state of the system.
* Resource concept: Not only is the concept of *resource* the same in both DSC and Chef, it is surfaced in the respective DSL's
  in nearly identical fashion and the same guarantees around idempotence / convergence. For example, in both systems the
  resource concept surfaced in the DSL expresses desired state by stating characteristics of the actual underlying
  resource. These characteristics of the desire state of the resource are referred to as *attributes* in Chef and *properties*
  in DSC, both of which have the same meaning. This suggests a direct mapping between DSC and Chef properties and attributes and
  thus resources.
  
## Problems addressed 

This proposal to provide Chef resources for interaction with DSC addresses the following issues:

* **Broadening the universe of manageable entities in Chef:** In order to manage some aspect of a system (e.g. installed
  applications / packages, component configuration, etc.) that aspect is typically exposed in Chef as a Chef resource (or an
  attribute of a resource) in the Chef DSL. Resources must be authored as an implementation in the Chef runtime itself or in the
  cookbooks which extend Chef. If a resource for some system component or behavior is not authored, it's not easily manageable
  by Chef. Since DSC already does and will continue to provide implementations of these system aspects through its own language
  entity with the same semantics as Chef resources, allowing those DSC resources to be re-used from Chef expands the sets of
  things that can be managed naturally in Chef (i.e. without resorting to executing scripts, which lack automatic idempotence
  and convergence properties).
* **Staying current with the latest Windows operating system and application features and fixes:** A challenge with providing Chef
  resources for operating system and application components is keeping up with new releases of the software. As software is
  updated or released, Chef or Chef cookbooks that provide resources for user in other cookbooks may need to be updated to take
  advantage of new features. Because DSC is an operating system component in Windows Server 2012 R2 and later versions, DSC on
  the Windows platform will have resources for the latest features of Windows. And since DSC resources are also distributed as
  PowerShell modules that are released along with relevant applications (e.g. PowerShell modules for the SQL Server application
  that are released along with SQL Server), DSC is also a way to access the most up-to-date methods for configuring such
  applications. By enabling the use of DSC resources from within Chef recipes, Chef users are able to implement cookbooks that
  will continue function across OS and application revisions as they are released without the need to wait for the community to
  develop the expertise needed to update Chef cookbooks that require low-level access to OS and application components.
* **Making efficient use of the Chef community's time**: The time required to research the correct way to model system
    configuration for new and updated low-level components can be a significant investment by the Chef community, particularly
    given the large number of such resources. Much of this work requires fairly detailed understanding of narrow aspects of the
    system. DSC resources provide just such expertise across a wide range of Windows versions and applications, so re-using
    these resources from within Chef reduces the amount of research and maintenance required to have access to system
    configuration, particularly on newer iterations of the Windows operating system for which DSC has the broadest configuration surface.

In general, DSC expands Chef's universe of manageability, timeliness with new OS and application support, and conserves the Chef
community's time. Development of higher-level Chef cookbooks and infrastructure based on Chef can be accelerated when Chef can
utilize DSC from within recipes.

## Definitions
This document assumes familiarity with the Chef resource DSL, which is
documented at <http://docs.opscode.com/chef/resources.html>.

## Overview

Integration of Chef and DSC is defined in the following fashion:

*Chef should surface DSC's configuration management capabilities from within Chef recipes*.

This means the integration allows Chef users to make use of DSC. This integration will be accomplished by providing Chef
resources which expose DSC functionality. These Chef resources are:

* `dsc_resource`: Allows a named DSC resource to be used with Chef resource semantics and pure Chef language syntax
* `dsc_script`: Allows specified PowerShell language script to be executed as a DSC configuration on the system
* `dsc_mof`: Allows Managed Object Format (MOF) code to be executed as a DSC configuration on the system

These resources make different tradeoffs between usability and full access to the DSC platform. For example, `dsc_resource`
usage is nearly identical to that of any other resource in the Chef DSL. Authors must be able to understand basic Chef DSL to
use it, but almost no knowledge of DSC other than the name of the DSC resource to be used and the DSC properties available for
that resource. Knowledge of DSC's DSL, PowerShell, or MOF is not needed with this resource, so it is ideal for users simply
looking for greater access to configuration who have not used DSC in other contexts.

The other resources, `dsc_script` and `dsc_mof` allow users who may have authored DSC code or at least have access to DSC
configuration artifacts (e.g. PowerShell scripts or MOF files) from other contexts to make use of that knowledge from within
Chef. They also have few restrictions on what features of DSC can be used, so limitations on the data types that can be
assigned to `dsc_resource` for example may be bypassed by using the less seamless `dsc_script` or `dsc_mof` resources.

### Simple examples

#### Create a group with DSC's `Group` resource

Here's how you create a group via DSC and the Chef `dsc_resource` resource:

```ruby
dsc_resource 'Chef Group' do
  resource_name :group
  property :GroupName, 'ChefUsers'
  property :MembersToInclude, 'administrator'
end
```

You could just use the DSC DSL in PowerShell directly if you like:

```ruby
dsc_script 'Chef Group DSC script' do
  code <<-EOH
  Configuration 'Chef users Group via DSC'
  {
    group 'ChefUsersGroup'
    { 
      Name = 'ChefUsers'
      MembersToInclude = 'administrator'
    }
  }
EOH
```

```ruby
dsc_mof 'Chef Group mof' do
  code <<-EOH
instance of MSFT_GroupResource as $MSFT_GroupResource1ref
{
ResourceID = "[Group]ChefUsersGroup1";
 MembersToInclude = "administrator";
 Name = "ChefUsers";
 ModuleName = "PSDesiredStateConfiguration";
 ModuleVersion = "1.0";
};

instance of OMI_ConfigurationDocument
{
 Version="1.0.0";
 Author="SysAdmin";
 GenerationDate="3/14/2014 1:41:42";
 GenerationHost="AdminBox";
};
EOH
end
```

If you use `dsc_script` or `dsc_mof`, it's actually less likely that you'll directly embed the explicity PowerShell or MOF code
in a recipe, and more likely that you already have PowerShell or MOF file artifacts that you'd like to re-use, like so:

```ruby
dsc_script 'Chef Group DSC script' do
  path "#{ENV['DSCDIR']}/scripts/chefgroup.ps1"
end
```

Or for MOF:

```ruby
dsc_mof 'Chef Group MOF' do
  path "#{ENV['DSCDIR']}/mofs/chefgroup/localhost.mof"
end
```

## Functional description

Details for this section coming soon.

### Requirements

### Chef resources for DSC

#### `dsc_resource` resource

#### `dsc_script` resource

#### `dsc_mof` resource

## Detailed examples

## Implementation notes

The initial implementation of this feature is assumed to function only on the Windows operating system, and requires PowerShell
4.0 or later.

## Future improvements

## Open issues

The following issues require specification before accepting the proposals in this document

* For DSC resource proeprties with non-trivial (e.g. types that inherit from System.Object in the CLR), how should they be
  translated from Chef / Ruby via the `dsc_resource` resource into a DSC-consumable artifact? The `PSCredential` type commonly
  used in PowerShell cmdlets is an example of such a type. One option is to disallow such types in `dsc_resource` and require
  the use of `dsc_script` or `dsc_mof` for this use case.

## References and further reading

* Chef documentation: <http://docs.opscode.com>
* Chef resource documentation: <http://docs.opscode.com/resource.html>
* DSC cookbook integration prototype: <https://github.com/opscode-cookbooks/dsc>. 
* Chef guard_interpreter documentation: <http://docs.opscode.com/resource_common.html>.
* Chef Client open source project: <https://github.com/opscode/chef>. 
