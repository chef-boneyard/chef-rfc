---
RFC: unassigned
Title: Authentication Configuration
Author: Thom May <thom@chef.io>
Status: Draft
Type: Standards Track
---

# Authentication Configuration

Currently, the Chef community maintains many tools to aid in the
management and switching of Chef Server configuration options - for
example `knife-block`. Any non-ruby tools must also implement their own
configuration management, since our configuration files must be parsed
as though they were ruby.
It would be delightful to provide a single configuration file that was
solely responsible for handling authentication options, and was in a
language agnostic format, such as TOML.

## Motivation

    As an Operations Engineer,
    I want to manage nodes on many Chef Servers,
    so that I can interact with my whole estate.

    As a tool developer,
    I want to use the language of my choice,
    so that I can effectively build delightful Chef features.

## Specification

A new file, `~/.chef/credentials`, will be supported by the chef client
libraries, and other implementations. It is a TOML file, containing one
or more sections, each associated with a profile.

```
[default]
node_name = "barney"
client_key = "barney_rubble.pem"
chef_server_url = "https://api.chef.io/organisations/bedrock"

[dev]
node_name = "admin"
client_key = "admin.pem"
validator_key = "test-validator.pem"
chef_server_url = "https://api.chef-server.dev/organizations/test"
```

File paths, such as `client_key` or `validator_key`, will be relative to
`~/.chef` unless absolute.

The profile is selected using the `CHEF_PROFILE` environment variable, which
client libraries MUST support. Optionally, tools can also provide a
`--profile` option, which would override the environment variable.

It is expected that the credentials file will be parsed first, allowing
the user's `knife.rb`/`config.rb` to continue to function as previously.

## Downstream Impact

Any chef API client library (such as `pychef`, `go-chef`,
`rs-chef-api`), as well as `chef-config`, should be updated
to support this file. 

Manage should be updated to produce a credentials file when generating a
knife config.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
