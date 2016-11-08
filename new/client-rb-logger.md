---
RFC: unassigned
Title: Logging for chient.rb
Author: Zeal Jagannatha <zeal@fb.com>
Status: Draft
Type: Standards Track
Tracking:
  - https://github.com/chef/chef/issues/5526
---

# Logging for client.rb

Output from client.rb doesn't get logged to the log file specified with --logfile.
If you want to save the output from client.rb along-side the chef logs, you need to redirect stdout, rather than using chef's built-in logging.
I'd like to make Chef::Log accessible from the client.rb so messages logged during client.rb execution can be stored using chef's built-in logging.

## Motivation

    As a chef user,
    I want to log output from client.rb into the same log file as the chef output,
    so that client.rb output can be tracked in the same method as the chef run.

## Specification

1. Create a [Logger](https://github.com/chef/mixlib-log) instance before client.rb is initialized.
1. Log messages on this logger will be written to stdout, and saved.
1. Once the real chef logger is initialized (based on the configuration in client.rb), saved log messages
   are written to the real log.

## Downstream Impact

No change for users, unless they start utilizing new functionality to log client.rb messages using Chef::Log.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
