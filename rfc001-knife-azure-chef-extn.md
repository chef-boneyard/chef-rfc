# RFC: Azure chef extension support in knife azure



**Author:**



- Kaustubh Deorukhkar (kaustubh@clogney.com)



**Date:** May 2014



**Document Status:** Design Proposal



This document is a request for comments to add support for adding azure chef extension in knife azure.



## Goal

The goal is to extend knife-azure:
  - Add chef extension to a new VM during knife-azure server create.

## Requirements

knife-azure: https://github.com/opscode/knife-azure


## Modified Commands

knife azure server create server_name \[options to add chef extension\]

## New Commands

knife azure server update \[options to add extension\]


## Overview

The goal is extend the knife-azure gem to add azure chef extension to a VM during server create.

Azure chef extension is a package that is deployed on the VM by Azure and managed by "Guest Agent" running on the VMs. Extension package automates deployment on Chef-client on the VM and configuring the chef-client. Configuration includes generating client.rb, specifying initial runlist and validation.pem file for the chef-client registration with chef as a node.

## Details
The extension will be added to VM in two cases, creation of new VM and updating existing VM. Addition of extension should behave similar to bootstrap process which installs chef-client and does a initial chef-client run to register the node.

Similary adding an extension to VM should ensure extension is added using azure API to VM and is installed but not enabled. 

Azure by default calls install and enable commands on any newly added extension, so we will need to update azure-chef-extension gem to handle scenario where enable should run conditionally only when extension is added via portal/azure commandlet and not via knife azure.
Status of extension installation will be retrieved via azure apis to check the progress of bootstrap.

## Impact on knife azure command

### Add Extension during VM creation using knife azure

Addition of extension will be treated as bootstrap protocol option for ease of use. For example
knife azure server create --bootstrap-protocol vmextension ...

"knife azure server create" should be updated to specify azure chef extension parameters as described below.


### Parameters required for adding azure chef extension

  - client.rb [ this may be used directly from the --config option ]
  - validation.pem [ again this can be read using the path mentioned in client.rb or we can have additional param]
  - runlist [again existing param for runlist can be used]
  - azure chef extension package version.
  - platform [just for a note here, mostly this will be inferred from image os]

### Add Extension to existing VM using knife azure

"knife azure server update" should be implemented to add azure chef extension to an existing VM.

### Parameters required for adding azure chef extension
  same as those mentioned above for new VM creation scenario.

## Impact on the bootstrap process

Adding a azure chef extension installs chef client as well as bootstrap process does. We will have to ensure regular bootstrap is not performed when adding chef extension.

## High level flow

### For new VM
  - Create a service
  - Add extension to the service
  - create a VM using reference to the extension added in previous step

### For existing VM
  - Add extension to a service associate with the VM
  - update the VM role to use the newly added extension [this should handle both add/update extension]

## References
  - http://msdn.microsoft.com/en-us/library/azure/dn169558.aspx
  - http://msdn.microsoft.com/en-us/library/azure/ee460813.aspx
  - http://msdn.microsoft.com/en-us/library/azure/ee460793.aspx
