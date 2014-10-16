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
4. The warning for missing config file is set to INFO.
5. When the config file is missing, the algorithm that detects the chef repository by looking for a "cookbooks/" directory also looks for "clients/" (and thus, after the first time you run chef-client, you will no longer get any warnings).

## Rationale

This will make it so that when you first walk up to Chef, your experience is thus:

```
$ echo "puts 'hi'" > x.rb
$ chef-client x.rb
WARN: No chef repository detected at or above current directory (no cookbooks/ or clients/ subdirectories found).  Assuming current directory (/Users/jkeiser/test).
WARN: chef-client will create a /Users/jkeiser/test/clients and /Users/jkeiser/test/nodes, and you will not see this warning again.
...
$ knife node list
foo
$ chef-client x.rb
...
```

Presently, when chef-client is run without configuration (or the configuration does not point at a Chef server), we assume the user wanted to point at a local Chef server (https://localhost:443).  This is not a particularly common mode of operation now that chef-zero exists (which only recently supported https), and many many more users will be running local mode.  Further, existing real clients will definitely *not* be pointing at localhost; they point at real servers.

This change could have been implemented more simply by simply defaulting `Chef::Config.local_mode` to `true`.  However, this would impact nearly all chef-clients (which would stop working until local_mode was turned off) without actually helping any more of the intended users (who generally will not have configuration).  By tying this to setting the `chef_server_url`, we ensure that clients who actually want to contact a Chef server can do so, and target only people who weren't talking to a Chef server in the first place.

The oddest behavior here is that users who want to run `chef-client` in local mode on a managed machine probably won't actually run in local mode.  Without changing the default behavior of `chef-client`, I'm not sure there is a way around this without changing the config structure completely (which would be another RFC).  Nonetheless, this at least gets us much closer to a parameter-free world, and *definitely* gets us there for new users.

## Impact

- `chef-client` and `knife`, when run with no parameters and no configuration, will run in local mode without the `-z` parameter.
- Existing clients that *do* have configuration but assume the Chef server is at https://localhost:443, will start running with empty runlists.
- Existing clients that do not have `/etc/chef/client.rb` but just assume https://localhost:443 will load `knife.rb`.
- Users who want to run `chef-client` in local mode on a managed machine with `/etc/chef/client.rb` will not end up loading `knife.rb` and probably not even run local mode.
- When users accidentally run knife and chef-client outside of their repository, they will now warn the user but still give them output which they might not expect.  When you run `knife node list`, for example, outside of a repository, it will not return any nodes and have empty output.  We rely on the warnings to indicate to the user that something is up:

```
$ knife node list
WARN: No chef repository detected at or above current directory (no cookbooks/ or clients/ subdirectories found).  Assuming current directory (/Users/jkeiser/test).
WARN: You may not be in the right directory.
```

Before, that would have triggered an error related to not having a private key or being able to access https://localhost:443.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.

```
