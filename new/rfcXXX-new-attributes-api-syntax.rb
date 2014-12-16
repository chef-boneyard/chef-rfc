## About this file:
# This is a supplementary document for the "New Attributes API" RFC.
# It is included in the pull request to facilitate conversation. When we reach
# a consensus about what shape the API should take, this document will be
# removed and the "winning" API option will be described in the "Specification"
# section of that RFC document.
#
## COPYRIGHT:
# This work is in the public domain. In jurisdictions that do not allow for this,
# this work is available under CC0. To the extent possible under law, the person
# who associated CC0 with this work has waived all copyright and related or
# neighboring rights to this work.

## API goals:
# * API should facilitate achieving the goals stated in the RFC's motivation section.
# * Balance brevity and clarity.
# * read and write should be unambiguous
# * Mass Assignment of attributes within a "namespace" should be easy
# * Single assignment of a nested value should be easy
#
## Things to consider:
# * Should we add explicit support for "dynamic" attributes?
# * Should there be a shortcut for setting/accessing attributes in a namespace
#   based on the cookbook name?

# Single nested attr assignment

## Array path option
default_attr(["mysql", "version"], "1.2.3")

## Multi-arg element assignment operator option:

default_attr["mysql", "version"] = "1.2.3"

## Method chaining:

default_attr("mysql", "version").to("1.2.3")

# Mass Default assignment

## Block w/ block variable, method chaining
defaults_for("mysql") do |mysql|
  mysql.set("version").to("1.2.3")
end

## Block with instance eval, method chaining

defaults_for("mysql") do
  set("version").to("1.2.3")
end

## Method missing chef-sugar API:

namespace 'apache2' do
  namespace 'config' do
    root '/var/www'
  end
end

# Nested Attr Reads

## User-defined attributes via node object
node.attr("mysql", "version")

## Same as above, but DSL delegates `attr` to `node.attr`
attr("mysql", "version")

## Ohai data:

node.sys("kernel", "machine")

## Same as above but with delegation:

sys("kernel", "machine")


