---
layout: manpage
title: Locking Down Cobbler
meta: 2.6.0
nav: 4 - Locking down Cobbler
navversion: nav26
---

<p>If you want to enable the
<a href="Cobbler%20web%20interface">Cobbler web interface</a> for a lot
of users, and don't trust all of them to know what they are doing
all of the time, here are some tips on some good configuration
practices to allow for configuring a server that is hard for
someone to mess with in ways they shouldn't be messing with it --
as defined by you and your site specific policy.</p>

<h2>/etc/cobbler/modules.conf</h2>

<p>For
<a href="Web%20Authentication">Web Authentication</a>,
choose authn_kerberos or authn_ldap if you don't have Kerberos.
See <a href="Kerberos">Kerberos</a> and
<a href="Ldap">LDAP</a> for details on how
to set those up. Failing that, using the authn_digest is perfectly
fine, but don't share passwords among the users. Logging goes to
<code>/var/log/cobbler/\*.log</code> and can be used to see what user does
what.</p>

<p>For <a href="Security%20Overview">Customizable Security</a>,
choose authz_ownership, as this will allow users to only edit
things that they create unless you declare certain users to be
admins. You should then define groups for users in
<code>/etc/cobbler/users.conf</code> following the format of that file, then
assign objects in cobbler (like distros, etc) ownership as
described in
<a href="/cobbler/wiki/AuthorizationWithOwnership">AuthorizationWithOwnership</a>.</p>

<h2>Firewall</h2>

<p>For koan to work you must unblock 25150 (XMLRPC/tcp-ip) as well as
HTTP 80, HTTPS 443 and TFTP 69 (tcp/udp) if you want PXE.</p>

<p>If you want to access read-write XMLRPC from outside the cobbler
server, you'll need to unblock 25151.</p>

<p>Also, if applicable, unblock DHCP!</p>

<p>While it may be tempting to disable cobblerd, don't... cobbler uses
cobblerd to generate dynamic content such as
<a href="Kickstart%20Templates">Kickstart Templates</a> and this
will mean nothing will work. Koan additionally communicates with
cobblerd.</p>

<h2>SELinux</h2>

<p>Cobbler works with SELinux -- though you should be using EL 5 or
later. EL 4 is not supported since it does not have
public_content_t, meaning files can't be served from Apache and
TFTP at the same time.</p>

<p>You should install the semanage rules that "cobbler check" tells
you about to ensure everything works according to plan.</p>

<p>Also note, you may run into some problems if you need to relocate
your <code>/var/www elsewhere</code>, which most users should not need to do.</p>

<h2>Default Passwords</h2>

<p>Run "cobbler check" and it will warn you if any of the sample
kickstarts still have "cobbler" as the password. If you are using
those templates, that's a problem, if not, don't worry about it,
but you may want to comment out the password line to prevent them
from being used.</p>

<h2>Test Your Configuration</h2>

<p>Log in as various users (create some in different groups if need
be) to make sure your authorization, authentication, and/or ACLs
are correct as you expect them. Then also make sure you can deploy
some physical and virtual systems outside the network to ensure
your firewall configurations do not cut off anything important.</p>

<h2>Command Line ACLs</h2>

<p>All of the above is about network security, if you want to run the
cobbler CLI as non root, you can run "cobbler aclsetup" to grant
access to non-root users, such as your friendly trusted
neighborhood administrators. Be aware this grants them file access
on all of cobbler's configuration. This all uses setfacl, don't
chmod yourself if you can help it as the RPM takes good steps to
get all of this right. Same for running setfacl yourself as there
are lots of places it must be applied.</p>

<h2>A Note About File Readablity and "Security"</h2>

<p>By nature of provisioning, TFTP and HTTP and so forth are typically
wide open protocols by design. This is actually a good thing due to
the Catch-22 that if it was hard to install, installing would be
hard. Ease of installation requires openness, so these steps above
are about keeping people from changing your provisioning
configurations to ways that they should not have access to change
them -- they are not about denying access to data in the
provisioning server, such as the contents of kickstarts. If you
need to be transferring sensitive files, a long "HERE" document in
kickstart %post is not the place to do it. scp those later or use a
config management system to move the files.</p>
