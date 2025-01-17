---
layout: manpage
title: Kerberos Authentication
meta: 2.6.0
nav: 3 - Kerberos
navversion: nav26
---

<p>Do you want to authenticate users using Cobbler's Web UI against
Kerberos? If so, this is for you.</p>

<p>You may also be interested in authenticating against LDAP instead
-- see <a href="Ldap">LDAP</a> -- though if you have Kerberos you probably want to use Kerberos.</p>

<p>We assume you've already got the WebUI up and running and just want
to kerberize it ... if not, see
<a href="Cobbler%20web%20interface">Cobbler web interface</a> first, then come back
here.</p>

<h2>Bonus</h2>

<p>These steps also work for kerberizing Cobbler XMLRPC transactions
provided those URLs are the Apache proxied versions as specified in
<code>/var/lib/cobbler/httpd.conf</code></p>

<h2>Configure the Authentication and Authorization Modes</h2>

<p>Edit <code>/etc/cobbler/modules.conf</code>:</p>

<pre><code>[authentication]
module = authn_passthru

[authorization]
module = authz_allowall
</code></pre>

<p>Note that you may want to change the authorization later, see
<a href="Web%20Authorization">Web Authorization</a>
for more info.</p>

<h2>A Note About Security</h2>

<p>The authn_passthru mode is only as secure as your Apache
configuraton. If you make the Apache configuration permit everyone
now, everyone will have access. For this reason you may want to
test your Apache config on a test path like <code>/var/www/html/test</code>
first, before using those controls to replace your default cobbler
controls.</p>

<h2>Configure your <code>/etc/krb5.conf</code></h2>

<p>NOTE: This is based on my file which I created during testing. Your
kerberos configuration could be rather different.</p>

<pre><code>[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 ticket_lifetime = 24000
 default_realm = EXAMPLE.COM
 dns_lookup_realm = false
 dns_lookup_kdc = false
 kdc_timesync = 0

[realms]
 REDHAT.COM = {
  kdc = kdc.example.com:88
  admin_server = kerberos.example.com:749
  default_domain = example.com
 }

[domain_realm]
 .example.com = EXAMPLE.COM
 example.com = EXAMPLE.COM

[kdc]
 profile = /var/kerberos/krb5kdc/kdc.conf

[pam]
 debug = false
 ticket_lifetime = 36000
 renew_lifetime = 36000
 forwardable = true
 krb4_convert = false
</code></pre>

<h2>Modify your Apache configuration file</h2>

<p>There's a section in <code>/etc/httpd/conf.d/cobbler.conf</code> that controls
access to <code>/var/www/cobbler/web</code>. We are going to modify that
section. Replace that specific "Directory" section with:</p>

<p>(Note that for Cobbler >= 2.0, the path is actually
"/cobbler_web/")</p>

<pre><code>LoadModule auth_kerb_module   modules/mod_auth_kerb.so

&lt;Directory "/var/www/cobbler/web/"&gt;
  SetHandler mod_python
  PythonHandler index
  PythonDebug on

  Order deny,allow
  Deny from all
  AuthType Kerberos
  AuthName "Kerberos Login"
  KrbMethodK5Passwd On
  KrbMethodNegotiate On
  KrbVerifyKDC Off
  KrbAuthRealms EXAMPLE.COM

  &lt;Limit GET POST&gt;
    require user \
      gooduser1@EXAMPLE.COM \
      gooduser2@EXAMPLE.COM
    Satisfy any
  &lt;/Limit&gt;

&lt;/Directory&gt;
</code></pre>

<p>Note that the above example configuration can be tweaked any way
you want, the idea is just that we are delegating Kerberos
authentication bits to Apache, and Apache will do the hard work for
us.</p>

<p>Also note that the above information lacks KeyTab and Service Principal info for
usage with the GSS API (so you don't have to type passwords in). If
you want to enable that, do so following whatever kerberos
documentation you like -- Cobbler is just deferring to Apache for
auth so you can do whatever you want. The above is just to get you
started.</p>

<h2>Restart Things And test</h2>

<pre><code>/sbin/service cobblerd restart
/sbin/service httpd restart
</code></pre>

<h2>A Note About Usernames</h2>

<p>If entering usernames and passwords into prompts, use
"user@EXAMPLE.COM" not "user".</p>

<p>If you are using one of the authorization mechanisms that uses
<code>/etc/cobbler/users.conf</code>, make sure these match and that you do not
use just the short form.</p>

<h2>Customizations</h2>

<p>You may be interested in the <a href="Web%20Authorization">Web Authorization</a>
section to further control things. For instance you can decide to let in
the users above, but only allow certain users to access certain
things. The authorization module can be used independent of your
choice of authentication modes.</p>

<h2>A note about restarting cobblerd</h2>

<p>Cobblerd regenerates an internal token on restart (for security
reasons), so if you restart cobblerd, you'll have to close your
browser to drop the session token and then try to login again.
Generally you won't be restarting cobblerd except when restarting
machines and on upgrades, so this shouldn't be a problem.</p>
