---
RFC: 40
Title: On-Demand Cookbook Libraries
Author: John Keiser <jkeiser@chef.io>
Status: Accepted
Type: Standards Track
---

# On-Demand Cookbook Libraries

## Motivation

    As a library cookbook writer,
    I want to have nested directories,
    So that I can organize my code and make it more readable.

    As a library cookbook writer,
    I want to control the load order of my library,
    So that I can have code in one file that refers to code in another file without constraining the filenames.

    As a library cookbook writer,
    I want to be able to `require` files in my library cookbook,
    So that I don't have to deal with the pitfalls of `require_relative` (particularly that it loads things multiple times).

    As a library cookbook user,
    I want to be able to `require` files in the library cookbooks I use,
    So that I can pick and choose what functionality I want to load.

## Specification

When a user creates a cookbook, they can add the following directive to the metadata:

```ruby
# metadata.rb
name "mylibrary"
version "0.0.1"
eager_load_libraries false
```

If `eager_load_libraries` is false, Chef Client would instead append it to the ruby load path.  This would occur in the phase where the `libraries` files of a cookbook otherwise be automatically required in alphabetical order.  All recipes, libraries, and other Ruby code running in the Chef Client can then use `require 'filename'`` and it will load `cookbooks/mycookbook/libraries/filename` if present.

If `eager_load_libraries` contains a list of files or globs, the library path is appended to the Ruby load path, and the listed files are loaded during the library load phase.

If `eager_load_libraries` is `true` or not specified, Chef Client loads the top level of files in alphabetical order, as before.

## Rationale

When a user wants to create a more complex library cookbook with multiple Ruby files, they have an issue right now: the library is automatically loaded in alphabetical order, making it hard to organize files.  You can circumvent it somewhat using `require_relative` to load the other files out of order, but that may load a file twice, leading to other problems.  This RFC circumvents that by requiring files to be loaded explicitly by the user or library writer using `require`, but allowing for an entry point (`default.rb`).

There is also the fact that you don't necessarily *need* all the functionality in a library cookbook, and this RFC lets you pick and choose what to load.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
