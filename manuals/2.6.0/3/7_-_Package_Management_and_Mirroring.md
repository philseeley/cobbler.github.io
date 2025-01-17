---
layout: manpage
title: Package Management and Mirroring
meta: 2.6.0
nav: Package Management and Mirroring
navversion: nav26
---

<h3>About</h3>

<p>This is a walkthrough of how to set up cobbler to be a full fledged
mirror of everything install and update related that you might ever
be interested in.</p>

<p>Updates and package installation are closely related. If you're
doing one, it makes sense to do the other.</p>

<h3>Why would you be interested in this?</h3>

<p>Suppose you manage a large number of machines and are (A) not
allowed to get to the outside world, (B) bandwidth constrained, or
(C) wanting to get access to 3rd party packages including custom
yum repositories.</p>

<p>All of these are good reasons to want a mirror server for all
things kickstart and yum related. Cobbler can do that for you.</p>

<h3>How To</h3>

<p>The following instructions walk through an example of setting up a
mirror of a Fedora install tree, including any updates. This will
require a good bit of hard disk space (we'll show you how to
hardlink to save space later), so be prepared :). These same
commands work for all varieties of RHEL, Fedora, or Centos.</p>

<p>First, follow the setup for a DVD import here using the Fedora 12
install media. See
<a href="Using%20cobbler%20import">Using Cobbler Import</a>.</p>

<p>Once the import is complete, we'll add the mirrors...</p>

<p><figure class="highlight"><pre><code class="language-bash" data-lang="bash">$ cobbler repo add --mirror=http://download.fedora.redhat.com/pub/fedora/linux/updates/12/ --name=f12-i386-updates
$ cobbler repo add --mirror=http://download.fedora.redhat.com/pub/fedora/linux/releases/12/Everything/i386/ --name=f12-i386-everything</code></pre></figure></p>

<p>Please replace i386 with your preferred architecture. If you own
x86_64 or ppc machines as well, just change it. If you're not
running Fedora, insert your yum URLs of choice. It all works the
same!</p>

<p>These are just a few common examples. Say you have a RHEL5 or
Centos4 machine? Perhaps you would want to add something from
<a href="http://fedoraproject.org/wiki/EPEL">EPEL</a>,
<a href="http://rpmfusion.org/">RPM Fusion</a>, or someplace else? No
problem.</p>

<p>Now that we've added the mirrors, let's pull down the content. This
will take a little while, but subsequent updates won't take nearly
as long.</p>

<pre><code>    cobbler reposync 
</code></pre>

<p>Now, that the repositories are mirrored locally, let's create a
cobbler profile that will be able to automatically install from the
above repositories and also configure clients to use the new
mirror.</p>

<pre><code>    cobbler profile add --name=f12-i386-test --repos="f12-i386-updates f12-i386-everything" --distro=F12-i386 --kickstart=/etc/cobbler/sample_end.ks 
</code></pre>

<p>Now, any machines installed from this mirror won't have to hit the
outside world for any content they may need during install or with
yum. They'll ask for content from the cobbler server instead.
Cool.</p>

<h3>RHN</h3>

<p>This is rather experimental, but if you have a provisioning need
for fast local installs without hitting an outside server
repeatedly (say you have a slow pipe), you can try:</p>

<pre><code>    cobbler repo add --name=insertnamehere --mirror=rhn://rhn-channel-name 
</code></pre>

<p>That's just the channel-name, no server. This only works on RHEL5+
and you'll need entitlements for the channel in question. You also
want a version of yum-utils at least equal to 1.0.4.</p>

<h2>Post Install Yum Usage</h2>

<p>If you want your installed systems to be automatically configured
to use your install server for updates, go into
<code>/etc/cobbler/settings</code> and set the following:</p>

<pre><code>yum_post_install_mirror: 1
</code></pre>

<p>(Don't do this if the servers can't reach the cobbler server at the
value set up in settings or if you're going to move the installed
machine to a different network later)</p>

<h3>Updates And Cron</h3>

<p>As you're mirroring repositories that change (and probably even
include some security updates from time to time), putting "cobbler
reposync" on crontab would be a good idea. Cobbler reposync will
update the content in all of your repositories.</p>

<p>You can disable updating of certain repos that you've already
pulled down and don't wish to contact again by toggling the
--keep-updated flag on the repo. Make sure you reposync them at
least once.</p>

<p>Use of the following flags will ensure smoother updates from cron:</p>

<pre><code>cobbler reposync --tries=3 --no-fail
</code></pre>

<p>This will allow Cobbler to keep trucking if one of your mirrors has
problems.</p>

<h3>Also Apt</h3>

<p>Starting, we can also do apt mirroring (see
<a href="Distribution%20Support">Distribution Support</a> ).</p>

<pre><code>cobbler repo add --name=foo --mirror=http://url --breed=apt --arch=i386
</code></pre>

<p>This is useful with Debian distributions (those that have
--breed=debian in the distro object), see
[Distribution Support](Distribution Support]</p>

<h3>Saving Space</h3>

<p>To eliminate space duplicated between mirrored updates and install
trees, run the following command</p>

<pre><code>cobbler hardlink
</code></pre>

<p>This requires that you have first installed the package
'hardlink'.</p>

<h3>To Review</h3>

<p>The above steps have set up your cobbler server as a full fledged
mirror, not just for install trees (which are imported using
"cobbler import" not reposync -- read
<a href="/cobbler/wiki/UsingCobblerImport">Using cobbler import</a>), but also
for future package installs and updates with yum.</p>

<p>Installation content during anaconda and afterwards will be pulled
from your cobbler mirror, not the outside world. You should see
faster installs and won't have to worry about whether your client
machines have outside internet connectivity.</p>

<p>Cobbler handles all of the yum, reposync, and createrepo magic for
you, so you don't have to know how they work. Plus, the kickstarts
are automatically aware of the configuration and build themselves
out based on what repos are defined. Bottom line: you don't need to
know how any of this stuff works. Cool.</p>

<p>If you have questions or want to clear up something in this
document, ask on the mailing list or stop by #cobbler on
irc.freenode.net.</p>
