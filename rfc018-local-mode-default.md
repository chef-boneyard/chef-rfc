---
RFC: unassigned
Author: John Keiser <jkeiser@getchef.com>
Status: Draft
Type: <Standards Track, Informational, Process>
---

# Title

Turn on Local Mode by default in Chef 12 (do not require -z).

## Motivation

    As a new Chef user,
    I want to be able to run my first recipe without typing weird parameters,
    so that I can come to love Chef that much more quickly and without any conceptual obstacles.

    As a local developer,
    I want to be able to iterate quickly on recipes with less typing,
    so that I can avoid carpal tunnel syndrome.

    As a Chef book or tutorial author,
    I want to be able to write examples free of dashes,
    because they mess up formatting and make the user ask questions I don't need them asking early in the tutorial.

## Specification

I propose that:
1. `Chef::Config.local_mode` default to `true` when `chef_server_url` is not set.
2. The default `Chef::Config.chef_server_url` of https://localhost:443 be removed (and have no default).
3. When `chef-client` does not find `/etc/chef/client.rb`, it search for `knife.rb` in the same manner as local mode.

## Impact

- `chef-client` and `knife`, when run with no parameters and no configuration, will run in local mode without the `-z` parameter.
- Existing clients that *do* have configuration but assume the Chef server is at `https://localhost:443`, will start running with empty runlists.
- Existing clients that do not have `/etc/chef/client.rb` but just assume `https://localhost:443` will load `knife.rb`.
- Users who want to run `chef-client` in local mode on a managed machine with `/etc/chef/client.rb` will not end up loading `knife.rb` and probably not even run local mode.

## Rationale

Presently, when chef-client is run without configuration (or the configuration does not point at a Chef server), we assume the user wanted to point at a local Chef server (https://localhost:443).  This is not a particularly common mode of operation now that chef-zero exists (which only recently supported https), and many many more users will be running local mode.  Further, existing real clients will definitely *not* be pointing at localhost; they point at real servers.

This change could have been implemented more simply by simply defaulting `Chef::Config.local_mode` to `true`.  However, this would impact nearly all chef-clients (which would stop working until local_mode was turned off) without actually helping any more of the intended users (who generally will not have configuration).  By tying this to setting the `chef_server_url`, we ensure that clients who actually want to contact a Chef server can do so, and target only people who weren't talking to a Chef server in the first place.

The oddest behavior here is that users who want to run `chef-client` in local mode on a managed machine probably won't actually run in local mode.  Without changing the default behavior of `chef-client`, I'm not sure there is a way around this without changing the config structure completely (which would be another RFC).  Nonetheless, this at least gets us much closer to a parameter-free world, and *definitely* gets us there for new users.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

```
