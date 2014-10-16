---
RFC: 26
Author: John Keiser <jkeiser@getchef.com>
Status: Accepted
Type: Standards Track
Chef-Version: 12
---

# Remove HTTP Config Files

Remove the ability to specify HTTP config files with `chef-client -c http://blah.com/client.rb`.

## Motivation

    As a Chef developer,
    I want to not have to directly find and fix the unknown number of bugs where we assume config_file is a path,
    so that I can write new features for Chef instead.

    As a Chef user,
    I am not using the ability to download a config file as a URL,
    And I am much more interested in the Chef developers writing new features instead of fixing bugs in it.

## Specification

1. Get rid of all code that lets you treat Chef::Config.config_file as an HTTP or HTTPS URL (in ConfigFetcher primarily).
2. Make it an error when you specify a config file that does not exist.

## Rationale

There are already bugs in the chef-client because we assume client is a path (`config_dir` is [File.dirname(`config_file`)](https://github.com/opscode/chef/blob/master/lib/chef/config.rb#L84), and some [rather crucial values](https://github.com/opscode/chef/blob/master/lib/chef/config.rb#L365) are inferred from `config_dir`).  While we could find and fix them all, we could also just make the code simpler by removing this capability.

## Impact and Workaround

Anyone running `chef-client -c http://blah.com/client.rb` will get an error saying the config file does not exist.

I suspect the number of people this will affect is somewhere between 0 and 0.  No Chef-written servers export config directly and there are very real security concerns around it.  If those people exist, there are real bugs in the client that those people are hitting because of it, as well (see the `config_dir` issue in Rationale).  Hence this RFC, so we can discuss it.

Users who *are* doing this can restore the original effect by doing the following in `/etc/chef/client.rb`:

```ruby
require 'net/http'
instance_eval(Net::HTTP.get('blah.com', '/client.rb'))
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
