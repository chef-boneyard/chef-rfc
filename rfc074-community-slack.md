---
RFC: 74
Title: Chef Community Slack
Author: Noah Kantrowitz <noah@coderanger.net>
Status: Accepted
Type: Informational
---

# Chef Community Slack

This document describes a plan to migrate the "default" chat for the Chef
community from IRC to Slack.

## tl;dr

We have created a public Slack team, Chef Community. IRC will continue to exist
but new users will receive a message from an IRC bot suggesting they ask questions
in Slack instead, with a link to the sign-up page
(http://community-slack.chef.io). Existing "web chat" links from the Chef
website and documentation will point at (or embed) the Slack team.

## Personas

Three distinct user stories are being considered. First we have the way many
people start with IRC, seeking help with a question. We will refer to the user
in this story as "Alex".

    As a Chef user,
    I want to get near-real-time support from the Chef community,
    so that I can learn Chef and debug problems.

Then we have more the answer-er side of things, wanting to help others so that
they can be successful with Chef. This persona is named "Bonnie".

    As a Chef community member,
    I want to help other community members,
    so that I can help the community grow.

And then finally a more nebulous use case, but no less important. Since day one,
Chef has thrived on having a strong, welcoming, friendly community. Any change
to our community tools must maintain this high standard of social interaction
for the future. This persona is dubbed "Colin".

    As a Chef community member,
    I want to talk with other community members,
    so that I can socialize with other people.

These personas are named for use in this document and the surrounding discussion
to allow easier communication about plans and potential issues.

## The Plan

The first and most obvious step is to register a new Slack team. This will be
distinct from Chef Software Inc's Slack team as Slack does not offer a
permissions system which would allow these to co-exist in the same structure.

[SlackIn](https://github.com/rauchg/slackin) will be deployed and mapped to
`community-slack.chef.io`. This tool allows users to "sign up" for Slack by
requesting an invitation email.
[Slack-IRC](https://github.com/ekmartin/slack-irc) will be deployed to map the
two Freenode IRC channels to Slack. An IRC bot will be written and deployed to
notify new users of the Slack channel and provider them a link to SlackIn. This
information will also be added to the `/topic` of both channels.

Running the new services (SlackIn and the various bots) is left to the discretion
of Chef Software in their role as stewards of the Chef community.

The new Slack channel will be advertised on the [Chef
Forums](https://discourse.chef.io), the pending `community.chef.io` landing
page, and the Chef documentation.

## Why Slack

IRC has been the backbone of the open-source software community for decades,
but it is more or less a UI/UX dead end. As the Chef community grows, we are
having increasing problems keeping our IRC channels a healthy part of it. This
has two sides. One is that Alex, in most cases, is unfamiliar with IRC and the
world of clients (web or otherwise), social customs (pastebins etc), and overall
usage that it entails. This has led to many Alexes unable to find the support
they need to be successful with Chef. The flip is that the Bonnies of the world
often don't want to deal with the usability nightmare that is IRC, and thus are
not able to jump in and answer questions even when they would otherwise have the
time and energy to do so. This has left the Bonnie role on the shoulders of
relatively few individuals in an overall unsustainable way. Slack helps both
Alex and Bonnie to reach their goals with a more modern experience and tools
they are already familiar with.

## Prior Art

Some other communities have gone through similar transitions recently, with
mixed results. The most high-profile negative experience was from [Free Code Camp](http://blog.freecodecamp.com/2015/06/so-yeah-we-tried-slack-and-we-deeply-regretted-it.html),
who quickly hit problems around membership caps. [Reactiflux](https://facebook.github.io/react/blog/2015/10/19/reactiflux-is-moving-to-discord.html)
had the same problem at around 7,500 users. The `#chef` IRC channel has had
3,137 distinct usernames in the past year, so we aren't likely to immediately
hit that kind of cap, but it persistent risk factor going forward.

More positively, [Wordpress](https://make.wordpress.org/chat/) migrated from
IRC to Slack and has been successful with over 8000 users. The HangOps community
Slack has also been far more successful than it's prior IRC channel. The Elixir
and Clojure communities have both started a similar migration, with around 5000
users each in their Slack teams.

Overall it seems like communities that have done similar IRC to Slack migrations
have been happy with them, but those hitting hard limits on the Slack side have
had zero recourse but to abort and move elsewhere.

## Alternatives

For the two problem cases mentioned above, they chose to migrate to [Gitter](https://gitter.im/)
and [Discord](https://discordapp.com/) respectively. Gitter doesn't have the
same level of mobile device support and might confuse some users as our
support discussions generally happen in a single, shared channel rather than
the smattering of repositories that make up Chef, Chef Server, etc. Discord
seems reasonable as an alternative, but the market penetration of Slack is a
strong nod in their favor.

There are a few generally-similar FOSS options
([Mattermost](http://www.mattermost.org/), [Zulip](https://www.zulip.org/), etc)
but none seem to be well polished enough to be worth migrating to at this point.
Additionally most require self-hosting, which would increase the operational
load on Chef Software's staff.

Another option is to simply stick with IRC, and try to set up a mix of hosted
bouncers/proxies and an improved web client. While this is possible, I've not
heard of any other major community providing this level of service for IRC.

## Problems

The biggest problem is mentioned above, unknown and nebulous user limits. We
will not be butting up against those immediately, but based on IRC usage numbers
I would expect us to be within striking distance within a year. This could
probably be solved with some level of pruning of idle users, only 14% of our
yearly IRC users have been active in the last month, but that brings really
gross UX with it. Additionally our projections are based on IRC, which could be
a drastic under-estimation as the improved UX of Slack encourages more users to
participate.

The second big problem is that Slack requires making your email address used
for the account public. Wordpress has built a workaround for this in the form
of a `chat.wordpress.org` mailserver that forwards based on your Wordpress.org
account information and only accepts email from Slack. We could take a similar
approach using Chef Supermarket logins, but this would require either augmenting
SlackIn or developing something custom.

The third big problem is the overall new user flow. Slack is designed assuming
a company structure, so it does not offer any form of public chat or
user-initiated signup. SlackIn offers this, but the UX is a bit awkward compared
to normal web application signup.

A fourth general systemic issue is that Slack, as a company, seems to not
consider this to be a use case worth pursuing. This means they have [stated
directly](https://www.quora.com/Is-there-a-way-to-ignore-certain-users-in-Slack)
that they do not plan to offer any community control or moderation features.
This means no user ignores, no kick/ban abilities, no way to mark trusted users
(equivalent to op/mod in IRC). Slack also doesn't offer public logs, though they
are visible to users once logged in. Some of these we could build ourselves by
virtue of the user signup process being external, others we will simply have to
hope that Slack will prioritize eventually.

None of these are fatal flaws, but all seem unlikely to improve given Slack's
corporate focus as we know it. The lack of moderation tools is the biggest gap,
and one that will need careful planning to overcome. _ed: we should come up with
a plan for moderation tools and update this document before merging /ed_

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.
