---
layout: manpage
title: Multi-Homed Cobbler Servers
meta: 2.6.0
nav: 7 - Multi Homed Cobbler Servers
navversion: nav26
---

<p>How do you use Cobbler to provision machines onto multiple
different subnets, assuming no DNS tricks can be employed, and
where the server to provision the systems has different addresses
on both sides of the "fence". Normally I'd hope that you could say
"bootserver" as a resolvable hostname is resolved on all sides, but
what if you can't have that? Suppose you have no working DNS. Now
you need to be able to have different values for the address of the
cobbler server.</p>

<p>Each profile and system object can take a --server
parameter, which will replace the value used for 'server' in the
cobbler settings file.</p>

<pre><code>cobbler system edit --name=foo --server=server2.example.org
</code></pre>

<p>This parameter can also be used to support multiple cobbler servers
from a centrally managed configuration (though cobbler replicate is
better suited to the task.</p>
