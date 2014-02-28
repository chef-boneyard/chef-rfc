# Named Network Support in knife-openstack

Proposal for generically supporting networks not named `public` or `private` with knife-openstack.

For the existing knife plugins there has been a general assumption that virtual machines provisioned have a `public` and/or a `private` IP address. With OpenStack's capability of having essentially unlimited named networks this assumption falls short. There have been several proposed fixes, but a generalized solution that is adaptable for each use case is needed.

## knife openstack server create

`knife openstack server create` will provide support for bootstrapping nodes on networks other than `public` and `private` IP addresses.

### Current

`knife openstack server create` currently supports `--private-network` to use the private IP for bootstrapping rather than the public IP.

There are also a number of networking-related tickets open with patches that may be relevant:

 * [KNIFE-231](https://tickets.opscode.com/browse/KNIFE-231) added ability to specify arbitrary network ID
 * [KNIFE-277](https://tickets.opscode.com/browse/KNIFE-277) knife openstack "ERROR: No IP address available for bootstrapping."

### Proposal

 * `knife openstack server create --network [NAMES_OR_IDS]`: comma separated list of networks to attach to. Default is `public,private`
 * `knife openstack server create --private-network`: Use the private IP for bootstrapping rather than the public IP, unchanged behavior

## knife openstack server delete

`knife openstack server delete` will display the proper network information for the node.

### Current

`knife openstack server delete` currently lists the `public` and `private` networks associated with the node marked for deletion.

### Proposal

`knife openstack server delete`: list all networks and IPs networks associated with the node.

#### Example output

```shell
$ knife openstack server delete 5fe19d0d-431a-415e-84f2-4281a5460460
Instance Name: os-3703903309844765
Instance ID: 5fe19d0d-431a-415e-84f2-4281a5460460
Flavor: 1
Image: c6ec4c81-e116-4d78-9b78-6c9bb9b91377
Bar IP Address: 172.168.100.81
Foo IP Address: 10.138.100.5
Public IP Address: 192.168.100.2

Do you really want to delete this server? (Y/N)
```

## Future work

This RFC is focused on associating with known named networks and these changes will be included in future releases after the [knife-cloud](https://github.com/opscode/knife-cloud/) refactoring. The knife-cloud refactoring will make these options available to additional knife plugins.

### knife openstack server list

`knife openstack server list` will provide support for listing nodes' networks other than `public` and `private`.

#### Current

'Public IP' and 'Private IP' are hard-coded in the output.

```shell
Instance ID                           Name                 Public IP      Private IP  Flavor  Image                                 Keypair  State
5fe19d0d-431a-415e-84f2-4281a5460460  os-3703903309844765  192.168.100.2              1       c6ec4c81-e116-4d78-9b78-6c9bb9b91377  testing  active
```

#### Proposal

The various permutations of "knife CLOUD server list" all have 'Public IP' and 'Private IP' as column headers (in various capitalizations and spacings). Standardizing this under knife-cloud and making an additional argument of `--network [NAMES_OR_IDS]` that defaulted to `public,private` would allow for overriding to show different networks without requiring the display of every potential network. An additional option of `--network-filter [NAMES_OR_IDS]` could be used to only show the nodes on those networks. Because this information may be easier to pull from the Chef node than from Fog (depending on the particular cloud provider), knife-cloud shold also provide the associated node's name as a column, a frequently mentioned feature request.

This will be part of a future knife-cloud-based release.

### knife openstack network list

`knife openstack network list` will list all of the networks available for attaching new nodes to.

#### Current

Not currently available.

#### Proposal

Outputs a list of available networks to the currently configured OpenStack account. `knife rackspace network list` currently lists the networks available for Rackspace users, the `knife CLOUD network list` will behave similarly.

This will be part of a future knife-cloud-based release.
