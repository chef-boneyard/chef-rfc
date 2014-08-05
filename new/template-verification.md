# File Content Verification

File-based resources should be able to verify a file's content via
user-supplied instructions before deploying the new content.

# Specification

The `verify` attribute of the `file`, `template`, `cookbook_file`, and
`remote_file` resources will take a user-provided block. At converge
time, the block will be passed the path to a temporary file holding
the proposed content for the file. If the block returns `true` the
provider will continue to update the file on disk as appropriate. If
the block returns false, the provider will raise an error. If no
verification block is supplied by the user, the provider assumes the
content is valid.

Multiple verify blocks may be provided by the user.  All given verify
block must pass before the content is deployed.

As an example:

```ruby
# This should succeed
template "/tmp/foo" do
  verify do |path|
    true
  end
end

# This should raise an error
template "/tmp/bar" do
  verify do |path|
    false
  end
end

# This should pass
template "/tmp/baz" do
  verify { true }
  verify { 1 == 1 }
end

# This should raise an error
template "/tmp/bat" do
   verify { true }
   verify { 1 == 0 }
end
```

Users could use this feature to shell out to tools which check the
configuration:

```ruby
template "/etc/nginx.conf" do
  verify do |path|
    `nginx -t -c #{path}`
    $? == 0
  end
end
```

Chef may ship built-in verifiers for common checks such as
content-type verification. Built-in verifiers can be used by passing
well-known symbols to the verify attribute:

```ruby
template "/etc/config.json" do
  verify :json
end
```

# Motivation

Typos and bugs in a template can lead Chef to render invalid
configuration files on a node. In some cases, this will cause the
related service to fail a notified restart, bringing down the user's
application. One hopes to catch such errors in testing, but that is
not always possible.

Many applications provide a means to verify a configuration file, but
it is currently difficult to use these tools to verify a template
without an elaborate series of resources chained together with
notifications.

# Related BUGS

https://tickets.opscode.com/browse/CHEF-4416
https://tickets.opscode.com/browse/CHEF-3634

# Compatibility

This feature is backwards compatible with existing recipes.
