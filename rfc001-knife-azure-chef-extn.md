# RFC: Azure chef extension support in knife azure



**Author:**



- Kaustubh Deorukhkar (kaustubh@clogney.com)



**Date:** May 2014



**Document Status:** Design Proposal



This document is a request for comments to add support for adding azure chef extension in knife azure.



## Goal

The goal is to extend knife-azure:
  - Add chef extension during knife-azure server create.
  - Update an existing VM using knife-azure to add or update chef extension

## Requirements

knife-azure: https://github.com/opscode/knife-azure


## New Commands

knife azure server update existing_server_name <options to add/update extension>



## Overview

The goal is extend the knife-azure gem to add support for managing azure chef extension.

Azure chef extension is a package that is deployed on the VM by Azure and managed by "Guest Agent" running on the VMs. Extension package automates deployment on Chef-client on the VM and configuring the chef-client. Configuration includes generating client.rb, specifying initial runlist and validation.pem file for the chef-client registration with chef as a node.

## Impact on knife azure command

### Add Extension during VM creation using knife azure

"knife azure server create" should be updated to specify azure chef extension parameters as described below.

### Add/Update Extension to an existing VM managed by knife azure

New "knife azure server update" command will be implemented to add extension to existing VM, or to update the extension version to a newer one.

### Parameters required for managing azure chef extension

  - client.rb [ this may be used directly from the --config option ]
  - validation.pem [ again this can be read using the path mentioned in client.rb or we can have additional param]
  - runlist [again existing param for runlist can be used]
  - azure chef extension package version.
  - platform [just for a note here, mostly this will be inferred from image os]

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