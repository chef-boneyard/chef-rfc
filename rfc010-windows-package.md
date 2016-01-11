---
RFC: 010
Author: Bryan McLellan <btm@loftninjas.org>
Status: Accepted
Type: Standards Track
---

# Windows Package Resource and Providers

Proposal for moving windows\_package LWRP from the windows cookbook into core Chef.

Chef internal PBI: [OC-5114](https://tickets.corp.opscode.com/browse/OC-5114)

There are a number of package installer frameworks that are common on Windows, which can specified by the user or detected. Installing packages usually means passing a flag to the installer to indicate it is an unattended installation.

Support for roles features will be handled by a separate resource.

## New Core Package Resource and Provider

### Chef::Resource::WindowsPackage
Shortcut Resource Name: `windows_package`
      
This would be the default package provider on windows, so you would use the 'package' resource and wouldn't necessarily need a shortcut resource.

### Attributes

* package_name - defaults to the resource name
* source - the location of package to install
* installer_type - for future use to manually differentiate between installers
* options - flags passed to the installer
* version - version of the package to install, if applicable
* returns - possible exit codes that indicate success

Deprecated attributes:  

* checksum  
The existing cookbook allows source to be a URL, we'd rather use remote_file to download packages unless we're passing the URL directly to the installer to avoid code duplication and maintain 'primatives.'
* success_codes  
This will be renamed to returns to match other existing core providers

### Platform specific resources
Utilizing the platform-specific resource functionality introduced in [CHEF-2698](https://tickets.opscode.com/browse/CHEF-2698), add a new package resource with windows specific attributes 

```
class Chef
  class Resource
    class WindowsPackage < Chef::Resource::Package

      provides :package, :on_platforms => ["windows"]
      
      def initialize(name, run_context=nil)
        super
        @action = :install
        @allowed_actions = [ :install, :remove ]
        @provider = Chef::Provider::Package::Windows
        @resource_name = :windows_package
        @installer_type = nil
        @checksum = nil
        @timeout = 600
        @success_codes = [0, 42, 127]
```      

### Chef::Provider::Package::Windows

Initial support for the Microsoft Installer (MSI) only, incrementally adding support for additional installers.

All installer support in core must use a unique identifier when available (e.g. Product Code, AppID) to:  
* Support upgrade/removal  
* Idempotently verify installation state

We must determine the installer type for the user to match the same experience of running the executable on windows itself. Some methods require reading the installer file, so we cannot make this determination in the resource and will do so in this provider, which will call another class specific to the determined installer

[Example framework](https://gist.github.com/btm/92a40020c3eea6cb8b28)

### Chef::Provider::Package::Windows::MSI

We will determine package installation status using ```MsiGetProductPropertyA``` and ```MsiGetProductInfoA``` using FFI. See the [proof of concept code](https://gist.github.com/btm/8673443#file-check_installed-rb).

#### Actions
* Install - Will execute the package if it is not already installed
* Remove - Will remove the package by corresponding product code if installed


#### Example

```
windows_package '7-Zip 9.20 (x64 edition)' do
  source 'http://downloads.sourceforge.net/sevenzip/7z920-x64.msi'
  action :install
end
```

#### Future work

* MSU (update) ([hotfixes + dism](http://blogs.technet.com/b/askcore/archive/2011/02/15/how-to-use-dism-to-install-a-hotfix-from-within-windows.aspx))
* MSP (patch)
* MST (transform)
* Idempotent upgrade based on ProductCode/ProductVersion/UpgradeCode/Revision Number Summary [Reference](http://msdn.microsoft.com/en-us/library/aa370579\(v=vs.85\).aspx)


## Existing Windows Cookbook

The existing windows cookbook contains a package LWRP

### Resources
* package  
    types: msi, inno, nsis, wise, installshield, custom  
    examples: putty-0.60-installer.exe, 7z920-x64.msi, 'Google Chrome'
    
    The type is either specified as an attribute or determined from the file extension, and is used to pass the correct arguments for a silent/automated installation to the underlying installer. The ```custom``` type requires the user to specify the correct arguments in the ```options``` attribute.

### Providers
* package: handles different installers with a set of default flags for the options attribute
