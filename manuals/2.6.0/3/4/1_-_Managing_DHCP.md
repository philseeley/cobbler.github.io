---
layout: manpage
title: Managing DHCP
meta: 2.6.0
nav: Managing DHCP
navversion: nav26
---

<p>You may want cobbler to manage the DHCP entries of its client systems. It currently supports either ISC DHCP or dnsmasq (which, despite the name, supports DHCP). Cobbler can also be used to manage your DNS configuration (see <a href="/manuals/2.6.0/3/4/2_-_Managing_DNS.html">Managing DNS</a> for more details).</p>

<p>To use ISC, your <code>/etc/cobbler/modules.conf</code> should contain:</p>

<p><figure class="highlight"><pre><code class="language-ini" data-lang="ini">[dhcp]
module = manage_isc</code></pre></figure></p>

<p>To use dnsmasq, it should contain:</p>

<p><figure class="highlight"><pre><code class="language-ini" data-lang="ini">[dns]
module = manage_dnsmasq</p>

<p>[dhcp]
module = manage_dnsmasq</code></pre></figure></p>

<div class="alert alert-info alert-block"><b>Note:</b> Using dnsmasq for DHCP requires that you use it for DNS, even if you disable `manage_dns` in your <a href="/manuals/2.6.0/3/3_-_Cobbler_Settings.html">Cobbler Settings</a>. You should not try to mix the ISC module with the dnsmasq module.</div>


<p>You also need to enable such management; this is done in <a href="/manuals/2.6.0/3/3_-_Cobbler_Settings.html">your settings</a>.</p>

<p><figure class="highlight"><pre><code class="language-yaml" data-lang="yaml">manage_dhcp: 1
restart_dhcp: 1</code></pre></figure></p>

<p>The relevant software packages also need to be present; <a href="/manuals/2.6.0/3/2/1_-_Check.html">Cobbler Check</a> will verify this.</p>

<h3>When To Enable DHCP Management</h3>

<p>DHCP is closely related to PXE-based installation.  If you are maintaining a database of your systems and what they run, it can make sense also to manage hostnames and IP addresses. Controlling DHCP from Cobbler can coordinate all this. This capability is a good fit if you can control DHCP for a lab or datacenter and want to run DHCP from the same server where you are running Cobbler. If you have an existing configuration of things that cobbler shouldn't be managing, you can copy them into your <code>/etc/cobbler/dhcp.template</code>.</p>

<p>The default behaviour is for cobbler <em>not</em> to manage your DHCP infrastructure. Make sure that in your existing <code>dhcp.conf</code> the next-server entry and filename information are correct to serve up pxelinux.0 to the machines that want it (for the case of bare metal installations over PXE).</p>

<h3>Setting up</h3>

<h4>ISC considerations</h4>

<p>The master DHCP file when run from cobbler is <code>/etc/cobbler/dhcp.template</code>, not the more usual <code>/etc/dhcpd.conf</code>. Edit this template file to suit your environment; this is mainly just making sure that the DHCP information is correct. You can also include anything you may have had from an existing setup.</p>

<h4>DNSMASQ considerations</h4>

<p>If using dnsmasq, the template file is <code>/etc/cobbler/dnsmasq.template</code> but it basically works as for ISC (above). Remember that dnsmasq also provides DNS.</p>

<h3>How It Works</h3>

<p>Suppose the following command is given (where &lt;profile name&gt; is an existing profile in cobbler):</p>

<p><figure class="highlight"><pre><code class="language-bash" data-lang="bash">$ cobbler system add --name=foo --profile=&lt;profile name&gt;
  --interface=eth0 --mac=AA:BB:CC:DD:EE:FF --ip-address=192.168.1.1</code></pre></figure></p>

<p>That will take the template file in <code>/etc/cobbler/dhcp.template</code>, fill in the appropriate fields, and generate a fuller configuration file <code>/etc/dhcpd.conf</code> that includes this machine, and ensures that when AA:BB:CC:DD:EE:FF asks for an IP, it gets 192.168.1.1. The <code>--ip-address=...</code> specification is optional; DHCP can make dynamic assignments within a configured range.</p>

<p>To make this active, run:</p>

<p><figure class="highlight"><pre><code class="language-bash" data-lang="bash">$ cobbler sync</code></pre></figure></p>

<p>As noted in the <a href="/manuals/2.6.0/3/2/2_-_Sync.html">Cobbler Sync</a> section, managing DHCP with the ISC module is one of the few times you will need to use the full sync via <code>cobbler sync</code>.</p>

<h3>Itanium: additional requirements</h3>

<p>Itanium-based systems are more complicated and special the other architectures, because their bootloader is not as intelligent, and requires a "filename" value that references elilo, not pxelinux.</p>

<ul>
<li>When creating the distro object, make sure that <code>--arch=ia64</code> is specified.</li>
<li>You need to create system objects, and the <code>--mac-address</code> argument is mandatory. (This is due to a deficiency in LILO where it will ask for an encoded IP address, but will not ask for a PXE configuration file based on the MAC address.)</li>
<li>You need to specify the <code>--ip-address=...</code> value on system objects.</li>
<li>In <code>/etc/cobbler/settings</code>, you must (for now) choose <code>dhcp_isc</code>.</li>
</ul>


<p>Also, sometimes Itaniums tend to hang during net installs; the reasons are unknown.</p>

<h3>ISC and OMAPI for dynamic DHCP updates</h3>

<p>OMAPI support for updating ISC DHCPD is actually not supported.  This was a buggy feature (we think OMAPI itself is buggy) and apparently OMAPI is slated for removal in a future version of ISC dhcpd.</p>

<h3>Static IPs</h3>

<p>Lots of users will deploy with DHCP for PXE purposes and then use the Anaconda installer or other mechanism to configure static networking.  For this, you do not need to use this DHCP Management feature. Instead you can configure your DHCP to provide a dynamic range, and configure the static addresses by other mechanisms.</p>

<p>For instance <code>cobbler system ...</code> can set each interface.  Cobbler's default <a href="/manuals/2.6.0/3/6_-_Snippets.html">Snippets</a> will handle the rest.</p>

<p>Alternatively, if your site uses a <a href="/manuals/2.6.0/4/3_-_Configuration_Management.html">Configuration Management</a> system, that might be suitable for such configuration.</p>

<h3>If You Don't Have Any DHCP</h3>

<p>If you don't have any DHCP at all, you can't PXE, and you can ignore this feature, but you can still take advantage of <a href="/manuals/2.6.0/3/2/6_-_Build_ISO.html">Build ISO</a> for bare metal installations.  This is also good for installing machines on different networks that might not have a next-server configured.</p>
