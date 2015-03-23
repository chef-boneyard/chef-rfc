---
RFC: unassigned
Author: Lamont Granquist <lamont@chef.io>
Status: Draft
Type: <Standards Track>
---

# Ohai Identity Attributes

The purpose of this RFC is to clarify the semantics of the node identity attributes:

* hostname
* machinename
* fqdn
* domain

This RFC encodes the current defacto standards as of Chef 12.1.x / Ohai 8.1.x

## Motivation

    As a Chef user
    I want consistent semantics for node identity attributes across platforms

    As a Cookbook author
    I want to be able to use node['fqdn'] and node['domain'] and have them DWIM

    As a Cookbook author
    I do not want to have to use attributes other than node['fqdn'] or node['domain'] to DWIM

    As a Solaris user
    I want the node['fqdn'] and node['domain'] to be computed from the short hostname and NIS domain

    As a Linux user
    I typically want to use the FQDN as my nodename and use that for derived attributes directly

    As a Chef user
    I do not want DNS failures to affect computation of my nodename/fqdn

## History

In Ohai 7.0.0 the semantics of the identity attributes were normalized to have the following meanings:

* `hostname`:  the short hostname discovered via `hostname` (all platforms were consistent here)
* `machinename`:  the raw output of `/bin/hostname` (this was introduced so that it was available for node
  name resolution inside of chef-client)
* `fqdn`:  equivalent to `/bin/hostname -f` (most platforms used this algorithm before 7.0.0, after 7.0.0 
  it was made consistent across all platforms -- in some cases this was the return of `/bin/hostname` and
  Solaris used hostname + NIS domain).
* `domain`: computed from the domain suffix of the `fqdn` attribute

Changing the `hostname` to be something other than the short hostname is most likely unwise since it has been
that way consistently since it was introduced.  Because of that the `machinename` attribute was introduced to
expose the actual return of `/bin/hostname` which is used in `node_name` guessing in the Chef::Client which
uses the algorithm:

```ruby
name = Chef::Config[:node_name] || ohai[:fqdn] || ohai[:machinename] || ohai[:hostname]
```

It was discussed making the `fqdn` attribute to prefer the return of `/bin/hostname` when that returned a
FQDN, but this felt to break some edge conditions in DNS related cookbooks (djbdns?) and so this was forced
to be the fqdn which was resolved via DNS resolution across all platforms.  For platforms that do not support
the `-f` flag to `hostname` a pure ruby version is used by ohai.

The changes in Ohai 7.0.0 to the `fqdn` attribute broke Solaris people with busted DNS who expected the
NIS domainname workaround to work.

There is also a weakness in the `fqdn` attribute in that it relies on having setup forward and reverse DNS and that
DNS is operating correctly.  A DNS failure may cause the fqdn attribute to be nil transiently.  This is likely
a problem because Chef::Client uses it internally as first precedence for guessing the `node_name` and `fqdn` is
used by many cookbooks.

# Specification

## First Proposal (Short Term Fix)

The first proposal is to modify the `fqdn` attribute to be:

# Equivalent to `/bin/hostname -f` if that algorithm succeeds in returning a FQDN
# Returning `/bin/hostname` if that returns a FQDN
# Returning `/bin/hostname` plus `/bin/domainname`

This is not a strict revert back to the Ohai 6.x behavior and it should be implemented consistently across
all platforms.  It will fix the Solaris behavior to construct the FQDN from the NIS domain in the absence of
working DNS when there's only a short hostname.

This will potentially break the semantics that the FQDN is supposed to be computed from the DNS domain.

Embedding this information into a different attribute will not solve the problem because too many cookbooks
expect the `fqdn` attribute to Just Work(tm) and there would be too many cookbooks to update.

This changes the semantics of the `fqdn` attribute and may be a breaking change, but would need to be
introduced in a minor release of Chef 12 in order to fix the issue for Solaris customers.  The risk is low.

## Second Proposal (Long Term Fix)

Since the short term fix breaks the strict semantics of the `fqdn` attribute, that opens the door as to if
those semantics were right in the first place.

The `hostname -f` lookup has an inherent weakness in that it relies on DNS, which may fail.  It is also obvious
that both cookbook users and authors expect the `fqdn` attribute to DWIM.  The use case for having the `fqdn`
attribute be strict is a very small subset of a few cookbooks and is the uncommon case.

It is proposed that the `fqdn` attribute semantics be changed to:

# Returning `/bin/hostname` if that returns a FQDN
# Returning `/bin/hostname` plus `/bin/domainname`
# Equivalent to `/bin/hostname -f` if that algorithm succeeds in returning a FQDN

By moving the FQDN lookup to last, it will only be tried if the hostname is not set to a FQDN, and there is no
configured NIS domain.  This precedence favors methods of determining the `fqdn` which cannot fail.

Additional attributes for `dns_fqdn` and `dns_domain` will be introduced which will always be the return of the
`/bin/hostname -f` algorithm.  There will be a few cookbooks which must be updated to use these new 
attributes.

This will definitely be considered a breaking change.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
