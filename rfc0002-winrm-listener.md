# Chef RFC: Secure WinRM Listener Configuration through the knife CLI

**Authors:**

- Mukta Aphale (mukta.aphale@clogney.com)
- Adam Edwards (adamed@getchef.com)

**Date:** January 2014

**Document Status:** Proposal

This document is a request for comments on managing the configuration of Windows Remote Management (WinRM) protocol listeners on Microsoft Windows systems to enable provisioning and ongoing remote management by Chef.

## Goal
The WinRM protocol is currently leveraged by Chef through tools such as knife to bootstrap (i.e. configure a system to query, enact, and report system
configuration to and from a Chef server) and otherwise remotely manage Windows systems. The WinRM protocol stack itself requires configuration before it can
be used for any of the aforementioned purposes.

The goal of the changes described in this document is to automate secure configuration of the WinRM protocol stack on Windows nodes that will be managed by Chef.

Automation here is valuable because secure WinRM configuration typically implies the use of WinRM's SSL transport, the configuration steps of which are cumbersome and not well-documented. Because of this configuration difficulty, users of the WinRM transport typically provision their Windows systems using the http protocol with no transport integrity or privacy because it is easier to do so using tools built into Windows itself. This results in systems that require additional security measures on configuration and remote management scenarios adding to the difficulty of securely using Chef over the WinRM protocol.

## Requirements
The requirements for automated configuration of WinRM SSL listeners are to

- Use the knife command line interface (CLI) for all WinRM listener management asks already familier to Chef users for Chef administration tasks in general
- All commands should be easy to use and learn for users of Windows and Chef 
- Commands should make use of conventions for similar tools in other software stacks common in the Chef user community
- Commands should be loosely coupled to reduce complexity and enable composition for as-yet unknown scenarios
- The following commands should be provided for the following functions
  - Generation of certificates for WinRM listeners
  - Installation of generated certificates in the certificate store of the
    Windows server on which the listener will be created
  - Creation of an SSL listener on the Windows server

## WinRM configuration management subcommands
The overall approach to managing WinRM listeners takes some inspiration from management of credentials for the ssh protocol, which is similar in many ways
to WinRM from a use case standpoint. The typical ssh configuration / usage scenario is

1. Generate an ssh key public key / private key pair for a particular user through a command such as ssh-keygen on some secure workstation
2. Configure an ssh daemon process of some sort (often these are configured by default in many *nix systems) on the system to be managed
3. Configure the public key in a well-known configuration store on the system to be managed to allow access via the ssh protocol by the holder of the private key
4. Use the private key on any remote system to establish an ssh session on the system to be managed

We propose an analogous workflow for WinRM

1. Generate a certificate containing a public / private key pair through a knife command on some secure workstation
2. Configure the WinRM service on the Windows system to be managed
3. Configure a WinRM listener with the generated certificate's public key on the system to be managed to allow access via the WinRM protocol by the holder
of the generated certificate which contains the private key
4. Use the generated certificate on any remote system to establish a WinRM session on they system to be managed

### Certificate generation command

    knife certificate winrm-certgen <options>
    
The output of the command will be X509 certificate. The certificate will be
generated in 2 formats:
- PKCS12: This should be added to the server's certificate store.
- PEM: This is needed by the client.

The command will also print out the thumbprint of the certificate generated.
The command can be run on any workstation.

  Options:

* `--domain`: By default there will be no domain name. So the hostname will be *. If the user wants to give the hostname as "*.mydomain.com then she must specify the domain as: --domain "mydomain.com"
* `--output-file`: You can specify alternate file path using this option. Eg: --output-file /home/.winrm/server_cert.pfx. This will create 2 files in the specified path with name server_cert.pem and server_cert.pfx.
* `--key-length`: Default is 2048.
* `--cert-validity`: Default is 24 months.
* `--cert-passphrase`: Default is winrmcertgen

The *winrm-certgen* command can be viewed as an analogue of the *ssh-keygen* command used to create ssh keys.

### Certificate installation command

    knife certificate winrm-certinstall CERT-PATH

This command should be run on the Windows server. The command will add the certificate specified in the CERT-PATH to its certificate store. The CERT-PATH
should point to a valid PKCS12 certificate.

Options:

* `--create-listener`: When this option is set, it will create the listener also on default port 5986.

### Listener creation command

    knife listener winrm create

This command is run on the Windows server. The command will create the winrm listener. Default is HTTP listener on port 5985

Options:

* `--thumbprint THUMBPRINT`: The command will create winrm HTTPS listener on port 5986. The THUMBPRINT should be a valid thumbprint of the certificate that is installed to the certificate store of the windows server.
* `--port`: Specify a port other than 5986.

Once a listener is created with this command, a WinRM connection can be established from a remote process that presents a certificate with the appropriate private key.

The *winrm-certinstall* command followed by the *winrm create* command can be viewed as similar to the configuration of ssh keys which is often accomplished by
copying an ssh key to a well-known configuration location for the ssh server process.

## Optional WinRM configuration commands
The following subcommands are useful, but not a requirement for an
implementation that meets the requirements declared in this document.

### Listener deletion command

    knife listener winrm delete HTTP/HTTPS

This command is run on Windows server. The command will delete the listener
specified.
### Listener list command

    knife listener winrm list

This command is run on Windows server. The command will list the winrm listeners.
