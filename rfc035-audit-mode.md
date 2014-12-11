---
RFC: 35
Author: Claire McQuin <claire@getchef.com>
Status: Accepted
Type: Standards Track
---

# Audit-Mode for Chef Client

Audit mode is an new phase in Chef which allows you to evaluate custom rules,
defined in your recipes, on every node during each chef-client run. Use audits
to ensure nodes fall into existing "known states" categories even before Chef
converges, and to validate your infrastructure after Chef converges.

## Motivation
    As an inheritor of a non-Chef-managed infrastructure
    I want to run chef-client and collect data on each node without converging
    so that I can determine the existing state of the inherited infrastructure.

    As a maintainer of a Chef-managed infrastructure
    I want to write custom rules defining expected state
    so that I can validate my infrastructure.

## Specification

### Audit mode phase
Audits are evaluated in their own phase. During a full `chef-client` run,
auditing occurs independently after client converges.

#### Configuration
By default, client will converge the node
and executed audits. Chef can be configured to skip audit mode via the command
line flag `--no-audit-mode` or the configuration file option `audit_mode :disabled`.

Alternatively, converge can be skipped via the command line flag `--audit-mode`
or the configuration file option `audit_mode :audit_only`.

#### Logging
As controls are evaluated during the audit phase, results will be streamed to
`Chef::Config[:log_location]`` in an easy to read format using
RSpec's [documentation formatter](https://www.relishapp.com/rspec/rspec-core/v/2-9/docs/command-line/format-option#documentation-format).

#### Event dispatch
The `Chef::EventDispatch::Base` will be updated to support the following events

Event Name | Context
-----------|---------
`converge_failed(error)` | client did not converge successfully with `error`
`audit_phase_start(run_status)` | audit phase started
`audit_phase_complete` | audit phase finished
`audit_phase_failed(exception)` | an uncaught `exception` occurred during the audit phase
`control_group_started(name)` | signifies the start of a `controls` group with a defined `name`
`control_example_success(control_group_name, example_data)` | an example in a `control_group_name` group completed successfully
`control_example_failure(control_group_name, example_data, error)` | an example in a `control_group_name` group failed with `error`

The `example_data` hash contains the informational fields
* the `name` of the evaluated audit rule
* the full `desc` of the evaluated audit rule (includes `name`)
* the `resource_type` evaluated, if any
* the name of the evaluated resource, `resource_name`
* any containing scope is saved in `context`
* the `line_number` of the failed audit


### Syntax
Audits are written inside recipe files. Audits can be written in a separate
recipe or can be added into recipes defining resources. Audits are collected
within a named `controls` block, which does not get evaluated until the audit
phase begins.

Audit rules are defined within a `controls` group using RSpec's `it` syntax.
Rules can be grouped together using the `control` method, or any other RSpec
example group method (e.g., `describe` or `context`). RSpec's built-in matchers
are available, as well as Serverspec types and matchers. The use of `:should`
is explicitly disabled, as this is deprecated in RSpec 3.

#### Example: Nobody is listening
Audits can be written to help ensure compliance requirements, such as asserting
nothing is listening on port 111. Depending on your distribution and its version,
your portmap service may be named "portmap" or "rpcbind", and could be renamed
after a version bump. Your recipe may use the correct service provider but the
init script may have been removed, preventing any service resource `:stop` action
from completing successfully.

The `ports::audit` recipe ensures nothing is listening on port 111:
```ruby
# cookbook: ports
# recipe: audit

controls "port compliance" do
  control port(111) do
    it "has nothing listening"
      expect(port(111)).to_not be_listening
  end
end
```

When `ports::audit` is added to the run-list and `chef-client` is run with
audit mode enabled, you would expect the log output to contain
```sh
port compliance
  Port "111"
    has nothing listening

Finished in 0.08615 seconds (files took 0.67889 seconds to load)
1 example, 0 failures
```

### Failures
When an audit fails, the failed example is marked in the log output for debugging.
At the end of the client run, Chef will exit with exit status 1.

#### Example: Somebody is listening
Suppose port 111 was not shut down correctly and someone is listening on it. When
the `ports::audit` recipe is run, the log output would contain something similar
to
```sh
port compliance
  Port "111"
    has nothing listening (FAILED - 1)

Failures:

  1) port compliance Port "111" has nothing listening
     Failure/Error: expect(port(111)).to_not be_listening
       expected Port "111" not to be listening
     # cookbooks/ports/recipes/audit.rb:7:in `block (3 levels) in from_file'

Finished in 0.12515 seconds (files took 0.70174 seconds to load)
1 example, 1 failure

Failed examples:

rspec cookbooks/ports/recipes/audit.rb:6 # port compliance Port "111" has nothing listening
```

### Exceptions
These exceptions can be raised during a client run due to errors in the audits
included in recipes in the run list:

* `Chef::Exceptions::AuditNameMissing`: Raised when `controls` is declared without
a name.
* `Chef::Exceptions::NoAuditsProvided`: Raise when `controls` is declared but
defines no audits.
* `Chef::Exceptions::AuditControlGroupDuplicate`: Raised when two `controls` are
declared with the same name. Multiple `controls` groups can
be defined in the same recipe, as this may happen when using `include_recipe`.
However, no two `controls` groups in the run list can have the same name.

### Error handling
Errors occurring in the converge phase do not affect the execution of the audit
phase. Similarly, errors occurring in the audit phase do not affect later phases.
Errors are collected to be provided to the appropriate error handlers once
each phase completes.

## Rationale
### Why distribute audits in recipes?
Cookbooks support versioning and are an effective medium for distributing code.
Including audits in recipes help to maintain a flat directory structure, and don't
require the addition of a new server segment.

### Why implement this in core chef?
Even though it's possible to build this logic as external libraries
(see [minitest-chef-handler](https://github.com/calavera/minitest-chef-handler))
building it as a first class citizen with config options, CLI options and hooks
for event handlers and maintaining it overtime will be a challenge.

Also to achieve usability, any TDI (test driven infrastructure) related logic
should be available out of the box inside the Client omnibus packages. As long
as functionality is available out of the box, building it into core as an alpha
feature vs implementing it as an external gem is only an implementation choice.
This doesn't change any compatibility commitments.

### Why use RSpec and Serverspec in audits?
In the future we can definitely come up with a better DSL than RSpec. But we
would like to reuse the awesome tool Serverspec and its practices as well as we
would like to provide a generic interface for the power users.

### Why support an audit-only phase?
The use case for auditing without converging is to support an existing Chef
customer absorbing a non-Chef managed infrastructure. In this instance, they can
only run audits until cookbooks have been prepared for the new infrastructure.
Similarly, an audit-only phase can help new users convert their unmanaged
infrastructure to a Chef-managed infrastructure.

### Why run audits after a failed converge?
So that you can validate your infrastructure is still in a state consistent
with your expectations. Ideally, when converge fails your audits should still
pass. It's reassuring to have that sanity check.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
