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

## knife openstack server list

"knife openstack server list" will provide support for listing nodes' networks other than `public` and `private`.

"knife CLOUD server list" all have `Public IP` and `Private IP` as column headers.


knife CLOUD server list
The various permutations of "knife CLOUD server list" all have `Public IP` and `Private IP` as column headers (in various capitalizations and spacings). Standardizing this under knife-cloud and making an additional argument of --network [NAMES_OR_IDS] that defaulted to `public,private` would allow for overriding to show different networks without requiring the display of every potential network. An additional option of --network-filter [NAMES_OR_IDS] could be used to only show the nodes on those networks. Because this information may be easier to pull from the Chef node than from Fog (depending on the particular cloud provider), knife-cloud shold also provide the associated node's name as a column, a frequently mentioned feature request.

## Future work

IPV6
ohai will properly list all networks other than `public` and `private`
Unit tests to validate all new options.
Integration tests where possible through the new Knife CI infrastructure.
knife CLOUD server create

Ohai

The Ohai `cloud` plugin pushes information into private_ips and public_ips, but if networks have an alternate name they are overlooked. In EC2, HP and Rackspace for example, `local_ipv4` is mapped to `cloud.private_ipv4`, which is likely to be incorrect in some cases. Additional network data may be available from the metadata server (ec2, hp, openstack) but this should be confirmed and normalized within `cloud`.

Ohai
The Ohai `cloud` plugin is populated by cloud-specific code, but it generally pushes `local` attributes into `private` and anything else gets pushed into a list of additional `private_ips` (ie. node['openstack']['local_ipv4'] becomes ['cloud']['local_ipv4'] and ['cloud']'['private_ips'][0]). Since 'public' and 'private' may not even be applicable (but are almost definitely expected by many current users, so may require longterm deprecation), the proposal is made to add a new 'networks' attribute with all of the node's networks embedded within. This allows new attributes without removing existing attributes and minimizes namespace collisions.

node['cloud']['networks'], the keys as NAMES_OR_IDS, likely to be ['public','private']. Users could call
node['cloud']['networks'].keys
to get the list of the node's networks.
node['cloud']['networks']['NAME_OR_ID'], each key of node['cloud']['networks'] is a hash of all relevant network data (ie. node['cloud']['networks']['public'])
node['cloud']['networks']['NAME_OR_ID']['associated'], list of IP addresses associated with the node on this network, likely to be singular (examples include floating IPs, Elastic IPs)
node['cloud']['networks']['NAME_OR_ID']['ipv4'], list of IPv4 addresses on this network, likely to be singular
node['cloud']['networks']['NAME_OR_ID']['ipv6'], list of IPv6 addresses on this network, likely to be singular
node['cloud']['networks']['NAME_OR_ID']['hostname'], list of hostnames associated with this network, likely to be singular
