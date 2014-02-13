# Windows Package Resource and Providers

Proposal for moving windows\_package and windows\_feature LWRPs from the windows cookbook into core Chef.

Chef internal PBI: [OC-5114](https://tickets.corp.opscode.com/browse/OC-5114)

There are a number of package installer frameworks that are common on Windows, which can specified by the user or detected. Installing packages usually means passing a flag to the installer to indicate it is an unattended installation.

In addition to packages, Windows also supports installing roles and features (formerly components) which are special packages that come with Windows. You can also enable roles such as 'DNS Server' and 'Web Server', and features like 'Failover Clustering'. Generally a role provides the software necessary for particular function, while a feature may enhance that function, but the lines are poorly defined. For instance, 'Telnet Server' is a feature, and not a role.

Roles and features are very much like packages. For example, their equivalent on Debian/Ubuntu are meta-packages, which are part of the default packaging system. However, roles and features are usually presented to Windows users in a way that does not expose this similarity. Customer feedback indicates a need for a unique resource. Because Chef already has the concept of roles, we will create a feature resource for both features and roles, similar to the feature LWRP in the windows cookbook.

## New Core Package Resource and Provider

### Chef::Resource::WindowsPackage
Shortcut Resource Name: `windows_package`


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
      
This would be the default package provider on windows, so you would use the 'package' resource and wouldn't necessarily need a shortcut resource.


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

## New Core Feature Resource and Providers

* Windows 7, Server 2008 R2, and later, use DISM for managing roles and features
* Windows Vista, Server 2008 (RTM - SP2), and earlier use Server Manager (servermanagercmd.exe) and Package Manager (pkgmgr) for managing roles and features. Server Manager was only available on Server SKUs.
* Server 2003 uses sysocmgr to manage components

The provider will be chosen based on platform_version, using DISM for platform_version >= 6.1.7600 (Windows 7)


### Chef::Resource::Feature


#### DISM **FIXME**


/All - All parent features

### Chef::Provider::Feature::DISM
Shortcut Resource Name: `dism_feature`

#### Examples
```
feature "IIS"
```

### Chef::Provider::Feature::ServerManager
Shortcut Resource Name: `server_manager_feature`

#### Examples

```
server_manager_package "Web-Server"
```

```
package "Web-Server" do
  provider Chef::Provider::Package::ServerManager
  action :install
```

## Existing Windows Cookbook

The existing windows cookbook contains two relevent LWRPs, package and feature.

### Resources
* package  
    types: msi, inno, nsis, wise, installshield, custom  
    examples: putty-0.60-installer.exe, 7z920-x64.msi, 'Google Chrome'
    
    The type is either specified as an attribute or determined from the file extension, and is used to pass the correct arguments for a silent/automated installation to the underlying installer. The ```custom``` type requires the user to specify the correct arguments in the ```options``` attribute.
* feature  
    types: dism, servermanagercmd  
    examples: DHCPServer, TelnetClient, TFTP, CertificateServices
    
    dism.exe is used on Server 2008 and later, servermanagercmd.exe on earlier version

### Providers
* package: handles different installers with a set of default flags for the options attribute
* feature\_dism: installs features using dism.exe
* feautre\_servermanagercmd: installs features using servermanagercmd.exe
