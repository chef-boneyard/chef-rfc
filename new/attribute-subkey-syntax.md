---
RFC: 000
Author: Steven Danna <steve@getchef.com>
Status: Accepted
Type: Standards Track
Chef-Version: 12
---

# Attribute Subkey Syntax

This RFC defines the syntax for accessing deeply nested keys inside
the node attribute structure.

When attributes are referred to as strings inside Ruby code or on the
command line, a dot(".") should be used as the key separator:

   - "key1.key2"
   - knife node show foo -a key1.key2

Additionally, in order to avoid escaping for keys that might contain
"." the following array syntax should also be supported:

   - ['key1', 'key2']
   - knife node show foo -a "['key1', 'key2']"

When the array syntax is used "." has no special meaning.

## Specification

The following are the contexts in which users access nested
attributes. Cases that require a change from the current behavior have
been called out.

### Command-line access (knife)

When specifying attributes on the command line, "." should be the
key separator.  Alternatively, an array can be provided:

```
knife node show foo -a key1.key2
knife node show foo -a "['key1', 'key2']"
```
### Command-line access (other)

*Requires Change* All other Chef-maintained tools should also use
dot-separated strings and arrays to specify not attributes, including Ohai:

```
ohai cpu.real
ohai "['cpu', 'real']"
```

Documentation for 3rd-party tool writers should encourage the use of
these formats as well.

### Search Syntax

*Requires Change* Chef search should support "." as the record separator:

```
search(:node, "key1.key2:4")
```

```
knife search node "key1.key2:4"
```

For backward compatibility, "_" should should be supported as
well through Chef 12.

```
knife search node "key1_key2:4"
```

### Partial Search Syntax

*Requires Change*

Search filters currently only supports the array syntax.  Dot-separated strings
```
partial_search(:node, 'role:web', keys => { 'name' => [ 'name' ],
                                            'kernel_version' => 'kernel.version' })

search(:node, 'role:web', :filter_result { 'kernel_version' => 'kernel.version'})
```

### Attribute Whitelisting

*Requires Change*

```
normal_attribute_whitelist = ['network.interfaces', 'fqdn']
normal_attribute_whitelist = [['network', 'interfaces'], 'fqdn']
```

Currently, "/" is used as the attribute separator.

### Ohai provides/requires statements

*Requires Change*

```
provides "network.interfaces"
```

Currently, Ohai 7 "provides" and "requires" statements use "/" as the attribute separator.

### Other Considerations

#### [] accessor method on the node object

When using the array accessor method([]) on node, Chef should not
interpret the "." as the record separator.  Namely,
`node['key1.key2']` should not be interpreted as
`node['key1']['key2']`.

#### Conflicts

Some users may want to use "." in their key names.  This poses a
problem when a conflict exists.  For example:

```
node['key1.key2'] = "foo"
node['key1']['key2'] = "bar"
```

When Chef tools encounter the attribute specification 'key1.key2' the
deeply nested key will be preferred. Thus, given the above example
'key1.key2' would refer to the attribute with the value "bar".

The array syntax should be used in cases when the user needs to
explicitly avoid the interpretation of ".".

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
