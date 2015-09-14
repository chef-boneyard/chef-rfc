---
RFC: unassigned
Author: Sean OMeara <sean@chef.io>
Status: Draft
Type: <Standards Track, Informational, Process>
<Replaces: RFCxxx>
<Tracking:>
<  - https://github.com/chef/chef/issues/X>
---

# Title

Define a governance system for transferring Supermarket namespace
ownership.

## Motivation

    As a supermarket consumer,
    I want to easily find well engineered, actively maintained
    cookbooks, using meaningful names, so that I can be successful
    with Chef.

    As a cookbook author,
    I want to publish cookbooks for technologies that occupy
    abandoned, unmaintained, or otherwise forsaken namespace on the
    supermarket.

## Exploration

As this point in time, this document serves as a place to collect
thoughts and begin the discussion. This RFC is a true request for
comments.

It is clear that we need some sort of governance model to help things
run more smoothly. The scope is the hard part. There are a ton of
instances of abandoned cookbooks, namespace squatting, and low quality
cookbooks occupying important names. People move on from the
community, people die, change jobs, and simply lose interest. These
needs to be a mechanism for dealing with this. Devising a fair,
effective, and enforceable system is a huge undertaking.
  
Before proceeding, I would like to examine exactly what the
Supermarket is. From there, we can decide the ends to which a
governance model should strive to achieve, and start looking to other
F/OSS communities for inspiration.

The major conceptual models are:
    
- Chef as a language.
- Chef as a software distribution.
- Something in between
   
### Chef as a language
    
In this model, we draw parallels with programming languages. In most
language communities, there is a system for contributing  and sharing
libraries. Ruby has Rubygems.org, Python has PyPI. Node has NPM, and
Java has Maven. Haskell has Hackage. Erlang has Hex.
    
There is a ton of momentum behind this mental model. Tooling such as
Berkshelf was built with this in mind. Cookbooks are packages and the
Supermarket is the hosting system.
   
Namespace governance is typically optimized for the preservation of
backwards compatibility of individual components consumed by build
systems.
    
When two libraries are concerned with the same topic, but work in
different ways, they play semantic games to distinguish themselves.

Some languages, by convention, use a special character for this
purpose. 'alice/json' vs 'bob/json' is a popular method. Enabling this
requires coordination among the ecosystem tooling at every level  and
implementations vary wildly. It would be worth exploring the logistics
of around this, if for no other reason than to have something to point
to when people suggest it.

Without a special character, semantic strategies fall on a spectrum.
At one end there is 'json' vs 'json2', or 'json-alice' vs 'json-bob'.
At the other end, you have... Ruby. While it may be perfectly
acceptable in the Ruby community to name an XML processing library
after a Japanese tree saw, I suspect that the Chef community might
prefer something less random. A governance activity might include the
creation and enforcement of a recommended naming conventions.
   
Some languages have the notion of "core modules", where different
governance rules come into play. This feels like something that Chef
should adopt.

This model starts to show cracks when you consider that most Chef
cookbooks currently on the supermarket are not written in a reusable
manner. Cookbooks that provide resources can be considered libraries
or modules, but recipes are really opinionated state policies.

### Chef as a distribution

In this model, we draw parallels with Linux and Unix distributions.
Most distributions can be described as the set of available packages
and the metadata that binds them.

Namespace governance is typically optimized for content curation, with
an emphasis on interoperability. To achieve this, packaging policies
are created to enforce common conventions.

This model is often used by sophisticated Chef shops, who often write
everything themselves and rarely consume cookbooks from the public
Supermarket.
   
In Linux distributions, two packages are rarely, if ever, concerned
with the same software. Rather than having 'alice/apache' vs
'bob/apache', the distribution will pick a preferred package and
declare if "the way of the system". Often these packages vary wildly
between distributions. The configuration conventions around the Apache
httpd server is a great example of this.

   
Distributions almost always have a notion of "core packages", much the
same as many languages. Alternative or additional packages are
typically used by enabling extra repository sources. Some  systems
have quazi-official repositories where packages outside the "core" set
are maintained, and usually still follow the packaging policy for the
distribution. The RHEL core/EPEL/SCL systems are examples of this, as
are the Ubuntu universe / PPA systems.

Governing the Supermarket like a Linux distribution might ultimately
provide the better experience for consumers, but it requires, by an
order of magnitude, more effort and thought. Interestingly, the
current flat namespace and dependency tooling fit this model well.
      
### Something in Between
   
Due to the nature of Configuration Management, neither of the above
models really fits like a glove. Recipes can be used to build
immutable image artifacts, but also to manage on-going state changes
of a long running machine. Packages typically drop off a default
configuration, where CM usually wants to own the whole bowl.
   
## Specification

- There needs to be a *clear* description of the ends that a
  governance policy is meant to achieve. This should be short, and a
  real collaboration between the Chef community and Chef Software Inc.
  
     
- Something I've always disliked is the tendency for exploitation of
  the "letter of the law", while completely disregarding the spirit of
  it. Therefore, I suggest "spirit clauses" that provide context for
  any major features of a governance policy. This will allow for
  rewording, and the correction of mis-steps, especially in the early
  days.
  
          
- Minimalism is an absolute must. Short lists of clear, easily
  grokable, and (perhaps most importantly) easily enforceable rules
  should be preferred over "page 3027, section 2, clause 3a" style
  documents.
      
- A formal system should be put into place for the selection of
  individuals responsible for rule management, interpretation, and
  enforcement.  
    
## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
