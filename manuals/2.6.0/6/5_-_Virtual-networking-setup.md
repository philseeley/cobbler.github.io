---
layout: manpage
title: Virtual Networking setup
meta: 2.6.0
nav: 5 - Virtual Networking Setup
navversion: nav26
---

<p>For Xen and qemu/KVM virtual machines to be able to get outside access they will need to have a virtual bridge configured on the virtual host.   (If you're using VMware this page won't apply to you)</p>

<p>While "virbr0" should automatically be set up if you are using a newer libvirt, it's not a real bridge and you won't be able to contact your guests from outside -- it's a private network.  So you most likely do NOT want to use virbr0 if you are doing anything useful.   "xenbr0" if you have that, is fine to use.</p>

<p>The following instructions show about how to set up bridging manually which must be done on a host to make things work as you would expect.</p>

<p>Remember if you have a "xenbr0", you can use that though -- it's a real bridge.  If you want something more specific you can still create your own.   xenbr0 is created in most versions of RHEL by xend startup.</p>

<h3>Networking</h3>

<p>Virtualization networking in koan uses "bridged" mode.   This is so that guests by default
can be connected to from the outside world, which is very important for them to be able to do useful things.</p>

<p>If a network bridge already exists, koan will be able to use that, though in some cases, you'll
have to create your own bridge in order to get koan to work.  You do this by modifying the network configuration on your virtual host,
and then using the koan parameter --virt-bridge=bridgename</p>

<p>(As we mentioned, if you use virbr0, it's a fake bridge, so be aware you won't be able to ssh into your guests .. however koan can use that if you REALLY want to)</p>

<h3>Basics</h3>

<p>The configuration in this section is adapted from [http://watzmann.net/blog/index.php/2007/04/27/networking_with_kvm_and_libvirt this link].  We're going to be ignoring the parts in that article about using virt-install as we want to use koan -- we want to make our virtualized configurations be managed server side, by Cobbler -- and to take advantage of things that cobbler provides for us, like syslog setup, templating, remote profile browsing, etc.</p>

<p>So here's the short rundown of what you need to do to create a bridge if you do not already have one.  Once you do this once for each guest, you're set up -- so if you have bare metal profiles for Cobbler set up, it may make sense to make those profiles set up your bridge at install time as well.</p>

<p>Set up /etc/sysconfig/network-scripts/ifcfg-peth0 to define your physical NIC:</p>

<pre><code>DEVICE=peth0
ONBOOT=yes
BRIDGE=eth0
HWADDR=XX:XX:XX:XX:XX:XX
</code></pre>

<p>Substitute the X's in HWADDR for the mac address of the NIC you'd get from /sbin/ifconfig</p>

<p>Now set up the bridge interface:  /sbin/sysconfig/network-scripts/ifcfg-eth0:</p>

<pre><code>DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
TYPE=Bridge
</code></pre>

<p>As the above link recommends, "You also want to add an iptables rule that allows forwarding of packets on the bridged physical NIC (otherwise DHCP from your guests won't work)".</p>

<pre><code># service iptables start
# iptables -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT
# service iptables save
</code></pre>

<p>Alternatively, you could also disable iptables (at your own risk).</p>

<p>Now you should be able to use koan as follows:</p>

<pre><code>koan --server=bootserver.example.org --profile=RHEL5-i386 --virt
</code></pre>

<p>To force a specific choice, you can use --virt-bridge and specify the name of any bridge you like.  Note that this must be a /real/ bridge, and not a physical interface.
If you use a physical interface things will not work.</p>

<pre><code>koan --server=bootserver.example.org --profile=RHEL5-i386 --virt --virt-bridge=peth0
</code></pre>

<p>Hopefully that helps address some of the basics around virtual networking setup.  The above instructions work for both Xen and qemu/KVM.</p>

<p>(If you encounter problems with the above please bring them up on the cobbler mailing list)</p>

<p>== Network Manager ==</p>

<p>At the time of writing this (Fedora 10), Network Manager does not support bridging.</p>

<p>You should also set NM_MANAGED=No in the configuration file for your physical interface to disable NetworkManager on hosts that use it.</p>

<p>(This has the side effect of tricking firefox into offline mode on startup, but we are hopefully talking about servers here... if this bothers you, go into about:config and search for networkmanager.  Turn off the firefox network manager toolkit.)</p>
