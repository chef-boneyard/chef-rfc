---
RFC: unassigned
Author: Jay Mundrawala <jdm@chef.io>
Author: Bryan McLellan <btm@chef.io>
Status: Draft
Type: Standards Track

---

# Knife Bootstrap `client.rb` Configuration

Knife bootstrap currently only allows a select few `client.rb` parameters
to be specified during bootstrap. This RFC proposes a solution to allow users
to pass bulk configuration data to `knife bootstrap` to be placed in the
`client.rb` before the first chef-client run.

## Background

The `knife bootstrap` command supports a small subset of possible parameters
a user can configure in the `client.rb`. The chef-client cookbook provides a
template that supports many more, allowing the user to configure additional
options during a Chef client converge. If something you are trying to do does
not fit into the template provided, you are also free to specify config files
in a `client.d` folder that will automatically be loaded. However, because
the chef-client cookbook is run along with the rest of the run list on the
first run, your settings do not take effect until the second chef-client
run.

## Motivation

    As a Chef user,
    I want to be able to configure chef-client with options that aren't supported by knife bootstrap,
    so that I do not have to maintain a fork of the bootstrap template,
    or so that I do not have to learn about bootstrap templates at all,
    or so that I don't have to make two chef-client runs on bootstrap to apply and use my configuration file.

    As a Chef developer,
    I want the user to have a generic way to pass custom client configuration file,
    so that I don't have the maintenance cost of additional bootstrap arguments for new features

## Specification

### Append Config Files From `client.d`

The `chef-client` cookbook adds a block to load all `.rb` files in
the `client.d` folder. The proposal here is to do the same thing.
Knife bootstrap will take a `client.d` folder, by default looking
the chef repo under `bootstrap`, optionally overwritable with a
switch `--client_d_dir`. The files will be loaded in alphabetical
order. Knife will still sync all files under `client.d`, however
only top-level files will the automatically loaded. The block to
do this would look something like:

```ruby
Dir.glob("/etc/chef/client.d/*.rb").sort.each do |conf|
  Chef::Config.from_file(conf)
end
```

#### Example

For this example, consider we want to configure Ohai's hostname plugin.
The execution of this plugin will determine the node name that will be
assigned to the node we are bootstraping, so it needs to be correct on
the first run.

We store the `ohai_config.rb` file in the Chef repo on our workstation:

```ruby
# chef-repo/bootstrap/client.d/ohai_config.rb

ohai.plugin[:hostname][:fqdn_using] = [ :hostname, :nis, :dns ]
```

```ruby
# chef-repo/bootstrap/client.d/ohai_plugins/custom_plugin.rb

# My custom ohai plugin
```

Next we bootstrap the node:

    knife bootstrap 10.0.0.100 -x chefuser -P oneofus

This generates the following `client.rb` and copies it to the box,
along with all the contents in our chef repo's `client.d` directory:

```ruby
# /etc/chef/client.rb

log_level        :info
log_location     STDOUT
chef_server_url  "https://api.chef.io/organizations/oneofus"
ohai.plugin_path = "/etc/chef/client.d/ohai_plugins"

Dir.glob("/etc/chef/client.d/*.rb").sort.each do |conf|
  Chef::Config.from_file(conf)
end
```

```ruby
# /etc/chef/client.d/ohai_config.rb

ohai.plugin[:hostname][:fqdn_using] = [ :hostname, :nis, :dns ]
```

```ruby
# /etc/chef/client.d/ohai_plugins/custom_plugin.rb

# My custom ohai plugin
```

Now, when chef-client runs on the box, our configurations to
Ohai's hostname plugin will be loaded before Ohai runs, allowing
the first Chef run to get the correct hostname.

Taking a look under `/etc/chef`, we should see something like:

    [vagrant@localhost ~]$ tree /etc/chef/
    /etc/chef/
    ├── client.d
    │   ├── ohai_config.rb
    │   └── ohai_plugins
    │       └── custom_plugin.rb
    ├── client.pem
    ├── client.rb
    ├── first-boot.json
    ├── trusted_certs
    │   └── localhost.crt
    └── validation.pem

### `client.rb` Bootstrap Template

The `client.rb.erb` template can be provided for more fine-grained control.
The default location for this file will be `chef-repo/bootstrap/client.rb.erb`,
in a similar fassion to where the bootstrap template lives. A `@config`
parameter for the knife bootstrap commands will be passed to the template.
Additional parameters, such as those not specified in the knife bootstrap
command line will be available under `@config[:withs]`. These can be
specified on the command line using `--with-paramname=value`. `--with-`
will be removed and the remaining string up to the equal sign will be added
the `@config[:withs]`. For example, `--with-paramname=value` with be added
to `@config` as `@config[:withs]['paramname'] = 'value'`.

#### Example

First, create a template.

    chef generate client-rb

    [vagrant@localhost chef-repo]$ tree .
    .
    └── bootstrap
        └── client.rb.erb

A default client.rb.erb could look like:

```ruby.erb
<% if @config[:node_name] -%>
node_name "<%= @config[:node_name] %>"
<% end %>

log_location STDOUT
chef_server_url "<%= @config[:chef_server_url] %>
validation_client_name "<%= config[:validation_client_name] %>"

<% if @config[:node_verify_api_cert]  == "peer" %>
ssl_verify_mode :verify_peer
<% elsif @config[:node_verify_api_cert]  == "none" %>
ssl_verify_mode :verify_none
<% end %>

<% if @config[:bootstrap_proxy] %>
http_proxy "<%= @config[:bootstrap_proxy] %>"
https_proxy "<%= @config[:bootstrap_proxy] %>"
<% end %>

<% if @config[:bootstrap_no_proxy] %>
no_proxy "<%= @config[:bootstrap_no_proxy] %>"
<% end %>

encrypted_data_bag_secret "/etc/chef/encrypted_data_bag_secret"
trusted_certs_dir "/etc/chef/trusted_certs"

Dir.glob("/etc/chef/client.d/*.rb").sort.each do |conf|
  Chef::Config.from_file(conf)
end
```
For this example, say we want to set `log_location`. `log_location` is
not settable through the knife bootstrap command. We could pass it in
using `--with-my_log_location`, which can be accessed through 
`@config[:withs]['my_log_location']` in the template. So part of the
template could look like:

```ruby.erb
<% if @config[:withs]['my_log_location'] == "STDERR" %>
log_location STDERR
<% elsif @config[:withs]['my_log_location'] %>
log_location "<%= @config[:withs]['my_log_location'] %>"
<% end %>
```

Now, we bootstrap the node. Since client.rb.erb is in the default
location in our chef repo (chef-repo/bootstrap/client.rb.erb), we
do not have to manually specify it:

    knife bootstrap 10.0.0.100 -x chefuser -P oneofus --with-my_log_location='/log.txt'


## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

