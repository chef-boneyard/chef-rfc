Chef resources for PowerShell Desired State Configuration
=========================================================

Chef language and conceptual artifacts share direct analogs with the PowerShell Desired State Configuration (DSC) platform
introduced with PowerShell 4.0. DSC is becoming a popular automation standard for the Microsoft Windows operating system. By
exposing DSC analogs in the Chef domain specific language, users of Chef gain all the *Delightful(tm)* benefits of DSC's wide scope of configuration capabilities.

## Document status

This Request for Comments (RFC) document proposes modifications to Chef Client and related components and is currently open for comments.

Specifically, the document specifies the new resources and other changes related to surfacing capabilities of PowerShell 4.0
Desired State Configuration (DSC).

Prototype source code in the form of a Chef cookbook for a subset of the functionality described in this document can be found
at <https://github.com/opscode-cookbooks/dsc>.

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

## Functional description

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

## Requirements

The integration of DSC into Chef has the following requirements:

* All interaction with DSC should happen through Chef resources in recipes
* There should be an "easy" resource usage that requires no knowledge of DSC syntax, only standard Chef DSL
* The easy mode should defend against script injection attacks
* There should be a more direct resource interaction that allows those with knowledge of or access to DSC native language
  artifacts defined with the PowerShell DSC or Managed Object Format (MOF) languages to use those languages from Chef recipes
* The resources that abstract the direct integration should automate all actual interactions with DSC subsystems such as the
  Local Configuration Manager.
* Errors returned from the Local Configuration Manager should be surfaced in Chef error output within the narrowest lexical
  scope possible to facilitate efficient debugging of recipes
* In order to use DSC resources in Chef, Users unfamiliar with DSC should not be required to understand beyond knowing the
following:
    * How to find the name and purpose of a useful resource from easily accessible documentation
    * How to find vendor-authored documentation for the resource
    * How to identify the names and meanings of the DSC properties of the resource
* For Chef resources used to access DSC, the Chef resource's idempotence in terms of changing state and reporting that the state was
  changed (or not) should mirror that reported by applicable underlying DSC resources


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

## Functional specification of Chef resources for DSC

This section describes the Chef resources that interact with DSC in terms of their attributes and general DSL usage within Chef
recipes. The behaviors implemented by the esources are also given in terms of how they would map to the equivalent PowerShell
script that would implement the intended configuration on the system. While this PowerShell-based description may strongly imply
an implementation for the Chef resources with regard to how they integrate with DSC, such an implementation is not in any way
advocated or mandated here, and is likely to deviate significantly if not completely from how a released implementation of this
document is realized.

### `dsc_resource` resource

The `dsc_resource` resource surfaces any DSC resource as an instance of `dsc_resource` within a cookbook. This allows users with
minimal knowledge of DSC resources to use the DSC resource within recipes.

#### `dsc_resource` actions

In addition to the standard `:nothing` action, this resource has the following actions

|Action|Description|
|------|-----------|
|`:set`|This is the default action. This action is used to enact DSC configuration specified by the resource's attributes by supplying that DSC configuration to the DSC Local Configuration Manager and requesting that the system be updated to reflect it. This resource is only updated if the LCM makes changes as part of the aforementioned interaction|
|`:test`|This action is similar to set, except that the LCM does not make changes, it only checks to see if changes to the system are needed to make the system compliant with the configuration expressed by the Chef resource. If changes are needed, the resource will be updated, otherwise it will not|

#### `dsc_resource` attributes

`dsc_resource` honors common resource attributes, as well as the following properties:

|Attribute|Description|
|---------|-----------|
|`resource_name`|The name of the DSC resource to use for configuration.|
|`property`| Optional. Multiple repetitions. This attribute is specified multiple times in each `dsc_resource`, once for each DSC resource property of the DSC resource type specified by `resource_name` that should be configured. The attribute takes two arguments -- a case-insensitive symbol that has the same lexical name as the DSC resource property and a second parameter for the value to which that property should be set|

In more detail, the `property` attribute has these behaviors:

* The second *value* argument of `property` must be one of the following types `String`, `Fixnum`, `Float`, `FalseClass`,
  `TrueClass`, `NilClass`, or `Chef::Resource::DscResource` or an exception is raised at compile time for the resource.
* The *value* argument will be converted to an equivalent .NET CLR data type since DSC consumes such types. The conversion will
  happen according to rules for type safety described in a subsequent section.
* If the `resource_name` attribute does not correspond to the name of DscResource installed on the system, an exception will be
  raised at converge time.
* For a given pair of *property name* and *value* passed to the `property` attribute, CLR type to which *value* is converted prior
  to submission to the LCM according to the aforementioned type rules **MUST** match the CLR type of the property specified by
  *property name* for the DSC resource specified by the `resource_name` attribute or an exception is raised at converge time.
* The same *property name* argument of the `property` attribute may not be specified more than once in a given `dsc_resource` block.

##### Type safety for `dsc_resource` `property` attributes

Prior to submitting configuration to DSC, values specified to the `property` attribute will be converted to CLR types based on the Ruby type used for the value according
to these rules:

|Ruby type|CLR type|
|---------|--------|
|`String`|`string`|
|`FixNum`|`int32`|
|`Float`|`double`|
|`TrueClass`|`bool`|
|`FalseClass`|`bool`|
|`NilClass`|`object`|
|`Chef::Resource::DscResource`|`OMI_Resource`|

Most of these type conversions should be umanbiguous and reversible, and mostly they should be direct and leave data
unchanged. The `String` conversion for example should require no actual type conversion. The conversion for `NilClass` would
simply present such a value as the CLR value `null`.

Classes of `Chef::Resource::DscResource` will result in the CLR representation of the DSC resource being assigned to a
property. This covers DSC use cases such as the following fragment of DSC PowerShell code below where an anonymous instance of
the `MSFT_xWebBindingInformation` DSC resource is used to express the configuration of the `BindingInfo` property of an
`xWebsite` instance:

```
  xWebsite NewWebsite
        {
            Ensure          = "Present"
            Name            = $WebSiteName
            State           = "Started"
            PhysicalPath    = $DestinationPath
            BindingInfo     = MSFT_xWebBindingInformation
                             {
                               Protocol              = "HTTPS"
                               Port                  = 8443
                               CertificateThumbprint ="71AD93562316F21F74606F1096B85D66289ED60F"
                               CertificateStoreName  = "WebHosting"
                             }
            DependsOn       = "[File]WebContent"
        }
```

#### `dsc_script` resource

#### `dsc_mof` resource

## Detailed examples

## Usability notes

## Inapplicable DSC features

## Implementation notes

The initial implementation of this feature is assumed to function only on the Windows operating system, and requires PowerShell
4.0 or later.

## Future improvements

## Open issues

The following issues require specification before accepting the proposals in this document

* For DSC resource properties with non-trivial (e.g. types that inherit from System.Object in the CLR), how should they be
  translated from Chef / Ruby via the `dsc_resource` resource into a DSC-consumable artifact? The `PSCredential` type commonly
  used in PowerShell cmdlets is an example of such a type. One option is to disallow such types in `dsc_resource` and require
  the use of `dsc_script` or `dsc_mof` for this use case.

## References and further reading

* Chef documentation: <http://docs.opscode.com>
* Chef resource documentation: <http://docs.opscode.com/resource.html>
* DSC cookbook integration prototype: <https://github.com/opscode-cookbooks/dsc>. 
* Chef guard_interpreter documentation: <http://docs.opscode.com/resource_common.html>.
* Chef Client open source project: <https://github.com/opscode/chef>. 
