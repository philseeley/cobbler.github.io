---
layout: manpage
title: Memtest
meta: 2.6.0
nav: D - Memtest
navversion: nav26
---

<p>If installed, cobbler will put an entry into all of your PXE menus
allowing you to run memtest on physical systems without making
changes in Cobbler. This can be handy for some simple diagnostics.</p>

<p>Steps to get memtest to show up in your PXE menus:</p>

<pre><code># yum install memtest86+
# cobbler image add --name=memtest86+ --file=/path/to/memtest86+ --image-type=direct
# cobbler sync
</code></pre>

<p>memtest will appear at the bottom of your menus after all of the
profiles.</p>

<h2>Targeted Memtesting</h2>

<p>However, if you already have a cobbler system record for the
system, you can't get the menu. No problem!</p>

<pre><code>cobbler image add --name=foo --file=/path/to/memtest86 --image-type=direct

cobbler system edit --name=bar --mac=AA:BB:CC:DD:EE:FF --image=foo --netboot-enabled=1
</code></pre>

<p>The system will boot to memtest until you put it back to it's
original profile.</p>

<p>CAUTION!</p>

<p>When restoring the system back from memtest, make sure you turn
it's netboot flag /off/ if you have it set to PXE first in the BIOS
order, unless you want to reinstall the system!</p>

<pre><code>cobbler system edit --name=bar --profile=old_profile_name --netboot-enabled=0
</code></pre>

<p>Naturally if you /do/ want to reinstall it after running memtest,
just use --netboot-enabled=1</p>
