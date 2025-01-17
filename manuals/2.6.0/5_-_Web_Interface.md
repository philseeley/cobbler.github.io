---
layout: manpage
title: Cobbler Web User Interface
meta: 2.6.0
nav: 5 - Web Interface
navversion: nav26
---

<p>This section of the manual covers the Cobbler Web Interface. With the web user interface (WebUI), you can:</p>

<ul>
<li>View all of the cobbler objects and the settings</li>
<li>Add and delete a system, distro, profile, or system</li>
<li>Run the equivalent of a "cobbler sync"</li>
<li>Edit kickstart files (which must be in <code>/etc/cobbler</code> and <code>/var/lib/cobbler/kickstarts</code>)</li>
</ul>


<p>You cannnot (yet):</p>

<ul>
<li>Auto-Import media</li>
<li>Do a "cobbler validateks"</li>
</ul>


<p>The WebUI is intended to be self-explanatory and contains tips and explanations for nearly every field you can edit.  It also contains links to additional documentation, including the Cobbler manpage documentation in HTML format.</p>

<h2>Basic Setup</h2>

<ol>
<li><p>You must have installed the cobbler-web package</p></li>
<li><p>Your <code>/etc/cobbler/modules.conf</code> should look something like this:</p>

<p>[authentication]<br/>
module = authn_configfile</p>

<p>[authorization]<br/>
module = authz_allowall</p></li>
<li><p>Change the password for the 'cobbler' username:</p>

<p>   htdigest /etc/cobbler/users.digest "Cobbler" cobbler</p></li>
<li><p>If this is not a new install, your Apache configuration for Cobbler might not be current.</p>

<p>cp /etc/httpd/conf.d/cobbler.conf.rpmnew /etc/httpd/conf.d/cobbler.conf</p></li>
<li><p>Now restart Apache and Cobblerd</p>

<p>/sbin/service cobblerd restart<br/>
/sbin/service httpd restart</p></li>
<li><p>If you use SELinux, you may also need to set the following, so that the WebUI can connect with the <a href="XMLRPC">XMLRPC</a>:</p>

<p>setsebool -P httpd_can_network_connect true</p></li>
</ol>


<h2>Basic setup (2.2.x and higher)</h2>

<p>In addition to the steps above, cobbler 2.2.x has a requirement for <code>mod_wsgi</code> which, when installed via EPEL, will be disabled by default. Attempting to start httpd will result in:</p>

<pre><code>Invalid command 'WSGIScriptAliasMatch', perhaps misspelled \
  or defined by a module not included in the server configuration
</code></pre>

<p>You can enable this module by editing <code>/etc/httpd/conf.d/wsgi.conf</code> and un-commenting the "LoadModule wsgi_module modules/mod_wsgi.so" line.</p>

<h3>Next steps</h3>

<p>It should be ready to go.  From your web browser visit the URL on your bootserver that resembles:</p>

<pre><code>https://bootserver.example.com/cobbler_web
</code></pre>

<p>and log in with the username (usually cobbler) and password that you set earlier.</p>

<p>Should you ever need to debug things, see the following log files:</p>

<pre><code>/var/log/httpd/error_log  
/var/log/cobbler/cobbler.log
</code></pre>

<h3>Further setup</h3>

<p>Cobbler authenticates all WebUI logins through <code>cobblerd</code>, which uses a configurable authentication mechanism.  You may wish to adjust that for your environment.  For instance, if in <code>modules.conf</code> above you choose to stay with the authn_configfile module, you may want to add your system administrator usernames to the digest file:</p>

<pre><code>htdigest /etc/cobbler/users.digest "Cobbler" &lt;username&gt;
</code></pre>

<p>You may also want to refine for authorization settings.</p>

<h3>Rewrite Rule for secure-http</h3>

<p>To redirect access to the WebUI via https on an Apache webserver, you can use the following rewrite rule, probably at the end of Apache's <code>ssl.conf</code>:</p>

<pre><code>### Force SSL only on the WebUI
&lt;VirtualHost *:80&gt;
    &lt;LocationMatch "^/cobbler/web/*"&gt;
       RewriteEngine on
       RewriteRule ^(.*) https://%{SERVER_NAME}/%{REQUEST_URI} [R,L]
   &lt;/LocationMatch&gt;
&lt;/VirtualHost&gt;
</code></pre>
