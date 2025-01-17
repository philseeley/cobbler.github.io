---
layout: manpage
title: Advanced Networking - VLANs
meta: 2.6.0
nav: 2 - VLANs
navversion: nav26
---

<p>You can now add VLAN tags to interfaces from Cobbler. In this case we have two VLANs on eth0: 10 and 20. The default VLAN (untagged traffic) is not used:</p>

<p><figure class="highlight"><pre><code class="language-bash" data-lang="bash">$ cobbler system edit --name=foo3.bar.local --interface=eth0 --mac=AA:BB:CC:DD:EE:F0 --static=1
$ cobbler system edit --name=foo3.bar.local --interface=eth0.10 --static=1 --ip-address=10.0.10.5 --subnet=255.255.255.0
$ cobbler system edit --name=foo3.bar.local --interface=eth0.20 --static=1 --ip-address=10.0.20.5 --subnet=255.255.255.0</code></pre></figure></p>

<p><strong>NOTE</strong> You must install the vconfig package during the build process for this to work in the %post section of your build.</p>
