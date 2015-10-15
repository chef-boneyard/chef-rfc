---
RFC: unassigned
Author:
  - Aaron Kalin <akalin@martinisoftware.com>
  - David Aronsohn <wagthattail@me.com>
Status: Draft
Type: Standards Track
---

# Title

Let users specify ohai plugins at bootstrap to provide additional node data on
the first and subsequent chef runs.

## Motivation

    As a chef user,
    I want to install ohai plugins during bootstrap,
    so that I have my ohai facts on my initial chef run.

## Specification

We add a new flag to the knife boostrap subcommand which allows you to specify
a single file or directory of ohai plugins to be placed in the newly created
`/etc/client.d` directory upon a bootstrap.

An example command would look like for a single plugin:

`knife bootstrap node.example.com --ohai-plugins="my_custom_plugin.rb" ...`

An example command would look like for a plugin directory:

`knife bootstrap node.example.com --ohai-plugins="my_plugin_dir" ...`

This command can accept glob notation to include parts of directories or files
which can help specify more specific groups of plugins:

`knife bootstrap node.example.com --ohai-plugins="my_plugin_dir/*_nginx.rb"

## Implementation

We will need to update the default knife bootstrap template and context to
include this new option in the template rendering context in a similar
fashion to how the chef client configuration is generated.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
