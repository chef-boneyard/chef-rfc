---
RFC: unassigned
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Draft
Type: Standards Track
---

# Dialects in Chef

Currently Chef supports a mix of Ruby DSLs and JSON for it's data. This RFC
proposes to add hooks in to Chef to allow cookbooks and knife plugins to support
additional formats.

## Motivation

The overall motivation can be summed up as:

    As a Chef user,
    I want to write in a variety of formats,
    so that cookbook maintenance is easier.

A specific version of that which deserves extra mention is:

    As a new Chef user,
    I want to write in a variety of formats,
    so that I don't have to learn Ruby.

## Specification

At heart, the dialects system is an additional layer of indirection around
all forms of file loading in Chef. Currently most code either calls
`FFI_Yajl::Parser.parse` or `ClassName.from_file`, sometimes with a simple
dispatcher like in `Chef::Knife::Core::ObjectLoader`. The dialects registry
provides a central location to register code to handle loading a given file
suffix or MIME type and then utility functions to return an object of a given
type and filename.

### Dialect Types

Dialects are used in two distinct places: cookbooks and knife plugins.
Dialect cookbooks are used to provide dialects for things like attribute
and recipe files, while dialect knife plugins provide support for files like
roles and data bags.

While both types of dialects use the same implementation, the ways they are used
require different packaging and support code (cookbook vs gem).

### Dialect Classes

The heart of any dialect implementation is a dialect class. This inherits from
`Chef::Dialect` and declares which file extensions and MIME types this dialect
will handle. For each object type the dialect will support, it defines a
method taking a blank object and a filesystem path which will process any
needed data and insert it in to the provided object.

### Dialect Selection

`Chef::Dialect` provides two class methods to load a dialect from either a
file extension or MIME type. These both return an instance of the dialect
class.

### Dialect Plugins

A dialect plugin for knife is simply a gem that defines one or more dialect
classes and ensures they are loaded by knife's plugin framework. The easiest
way to accomplish this is to place the dialect class in
`lib/chef/knife/dialect_<name>.rb`.

An example dialect which creates a role from a text file:

```ruby
class Chef::Dialect::Example < Chef::Dialect
  register_dialect '.txt'

  def compile_role(role, filename)
    role.name(File.basename(filename, '.rb')
    role.description(IO.read(filename))
  end
end
```

### Dialect Cookbooks

Dialect cookbooks work similarly to the gem variety, except packaged as a Chef
cookbook. Dialect code should be placed under `libraries/` so it is loaded
before other cookbook files. This also means dialect cookbooks can be listed as
a dependency if you want to use one in your own cookbook.

```ruby
class Chef::Dialect::Example < Chef::Dialect
  register_dialect '.txt'

  def compile_recipe(recipe, filename)
    recipe.log(IO.read(filename))
  end
end
```

At this time there isn't a good way to install gems during the library loading
phase, so there is no good way to share code between a gem and cookbook form of
the same dialect. This will likely result in duplicated code in some places.

## Rationale

The dialects system exists to allow easier experimentation with file formats
outside of Chef core. In some cases these might be subtle DSL changes or
extensions, in others it could be whole new languages. My main drive is to
provide a simpler experience, especially for new Chef users that don't know
Ruby. Even for experienced users, simpler file formats can boost productivity
and reduce the maintenance burden.

This will also help unify file loading logic between things like chef_fs and
knife. This could allow moving forward with [RFC 31](https://github.com/opscode/chef-rfc/blob/master/rfc31-replace-solo-with-local-mode.md).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
