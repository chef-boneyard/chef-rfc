# The Great Workflow RFC

This RFC is about Chef Workflow - which ones exist in the wild, which ones are supported, and how we as a community go about teaching folks:

1. How to get started with Chef
1. How to create your Chef cookbooks
1. How to create your Chef policy (everything that isn't a cookbook)
1. How to manage external dependencies (on cookbooks, libraries, etc.)
1. How to test your cookbooks and policy
1. How to publish your cookbooks and policy

This document covers each of these topics, and proposes two supported workflows for Chef: the monolithic repository workflow, and the independent software projects workflow.

_Note: This RFC is written in active voice, but much of what it documents is not yet ready to be released on the world, in particular the unification of interfaces between multiple workflows. Hold tight, my friends. In particular, for the sake of sanity, assume the monolithic repository workflow works the same as the 'classic' chef workflow. We'll unify the interface between the workflows, and push some smarts into that layer._

## What is a supported workflow?

Chef has lots of moving parts, and as a tool, it is broadly un-opinonated about how you use them. That has real benefits when it comes to solving your day-to-day problems (for example, there is nothing about Chef you can't customize from a cookbook, which is awesome) - but it makes life difficult when you try and bring on new folks, or decide for yourself how to approach a problem.

The workflows in this document are "supported" for three reasons:

1. *They are battle hardened*: the entire community agrees that they are useful and broadly applicable in many real-world scenarios.
2. *Tooling support*: the built-in tooling for Chef supports these workflows as first-class citizens - generators, test harnesses, etc will all work "out-of-the-box" with these workflows.
3. *The Chef Development Kit*: In particular, the Chef Development Kit will support the supported workflows out-of-the-box.

If you think you have another workflow, that's amazing! The currently supported workflows came about from experimentation just like yours. If it becomes mature enough to have broad ecosystem support, propose a change to this RFC.

All workflows and commands documented in this RFC assume you are using the [Chef Development Kit](http://downloads.getchef.com/chef-dk/).

## Chef DK & Knife

_Note: This section can be removed once we are over it_

We have long supported `knife` as a catch-all for workflow with Chef. Knife began life as the command line interface to the Chef Server API - and has grown literal wings. As we consolidate the various supported workflows, we're going to be moving the commands used in them to the `chef` command, for two reasons:

1. It provides us a blank slate for implementation of new workflow super-powers
1. It ensures we won't break existing knife based workflows while we consolidate
1. It makes more sense from a 'come in alone' perspective - the tool you use to do 'chef' stuff as a developer is, unsuprisingly.. called 'chef'.

So this document talks primarily about the `chef` command, and not `knife`.

# How to get started with Chef

This is the one step that should not differ between supported workflows.

Rather than detail every step here, lets call out a couple of important principles when you teach anyone how to use Chef.

1. There are no shortcuts to building complex infrastructure - by extension, there are no shortcuts to building complex infrastructure with Chef. You have to learn things, piece by piece. Zooming someone to the end doesn't help - it actually hurts.
1. The concept of [Progressive Disclosure](http://en.wikipedia.org/wiki/Progressive_disclosure) should always be kept in mind. Make more information available easily, but don't overwhelm users with every feature and possibility.
1. The [Learn Chef](http://learn.getchef.com) site is the place for collaborating on early
stage tutorial content. If a user needs to learn the basics, send them here.
1. The [Fundamentals Webinar](http://learn.getchef.com/additional-resources/) is a series of video tutorials and attendant slide decks that can augement the Learn Chef content.

Regardless of the workflow you eventually settle in to, these rules and basics apply across the board.

As a community, we should agree on one method for beginners to learn the fundamentals. We can add to the list above as more resources come on line (books, more content, etc.)

# Supported Workflows

## Monolithic Repository Workflow

This workflow presents the following key features:

1. All of your Chef related source code, including any 3rd party dependencies, are tracked in one source control repository using Git.
1. External dependencies, and any local modifications to them, are made with built-in vendor branches, allowing you to easily track the upstream for modifications.

This workflow is also the original supported Chef workflow.

### Setup

To get started with this workflow, execute the following:

```
$ chef generate repo chef-repo
$ git add .
$ git commit -a -m "First commit"
```
_Note: This creates a chef-repo exactly like the one you would clone from github today._

You now have a fresh Chef repository, ready for your content.

### How to create your Chef cookbooks

To create a new cookbook, from the top of your chef-repo:

```
$ chef generate cookbook snazzy
```
_Note: We should make the generators smarter about knowing you are in a monolithic repo, and we should tune the generator to do the right things. Also, the options that exist in knife cookbook create need to be fully supported. For example, it should auto-detect the cookbooks directory is the right place._

When you are done writing your cookbook, add it to your git repository:

```
$ git add snazzy
$ git commit -a -m "One snazzy cookbook"
```

### How to create your Chef policy (everything that isn't a cookbook)

To create a new type of policy document, from the top of your chef-repo:

```
$ chef generate THING name
```
_Note: None of these generators exist yet. They should subsume the functionality of the attendent knife X commands, and be intelligent about which workflow we've chosen._

This will result in a blank, JSON formatted policy document created in the appropriate
subdirectory of your repository. Edit it to your satisfaction, and then:

```
$ git add .
$ git commit -a -m "Super dope policy"
```

### How to manage external dependencies

In this workflow, all external dependencies are tracked within the same source code repository as your custom-built source code. To install, for example, a 3rd party cookbook called "apache2" from the [supermarket](http://supermarket.getchef.com):

```
$ chef vendor dependencies
```
_Note: this command should approximate the 'knife cookbook site install' commands behavior, which is to fetch the cookbook and its dependencies from supermarket, and create vendor branches for each of them. Unlike cookbook site install, it should inspect all the metadata for every cookbook in the repository, and dynamically attempt to fetch any dependency it doesn't have. It should be version agnostic._

If you have a top level dependency, you can specify the cookbook name:

```
$ chef vendor dependencies apache2
```

### How to test your cookbooks and policy

When testing your cookbooks with [ChefSpec](https://github.com/sethvargo/chefspec) or [Test Kitchen](https://github.com/test-kitchen/test-kitchen), all your cookbook dependencies should have been resolved with `chef vendor dependencies` above. You can then run your unit tests with:

```
$ chef test unit
```

And your integration tests with:

```
$ chef test integration
```

_Note: We will need to have the generators for each of these tools drop off a standard file for dependency resolution that states we should exlusively look at the directory above us for our content. Also - should this really be chef test unit/chef test integration?_

### How to publish your cookbooks and policy

To publish your cookbooks and policy to a Chef Server:

```
$ chef upload
```
_Note: This is currently a knife command, that should be ported to the chef DK, so we can
abstract it against multiple workflows._

## Independent Software Projects Workflow

This workflow presents the following key features:

1. All of the Chef cookbooks are treated as independent software projects, that can be built in isolation from any other cookbook.
1. External dependencies are fetched as-needed, and treated as artifacts. Changes to the upstream creates a new software projects, and is tracked as such.

### Setup

To get started with this workflow, create a directory for your (multiple) source repositories.

```
$ mkdir ~/src/chef
```

### How to create your Chef cookbooks

To create a new cookbook, from the top of your source directory:

```
$ chef generate cookbook snazzy
```
_Note: We should recognize that we are in the independent software projects workflow, and adjust accordingly._

The cookbook will be automatically initialized as a git project - so when you are done with your first pass, commit it.

```
$ git commit -a -m "One snazzy cookbook"
```

### How to create your Chef policy (everything that isn't a cookbook)

Create a policy-only repository:

```
$ chef generate repo chef-policy --policy-only
```
_Note: this should create a chef-repo minus the cookbooks directory_

To create a new type of policy document, from the top of your chef-policy directory:

```
$ chef generate THING name
```

One exception to this structure are data bags:

```
$ chef generate data-bag BAG_NAME ITEM_NAME
```
_Note: None of these generators exist yet. They should subsume the functionality of the attendent knife X commands, and be intelligent about which workflow we've chosen._

This will result in a blank, JSON formatted policy document created in the appropriate
subdirectory of your repository. Edit it to your satisfaction, and then:

```
$ git add .
$ git commit -a -m "Super dope policy"
```

### How to manage external dependencies

In this workflow, all external dependencies are tracked within their project that has the dependency directly, and treated as artifacts. Adding a dependency to your cookbooks metadata.rb will result in it being automatically downloaded and injected into your project on an add needed basis.

### How to test your cookbooks and policy

When testing your cookbooks with [ChefSpec](https://github.com/sethvargo/chefspec) or [Test Kitchen](https://github.com/test-kitchen/test-kitchen), your dependencies will be automatically resolved.

```
$ chef test unit
```

And your integration tests with:

```
$ chef test integration
```

_Note: We will need to have the generators for each of these tools drop off a standard file for dependency resolution that states we should exlusively look at the directory above us for our content. Also - should this really be chef test unit/chef test integration?_

### How to publish your cookbooks and policy

To publish your cookbooks and policy to a chef server:

```
$ chef upload
```
_Note: This is currently a knife command, that should be ported to the chef DK, so we can abstract it against multiple workflows._

To publish your cookbooks for use with chef-zero:

```
$ chef package / --policy=~/src/chef-policy
```
_Note: This command should package up all your cookbooks and extra policy as a Chef Solo tarball._

