---
RFC: unassigned
Author: Drew Blessing <drew.blessing@mac.com>
Status: Draft
Type: <Standards Track, Informational, Process>
<Replaces: RFCxxx>
---

# Title

Add nested recipe support

## Motivation

As a cookbook developer,
I want to be able to organize recipes into a nested directory structure
so that recipes are more organized.

## Specification

Load files in the `recipes` directory recursively.

Example directory structure:

```
|------ my_cookbook
|        |------ recipes
|        |        |____ default.rb
|        |        |____ config.rb
|        |        |____ config
|        |        |         |______ client.rb
|        |        |         |______ server.rb
|        |        |____ install
|        |        |         |______ client.rb
|        |        |         |______ server.rb
```

Recipes will namespaced based on the directory structure and referenced using the namespace.

`my_cookbook/recipes/install/client.rb` will be referenced as `recipe[my_cookbook::install::client]`
in run lists and `my_cookbook::install::client` in recipes.

Additionally, a recipe and a directory may have the same name and won't conflict.

`my_cookbook/recipes/config.rb` and `my__cookbook/recipes/config/` are treated as both a
recipe *and* a namespace. Therefore, `recipe[my_cookbook::config]` and `recipe[my_cookbook::config::server.rb`
are valid references.

## Rationale

Organization can be a problem, especially in a complex cookbook with many recipes. With a nested directory
structure the cookbook developer can split recipes up into logical groups. This also serves
to make the cookbook easier to understand for other developers and for cookbook users as well. Consider
that this is similar to the way Ruby library classes can be organized.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

```

## Influences

[chef/chef-rfc#24](https://github.com/chef/chef-rfc/issues/24) - The issue has a lot of discussion
about this proposed feature. Seth Vargo originally raised the issue. Jean Mertz work on
[chef/chef#2129](https://github.com/chef/chef/pull/2129#issuecomment-57237381) is very similar. John
Dyer also provides some examples in chef/chef-rfc#24.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.