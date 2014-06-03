# RFC: Replacing yajl-ruby and json gems with ffi-yajl gem

## Issues

* The yajl-ruby gem is stuck on yajl 1.x, this is affecting customers because of yajl 1.x's lax JSON parsing (allows trailing junk and
  auto-closes arrays and hashes producing valid JSON parsing for truncated strings).
* The yajl-ruby gem has issues cross-compiling on non-GCC based systems due to hardcoded CFLAGs and other issues
* The yajl-ruby gem is tightly coupled to its own embedded yajl c-library and turning off the embedded c-library is not supported, which
  blocks embedding chef-client in some distros who have policies about including forks of libraries they provide in the base distro
* The JSON gem has been problematic in the past with SemVer violating patches, and its pinning is a frequent issue of contention
* The JSON gem does not have good error messages that usefully report back to users where the syntax errors are in their JSON

## ffi-yajl Background

Much of the work on writing a replacement JSON gem around yajl 2.x has already been done.  This was the result of off-time work based on
the premise of "lets try to write a ffi wrapper around yajl 2.x, how hard could it be?".  So the work there is done.

## ffi-yajl Features

* Designed to be API compatible with Yajl.  Some features are not implemented (stream parsing), but enough to support core chef and ohai.  It
  can be fleshed out into being fully compatible.
* Has both FFI bindings and a native C-extension for speed.  After writing the FFI implementation the speed suffered mostly due to overhead of
  "context switching" between ruby and C using FFI.  The C extension avoid this penalty and gives performance which is very close to yajl-ruby.
* Runs on MRI, Rubinius and JRuby
* Supports ruby 1.8.7/1.9.2/1.9.3/2.0.x/2.1.x
* SemVer compliance

## ffi-yajl Chef-Specific Features

* The ffi-yajl encoder has been hardened against Encoding issues and has an additional feature flag which will allow throwing arbitrary binary
  data in strings (encoded as any of US-ASCII, ASCII-8BIT or UTF-8) and ffi-yajl will emit valid JSON with lots of '?'s for characters which do
  not encode into UTF-8.  This can, for example, be used to completely prevent Encoding exceptions in POST'ing resource reports at the end of
  chef-client runs -- moving the problem from one where the chef-client fails its run to where the user sees garbage in resource reporting.
* Since ffi-yajl uses yajl 2.x we can turn on the feature flag to allow comments in JSON data like roles, data bags, etc.

## Why not port yajl 2.x into yajl-ruby?

When I first looked at doing that with yajl-ruby the fact that the author of that gem had mentioned "i should port in 2.x" over 2 years ago did
not inspire confidence in that direction.  The yajl-ruby gem also is a patched branch of yajl 1.x where the yajl sources have been incorporated 
into the gem and then tightly coupled and forked and patched independently of the upstream.  Porting 2.x into the yajl gem will probably require
doing the necessary archaeology to determine if the fixes in the gem have already been put into the upstream or not.

The ffi-yajl gems build infrastructure is constructed differently.  It takes the upstream Yajl sources as a git submodule (ugly, but it establishes
a hard boundary), and then copies those sources into the ruby build infrastructre and applies a few necessary patches.  It is structured more like
FreeBSD ports or SRPMs with separated upstream sources and patches.  It should be much easier to track the upstream yajl library and to allow
distros to turn off the embedded library and use the distro supplied yajl 2.x library.

There was also an attempt to wrap yajl with FFI bindings in the yajl-ruby gem which was also abandoned.

At the time when I first looked at fixing yajl-ruby it did not look like something that I would be successful at accomplishing, so I did not
bother with that, and I wrote the FFI wrapper instead.  After having plagarized (MIT Licensed, so that's kosher) large chunks of the yajl-ruby gem
for ffi-yajl, I understand it better and could probably work on fixing yajl-ruby now, but that would require a complete reset.

## Why not put any effort into fixing the JSON gem?

The YAJL C library error reporting is much better and is considered a necessary requirement for chef-client.  Based on that and other concerns and
pain, that direction never seemed viable.

## Benefits of forking

Forking does bring flexibility.  The feature flag to harden the encoding API against throwing exceptions when fed random binary data is an example of a
feature which is somewhat difficult to implement as code in chef-client itself (you could .to_hash or .for_json all your objects then walk through
the whole data structure and sanitize all the strings before feeding it into a JSON encoder, but its much simpler code as an option to the JSON
encoder itself).  To modify the JSON gem you could monkeypatch the String#to_json method that the JSON gem uses but that will be brittle.  And
patching yajl-ruby would require modifications to the C source code.  This feature is also likely to provoke religious warfare since you are feeding
input which "should" produce an exception since its invalid and then mangling it and suppressing it, and there's no guarantee that gem authors would
view it as an acceptable feature.

## Why support Rubinius, JRuby, 1.8.7, etc?

Because at the time it seemed like a fun thing to do so I did it.  There also does appear to be a stated need in the community for better cross platform
JSON support, and producing a gem which runs anywhere on any distro with any ruby VM produces a more compelling use case for users outside of the
Chef community.  Hopefully, that will lead to better community involvement and could eventually support shifting support of the gem into the larger
ruby community.

## What about the Oj gem?

I didn't know about the Oj gem until after I'd written the FFI code and was doing speed benchmarks.  For chef-client we generally trust the accuracy of
the yajl c-library and require the user-friendly parse errors that it emits, and have not done an evaluation of the Oj gem to see if it meets those
requirements.

The architecture of the Oj gem that produces its speed could also likely be applied to the ffi-yajl gem -- producing a gem which ran on any distro (Linux,
Solaris, AIX, etc) and on any Ruby VM (MRI, RBX, JRuby) at Oj-comparable levels of speed.

