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
A windows\_package shortcut resource would be overridden by the package LWRP in the windows cookbook, causing confusion if you were
still using other parts of the windows cookbook.

### DISMPackage
Shortcut Resource Name: `dism_package`

### ServerManagerPackage
Shortcut Resource Name: `server_manager_package`

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
