Chef resources for PowerShell Desired State Configuration
=========================================================

Chef language and conceptual artifacts share direct analogs with the PowerShell Desired State Configuration (DSC) platform
introduced with PowerShell 4.0. DSC is becoming a popular automation standard for the Microsoft Windows operating system. By
exposing DSC analogs in the Chef domain specific language, users of Chef gain all the *Delightful(tm)* benefits of DSC's wide scope of configuration capabilities.

## Document status

This Request for Comments (RFC) document proposes modifications to Chef Client and related components and is currently open for comments.

Specifically, the document specifies the new resources and other changes related to surfacing capabilities of [PowerShell 4.0
Desired State Configuration (DSC)](http://technet.microsoft.com/en-us/library/dn249912.aspx).

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

* **Chef resource**: This refers to the concept and implementation exposed through the Chef DSL as documented in Chef
    documentation. Specifically, a Chef resource is an instance of a Ruby class that contains the Ruby class `Chef::Resource` in
    its derivation tree. Resources have attributes that represent the desired state of configuration when the attributes are
    assigned values in a Chef recipe. Resources also have actions, methods that perform idempotent operations on system state.
* **DSC resource**: A [DSC resource](http://technet.microsoft.com/en-us/library/dn282125.aspx) models the same concept of system
    configuration as a Chef resource. As such, many DSC resources are direct analogs of Chef resources right down to naming
    (e.g. the `File` resource in Chef and the `File` resource in DSC). DSC resources contain *properties* that define the
    desired characteristics of the configuration represented by the resource.
* **DSC property**: A *property* of a DSC resource is the DSC analog of *attribute* of a Chef resource.
* **DSC configuration document**: A serialized artifact that contains a representation of the DSC resources that model the
    desired state of one or more operating system instances
* **DSC Local Configuration Manager (LCM)**: The LCM is the system component of a single operating system instance that translates a DSC configuration document into
    actual state changes that conform to the desired state expressed in the document. It is analogous to the **chef-client**
    component of Chef which performs the same function on an operating system instance.
* **Managed Object Format (MOF)**: [MOF](http://en.wikipedia.org/wiki/Managed_Object_Format) is an open standard format with the capability to represent entities described by the
[Common Information Model (CIM)](http://en.wikipedia.org/wiki/Common_Information_Model_(computing)) open standard. CIM
represents objects as a composition a set of primitive data types and other previously defined objects, the operations
allowed on those objects, and the relationships between classes of objects. It is used by DSC infrastructure to communicate desired state of
one or more operating system instances to implementations that enact changes to conform to the desired state such as the LCM.

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

#### Create a security group with DSC's `Group` resource

Here's how you create a security group via DSC and the Chef `dsc_resource` resource:

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

If you use `dsc_script` or `dsc_mof`, it's actually less likely that you'll directly embed the explicitly PowerShell or MOF code
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
recipes. The behaviors implemented by the resources are also given in terms of how they would map to the equivalent PowerShell
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
* If the `resource_name` attribute does not correspond to the name of a DSC resource installed on the system, an exception will be
  raised at converge time.
* For a given pair of *property name* and *value* passed to the `property` attribute, CLR type to which *value* is converted prior
  to submission to the LCM according to the aforementioned type rules **MUST** match the CLR type of the property specified by
  *property name* for the DSC resource specified by the `resource_name` attribute or an exception is raised at converge time.
* The same *property name* argument of the `property` attribute may not be specified more than once in a given `dsc_resource` block.

#### Forbidden DSC properties

Certain common properties of DSC resources may not be expressed using DSC resource, primarily because they have no utility in
the context of the way in which Chef is using them or because they may interfere with reliable predictable functioning of the
resource. Currently there is only one such property:

* `dependson`: this property allows temporal dependencies between resources to be declared, thus allowing an order of
  configuration execution across a set of DSC resources presented in a configuration document. Because `dsc_resource`

#### Type safety for `dsc_resource` `property` attributes

Prior to submitting configuration to DSC, values specified to the `property` attribute will be converted to CIM types based on the Ruby type used for the value according
to these rules:

|Ruby type|CIM type|
|---------|--------|
|`String`|`string`|
|`Fixnum`|`int32`|
|`Float`|`double`|
|`TrueClass`|`boolean`|
|`FalseClass`|`boolean`|
|`NilClass`|`CIM_Object`|
|`Chef::Resource::DscResource`|`OMI_Resource`|

These type conversions should be unambiguous and reversible, and most of them should be direct and leave data representations
unchanged. The `String` conversion for example should require no actual representational conversion. The conversion for `NilClass` would
simply present such a value as the CIM value `null`.

Classes of `Chef::Resource::DscResource` will result in the MOF representation of the DSC resource being assigned to a
property in the resultant configuration document. This covers DSC use cases such as the following fragment of DSC PowerShell code below where an anonymous instance of
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

#### `dsc_resource` usability

In order to use `dsc_resource`, recipe authors will not need to know the PowerShell DSC language or even very much in the way of
concepts around DSC. Use of DSC resources in Chef through `dsc_resource` requires the following knowledge:

|Knowledge|Source|
|---------|------|
|Existence of relevant DSC resource|Internet search on DSC documentation|
|DSC resource name|DSC documentation|
|DSC resource property names|DSC documentation|
|DSC resource property behavior|DSC documentation|

That's it. As an example, consider the case of someone who wanted to see if DSC could be used to unzip a compressed file:

1. She uses an Internet search engine with terms such as *"PowerShell DSC unzip file"* and browse the results
2. Several results will show examples of a DSC resource called 'archive'
3. Use of the search engine again with the terms *"powershell dsc archive"* returns a link to the
[DSC Archive resource documentation](http://technet.microsoft.com/en-us/library/dn249917.aspx).
4. The first sentence of the document indicates that it can unzip ".zip" files, so it's the resource she wants.
5. The **syntax** section of the documentation states that the name of the resource is "Archive."
6. A perusal of the **syntax** and **properties** section seems to indicate that setting the `Path` and `Destination` properties
will result in the desired behavior of unzipping a file located at a given location into another directory.
7. The example at the end of the documentation confirms the understanding above with a demonstration of the desired use case.
8. The user then adds a `dsc_resource` instance to a Chef recipe, setting `resource_name` to `:Archive` and using the `property`
attribute to set the `Path` and `Destination` attributes of the underlying DSC resource.
9. The recipe runs this simple case with the results the user expected.

These steps are fairly simple -- some Internet searches, followed by a very quick reading of documentation, and finally filling
in the "template" provided by `dsc_resource` with literal transcriptions of syntax elements from the DSC documentation.

More importantly, the steps above are almost the same as those that would be followed if a person with knowledge of the Chef DSL
were to look for a Chef resource to use for a given purpose and then tested out that resource. And the knowledge required in
both the case of the standard Chef resource and that of the use of `dsc_resource` is the same -- no real knowledge of DSC is
required to use `dsc_resource`, all this is needed is an understanding of how to set attributes of `dsc_resource` to obtain
behaviors described in the DSC documentation.

Thus, using DSC resources in Chef is quite nearly as easy as simply using Chef resources -- additional documentation on
`dsc_resource` that provides helpful links to DSC resources can make it even easier.


#### `dsc_script` resource

The `dsc_script` resource allows authors to re-use existing DSC script
artifacts. For example, an organization may have a library of PowerShell DSC
scripts used interactively or by various tools that integrate with DSC. Such
artifacts may alse be accessible if there is an internal or external community
around DSC that provides library scripts for common tasks.

Re-use of such existing infrastructure is the primary use case for
`dsc_script` -- otherwise, any desired re-use with Chef requires a conversion of the
scripts to the Chef DSL form mandated by `dsc_resource` or execution of script
commands, neither of which is desirable from an implementation cost
perspective nor that of maintainability / transparency.

A second use case is that of transcending limits that the `dsc_resource`
resource places on expression of DSC intent. For example, DSC PowerShell
script allows the use of all features of PowerShell (similar to the way all
Ruby capabilities may be accessed from within the Chef DSL), and in some cases
it may be convenient to express a configuration by making use of PowerShell
types or cmdlets. By using `dsc_script`, users can trade off the simplicity
and safety of `dsc_resource` for the deeper DSC knowledge and flexibility of `dsc_script`.

#### `dsc_script` actions

In addition to the standard `:nothing` action, this resource has the following actions

|Action|Description|
|------|-----------|
|`:set`|This is the default action. This action is used to enact DSC configuration specified by the resource's attributes by supplying that DSC configuration to the DSC Local Configuration Manager and requesting that the system be updated to reflect it. This resource is only updated if the LCM makes changes as part of the aforementioned interaction|
|`:test`|This action is similar to set, except that the LCM does not make changes, it only checks to see if changes to the system are needed to make the system compliant with the configuration expressed by the Chef resource. If changes are needed, the resource will be updated, otherwise it will not|

#### `dsc_script` attributes

`dsc_script` honors common resource attributes, as well as the following
properties, either of which defines the DSC configuration to set by simply
supplying a source to DSC script:

|Attribute|Description|
|---------|-----------|
|`configuration`| This attribute defines the DSC configuration to submit to
|DSC using the PowerShell DSC DSL. The attribute is a `String` that contains
|the literal PowerShell DSC code to configure the node. This attribute **MUST
|NOT** be set to a non-`nil` value if the `path` attribute is to anything other than `nil`. |
|`path`| Path to a file containing PowerShell DSC script code with which to
|configure the node. This attribute **MUST NOT** be set to a non-`nil` value
|if the `configuration` attribute is set to anything other than `nil`. |

#### `dsc_mof` resource

The `dsc_mof` resource is similar to `dsc_script, except that the embedded
language the user specifies to the resource is not the PowerShell-based DSC
DSL, but MOF. 

The use cases are similar with respsect to the focus on re-use of existing
content. There are some specific reasons why an organization may have MOF
content instead of PowerShell DSC DSL configuration content:

1. DSC does not require PowerShell to function -- configuration documents
might be generated by other tools or languages that produce MOF. Additionally,
DSC can be consumed on systems that explicitly do not have a PowerShell
runtime, specifically Unix-based systems. Since MOF is an open standard with
implementations on Unix, recipes that invoke `dsc_mof` instead of `dsc_script`
could potentially function on both Unix and Windows platforms.
2. In general MOF is also viewed as a transport format for configuration. So
in the event that configuration is sent from a centralized server to systems
that will be set according to that configuration, `dsc_mof` can process any
such configuration.

#### `dsc_mof` actions

`dsc_mof` has the same actions with the same semantics as those of `dsc_script`.

#### `dsc_mof` attributes

The attributes for `dsc_mof` are almost the same as those for `dsc_script`,
with the key difference being the language used to describe the configuration:

|Attribute|Description|
|---------|-----------|
|`configuration`| This attribute defines the DSC configuration to submit to
|DSC using the MOF language. The attribute is a `String` that contains
|the literal MOF code to configure the node. This attribute **MUST
|NOT** be set to a non-`nil` value if the `path` attribute is to anything other than `nil`. |
|`path`| Path to a file containing MOF code with which to
|configure the node. This attribute **MUST NOT** be set to a non-`nil` value
|if the `configuration` attribute is set to anything other than `nil`. |


## Detailed examples

## Inapplicable DSC features

## Implementation notes

The initial implementation of this feature is assumed to function only on the Windows operating system, and requires PowerShell
4.0 or later.

### Implementation overview

Any general implementation of Chef resources that interface with DSC in the Chef client will perform the following sequence of operations:

1. During a Chef client run, generate a DSC configuration document representation of the configuration
declared in the Chef recipe by one of the Chef resources for DSC, `dsc_resource`,
`dsc_script`, or `dsc_mof`. This document generation requires a translation
of the Chef DSL representation via the particular resource to DSC's MOF format
for configuration documents. The DSC API with which Chef and other systems
interact requires the MOF format for any communication of configuration.
2. Part of the aforementioned document generation should include syntax
checking of some sort, possibly based on parts of the DSC API that surface
type information and other metadata about DSC resources, so that the most
useful errors closest to the author or operator's context in the Chef DSL may
be returned.
3. Interrogate DSC through the API using the generated document to determine
if any changes must be made to the system in order for the configuration
described by the document to present in the system state
4. If no changes are needed, then Chef takes no further actions for that
resource and reports it as being up to date through standard Chef resource
interfaces.
5. If changes are needed, the configuration document is resbumitted to the DSC
API, this time with a request to apply the configuration.
6. If the request to apply the configuration fails, an error is returned for
the resource through standard Chef resource error conventions. Otherwise,
successful application of the configuration document will mean that the system
state conforms to the document and thus to the Chef resource from which it was
generated, and will then result in Chef reporting the resource as successfully
updated.

It should be noted that among the 3 resources `dsc_resource`, `dsc_script`,
and `dsc_mof`, the degree of complexity of the translation will likely vary as
follows:

* `dsc_mof`: This translation should be trivial, since the resource attributes
  provide a MOF, and hence it can be submitted directly to DSC.
* `dsc_mof`: This is a translation from the PowerShell-based DSC DSL to MOF,
  and since DSC provides an API to perform this, the process is still
  relatively simple.
* `dsc_resource`: This is the most complex translation. This resource provides
  neither MOF nor a single attribute from which an existing API could make a
  translation. Instead, it provides a DSC resource name and DSC property values
  for those resources. That information is sufficient to generate a DSC MOF
  document with a configuration for that DSC resource.

Further details are given below on issues around translation from the Chef DSL
to MOF, validation of the translation, and specifics of interaction with the
DSC API from Chef.

### Resource convergence for `dsc_mof`

The `dsc_mof` resource requires the user of the resource to explicitly provide a
configuration document in MOF format as an attribute of the resource.
Convergence works as follows:

1. Generation of a configuration document for use with LCM is trivial -- the
document is actually given in a resource attribute and that attribute can be transmitted
directly to LCM as the configuration document.
2. In the context of the provider's `LoadCurrentResource` method, the LCM is presented with the document and queried to see if
any changes would be made to the system if the document's configuration were to be enacted.
3. In the context of the provider's `run_action` for the `:set` or `:test` actions:
   1. If the `LoadCurrentResource` step indicates
that no changes will occur, a `converge_by` block is executed that does nothing but return `false` so that no configuration change
is executed and the return value of `false` means that the resource will be reported as being *"skipped."*
   2. If `LoadCurrentResource` indicates that a change would occur with this configuration document and the action is `:test`,
   a `converge_by` block is executed that does nothing but return `true` so that no changes are made to the system but the
   resource will be reported as *"executed"* rather than "skipped."
   3. If `LoadCurrentResource` indicates that a change in configuration should occur for the configuration document, then with a
   `converge_by` block a call is made to the LCM and a value of `false` is returned of the LCM ends up not making changes (rare,
   but could occur due to rare but unavoidable race conditions), or `true` if the LCM does make changes to the system
   successfully. The resource is then reported as being "executed" or "skipped" depending on whether `true` or `false` was
   returned by the `converge_by` block.

This approach has the following properties:

* For each instance of `dsc_mof` in a Chef run, DSC will be invoked with the generated configuration document twice for
  every `:set` action of `dsc_resource`. The first invocation checks if DSC needs to execute to enact the configuration in the
  Chef resource, and the second enacts the configuration.
* Chef will only report an instance of `dsc_mof` as updated during the Chef client run if the LCM makes changes to the
  system (or if it would have made changes in the case of the `:test` action).

### Resource convergence for `dsc_script`

Like `dsc_mof`, `dsc_script` allows the user to specify a configuration
document, but instead of doing this in MOF format, it does this indirectly by
specifying PowerShell DSC DSL that itself can generate the configuration
document. Convergence occurs as follows:

1. The attribute of `dsc_script` that supplies the PowerShell code for the
document is executed -- this creates a configuration file in MOF format that
can be transmitted to the LCM. Note that this PowerShell code is not subset of
PowerShell -- any valid PowerShell code that is present in the script,
including that not related to DSC, will be executed
2. Convergence then proceeds the same as for `dsc_mof`, as if `dsc_mof`'s code
attribute had been supplied the configuration document generated in the
previous step.

Idempotence behaviors are the same for `dsc_script` as for `dsc_mof`.

### Resource convergence for `dsc_resource`

Unlike `dsc_mof` and `dsc_script`, `dsc_resource` does not allow the user to
specify configuration using a different language. Instead, only the Chef DSL
is used to specify the configuration, in this case by specifying attributes
that define DSC properties of some DSC resource. 

For a given instance of a DSC resource, the provider for the resource will perform the following operations:

1. Retrieve metadata from DSC API's DSC resource indicated by the `resource_name` attribute of the resource. It will also retrieve
supported properties, and the types of each property, and the PowerShell module that implements the resource.
    1. If DSC cannot locate the resource with the specified name, an exception is raised
    2. If any of the DSC properties specified through the `property` attribute of the resource does not exist for the DSC resource
    named by the `resource_name` attribute, an exception is raised
    3. For any property specified in the resource through `property`, if the value specified for the property cannot be coerced
    to the type returned for that property in the metadata retrieved earlier as defined by the previously described type safety
    rules, an exception is raised.
2. Property values specified by the Chef `property` attribute have their representation converted to one that will result in the
    correct type for the DSC resource when a configuration document is generated for the DSC resource specified by the
    `dsc_resource` resource. The type conversion "escapes" its input as described in the type safety rules and thus prevents
    code injection through the `property` attribute.
3. Using the name of the resource specified by the `resource_name` attribute and the property names and type-converted property
values, a DSC MOF configuration document is generated
4. From this point, convergence proceeds as it does for `dsc_mof` using the
configuration document supplied above as if that document's contents were the
value of the `configuration` attribute of `dsc_mof`.

This approach has the following properties in addition to sharing properties
of the `dsc_mof resource:

* For each instance of `dsc_resource` in a Chef run, DSC will be invoked with the generated configuration document twice for
  every `:set` action of `dsc_resource`. The first invocation checks if DSC needs to execute to enact the configuration in the
  Chef resource, and the second enacts the configuration.
* Chef will only report an instance of `dsc_resource` as updated during the Chef client run if the LCM makes changes to the
  system (or if it would have made changes in the case of the `:test` action).
* Since the type conversions from Chef to MOF escapes strings and is otherwise restricted to emitting values of simple types
  such as integers or boolean literals, code injection at the layer of the MOF runtime or above is mitigated.
* Any configuration document submitted to the LCM by Chef as a representation of the intent of a `dsc_resource` instance will be
  a syntactically well-formed document because Chef generates configuration documents from a known and fixed subset of methods
  of generating such documents that can be shown to emit only such correct documents.

#### Error reporting for `dsc_resource`

Explicit care must be taken to handle errors in an actionable way for Chef users, since Chef itself has limited knowledge of the
correctness of any DSC configuration that `dsc_resource` submits to the LCM. While Chef cannot interpret the correctness of the 
document, it can and should rely on any information surfaced by interactions with the LCM regarding the document to relay the
most relevant error information to Chef's standard error reporting channels so that authors and operators can take the same
corrective actions as if they had natively authored the document in DSC's DSL.

The classes of error cases and the required response by Chef is given below:

|Error class|Response|
|-----------|--------|
|Unsupported value type for `property` attribute|Exception **MUST** be raised at converge time|
|Non-existent DSC resource name specified to `resource_name` attribute|Exception **MUST** be raised in converge phase|
|Non-existent DSC property name for the DSC resource specified by `resource_name`|Exception **MUST** be raised in converge phase|
|Error when submitting the DSC configuration document to the LCM|Exception **MUST** be raised in converge phase|
|Other errors interacting with DSC API's|Exception **MUST** be raised at converge time|

When errors are reported, sufficient context should be given in exception messages surfaced to authors and operators in order to
correct errors. The required error context can be described as follows:

* **`property` type error**: If changing the Chef data type for a value supplied to the `property` attribute could fix the
    error, the context should include the file and line number of the erroneous `property` attribute in the Chef recipe.
* **Non-existent resource**: If correcting the value of the `resource_name` attribute or installing a PowerShell module on the
    system the DSC attribute named by the `resource_name` attribute would address the error, the file and line number of the
    erroneous `resource_name` attribute should be included in the reported error context.
* **Errors returned from interaction with DSC API's**: Any such errors returned by an interaction with the LCM or other DSC
    components **MUST** include the exception message from DSC and the line number and file name of the `dsc_resource` instance
    that was the source of the error, along with the values of all Chef attributes **AND** DSC property values specified through
    the `property` attribute.

## Future improvements

## Open issues

The following issues require specification before accepting the proposals in this document

* For DSC resource properties with non-trivial (e.g. types that inherit from System.Object in the CLR), how should they be
  translated from Chef / Ruby via the `dsc_resource` resource into a DSC-consumable artifact? The `PSCredential` type commonly
  used in PowerShell cmdlets is an example of such a type. One option is to disallow such types in `dsc_resource` and require
  the use of `dsc_script` or `dsc_mof` for this use case. Another option is to provide a helper in the Chef DSL for these cases
  that would generate the appropriate representation in the configuration document.
* Should `dsc_mof` and `dsc_script` simply be the same resource, say
  `dsc_configuration` with an attribute to specify the language?
  
## Appendices

### Additional usability discussion

Given that the integration of DSC capabilities into Chef implies some sort of "mapping" between language concepts and other
capabilities of the systems, it is worth asking how much of this translation is the responsibility of cookbook authors and how
much of it can be completely automated. The more that Chef can automate the mapping, the more seamless the experience for
authors. Decreasing the cognitive burden of understanding both systems sufficiently to consciously map between the two is thus a
priority.

To get a clearer picture of the challenge, consider the knowledge workflow of a cookbook author simply using Chef resources
built into `chef-client`. It looks something like this:

1. Learn the concepts and syntax of the Chef DSL, along with a minimal amount of Ruby -- this only needs to be done once.
2. When writing cookbooks, use the [Chef documentation site](https://docs.getchef.com) to find useful resources that allow for
the configuration of state relevant to the task at hand.
3. For each resource used in the recipe, identify the name of the resource, and the attributes and allowed values for
configuring the resource according to the desired state
4. Write the Chef code
5. Use tools such as `chef-client --local-mode` or `test-kitchen` to execute and test the recipes -- use error information from
`chef-client` to diagnose failures and fix problems
6. Deploy the recipe in a cookbook and use it for production scenarios.

Ideally, we'd prefer that the introduction of DSC into Chef not alter that workflow significantly, otherwise the greater the
deviation the less of a net benefit the use of DSC is over, say, simply authoring your own resource using Chef + Ruby or other
scripting languages with which the author is already familiar.

Let's compare the workflow requirements for the two approaches presented in this document. The first is the `seamless` approach
exemplified by `dsc_resource` in which the expression of the resource in the Chef DSL in recipes presents a resource that looks
like any other Chef resource and gives no hint of the fact that it abstracts a DSC resource other than the prefix in the name
`dsc_resource`.

The second approach is that taken by `dsc_script` and `dsc_mof`, in which the recipes embed the DSC or MOF languages within the
recipe. Whether the language is embedded literally in the recipe as the string value of a resource attribute, or it is implied
by the presence of a path attribute with a value set to that of a file ending in a suggestive `.ps1` or `.mof` extension, the
step outside of the Chef / Ruby language environment is evident. If that PowerShell or MOF code was not simply re-used but
authored specifically for use in the recipe, then the author will have essentially been developing the cookbook in two languages
simultaneously, perhaps in some way like the use of both HTML and JavaScript languages in web browsers.

Here are the workflows with abbreviated descriptions:

| Seamless approach | Embedded code approach |
|-------------------|------------------------|
|1. Learn the Chef DSL|1a. Learn the Chef DSL|
|| 1b. Learn PowerShell DSC or MOF|
|2. Consult the Chef docs| 2. Consult the Chef docs|
||2b. Consult the DSC docs|
|3. Identify DSC resources and properties| 3. Identify DSC resources and properties|
|4a. Write Chef code | 4a. Write Chef code |
|4b. Translate DSC attributes to Chef properties|4b. Embed DSC code in Chef code |
|5. Test / debug the cookbook | Test / debug the cookbook |
|6. Deploy to production |Deploy to production|

Overall, the embedded code approach has 2 additional steps compared to the seamless method. And when comparing step 4b, the
actual implementation for the seamless approach is fairly lightweight and requires no knowledge of DSC.


## References and further reading

* Chef documentation: <http://docs.opscode.com>
* DSC documentation: <http://technet.microsoft.com/en-us/library/dn249912.aspx>
* Chef resource documentation: <http://docs.opscode.com/resource.html>
* DSC cookbook integration prototype: <https://github.com/opscode-cookbooks/dsc>. 
* Chef guard_interpreter documentation: <http://docs.opscode.com/resource_common.html>.
* Chef Client open source project: <https://github.com/opscode/chef>. 
