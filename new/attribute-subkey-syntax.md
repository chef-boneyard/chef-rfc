# Attribute Subkey Syntax

This RFC defines the syntax for accessing deeply nested keys inside
the node attribute structure.  It recommends that Chef and
Chef-related tooling support the following two key access methods when
dealing with Ruby code:

   - Hash access: `node['key1']['key2']`
   - Method calls: `node.key1.key2

When attributes are referred to as strings inside Ruby code or on the
command line, a dot(".") should be used a the key separator:

   - "key1.key2"
   - knife node show foo -a key1.key2

# Specification

The following are places examples of how node attributes should be
accessed in different Chef contexts.  Cases that require a change from
the current behavior have been called out:

## In-recipe access

The following two access methods should be supported inside recipes
and other code with access to the node object:

```
node['key1']['key2']
node.key1.key2
```

## Command-line access (knife)

When specifying attributes on the command line, "." should be the
key separator:

```
knife node show foo -a key1.key2
```

## Command-line access (other)

*Requires Change* All other Chef-maintained tools should also use "."
as the attribute key separator,
including Ohai:

```
ohai cpu.real
```

Documentation for 3rd-party tool writers should encourage them to use
"." as well.

## Search Syntax

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

**Question**: Should the Server API also change?

## Partial Search Syntax

*Requires Change*

```
partial_search(:node, 'role:web', keys => { 'name' => [ 'name' ],
                                            'kernel_version' => 'kernel.version' })

search(:node, 'role:web', :filter_result { 'kernel_version' => 'kernel.version'})
```

This is a change from the current API which requires passing an array:

```
search(:node, 'role:web', :filter_result { 'kernel_version' =>
['kernel', 'version']})
```

**Question**: Should the Chef Server API also change?

## Attribute Whitelisting

*Requires Change*

```
normal_attribute_whitelist = ["network.interfaces"]
```

Currently, "/" is used as the attribute separator.

## Ohai provides/requires statements

*Requires Change*

```
provides "network.interfaces"
```

Currently, Ohai 7 "provides" and "requires" statements use "/" as the attribute separator.

## Other Considerations

### Array Syntax

When using the array access syntax in a recipe, Chef should not
interpret the "." as the record separator.  Namely, `node['key1.key2']`
should not be interpreted as `node['key1']['key2']`.

### Conflicts

Some users may want to use "." in their key names.  This poses a
problem when a conflict exists.  For example:

```
node['key1.key2'] = "foo"
node['key1']['key2'] = "bar"
```

When Chef tools encounter the attribute specification 'key1.key2' the
deeply nested key will be preferred. Thus, given the above example
'key1.key2' would refer to the attribute with the value "bar".

To escape a ".", the user should prepend a the character "\". Thus, in
the above example, `'key1\.key2'` refers to the attribute
`node['key1.key2']`. `'key1\\.key2'` refers to the attribute
`node['key1\.key2']`.

When no conflict exists, Chef should return the value of the given
key. That is, if `node['key1.key2']` exists but
`node['key1']['key2']` does not, 'key1.key2' would refer to the
attribute `node['key1.key2']`.

# Motivation

Inconsistent syntax for accessing subkeys confuses new users.  This is
particularly difficult when interaction with search:

```
knife search node 'kernel_machine:x86_64' -a kernel.machine
```

Standardizing the syntax for accessing subkeys will help new users
avoid this frustration while also making it easier on tool developers
who no longer need to make this UI decision themselves.
