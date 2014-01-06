# Windows Package Resource and Providers

Proposal for moving windows\_package and windows\_feature LWRPs from the windows cookbook into core Chef.

Chef internal PBI: [OC-5114](https://tickets.corp.opscode.com/browse/OC-5114)

Installing packages on Windows usually means passing a flag to the installer to indicate it is an unattended installation. 
There are a number of standard installation packages which can specified or detected in the windows cookbook, or the user can specify the correct flags.

Windows also supports installing features (formerly components) which are special packages that come with windows.
Features map closely to the package resource in Chef, so we can make additional providers rather than add a core 'feature' resource.

## New Core Resources/Providers

### WindowsPackage 
Shortcut Resource Name: `none`

This would be the default package provider on windows, so you would use the 'package' resource and wouldn't need a shortcut.

If we used a shortcut resource named windows\_package it would be overridden by the package LWRP in the windows cookbook, causing confusion if you were
still using other parts of the windows cookbook.

#### Examples

```
package "PuTTY version 0.60" do
  source "http://the.earth.li/~sgtatham/putty/latest/x86/putty-0.60-installer.exe"
  installer_type :inno
  action :install
end
```

```
package "VLC media player 1.1.10" do
  source "http://superb-sea2.dl.sourceforge.net/project/vlc/1.1.10/win32/vlc-1.1.10-win32.exe"
  action :install
end
```

### DISMPackage
Shortcut Resource Name: `dism_package`

#### Examples
```
dism_package "IIS"
```

```
package "IIS" do
  provider Chef::Provider::Package::DISM
  action :install
```

### ServerManagerPackage
Shortcut Resource Name: `server_manager_package`

#### Examples

```
server_manager_package "Web-Server"
```

```
package "Web-Server" do
  provider Chef::Provider::Package::ServerManager
  action :install
```

## Windows Cookbook

The existing windows cookbook contains two relevent LWRPs, package and feature.

### Resources
* package  
    types: msi, inno, nsis, wise, installshield, custom  
    examples: putty-0.60-installer.exe, 7z920-x64.msi, 'Google Chrome'  
* feature  
    types: dism, servermanagercmd  
    examples: DHCPServer, TelnetClient, TFTP, CertificateServices  

### Providers
* package: handles different installers with a set of default flags for the options attribute
* feature\_dism: installs features using dism.exe
* feautre\_servermanagercmd: installs features using servermanagercmd.exe
