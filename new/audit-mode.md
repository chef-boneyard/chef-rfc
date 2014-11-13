---
RFC: unassigned
Author: Claire McQuin <claire@getchef.com>
Status: Draft
Type: Standards Track
---

# Audit Mode for Chef Client

Add an auditing feature to core Chef which will allow users to develop a test
drivin infrastructure, as well as evaluate and monitor its state, without the
need for additional software tools.

## Motivation

    As a maintainer of a Chef-managed infrastructure,
    I want the ability to write custom tests inside my cookbook recipes
    so that I can have a test-driven infrastructure.

## Specification

### Recipes
We introduce the following new syntax to recipes:

* `controls(description_str, &block)`: Used to denote a group of audits, or controls,
to be evaluated on the node.
* `control(description, &block)`: Used to denote a subset of audits.
Only available within the context of `controls`. `control` groups can be nested.

Audits are written using RSpec 3, with `:should` syntax explicitly disabled.
Additionally, Serverspec types and matchers are made available.

#### Example

```ruby
controls "My Infrastructure" do
  it "has a root user" do
    expect(user("root")).to exist
  end

  control "MySQL" do
    control package("mysql") do
      it "is installed" do
        expect(subject).to be_installed
      end
    end

    control service("mysql") do
      it "is enabled" do
        expect(subject).to be_enabled
      end
      it "is running" do
        expect(subject).to be_running
      end
    end
  end
end
```

### Logging
As controls are evaluated during the audit phase, results will be streamed to
`Chef::Config[:log_location]` in an easy to read format using RSpec's
[documentation formatter](https://www.relishapp.com/rspec/rspec-core/v/2-9/docs/command-line/format-option#documentation-format).

### Chef client runner
An audit phase will be performed after client converges. By default, audit mode
will be enabled. Only audits included in recipes in the expanded run list will
be evaluated on the node.

Converging Chef and evaluating audits can occur independently of each other
using the `--[no-]audit-mode` CLI option. If neither form of the flag is passed,
both phases will run. If passed `--no-audit-mode`, client will skip audits after
it converges. If passed `--audit-mode`, client will skip converge before running
audits.

Errors in the converge phase do not affect running the audit phase, and vice versa.
These phases are run independently and errors are collected and provided to the
error handlers once each phase completes.


### Event dispatch base

The following events will be added to `Chef::EventDispatch::Base`

* `converge_failed(exception)`: called if the converge phase fails
* `audit_phase_start(run_status)`: called before audit phase starts
* `audit_phase_complete`: called when the audit phase successfully finishes
* `audit_phase_failed(exception)`: called if there is an uncaught exception
during the audit phase.
* `control_group_started(name)`: signifies the start of a `controls` group with
a defined `name`
* `control_example_success(control_group_name, example_data)`: an example in a
`controls` group completed successfully
* `control_example_failure(control_group_name, example_data, error)`: an example
in a `controls` group failed with `error`

## Rationale

#### Why write `controls` in recipes?
Our goal has been to simplify the directory structure of cookbooks. Writing
audits in recipes means users don't need to add an additional directory to their
cookbooks, and more tightly couples testing and development which helps users
develop good test driven infrastructure practices.

#### Why support an audit-only phase?
The use case for auditing without converging is to support an existing
Chef customer absorbing a non-Chef managed infrastructure. In this instance, they
can only run audits until cookbooks have been prepared for the new infrastructure.
Similarly, an audit-only phase can help new users convert their unmanaged
infrastructure to a Chef-managed infrastructure.

#### Why run audits after a failed converge?
So that you can validate your infrastructure is still in a state consistent with
your expectations. Ideally, when converge fails your audits should still pass.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
