---
layout: manpage
title: Web Authorization
meta: 2.6.0
nav: 3 - Web Authorization
navversion: nav26
---

<p>Authorization happens after users have been <a href="Web%20Authentication">authenticated</a> and controls who is then allowed, or not allowed, to perform certain specific operations in cobbler.</p>

<p>Note that this applies to the <a href="Cobbler%20web%20interface">Cobbler Web Interface</a> and <a href="XmlRpc">XMLRPC</a> only -- the local cobbler instance can be modified with the command line tool "cobbler" as the root user, regardless of authorization policy.</p>

<p>Authorization choices are set in the <code>[authorization]</code> section of <code>/etc/cobbler/modules.conf</code>, whose options are as follows:</p>

<h3>Allow All</h3>

<pre><code>[authorization]
module = authz_allowall
</code></pre>

<p>This module permits any user who has passed through authorization successfully to do anything they need to do, regardless of username.  This is a valid choice if you are authenticating against a source that only contains trusted accounts, such as the digest authentication module.  But if you are authenticating against an entire company's LDAP server or Kerberos server, however, this would be a poor choice.</p>

<h3>Config File</h3>

<pre><code>[authorization]
module = authz_configfile
</code></pre>

<p>This uses the simple file <code>/etc/cobbler/users.conf</code> to provide a list of what users can access the server.  The format is described below in a separate section.  There are no
semantics given to groups and any listed user can access cobbler to make any changes requested.  Users not in this file do not have access.  An example use of this setting
would be if you wanted to <a href="Kerberos">authenticate admins against Kerberos</a> but kerberos contained other passwords and you wanted to allow only users
present in your whitelist to be able to make changes.</p>

<h3>Ownership</h3>

<pre><code>[authorization]
module = authz_ownership
</code></pre>

<p>This is similar to authz_configfile but now enforces group dynamics.  Each file in the users file (format described below) belongs to a group.</p>

<p>The module keeps users from modifying distributions, profiles, or system records that they do not have access to.  This is a good choice if you are using cobbler in a large
company, have multiple levels of administrators, or want to grant access to users to control specific systems.</p>

<p>If a user is in a group named "admin" or "admins" they will be able to edit any object regardless of the ownership information stored on that object in Cobbler.</p>

<p>Here's an example of storing ownership details in Cobbler:</p>

<pre><code> cobbler system edit --name=system-name --owner=dbagroup,pete,mac,jack
</code></pre>

<p>This policy is rather detailed, so see more at AuthorizationWithOwnership for the full details on how this works.</p>

<h2>Other authorization controls</h2>

<h3>User Supplied Module</h3>

<p>The above authentication systems aren't expected to work for everyone.</p>

<p>As with any CobblerModule, users can write their own, and if they wish, submit them to the mailing list for others to use.  This allows
for developing even finer grained access control, or adapting cobbler to more custom/unusual configurations.</p>

<p>Using something like authz_ownership as a base would probably provide a very good place to start.  If you develop something interesting
you think others may want to use for policy, sharing is greatly appreciated!</p>

<h3>File Format</h3>

<p>The file <code>/etc/cobbler/users.conf</code> is there to configure alternative authentication modes for modules like authz_ownership and authz_configfile.  In the default cobbler configuration (authz_allowall), this file is IGNORED, as is indicated by the comments in the file.</p>

<p>Here's a sample file defining a few users and groups:</p>

<pre><code>[admins]
admin = ""
cobbler = ""
mdehaan = ""

[superlab]
obiwan = ""
luke = ""

[basement]
darth = ""
</code></pre>

<p>Note that how this file is used depends entirely on what you have in <code>/etc/cobbler/modules.conf</code> (as described above in "Module Choices").   After changing this file, cobblerd must be restarted in order for the changes to take effect.</p>

<p>You'll note the values have the "equals quote quote" after them.  These values are currently required, but ignored.  Basically they are reserved
for later use.</p>
