---
RFC: unassigned
Title: Resource Validation Messaging
Author: Tim Smith <tsmith@chef.io>
Status: Draft
Type: Standards Track
---

# Resource Validation Messaging

Custom resources provide multiple property validators allowing authors to control property input beyond just simple data types. Authors can expect strings to match predefined strings, match a regex, or return true from a callback method. This gives the author great control over the input data, but doesn't provide the consumer with much information when the validator fails. This RFC provides the author with the ability control the error text when the validator fails.

## Motivation

    As an author of custom resources, 
    I want to control property inputs while providing useful error messaging on failure,
    so that users can easily understand why input data is not acceptable

    As a consumer of custom resources,
    I want detailed errors when I pass incorrect data to a resource, 
    so that I quickly resolve failed chef-client runs.

## Specification

This RFC will implement a new `validation_message` option for properties, which accepts a string. This message will be shown on failure in place of a generic failure message.

### Example

in resources/example.rb

```ruby
property :version,
          kind_of: String,
          default: '8.0.35'
          regex: [/^(?:(\d+)\.)?(?:(\d+)\.)?(\*|\d+)$/]
          validation_message: 'Version must be a X.Y.Z format String type'
```

## Downstream Impact

No anticipated downstream impact

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this, this work is available under CC0\. To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
