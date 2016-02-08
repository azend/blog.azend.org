---
layout: post
title:  "TekSavvy blocks your email"
date:   2016-02-08 02:34:34
categories: homelab server
comments: true
---
So today I was setting up a GitLab instance on a local Proxmox node of mine which you can read about in the last post. All was going reasonably smoothly until I ran into what I thought was a reasonably simple snag -- sending email. Ok I thought, this probably just calls for a basic `dpkg-reconfigure postfix` to update the config from the copy in the template.

And then I started to notice something unusual in my log files.

{% highlight text %}
Feb  8 07:21:18 git postfix/smtp[30700]: connect to aspmx2.googlemail.com[173.194.205.26]:25: Connection timed out
Feb  8 07:21:18 git postfix/smtp[30698]: connect to aspmx3.googlemail.com[74.125.141.26]:25: Connection timed out
Feb  8 07:21:18 git postfix/smtp[30699]: connect to aspmx2.googlemail.com[173.194.205.26]:25: Connection timed out
Feb  8 07:21:48 git postfix/smtp[30700]: connect to aspmx3.googlemail.com[74.125.141.26]:25: Connection timed out
Feb  8 07:21:48 git postfix/smtp[30699]: connect to aspmx3.googlemail.com[74.125.141.26]:25: Connection timed out
Feb  8 07:21:48 git postfix/smtp[30698]: connect to aspmx2.googlemail.com[173.194.205.26]:25: Connection timed out
{% endhighlight %}

Hmm I wondered. What could cause this? A simple `ping` shows good response times so there can't be something stupid like a loose ethernet plug. I try connecting to the Google mail server directly with netcat and no luck. Super strange right!

Traceroute to figure out where my packets are getting dropped:

{% highlight bash %}
$ traceroute -n -T -p 25 gmail-smtp-in.l.google.com
traceroute to gmail-smtp-in.l.google.com (74.125.193.27), 30 hops max, 44 byte packets
1  192.168.1.1  0.698 ms  1.422 ms  1.410 ms
2  * * *
3  * * *
4  * * *
5  * * *
6  * * *
7  * * *
8  * * *
9  * * *
10  * * *
11  * * *
12  * * *
13  * * *
14  * * *
15  * * *
16  * * *
17  * * *
{% endhighlight %}

So we're dead right out of the gate. At first I think it is some weird setting in my router that might be causing this issue. I've been bitten by tunnel filtering before. A few good looks and some perusing later, I wonder "is my TekSavvy screwing with me?"

Yes. TekSavvy is screwing with me. It turns out they block all outgoing SMTP traffic that doesn't go to their mail servers. Why? My guess is to prevent virus-ridden customers from sending out mass amounts of spam email without even knowing it. According to the blogger below, you can pay extra to get rid of this block but who wants to do that!

Instead what TekSavvy offers instead is an external SMTP relay server that will pass along your mail for you. While I know email is all based in plain text and my ISP already has all my packets anyway, it does kind of bother me to be forced into handing over all my email just to get it sent. However, I suppose the true answer to making unintended people not read my email is PGP.

One quick config change later in `/etc/postfix/main.cf` and my problem is solved.

{% highlight text %}
...
relayhost = smtp.teksavvy.com:25
...
{% endhighlight %}


