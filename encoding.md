## Related Encoding Tickets

https://tickets.opscode.com/browse/CHEF-5082
https://tickets.opscode.com/browse/OHAI-564
https://tickets.opscode.com/browse/CHEF-3304

Among many, many others.

## Background: LC_ALL=C Breaks Fucking Everything

Generally with ruby >= 1.9.3 the cause of `"\xC8" on US-ASCII
(Encoding::InvalidByteSequenceError)` errors is either:

* The default_encoding in ruby is US-ASCII because the locale is not UTF-8
  (`LC_ALL=C`)
* A 'block read' API like IO#readybytes() was called which could slice a
  unicode multibyte character in half, so ruby forces the encoding on the
  string to single-bit (`ASCII_8BIT`).

The open tickets on Encoding errors right now are all the former as far I know
and we do not have open bugs on the latter.  The former is coming primarily
from two sources:

* Users have dotfiles which sets `LC_ALL=C` (most likely to 'fix' the output
  sorting of `ls -la` which is actually a horribly incorrect fix in the UTF-8
  world)
* The mixlib-shellout library and Chef internally sets a default `LC_ALL=C`

## Background: English is an Internal Chef API

It is a fact that we MUST parse localized strings out of commands and compare
them against English language strings as part of interacting with the system in
Provider code.  This means that debug output will have output from shell
commands in English.  Trying to convert this to localization independent code
will not be tractable or solvable.  We cannot get every distro to provide
utilities that have localization-independent ways of getting at all the data
and state that we desire -- particular since it would also mean fixing old
distros like CentOS5 that we have to support.

## Background: Its Not Just Shellout

CHEF-5082 is caused because someone had a metadata.rb which does an IO.read()
on 'README.md' which contains UTF-8 code and the user is running knife under
`LC_ALL=C`.  So while I'm going to propose a lot of changes that focus on
mixlib-shellout, we have bugs which have nothing to do with mixlib-shellout,
and in some cases are ruby methods that aren't in the Chef codebase and are in
cookbook files outside of our control to 'fix'.  Trying to bug-bash and
whack-a-mole the problem is nearly infinitely unsolvable.

## Background: Users Are Not Unicode Experts

I ran with `LC_ALL=C` for many years until I started to work on Chef because
setting `LC_ALL=en_US.UTF-8` changes the output of `ls -la` to have dotfiles
mixed with not-dotfiles which is what absolutely nobody wants.  The correct way
to fix that problem is:

```ruby 
unset LC_ALL
export LANG=en_US.UTF-8
export LC_COLLATE=C
```

Most of the Encoding bugs that we see now are typically due to inheriting
`LC_ALL=C` from the users environment because they have misconfigured their
dotfiles on their system.  They file Chef bugs pointing at our code being
broken.  Our code works fine, but their environment is misconfigured.  I've
attempted to explain this even to internal Chef support and my solution has been
labeled a "workaround" when its not -- the user has configured their system
with a non-UTF-8 locale and then fed a UTF-8 file into Chef which has choked
and barfed on it because computers only do what you tell them to.

And this is mostly to point out how non-productive that discussion gets with
Users once they've hit bug reports.  Just documenting that Chef must be run
under a UTF-8 locale is not sufficient.  Closing bug reports telling users to
fix their broken shit is not a helpful approach either.  We need to either
mitigate these bugs or need to be more proactive in getting in front of the
users by detecting these problems and steering users towards solutions (Chef
raising an Encoding::InvalidByteSequenceError is simply not helpful and we've
lost the battle by the time that happens)

## Proposal #1: mixlib-shellout

There exists a hard-coded workaround in mixlib-shellout where failure to
specify an 'LC_ALL' value will set the value to 'C'.  This was done,
apparently, to work around encoding problems in ruby 1.8.7.  Since ruby 1.8.7
will not be supported at all in Chef 12 this value is no longer appropriate and
actively harmful since it is not a UTF-8 locale and this is a source of
Encoding errors.  The default in mixlib-shellout could be changed to
'en_US.UTF-8' but this presents a bit of an issue because of the hard-coding of
English.

At an API-level the fact that mixlib-shellout does this at all is problematic.
If you want to avoid setting the override you pass in `'LC_ALL'=>nil` which
then passes through the system `ENV['LC_ALL']` variable.  For all other env
hash keys setting `'KEY'=>nil` will instead unset the env variable.  This means
that in order to write code which unsets LC_ALL one would need to do:

```ruby
saved_lc_all = ENV['LC_ALL']
ENV['LC_ALL'] = nil
Mixlib::ShellOut.new("whatever", :env => {'LC_ALL' => nil}).run_command
ENV['LC_ALL'] = saved_lc_all
```

Proposed:  major version bump of mixlib-shellout that removes this feature and
the default behavior is that the `LC_ALL` value is passed through unchanged,
and that setting `'LC_ALL' => nil` will unset the value.

## Proposal #2: Chef shell_out LC_ALL=en_US.UTF-8 default

The existing `LC_ALL=C` behavior is just broken at this point, and ruby >=
1.9.3 does not need the Encoding workaround that ruby 1.8.7 needed.  We are
dropping support for ruby 1.8.7 so we need to get rid of the `LC_ALL=C` default
here.  As stated in the background we use English internally as a Chef API from
localized output from shell commands.  We need both a UTF-8 and English locale,
so that implies 'en_US.UTF-8'.

We have and will still need to support shell_out_with_systems_locale() since
its likely that there will cases where people expect resources like execute,
bash, etc which start subshells for users that the systems locale should be
preserved.

It should be noted that I suspect that shell_out_with_systems_locale() has been
getting used in cases where we needed UTF-8 support (since most systems come
with UTF-8 support) and it is being used completely incorrectly (e.g.
internally to the apt and dpkg providers -- if you set LC_ALL=C and run
apt_package against a package that produces UTF-8 output on the command line I
suspect that chef-client will throw the very Encoding exception that
shell_out_with_systems_locale is trying to prevent there).

## Proposal #3:  Warn *LOUDLY* and *IMMEDIATELY*  when running in non-UTF-8 locales

In Chef::Application we should have a test which determines if the default
external encoding for ruby is UTF-8-compatible or not and if not, it warns the
user with some help to steer them away from `LC_ALL=C` or whatever they have
done.  A banner message should be emitted similar to the one emitted for the
SSL noverify configuration.

## Proposal #4:  Config Option for Locale variables

You can already do this in config.rb since its just ruby and you can set your
ENV['LC_ALL'] but we could provide config options and document them.

## Proposal #5:  Enforce `LC_ALL=en_US` By Default

This might be contentious, but this would largely eliminate Encoding errors due
to misconfiguration entirely and would not require any user eduction about
Encoding.  This would go along with the config option for LC_ALL in config.rb
and would establish that the default is `en_US.UTF-8` by default.  We would
need to save the actual default systems locale somewhere and then later use
that in shell_out_with_systems_locale for those cases where we want to pass
through the real systems locale to a user shell.

This is actually the only way to prevent bugs like CHEF-5082.  There is nothing
else to patch in the Chef codebase.  So our choices of what to do about CHEF-5082
are:

- yell at cookbook authors endlessly to correctly decorate files with UTF-8
  magic comments
- yell at users endlessly to learn Encoding, UTF-8 and localization and setup
  their environment correctly
- scream loud warnings at users with non-UTF-8 locales whenever they run a chef
  command
- set a default UTF-8 locale and prevent the exceptions from occurring.

## My Recommendation

Carpet Bombing Encoding with All Of The Above.

