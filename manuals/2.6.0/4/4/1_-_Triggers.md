---
layout: manpage
title: Triggers
meta: 2.6.0
nav: 1 - Triggers
navversion: nav26
---

<h2>About</h2>

<p>Cobbler triggers provide a way to tie user-defined actions to
certain cobbler commands -- for instance, to provide additional
logging, integration with apps like Puppet or cfengine, set up SSH
keys, tieing in with a DNS server configuration script, or for some
other purpose.</p>

<p>Cobbler Triggers should be Python modules written using the low-level
Python API for maximum speed, but could also be simple executable shell
scripts.</p>

<p>As a general rule, if you need access to Cobbler's object data from
a trigger, you need to write the trigger as a module. Also never
invoke cobbler from a trigger, or use Cobbler XMLRPC from a
trigger. Essentially, cobbler triggers can be thought of as plugins
into cobbler, though they are not essentially plugins per se.</p>

<h2>Trigger Names (for Old-Style Triggers)</h2>

<p>Cobbler script-based triggers are scripts installed in the
following locations, and must be made chmod +x.</p>

<pre><code>/var/lib/cobbler/triggers/add/system/pre/*
/var/lib/cobbler/triggers/add/system/post/*
/var/lib/cobbler/triggers/add/profile/pre/*
/var/lib/cobbler/triggers/add/profile/post/*
/var/lib/cobbler/triggers/add/distro/pre/*
/var/lib/cobbler/triggers/add/distro/post/*
/var/lib/cobbler/triggers/add/repo/pre/*
/var/lib/cobbler/triggers/add/repo/post/*
/var/lib/cobbler/triggers/sync/pre/*
/var/lib/cobbler/triggers/sync/post/*
/var/lib/cobbler/triggers/install/pre/*
/var/lib/cobbler/triggers/install/post/*
</code></pre>

<p>And the same as the above replacing "add" with "remove".</p>

<p>Pre-triggers are capable of failing an operation if they return
anything other than 0. They are to be thought of as "validation"
filters. Post-triggers cannot fail an operation and are to be
thought of notifications.</p>

<p>We may add additional types as time goes on.</p>

<h2>Pure Python Triggers</h2>

<p>As mentioned earlier, triggers can be written in pure python, and
many of these kinds of triggers ship with cobbler as stock.</p>

<p>Look in your site-packages/cobbler/modules directory and cat
"install_post_report.py" for an example trigger that sends email
when a system gets done installing.</p>

<p>Notice how the trigger has a register method with a path that
matches with the shell patterns above. That's how we know what type
each trigger is.</p>

<p>You will see the path used in the trigger corresponds with the path
where it would exist if it was a script -- this is how we know what
type of trigger the module is providing.</p>

<h2>The Simplest Trigger Possible</h2>

<p>create /var/lib/cobbler/triggers/add/system/post/test.sh chmod +x
the file</p>

<pre><code>#!/bin/bash
echo "Hi, my name is $1 and I'm a newly added system"
</code></pre>

<p>However that's not very interesting as all you get are the names
passed across. For triggers to be the most powerful, they should
take advantage of the Cobbler API -- which means writing them as a
Python module.</p>

<h2>Performance Note</h2>

<p>If you have a very large number of systems, using the Cobbler API
from scripts with old style (non-Python modules, just scripts in
/var/lib/cobbler/triggers) is a very very bad idea. The reason for
this is that the cobbler API brings the cobbler engine up with it,
and since it's a seperate process, you have to wait for that to
load. If you invoke 3000 triggers editing 3000 objects, you can see
where this would get slow pretty quickly. However, if you write a
modular trigger (see above) this suffers no performance penalties
-- it's crazy fast and you experience no problems.</p>

<h2>Permissions</h2>

<p>The /var/lib/cobbler/triggers directory is only writeable by root
(and are executed by cobbler on a regular basis). For security
reasons do not loosen these permissions.</p>

<h2>Example trigger for resetting Cfengine keys</h2>

<p>Here is an example where cobbler and cfengine are running on two
different machines and xmlrpc is used to communicate between the
hosts.</p>

<p>Note that this uses the Cobbler API so it's somewhat inefficient --
it should be converted to a Python module-based trigger. If it were
in a pure Python modular trigger, it would fly.</p>

<p>On the cobbler box:</p>

<p>/var/lib/cobbler/triggers/install/post/clientkeys.py</p>

<pre><code>#!/usr/bin/python
import socket
import xmlrpclib
import sys
from cobbler import api
cobbler_api = api.BootAPI()
systems = cobbler_api.systems()
box = systems.find(sys.argv[2])
server = xmlrpclib.ServerProxy("http://cfengine:9000")
server.update(box.get_ip_address())
</code></pre>

<p>On the cfengine box, we run a daemon that does the following (along
with a few steps to update our ssh_known_hosts file):</p>

<pre><code>#!/usr/bin/python
import SimpleXMLRPCServer
import os
class Keys(object):
     def update(self, ip):
         try:
            os.unlink('/var/cfengine/ppkeys/root-%s.pub' % ip)
        except OSError:
            pass
keys = Keys()
server = SimpleXMLRPCServer.SimpleXMLRPCServer(("cfengine",9000))
server.register_instance(keys)
server.serve_forever()
</code></pre>

<h2>See Also</h2>

<p>post by Ithiriel:</p>

<p><a href="http://www.ithiriel.com/content/2010/03/29/writing-install-triggers-cobbler">Writing Install Triggers</a></p>
