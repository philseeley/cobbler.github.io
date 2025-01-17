---
layout: manpage
title: File System Information
meta: 2.6.0
nav: File System Information
navversion: nav26
---

<p>A typical Cobbler install looks something as follows. Note that in general Cobbler manages its own directories. Editing templates and configuration files is intended. Deleting directories will result in very loud alarms. Please do not ask for help if you decide to delete core directories or move them around.</p>

<p>See <a href="/manuals/2.6.0/2/5_-_Relocating_Your_Installation.html">Relocating Your Installation</a> if you have space problems.</p>

<h3>/var/log/cobbler</h3>

<p>All Cobbler logs go here. Cobbler does not dump to /var/log/messages, though other system services relating to netbooting do.</p>

<h3>/var/www/cobbler</h3>

<p>This is a Cobbler owned and managed directory for serving up various content that we need to serve up via http. Further selected details are below. As tempting as it is to self-garden this directory, do not do so. Manage it using the "cobbler" command or the Cobbler web app.</p>

<h4>/var/www/cobbler/web/</h4>

<p>Here is where the mod_python web interface and supporting service scripts live for Cobbler pre 2.0</p>

<h4>/var/www/cobbler/webui/</h4>

<p>Here is where content for the (pre 2.0) webapp lives that is not a template. Web templates for all versions live in /usr/share/cobbler.</p>

<h4>/var/www/cobbler/aux/</h4>

<p>This is used to serve up certain scripts to anaconda, such as anamon (See <a href="/manuals/2.6.0/Appendix/E_-_Anaconda_Monitoring.html">Anaconda Monitoring</a> for more information on anamon).</p>

<h4>/var/www/cobbler/svc/</h4>

<p>This is where the mod_wsgi script for Cobbler lives.</p>

<h4>/var/www/cobbler/images/</h4>

<p>Kernel and initrd files are copied/symlinked here for usage by koan.</p>

<h4>/var/www/cobbler/ks_mirror/</h4>

<p>Install trees are copied here.</p>

<h4>/var/www/cobbler/repo_mirror/</h4>

<p>Cobbler repo objects (i.e. yum, apt-mirror) are copied here.</p>

<h3>/var/lib/cobbler/</h3>

<p>This is the main data directory for Cobbler. See individual descriptions of subdirectories below.</p>

<h4>/var/lib/cobbler/config/</h4>

<p>Here Cobbler stores configuration files that it creates when you make or edit Cobbler objects. If you are using serializer_catalog in modules.conf, these will exist in various ".d" directories under this main directory.</p>

<h4>/var/lib/cobbler/backups/</h4>

<p>This is a backup of the config directory created on RPM upgrades.  The configuration format is intended to be forward compatible (i.e.  upgrades without user intervention are supported) though this file is kept around in case something goes wrong during an install (though it never should, it never hurts to be safe).</p>

<h4>/var/lib/cobbler/kickstarts/</h4>

<p>This is where Cobbler's shipped kickstart templates are stored. You may also keep yours here if you like. If you want to edit kickstarts in the web application this is the recommended place for them. Though other distributions may have templates that are not explicitly 'kickstarts', we also keep them here.</p>

<h4>/var/lib/cobbler/snippets/</h4>

<p>This is where Cobbler keeps snippet files, which are pieces of text that can be reused between multiple kickstarts.</p>

<h4>/var/lib/cobbler/triggers/</h4>

<p>Various user-scripts to extend Cobbler to perform certain actions can be dropped into subdirectories of this directory. See the <a href="/manuals/2.6.0/4/4/1_-_Triggers.html">Triggers</a> section for more information.</p>

<h3>/usr/share/cobbler/web</h3>

<p>This is where the cobbler-web package (for Cobbler 2.0 and later) lives. It is a Django app.</p>

<h3>/etc/cobbler/</h3>

<ul>
<li><strong>cobbler.conf</strong> - Cobbler's most important config file. Self-explanatory with comments, in YAML format.</li>
<li><strong>modules.conf</strong> - auxilliary config file. controls Cobbler security, and what DHCP/DNS engine is attached, see <a href="/manuals/2.6.0/4/4/2_-_Modules.html">Modules</a> for developer-level details, and also <a href="/manuals/2.6.0/5/1_-_Security_Overview.html">Security Overview</a>. This file is in an INI-style format that can be read by the ConfigParser class.</li>
<li><strong>users.digest</strong> - if using the digest authorization module this is where your web app username/passwords live. Refer to the <a href="/manuals/2.6.0/5_-_Web_Interface.html">Cobbler Web User Interface</a> section for more info.</li>
</ul>


<h4>/etc/cobbler/power</h4>

<p>Here we keep the templates for the various power management modules Cobbler supports. Please refer to the <a href="/manuals/2.6.0/4/5_-_Power_Management.html">Power Management</a> section for more details on configuring power management features.</p>

<h4>/etc/cobbler/pxe</h4>

<p>Various templates related to netboot installation, not neccessarily "pxe".</p>

<h4>/etc/cobbler/zone_templates</h4>

<p>If the chosen DNS management module for DNS is BIND, this directory is where templates for each zone file live. dnsmasq does not use this directory.</p>

<h4>/etc/cobbler/reporting</h4>

<p>Templates for various reporting related functions of Cobbler, most notably the new system email feature in Cobbler 1.5 and later.</p>

<h3>/usr/lib/python${VERSION}/site-packages/cobbler/</h3>

<p>The source code to Cobbler lives here. If you have multiple versions of python installed, make sure Cobbler is in the site-packages directory for the correct python version (you can use symlinks to make it available to multiple versions).</p>

<h4>/usr/lib/python${VERSION}/site-packages/cobbler/modules/</h4>

<p>This is a directory where modules can be dropped to extend Cobbler without modifying the core. See <a href="/manuals/2.6.0/4/4/2_-_Modules.html">Modules</a> for more information.</p>
