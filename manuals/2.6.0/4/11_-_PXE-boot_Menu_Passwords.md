---
layout: manpage
title: PXE Boot Menu Passwords 
meta: 2.6.0
nav: 11 - PXE boot menu passwords
navversion: nav26
---

<p>== How to create a PXE boot menu password ==</p>

<p>There are two different levels of password:</p>

<p>MENU MASTER PASSWD passwd</p>

<pre><code>    Sets a master password.  This password can be used to boot any
    menu entry, and is required for the [Tab] and [Esc] keys to
    work.
</code></pre>

<p>MENU PASSWD passwd</p>

<pre><code>    (Only valid after a LABEL statement.)
    Sets a password on this menu entry.  "passwd" can be either a
    cleartext password or a SHA-1 encrypted password; use the
    included Perl script "sha1pass" to encrypt passwords.
    (Obviously, if you don't encrypt your passwords they will not
    be very secure at all.)

    If you are using passwords, you want to make sure you also use
    the settings "NOESCAPE 1", "PROMPT 0", and either set
    "ALLOWOPTIONS 0" or use a master password (see below.)

    If passwd is an empty string, this menu entry can only be
    unlocked with the master password.
</code></pre>

<h3>Creating the password hash</h3>

<p>If you have sha1pass on your system (you probably don't, but it's supposed to come with syslinux) you can do:</p>

<p>sha1pass mypassword</p>

<p>If you do <em>not</em> have sha1pass, you can use openssl to create the pasword (the hashes appear to be compatible):</p>

<p>openssl passwd -1 -salt sXiKzkus mypassword</p>

<h3>Files to edit</h3>

<ul>
<li>for master menu password: /etc/cobbler/pxe/pxedefault.template</li>
<li>for individual entries: /etc/cobbler/pxe/pxeprofile.template</li>
</ul>


<h3>Sample usage</h3>

<p>In this example, the master menu password will be used for all the entries (because the profile entry is blank).  I have not looked into a way to dynamically set a different password based on the profile variables yet.</p>

<p>pxedefault.template:</p>

<pre><code>DEFAULT menu
PROMPT 0
MENU TITLE Cobbler | http://github.com/cobbler
MENU MASTER PASSWD $1$sXiKzkus$haDZ9JpVrRHBznY5OxB82.

TIMEOUT 200
TOTALTIMEOUT 6000
ONTIMEOUT $pxe_timeout_profile

LABEL local
        MENU LABEL (local)
        MENU DEFAULT
        LOCALBOOT 0

$pxe_menu_items

MENU end
</code></pre>

<p>pxeprofile.template:</p>

<pre><code>LABEL $profile_name
        MENU PASSWD
        kernel $kernel_path
        $menu_label
        $append_line
        ipappend 2
</code></pre>

<h3>References</h3>

<ul>
<li>/usr/share/doc/syslinux*/syslinux.doc</li>
<li>/usr/share/doc/syslinux*/README.menu</li>
</ul>

