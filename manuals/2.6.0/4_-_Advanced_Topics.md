---
layout: manpage
title: Advanced Topics
meta: 2.6.0
nav: 4 - Advanced Topics
navversion: nav26
---

<p>This section of the manual covers the more advanced use cases for Cobbler, including methods for customizing and
extending cobbler without needing to write code.</p>

<h2>PXE behaviour and tailoring</h2>

<h3>Menus</h3>

<p>Cobbler will automatically generate PXE menus for all profiles it has defined.  Running "cobbler sync" is required to
generate and update these menus.</p>

<p>To access the menus, type "menu" at the "boot:" prompt while a system is PXE booting. If nothing is typed, the
network boot will default to a local boot.  If "menu" is typed, the user can then choose and provision any cobbler
profile the system knows about.</p>

<p>If the association between a system (MAC address) and a profile is already known, it may be more useful to just use
"system add" commands and declare that relationship in cobbler; however many use cases will prefer having a PXE system,
especially when provisioning is done at the same time as installing new physical machines.</p>

<p>If this behavior is not desired, run "cobbler system add --name=default --profile=plugh" to default all PXE booting
machines to get a new copy of the profile "plugh".  To go back to the menu system, run
"cobbler system remove --name=default" and then "cobbler sync" to regenerate the menus.</p>

<p>When using PXE menu deployment exclusively, it is not neccessary to make cobbler system records, although the two can
easily be mixed.</p>

<p>Additionally, note that all files generated for the pxe menu configurations are templatable, so if you wish to change
the color scheme or equivalent, see the files in <code>/etc/cobbler</code>.</p>

<h3>Default boot behavior</h3>

<p>If cobbler has no record of the system being booted, cobbler will configure PXE to boot to the contents of
<code>/etc/cobbler/default.pxe</code> which, if unmodified, will just fall through to the local boot process.</p>

<p>The recommended way to specify a different default cobbler profile to PXE boot is to create an explicit system named
"default".  This will cause <code>/etc/cobbler/default.pxe</code> to be ignored.</p>

<pre><code>cobbler system add --name=default --profile=boot_this
</code></pre>

<p>To restore the previous behavior remove that explicit "default" system:</p>

<pre><code>cobbler system remove --name=default
</code></pre>

<p>It is also possible to control the default behavior for a specific network:</p>

<pre><code>cobbler system add --name=network1 --ip-address=192.168.0.0/24 --profile=boot_this
</code></pre>

<h3>Preventing boot loops</h3>

<p>If your machines are set to PXE first in the boot order (ahead of hard drives), change the <code>pxe_just_once</code>
flag in <code>/etc/cobbler/settings</code> to 1. This will set the machines <em>not</em> to PXE-boot on successive boots
once they complete one install.  To re-enable PXE for a specific system, run the following command:</p>

<pre><code>cobbler system edit --name=name --netboot-enabled=1
</code></pre>

<h2>Service Discovery (Avahi)</h2>

<p>If the avahi-tools package is installed, cobblerd will broadcast it's presence on the network, allowing it to be
discovered by koan with the koan --server=DISCOVER parameter.</p>

<h2>Repo Management</h2>

<p>This has already been covered a good bit in the command reference section.</p>

<p>Yum repository management is an optional feature, and is not required to provision through cobbler. However, if
cobbler is configured to mirror certain repositories, it can then be used to associate profiles with those repositories.
Systems installed under those profiles will then be autoconfigured to use these repository mirrors in
<code>/etc/yum.repos.d</code>, and if supported (Fedora Core 6 and later) these repositories can be leveraged even
within Anaconda.  This can be useful if (A) you have a large install base, (B) you want fast installation and upgrades
for your systems, or (C) have some extra software not in a standard repository but want provisioned systems to know
about that repository.</p>

<p>Make sure there is plenty of space in cobbler's webdir, which defaults to <code>/var/www/cobbler</code>.</p>

<pre><code>cobbler reposync [--tries=N] [--no-fail]
</code></pre>

<p>Cobbler reposync is the command to use to update repos as configured with "cobbler repo add".  Mirroring
can take a long time, and usage of cobbler reposync prior to usage is needed to ensure provisioned systems have the
files they need to actually use the mirrored repositories.  If you just add repos and never run "cobbler reposync", the
repos will never be mirrored.  This is probably a command you would want to put on a crontab, though the frequency of
that crontab and where the output goes is left up to the systems administrator.</p>

<p>For those familiar with yum's reposync, cobbler's reposync is (in most uses) a wrapper around the yum command.
Please use "cobbler reposync" to update cobbler mirrors, as yum's reposync does not perform all required steps. Also
cobbler adds support for rsync and SSH locations, where as yum's reposync only supports what yum supports (http/ftp).</p>

<p>If you ever want to update a certain repository you can run:</p>

<pre><code>cobbler reposync --only="reponame1" ...
</code></pre>

<p>When updating repos by name, a repo will be updated even if it is set to be not updated during a regular reposync
operation (ex: cobbler repo edit --name=reponame1 --keep-updated=0).</p>

<p>Note that if a cobbler import provides enough information to use the boot server as a yum mirror for core packages,
cobbler can set up kickstarts to use the cobbler server as a mirror instead of the outside world.  If this feature is
desirable, it can be turned on by setting yum_post_install_mirror to 1 in <code>/etc/cobbler/settings</code> (and
running "cobbler sync").  You should not use this feature if machines are provisioned on a different VLAN/network than
production, or if you are provisioning laptops that will want to acquire updates on multiple networks.</p>

<p>The flags --tries=N (for example, --tries=3) and --no-fail should likely be used when putting reposync on a crontab.
They ensure network glitches in one repo can be retried and also that a failure to synchronize one repo does not stop
other repositories from being synchronized.</p>

<h2>Kickstart Tracking</h2>

<p>Cobbler knows how to keep track of the status of kickstarting machines.</p>

<pre><code>cobbler status
</code></pre>

<p>Using the status command will show when cobbler thinks a machine started kickstarting and when it finished, provided
the proper snippets are found in the kickstart template.   This is a good way to track machines that may have gone
interactive (or stalled/crashed) during kickstarts.</p>

<h2>Boot CD</h2>

<p>Cobbler can build all of its profiles into a bootable CD image using the "cobbler buildiso" command.  This allows for
PXE-menu like bringup of bare metal in evnvironments where PXE is not possible.  Another more advanced method is
described in the koan manpage, though this method is easier and sufficient for most applications.</p>
