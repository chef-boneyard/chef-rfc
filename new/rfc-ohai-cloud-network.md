# Enhanced Ohai Network Support

The Ohai `cloud` plugin pushes information into `private_ips` and `public_ips`, but if networks have an alternate name they are overlooked. In EC2, HP and Rackspace for example, `local_ipv4` is mapped to `cloud.private_ipv4`, which is likely to be incorrect in some cases. Additional network data may be available from the metadata server (ec2, hp, openstack) but this should be confirmed and normalized within `cloud`.

This was previously discussed internally at Chef at http://wiki.corp.opscode.com/display/CORP/RFC+Generalized+Network+Configuration+Specification+for+Knife+Cloud+Plugins

## OpenStack

The Ohai `cloud` plugin is populated by cloud-specific code, but it generally pushes `local` attributes into `private` and anything else gets pushed into a list of additional `private_ips` (ie. `node['openstack']['local_ipv4']` becomes `['cloud']['local_ipv4']` and `['cloud']'['private_ips'][0]`). The mapping of values from the API into the existing cloud attribute namespaces should be checked for validity.

## Proposal

Since `public` and `private` may not even be applicable (but are almost definitely expected by many current users, so may require longterm deprecation), the proposal is made to add an additional `networks` attribute with all of the node's networks embedded within. This allows new attributes without removing existing attributes and minimizes namespace collisions.

 * `node['cloud']['networks']`, the keys as NAMES_OR_IDS, likely to be `['public','private']`. Users could call `node['cloud']['networks'].keys` to get the list of the node's networks.
 * `node['cloud']['networks']['NAME_OR_ID']`, each key of `node['cloud']['networks']` is a hash of all relevant network data (ie. `node['cloud']['networks']['public']`)
 * `node['cloud']['networks']['NAME_OR_ID']['associated_ipv4']`, list of IPv4 addresses associated with the node on this network, likely to be singular (examples include floating IPs, Elastic IPs)
 * `node['cloud']['networks']['NAME_OR_ID']['associated_ipv6']`, list of IPv6 addresses associated with the node on this network, likely to be singular (examples include floating IPs, Elastic IPs)
 * `node['cloud']['networks']['NAME_OR_ID']['ipv4']`, list of IPv4 addresses on this network, likely to be singular
 * `node['cloud']['networks']['NAME_OR_ID']['ipv6']`, list of IPv6 addresses on this network, likely to be singular
 * `node['cloud']['networks']['NAME_OR_ID']['hostnames']`, list of hostnames associated with this network, likely to be singular

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
