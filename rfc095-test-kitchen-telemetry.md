---
RFC: 95
Title: Use of telemetry in Test Kitchen
Author: Thom May <thom@may.lt>
Status: Accepted
Type: Standards Track
---

# Use of telemetry in Test Kitchen

This RFC is a description of Test Kitchen's implementation of RFC-94, as required in that RFC.

## What questions do we hope to answer?

 * What platforms do our users run kitchen on?
 * Which plugins are used by kitchen users?
 * Which bento boxes are used?
 * Which provisioners are used?
 * If a chef provisioner is used, which chef versions are installed?
 * Which commands are used?

## Implementation

The bulk of this RFC is the description of the events, below. We
envisage that a single client library will be built for all chef
projects, and Kitchen will consume that to send events. That library
would ensure events are sent in a non-blocking manner, and would deal
with retries, session handling and opt-out.

## Events

Let's examine a typical user interacting with kitchen in an existing cookbook,
and enumerate the events and information that's sent. We'll elide the fields
from the payload that are common to all chef telemetry systems. To ensure
that we don't leak private information, drivers will only report provisioning
targets when they are not specified explicitly by the user.

The user performs a full test run on a Debian instance:

`kitchen test default-debian-9`

using the `kitchen-hyperv` driver on Windows 10, and the `debian-9-amd64` bento box.
This results in the following events:

```json
{
    "product": "test-kitchen",
    "session_id": "504ec380-5a75-458c-9f56-afa3c47b8705",
    "payload": {
        "event": "command-line",
        "properties": {
            "action": "test",
            "platform": "windows-10-x64"
            "version": "1.16"
        }
    }
}
```

Running test first destroys the instance, and then creates, converges and verifies a new instance.
Lastly, the instance is destroyed again.

```json
{
    "product": "test-kitchen",
    "session_id": "504ec380-5a75-458c-9f56-afa3c47b8705",
    "payload": {
        "event": "destroy",
        "properties": {
            "platform": "windows-10-x64",
            "version": "1.16"
        }
    }
}
```

```json
{
    "product": "test-kitchen",
    "session_id": "504ec380-5a75-458c-9f56-afa3c47b8705",
    "payload": {
        "event": "create",
        "properties": {
            "target": "bento/debian-9.0-amd64",
            "driver": "kitchen-hyperv",
            "driver_version": "1.2.3",
            "transport": "ssh",
            "platform": "windows-10-x64",
            "version": "1.16"
        }
    }
}
```

when the instance is ready, the user has configured the `chef-zero` provisioner, and requested
chef client `13`, using the new style configuration. They're using Policyfiles:

```json
{
    "product": "test-kitchen",
    "session_id": "504ec380-5a75-458c-9f56-afa3c47b8705",
    "payload": {
        "event": "converge",
        "properties": {
            "product": "chef",
            "product_version": "13",
            "channel": "stable",
            "provisioner": "chef-zero",
            "resolver": "policyfile",
            "platform": "windows-10-x64",
            "version": "1.16"
        }
    }
}
```

We now proceed to verifying the instance:

```json
{
    "product": "test-kitchen",
    "session_id": "504ec380-5a75-458c-9f56-afa3c47b8705",
    "payload": {
        "event": "verify",
        "properties": {
            "verifier": "kitchen-inspec",
            "verifier_version": "1.2.3",
            "platform": "windows-10-x64",
            "version": "1.16"
        }
    }
}
```

Before deleting it again (see above).

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
