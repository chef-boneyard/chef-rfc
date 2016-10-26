---
RFC: 18
Title: Attribute Subkey Syntax
Author: Steven Danna <steve@getchef.com>
Status: Accepted
Type: Standards Track
Chef-Version: 12
---

# Attribute Subkey Syntax

This RFC defines the syntax for accessing deeply nested keys inside
the node attribute structure.

The preferred shape of APIs that refer to attributes is functional
notation where the arguments are expressed as strings.  APIs which
only implement this pattern are acceptable.

   - get("foo", "bar", "baz")
   - set("foo", "bar", "baz", value)

The method chaining syntax is also fully supported, although discouraged
for new APIs.  APIs which only implement this pattern are acceptable.

   - node["foo"]["bar"]["baz"]
   - node["foo"]["bar"]["baz"] = value

Both the functional syntax and the method chaining syntax may continue
to use symbols in addition to strings (Mash objects), although strings
are preferred and symbols are discouraged.

For static use array syntax is considered equvalent to the functional
'splat' argument syntax:

  - config_variable = [ [ "foo", "bar" ], [ "baz", "qux" ] ]

In order to support command line usage, it is acceptable to use dots
as a field separator:

   - knife node show mynode -a foo.bar

Additionally, in order to avoid escaping for keys that might contain
"." it should be possible to pass a user-defined field separator key:

   - knife node show mynode -S: -a foo:bar

The use of command line syntax in ruby code which can use one of the
prior two formats is discouraged.  The use of the field separator is
only used when the ruby API versions of the call would be awkward.

For the static array form APIs MAY support both dot notation and array
notation, even though it may not be possible to override the path
separator.  APIs are NOT required to implement dot notation:

   - config_variable = [ "foo.bar", "baz.qux" ]

The functional splat notation MUST NOT implement dot notation.

## Specification

The following are the contexts in which users access nested
attributes. Cases that require a change from the current behavior have
been called out.

### Command-line access (knife)

When specifying attributes on the command line, "." should be the
default key separator.

```
knife node show foo -a key1.key2
knife node show foo -S: key1:key2
```

### Command-line access (other)

*Requires Change* All other Chef-maintained tools should also use
dot-separated strings and arrays to specify not attributes, including Ohai:

```
ohai cpu.real
ohai -S: cpu:real
```

Documentation for 3rd-party tool writers should encourage the use of
these formats as well.

### Search Syntax

*Requires Change* Chef search should support using the functional `*args`
notation:

```
search(:node, "key1", "key2", "4")
```

Knife search should suport the -S notation on the command line:

```
knife search node -S; "key1;key2:4"
```

For backward compatibility, `"_"` should should be supported as
well through Chef 13.

```
knife search node "key1_key2:4"
```

### Attribute Whitelisting

*Requires Change*

```
normal_attribute_whitelist = [ ["network", "interfaces"], "fqdn" ]
normal_attribute_whitelist = [ ["network.interfaces"], "fqdn" ]
```

Currently, "/" is used as the attribute separator.

### Ohai provides/requires statements

*Requires Change*

```
provides("network", "interfaces")
```

Currently, Ohai 7 "provides" and "requires" statements use "/" as the attribute separator.

### Other Considerations

#### [] accessor method on the node object

When using the array accessor method([]) on node, Chef should not
interpret the "." as the record separator.  Namely,
`node["key1.key2"]` should not be interpreted as
`node["key1"]["key2"]`.

#### Conflicts

Since some users may want to use "." in their key names the use of the
"." syntax in ruby code is discouraged to avoid conflicts.  For example:

```
node["128.95.73.67"] = "crashed"
node["128"]["95"]["73"]["65"] = "i would never want to set this"
```

Ruby APIs shall not be required to implement the dot syntax to avoid that ambiguity.

# Motivation

Inconsistent syntax for accessing subkeys confuses new users.  This is
particularly difficult when interaction with search:

```
knife search node 'kernel_machine:x86_64' -a kernel.machine
```

Standardizing the syntax for accessing subkeys will help new users
avoid this frustration while also making it easier on tool developers
who no longer need to make this UI decision themselves.

## Copyright

This work is in the public domain. In jurisdictions that do not allow
for this, this work is available under CC0. To the extent possible
under law, the person who associated CC0 with this work has waived all
copyright and related or neighboring rights to this work.
