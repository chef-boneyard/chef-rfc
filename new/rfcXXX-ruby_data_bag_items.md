---
RFC: unassigned
Author: Eric Krupnik <ekrupnik@copyright.com>
Status: Draft
Type: Standards Track
---
# Ruby data bag items

Currently, Chef only supports JSON data bag items, and not Ruby. Chef **does**
support having other configuration-based files (such as `environments` and `roles`)
be written in either JSON or Ruby. JSON does not allow comments, so it becomes
impossible to outline WHY a specific configuration is set to it's specific value.

This seems like it was looked into a little bit with [this Gist](https://gist.github.com/jtimberman/2359433) from **[@jtimberman](https://github.com/jtimberman)**.

# Motivation

This proposal has a specific use case:

    As a Chef user and developer,
    I want to have a both Ruby and JSON data bag items supported,
    so that data bag items allow user comments, and are consistent with other Chef files.

Adding support for both JSON and Ruby data bag items will provide Chef users 
and developers the ability to comment in data bag items, thus outlining why a 
specific configuration is set in that data bag item. It will also bring data bags
much more in-line with other Chef based configuration files, such as `roles` and
`environment` files.

Until now, my team and I have come up with several workarounds, however none of them feel clean:

#####1. Duplicate keys in data bag item
In the example you will see below, if including multiple `age` keys, with different values, the
top key would be treated as a comment, and the second key would be the value:

```json
{
  "id": "workaround_example_1",
  "names": {
    "first": "Eric",
    "last": "Krupnik"
  },
  "age": "find out why age is 'unknown', people should know their age",
  "age": "unknown",
  "city": "Boston",
  "state": "MA"
}
```
but this is both confusing to someone reading the data bag item, and does not seem clean.

#####2. Special character which recipes know to trim
In the example you will see below, if including a special character (such as `|`), the recipe(s)
could be smart enough to know everything following a `|` character is a comment, and strip the
comment off before using the value.
```json
{
  "id": "workaround_example_2",
  "names": {
    "first": "Eric",
    "last": "Krupnik"
  },
  "age": "unknown|find out why age is 'unknown', people should know their age",
  "city": "Boston",
  "state": "MA"
}
```
But this presents it's own problems, such as data which might contain a `|` character. Like the
multiple key workaround outlined above, this also feels like it would be confusing to readers.

#####3. Gist from **[@jtimberman](https://github.com/jtimberman)**
[This Gist](https://gist.github.com/jtimberman/2359433) which outlines how to use Ruby data bag items
works but only with a Chef Server involved (`chef-client`). When running cookbooks to develop and
test our Chef code, we are not using `chef-client`, but are using `chef-solo`. Therefore, this
workaround did not prove to be a working solution for our team (or anyone not using the Chef Server).

# Specification

### JSON data bag items
To support JSON data bag items, there should be no required changes, as JSON is
currently the only supported format.

A sample JSON data bag item would remain unchanged, so the below example would be valid:

```json
{
  "id": "json_example",
  "names": {
    "first": "Eric",
    "last": "Krupnik"
  },
  "age": "unknown",
  "city": "Boston",
  "state": "MA"
}
```

### Ruby data bag items
To support Ruby data bag items, the data bags should be run through the same code
as `environment` files and `roles`, since those already do support both the JSON
and Ruby formats.

A sample Ruby data bag item representation of the JSON data bag item outlined above:

```ruby
{
  "id" => "ruby_example",
  "names" => {
    "first" => "Eric",
    "last" => "Krupnik"
  },
  "age" => "unknown",
  "city" => "Boston",
  "state" => "MA"
}
```

This should be supported in all Chef "types" (`chef-client`, `chef-solo`, and `chef-zero`).
Additionally, all tools which use Chef, such as `test-kitchen`, should work with either
format.

### Read from data bag item
The call to get a value from a data bag item would remain unchanged.

# Rationale
TBD

# Copyright
This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.