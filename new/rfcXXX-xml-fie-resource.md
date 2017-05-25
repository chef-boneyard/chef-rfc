---
RFC: unassigned
Author: Ranjib Dey (ranjib@linux.com)
Status: Draft
Type: Standards Track
---

# XML file resource

XML file resource gives the ability to control parts of an XML file
idempotently.

# Motivation

A vast majority of JVM based applications rely on XML as their configurations
(e.g Jenkins, GoCD, Tomcat, JBoss etc). Sometime these files are augmented
into multiple xml files, sometimes they are just a single giant config file.
As a chef user, when I automate these applications I want to inject only bits
and pieces of values that are known, in a larger configuration file.
For example the `pipelines` in  GoCD config XML, or the `antiResourceLocking`
attribute in Tomcat configuration xml can be managed by Chef without controlling
the content of the entire XML file ( which often contain temporal or version
specific data).

For reference, augeus XML lense provides similar features.

# Specification

XML File resource will allow user to specify a set of XSLT based mappings
(apart from regular file attributes like owner, group, moee etc) in key-value pairs
where the key will be valid XSLT selectors abd the values will be expected data
inside those targets.

```ruby
xml_file '/path/to/xml/file' do
  owner 'jenkins'
  group 'jenkins'
  mode 0644
  mappings(
    '//adminlist' => admin_users,
    '//accessToken' => access_token
  )
  action :edit
end

```

# Compatibility
This is a new feature which wont break any existing

# Copyright

This work is in the public domain. In jurisdictions that do not allow
for this, this work is available under CC0. To the extent possible
under law, the person who associated CC0 with this work has waived all
copyright and related or neighboring rights to this work.
