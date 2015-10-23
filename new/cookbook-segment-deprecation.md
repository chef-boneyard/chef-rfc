---
RFC: unassigned
Author: Lamont Granquist <lamont@chef.io>
Status: Draft
Type: Standards Track
---

# Title

Cookbook Segment Deprecation

## Motivation

    As a Chef User/Developer
    I want to be able to extend the structure of cookbooks easily,
    in order to quickly adapt to new automation needs.

## Specification

This RFC specifies a new format for the GET and PUT requests to the cookbooks/NAME/VERSION
endpoint.  This is a breaking change which will mandate a bumping of the API version to
the protocol.  The existing 'segments' will be removed out of the cookbook version and a
new 'all_files' segment will be introduced which will simply be a list of all the files in
the cookbook.

The Chef Server MUST respond to all GET requests that do not contain an appropriate API version
with the old protocol with segments.  Cookbooks that have been uploaded in the new format
MUST have their manifest information filtered so that an old style response can be constructed.
When the Chef Server sees an API version in the GET request that accepts the new style it
MUST respond only with the 'all_files' segment in the body of the response.

All new Clients MUST set their API version correctly in order to get the new behavior on
PUT or GET.  Since old Servers will not accept the new 'all_files' segment Clients MUST determine
the server version they are talking to and send their PUT requests correctly.  Clients MAY
use prior communication with the Chef Server (i.e. during the uploading of sandbox files they
MAY determine the API version of the Chef Server off of the replies and use that information) to
determine the correct API version to use and format their PUT request accordingly.  Clients
MAY also PUT with the new format and after receiving a 4xx code from the Server retry the
request in the old format and downgrade.

Note that the paths in 'all_files' necessarily change to include the leading segment (or not
in the case of the old `root_files`).

The implementation of this RFC must still fully support both settings of the `no_lazy_load`
config parameter.

## Request/Response Format

The old format of GET/PUT requests to coobooks/NAME/VERSION looks like:

```
{
  "definitions": [
    {
      "name": "unicorn_config.rb",
      "checksum": "c92b659171552e896074caa58dada0c2",
      "path": "definitions/unicorn_config.rb",
      "specificity": "default"
    }
  ],
  "name": "unicorn-0.1.2",
  "attributes": [],
  "files": [],
  "json_class": "Chef::CookbookVersion",
  "providers": [],
  "metadata": {
    "dependencies": {"ruby": [], "rubygems": []},
    "name": "unicorn",
    "maintainer_email": "ops@opscode.com",
    "attributes": {},
    "license": "Apache 2.0",
    "suggestions": {},
    "platforms": {},
    "maintainer": "Opscode, Inc",
    "long_description": "= LICENSE AND AUTHOR:\n\nAuthor:: Adam Jacob...",
    "recommendations": {},
    "version": "0.1.2",
    "conflicting": {},
    "recipes": {"unicorn": "Installs unicorn rubygem"},
    "groupings": {},
    "replacing": {},
    "description": "Installs/Configures unicorn",
    "providing": {}
  },
  "libraries": [],
  "templates": [
    {
      "name": "unicorn.rb.erb",
      "checksum": "36a1cc1b225708db96d48026c3f624b2",
      "path": "templates/default/unicorn.rb.erb",
      "specificity": "default"
    }
  ],
  "resources": [],
  "cookbook_name": "unicorn",
  "version": "0.1.2",
  "recipes": [
    {
      "name": "default.rb",
      "checksum": "ba0dadcbca26710a521e0e3160cc5e20",
      "path": "recipes/default.rb",
      "specificity": "default"
    }
  ],
  "root_files": [
    {
      "name": "README.rdoc",
      "checksum": "d18c630c8a68ffa4852d13214d0525a6",
      "path": "README.rdoc",
      "specificity": "default"
    },
    {
      "name": "metadata.rb",
      "checksum": "967087a09f48f234028d3aa27a094882",
      "path": "metadata.rb",
      "specificity": "default"
    },
    {
      "name": "metadata.json",
      "checksum": "45b27c78955f6a738d2d42d88056c57c",
      "path": "metadata.json",
      "specificity": "default"
    }
  ],
  "chef_type": "cookbook_version"
}
```

That same request with the new format would look like:

```
{
  "name": "unicorn-0.1.2",
  "json_class": "Chef::CookbookVersion",
  "metadata": {
    "dependencies": {"ruby": [], "rubygems": []},
    "name": "unicorn",
    "maintainer_email": "ops@opscode.com",
    "attributes": {},
    "license": "Apache 2.0",
    "suggestions": {},
    "platforms": {},
    "maintainer": "Opscode, Inc",
    "long_description": "= LICENSE AND AUTHOR:\n\nAuthor:: Adam Jacob...",
    "recommendations": {},
    "version": "0.1.2",
    "conflicting": {},
    "recipes": {"unicorn": "Installs unicorn rubygem"},
    "groupings": {},
    "replacing": {},
    "description": "Installs/Configures unicorn",
    "providing": {}
  },
  "cookbook_name": "unicorn",
  "version": "0.1.2",
  "all_files": [
    {
      "name": "README.rdoc",
      "checksum": "d18c630c8a68ffa4852d13214d0525a6",
      "path": "README.rdoc",
      "specificity": "default"
    },
    {
      "name": "metadata.rb",
      "checksum": "967087a09f48f234028d3aa27a094882",
      "path": "metadata.rb",
      "specificity": "default"
    },
    {
      "name": "metadata.json",
      "checksum": "45b27c78955f6a738d2d42d88056c57c",
      "path": "metadata.json",
      "specificity": "default"
    },
    {
      "name": "recipes/default.rb",
      "checksum": "ba0dadcbca26710a521e0e3160cc5e20",
      "path": "recipes/default.rb",
      "specificity": "default"
    },
    {
      "name": "templates/unicorn.rb.erb",
      "checksum": "36a1cc1b225708db96d48026c3f624b2",
      "path": "templates/default/unicorn.rb.erb",
      "specificity": "default"
    },
    {
      "name": "definitions/unicorn_config.rb",
      "checksum": "c92b659171552e896074caa58dada0c2",
      "path": "definitions/unicorn_config.rb",
      "specificity": "default"
    }
  ],
  "chef_type": "cookbook_version"
}
```

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
