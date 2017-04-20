---
RFC: 73
Title: Enabling meetbot for Chef IRC Community meetings.
Author: JJ Asghar <jj@chef.io>
Status: On Hold
Type: Process
---

# Enabling meetbot for Chef IRC Community meetings.

We will enable [meetbot][meetbot] for the Chef IRC Community Meetings.
Shifting responsibility for taking meeting notes from the designated secretary
to software allows the person acting as the secretary to instead participate
fully in the discussion.

## Motivation

    As a community member of Chef,
    I want the meeting notes to be automated,
    so that the secretary can participate fully in the discussion.

## Specification

The OpenStack community has constant IRC meetings. They leverage something called
[meetbot][meetbot] to help take notes for them. There would be not
only increased productivity and communication but a more natural flow to the
conversations. There are built in commands that help track `#actions` or `#links`
that output an executive summary so you can see in a quick fashion what was discussed.

There will be a small learning curve to learn to use this bot, but the majority
the commands can be used are:

```
Admin commands (for only Chairs):

#startmeeting - Start a meeting. You are designated the owner (and have permanent chair powers).
#endmeeting - End the meeting. Must be called by a chair.
#topic - Set a new topic.
#agreed - Document an agreement in the minutes.

Commands for Everyone:

#info - Add an info item to the minutes. People should liberally use this for important things they say, so that they can be logged in the minutes.
#action - Document an action item in the minutes. Include any nicknames in the line, and the item will be assigned to them. (nicknames are case-sensitive)
#idea - Add an idea to the minutes.
#help - Add a "Call for Help" to the minutes. Use this command when you need to recruit someone to do a task. (Counter-intuitively, this doesn't provide help on the bot)
#link - Add a link to the meeting minutes. The link should be the first non-command on the line, other commentary after the link is OK. Links beginning with http:// and a few other protocols are automatically detected.
```

An example of the [executive summary is here][executive_summary].

This will require Chef Inc, to host the IRC bot someplace so it can track our meetings,
but there is no reason why we couldn't export the logs to Github after the fact
and have it consistent with the previous meetings. This will allow for the least
amount of friction for adoption.

## Copyright

This work is in the public domain. In jurisdictions that do not allow for this,
this work is available under CC0. To the extent possible under law, the person
who associated CC0 with this work has waived all copyright and related or
neighboring rights to this work.

[meetbot]: https://wiki.debian.org/MeetBot
[openstack_meetbot]: http://docs.openstack.org/infra/system-config/irc.html#meetbot
[executive_summary]: http://eavesdrop.openstack.org/meetings/nova/2015/nova.2015-02-19-14.00.html
