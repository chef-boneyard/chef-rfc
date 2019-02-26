---
RFC: unassigned
Title: Policyfile Remote Includes and policy_revision_id Validation
Author: Matt Ray <matt@chef.io>
Status: Draft
Type: Standards Track
<Tracking:>
<  - https://github.com/chef/chef/issues/X>
---

# Policyfile Remote Includes and policy_revision_id Validation

This RFC specifies how an `include_policy` will use a `remote` source and how the `policy_revision_id` can be used to validate lock files for `remote` and `path` sources. [RFC097 "Policyfile Includes"](https://github.com/chef/chef-rfc/blob/master/rfc097-policyfile-includes.md) specifies that policyfiles may use `include_policy` to include other policies through `path`, `git`, and `server` sources. The `path` mechanism is specifically for local filesystems, but users may want to retrieve a policy from a remote filesystem via HTTP or HTTPS (ie. Artifactory).

`policy_revision_id` is available as an option for the `git` and `server` sources, adding it to the `path` and `remote` sources could be used to ensure the exact version is used.

## Motivation

    As a maintainer of policies built through inclusion of different layers,
    I want to include policies that I may not have source control access to
    so that I can test and build policies without manually downloading remote files.

In an organization with different teams responsible for layers of the infrastructure, using `include_policy` is a consistent approach to separating concerns within the Chef-managed stack. The existing `path`, `git`, and `server` sources cover most use cases, but including a policy from a remote server is not currently available. We want to add support for `policy_revision_id` to `path` and `remote` sources to ensure exact versions are used in non-source controlled environments.

## Specification

The proposed solution is to add an additional `remote` source for `include_policy`, similar to those already documented in [RFC097](https://github.com/chef/chef-rfc/blob/master/rfc097-policyfile-includes.md). The mechanics for inclusion and merging of data will be exactly the same behavior as if the .lock was retrieved using the `path:` source.

To use a locked policy from a `remote` location via a URI:
```
include_policy "policy_name", remote: "http://internal.example.com/foo/base.lock.json"
```

If you want to ensure a `revision_id` is a specified value, specify the `policy_revision_id`.
```
include_policy "policy_name", policy_revision_id: "38abbedb17", remote: "http://internal.example.com/foo/base.lock.json"
```

The `path` source will be updated the same way, both source types will fail during the `chef install` if the `policy_revision_id` does not match.
```
include_policy "policy_name", policy_revision_id: "revision1", path: "./base.lock.json"
```

The lock file generated with the `remote` `policy_include` will have a section similar to this in the lock file, with the corresponding `source_options`.

```json
  "included_policy_locks": [
    {
      "name": "base",
      "revision_id": "38abbedb17005dd94924693a1b49aca2fe336ecc955b5492f10e9ddf0219b07b",
      "source_options": {
        "remote": "http://internal.example.com/foo/base.lock.json"
      }
    }
  ],
```

## Problems

If the remote included policy references cookbooks from the `path` source option they will not be found. All other behavior should be unchanged.

## Code

Within the [Chef DK](https://github.com/chef/chef-dk) repository, the [policyfile_location_specification.rb](https://github.com/chef/chef-dk/blob/master/lib/chef-dk/policyfile/policyfile_location_specification.rb) will need to be updated and a new RemoteLockFetcher will need to be implemented. The existing [local_lock_fetcher.rb](https://github.com/chef/chef-dk/blob/master/lib/chef-dk/policyfile/local_lock_fetcher.rb) will be updated to support the new `policy_revision_id` validation.

## Downstream Impact

The impact should not affect any tools which use existing policyfile behavior, as the use of existing `include_policy` is unchanged and all API calls and surrounding tools will be unaffected. The Chef Docs [About Policyfile](https://docs.chef.io/policyfile.html) will need to be updated with this change.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
