# RFC: Chef Extension Azure Cmdlet 

**Author:**

- Mukta Aphale (mukta.aphale@clogney.com)

**Date:** April 2014

**Document Status:** Design Proposal

This document is a request for comments on writing a cmdlet which will add Chef Extension to VMs on Azure.

## Goal
The goal is to extend Azure Cmdlets to generate the required JSON for Chef handler and pass that in with the VM creation. The benefit of this is that we can do more customization of the Chef config.

## Requirements
Azure SDK Tools: https://github.com/Azure/azure-sdk-tools/

## New Cmdlets
There would be 2 cmdlets: Set-ChefAzureVMExtension and Create-AzureVMWithChefExtension

### Set-ChefAzureVMExtension
Azure SDK has the cmdlet below to add an extension - Set-AzureVMExtension: https://github.com/Azure/azure-sdk-tools/blob/master/WindowsAzurePowershell/src/Commands.ServiceManagement/IaaS/Extensions/Common/SetAzureVMExtension.cs

The command can be used to add Chef extension, currently as:
$vmObj1 = Set-AzureVMExtension -VM $vmObj1 -ExtensionName ‘ChefAgent’ -Publisher ‘Chef.Azure’ -Version 11.6 -PublicConfigPath 'publicconfig.config' -PrivateConfigPath 'privateconfig.config'

The above command would be customized as:
Set-ChefAzureVMExtension -VM $vmObj1 -Version 11.6 -ClientRb 'Path/client.rb' -ValidationPem '/path/validation.pem' -RunList '<runlist, eg: git,recipe[redis]>'

The command Set-ChefAzureVMExtension will create the private & public files as needed and pass the params to Set-AzureVMExtension command.

#### Using above command to create VM in Azure
We use the following commands to create a VM in Azure:

	$img = "52f61c51e72e459f9aa04b5996ee7e63__Test-Windows-Server-2012-R2-201310.01-en.us-127GB.vhd"

	$vm1 = "MyVMName"
	$vmObj1 = New-AzureVMConfig -Name $vm1 -InstanceSize Small -ImageName $img

	$username = 'MyUser'
	$password = 'MyPassword@123'

	$vmObj1 = Set-ChefAzureVMExtension -VM $vmObj1 -Version 11.6 -ClientRb 'Path/client.rb' -ValidationPem '/path/validation.pem' -RunList '<runlist, eg: git,recipe[redis]>'

	$svc = "MyCloudSvc"

	$vmobj1.ImageName = ''
	$vmObj1 = Add-AzureProvisioningConfig -VM $vmObj1 -Password $password -AdminUsername $username –Windows

	New-AzureVM -Location 'West US' -ServiceName $svc -VM $vmObj1

### Create-AzureVMWithChefExtension
The group of commands mentioned above can be combined into a PS module to create a VM. The user will not have to remember the steps above. Running the cmdlet Create-AzureVMWithChefExtension will create a VM which will have the Chef Extension installed on the VM.

	function Create-AzureVMWithChefExtension
	{
		param (
			[String]$img,
			[string]$vm1,
			[String]$username,
			[String]$password,
			[String]$client_rb,
			[String]$validation_pem,
			[String]$runlist,
			[String]$svc
		)
		
		# We can think of defaulting the image to be a Windows 2012 image. So that the image param will be optional.
		# We can think of randomising VM name & Cloud Service name, if user does not enter those params.
		# We can add "location" as one of the params & default it if user does not specify it

		$vmObj1 = New-AzureVMConfig -Name $vm1 -InstanceSize Small -ImageName $img

		$vmObj1 = Set-ChefAzureVMExtension -VM $vmObj1 -Version 11.6 -ClientRb $client_rb -ValidationPem $validation_pem -RunList $runlist

		$vmobj1.ImageName = ''
		$vmObj1 = Add-AzureProvisioningConfig -VM $vmObj1 -Password $password -AdminUsername $username –Windows

		New-AzureVM -Location 'West US' -ServiceName $svc -VM $vmObj1
	}

## Image Validation
The change proposed above does not check to validate if the image specified by the user has the extension support. We assume that image validation will be done by the existing Azure cmdlets.