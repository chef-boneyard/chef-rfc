---
RFC: 32
Title: Powershell DSC Resource Modules
Author:
- Mukta Aphale <mukta.aphale@clogney.com>
- Siddheshwar More <siddheshwar.more@clogeny.com>
Status: Accepted
Type: Standards Track
---

# Powershell DSC Resource Modules

This document is a request for suggestions on DSC module resource for [PowerShell](https://github.com/chef-windows/powershell) cookbook provided by chef.

## Quick overview of DSC resource module
- Desired State Configuration is Microsoft’s technology, introduced in Windows Management Framework 4.0, for declarative configuration of systems. At the risk of oversimplifying a bit, DSC lets you create specially formatted text files that describe how a system should be configured. You then deploy those files to the actual systems, and they magically configure themselves as directed. At the top level DSC uses domain specific language that just listing how you want a system to look.
- It works like: (step 1) write a configuration script in PowerShell. Then you (step 2) run that script, and the result is one or more MOF files. MOF stands for Managed Object Format, and it’s basically a specially formatted text file. Then, (step 3), the MOF files are somehow conveyed to the machines they’re meant for, and (step 4) those machines start configuring themselves to match what the MOF says.
- DSC configuration block includes in-built and custom DSC resources.
- Example:

```
Configuration MyWebConfig
{
   # A Configuration block can have zero or more Node blocks
   Node "Server001"
   {
      # Next, specify one or more resource blocks
      # File is a built-in resource you can use to manage files and directories
      # This example ensures files from the source directory are present
      File MyFileExample
      {
         # You can also set Ensure to "Absent"
         Ensure = "Present"
         # Default is “File”
         Type = "Directory"
         Recurse = $true
         SourcePath = $WebsiteFilePath
         DestinationPath = "C:\inetpub\wwwroot"
      }
   }
}
```

- The Desired State Configuration (DSC) resource is a PowerShell module that is used to model one or more entities that you want to be in a specific, desired state.
- There are certain rules which must be followed by custom DSC resource.
- All DSC resources should be deployed in the following folder hierarchy:

```
$env: psmodulepath (folder)
  |- <ModuleName> (folder)
    |-  <ModuleName.psd1> (file,required)
    |- DSCResources (folder)
      |- <DSCResourceName1> (folder)
        |- <DSCResourceName1.psd1> (file, optional)
        |- <DSCResourceName1.psm1> (file, required)
        |- <DSCResourceName1.schema.mof> (file, required)
      |- <DSCResourceName2>(folder)
        |- <DSCResourceName2.psd1> (file, optional)
        |- <DSCResourceName2.psm1> (file, required)
        |- <DSCResourceName2.schema.mof> (file, required)
```

- DSC introduced Import-DscResource dynamic keyword to import custom DSC resources. This keyword is only available inside configuration block.
- The Import-DscResource command will loop through all modules installed in all paths in $env:PSModulePath to find the ones containing resources

## Goal

The goal of the changes mentioned in this document is to manage custom DSC resource modules for desired workstation. This change is required for user to easily allow access for custom DSC resources. Currently there is no automated way to manage custom resources.  We are adding DSC module resource to PowerShell cookbook to manage (i.e install/uninstall) custom resource.

## Requirements

The resource have meaningful name, `powershell_dsc_module`.

## Actions

### :install *(default)*

It will install DSC module. User can use this module in configuration block by using 'Import-DscResource'.

### :uninstall

It will remove DSC module by deleting DSC resource module dir from $psmodulepath location.

## Attributes
* module_name - The name of the module and its mandatory.
* remote_url - The remote url for *.zip DSC module file. Its mandatory attribute. The zip file should have the same folder structure required for DSC module (see Quick overview of DSC resource module section).
* version - DSC module may have multiple versions. Optional.

## Example

```ruby
powershell_dsc_module "test_module" do
  module_name "test_module"
  remote_url "https://s3.aws.com/test_module.zip"
  action :install
end

powershell_dsc_module "test_module" do
  module_name "test_module"
  action :uninstall
end
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
