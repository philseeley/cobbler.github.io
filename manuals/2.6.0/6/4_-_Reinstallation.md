---
layout: manpage
title: Reinstallation
meta: 2.6.0
nav: 4 - Reinstallation
navversion: nav26
---

<p>Cobbler's helper program, koan, can be installed on remote systems.</p>

<p>It can then be used to reinstall systems, as well as it's original purpose of installing virtual machines.</p>

<p>Usage is as follows:</p>

<pre><code>koan --server cobbler.example.com --profile profileName
koan --server cobbler.example.com --system systemName
</code></pre>

<p>Koan will then configure the bootloader to reinstall the system at next boot.  This can also be used for OS upgrades with an upgrade kickstart as opposed to a kickstart that specifies a clean install.</p>
