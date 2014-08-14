Ubuntu init provider
====================

## Summary

Proposal to resolve [issue](https://github.com/opscode/chef/issues/1587) with the goal to address the idiosyncracies of the planned Ubuntu init system changes.

As of Ubuntu 13.10 the governing body of Ubuntu decided to move to using [Upstart](http://upstart.ubuntu.com/) as
the system for controlling system tasks. As of Ubuntu 14.04 LTS this is the only init system, all init.d backward compatibility has been dropped.
For Ubuntu releases after 14.04 LTS, [Canonical](http://www.markshuttleworth.com/archives/1316) will be moving to [systemd](http://www.freedesktop.org/wiki/Software/systemd/).

This RFC serves as the groundwork to sanely address the provider support for all the permutations of init systems on the Ubuntu platform.

| Ubuntu version     | system  |
| ------------------ | ------  |
| < 13.10            | init.d  |
| > 13.10 or < 14.04 | upstart |
| > 14.04            | systemd |

## Document status

This Request for Comments (RFC) document's proposals are accepted as an
active implementation in a regression for Chef Client 11.11.0 and subsequent releases of Chef
Client.

See  <https://docs.opscode.com> for authoritative, updated documentation on these features.

## Motivation

At this time most cookbooks require a workaround to select a working provider on Ubuntu 14.04. An example:

```ruby
service "rsyslog" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true
  action [:enable,:start]
end
```

This implies that every service in each cookbook will have to have that extra line.
This requires extra logic to select the appropriate mapping of Ubuntu version to provider. 

## Work that has already been done

Lamount has created a [framework](https://github.com/opscode/chef/pull/1596) to have a way to check for the system you are using.
Which could fix help move this forward, but it would need to be thourghly tested and
would require each cookbook to be updated.

btm put in a note to the README.md for chef [about this](https://github.com/opscode/chef/commit/9e629347d519f3e9370f46efa1d48bec4ac8e152)
to help vocalize the issue, but it still isn't a fix.

## Proposed Solution

Leverage Lamuount's framework in the long term, but for the short term we need to
either c

## References and further reading

* Chef documentation: <http://docs.opscode.com>
* Chef resource documentation: <http://docs.opscode.com/resource.html>
* Chef main status of this fix: <https://github.com/opscode/chef/issues/1587>
* CHEF-3404 Provider Resolver: <https://github.com/opscode/chef/pull/1596>
* Mark Shuttleworth's post about converting to systemd: <http://www.markshuttleworth.com/archives/1316>
* Matthew McMillan's post how to fix 14.04 restarts: <http://matthewcmcmillan.blogspot.com/2014/06/ubuntu-1404-init-scripts-fail-and-throw.html>
* zdnet explaination about the debate: <http://www.zdnet.com/after-linux-civil-war-ubuntu-to-adopt-systems-7000026373/>
* Upstart Compatible Init Scripts: <https://wiki.ubuntu.com/UpstartCompatibleInitScripts>
* Joshua Timberman's Bugreport about init scripts: <https://bugs.launchpad.net/ubuntu/+source/rsyslog/+bug/1311810>
