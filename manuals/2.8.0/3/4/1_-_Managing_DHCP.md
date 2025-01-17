---
layout: manpage
title: Managing DHCP
meta: 2.8.0
nav: Managing DHCP
navversion: nav28
---

You may want cobbler to manage the DHCP entries of its client systems. It currently supports either ISC DHCP or dnsmasq
(which, despite the name, supports DHCP). Cobbler can also be used to manage your DNS configuration (see 
[Managing DNS]({% link manuals/2.8.0/3/4/2_-_Managing_DNS.md %}) for more details).

To use ISC, your `/etc/cobbler/modules.conf` should contain:

{% highlight ini %}
[dhcp]
module = manage_isc
{% endhighlight %}

To use dnsmasq, it should contain:

{% highlight ini %}
[dns]
module = manage_dnsmasq

[dhcp]
module = manage_dnsmasq
{% endhighlight %}

<div class="alert alert-info alert-block"><b>Note:</b> Using dnsmasq for DHCP requires that you use it for DNS, even if
you disable `manage_dns` in your [Cobbler Settings]({% link manuals/2.8.0/3/3_-_Cobbler_Settings.md %}). You should not
try to mix the ISC module with the dnsmasq module.</div>

You also need to enable such management; this is done in
[Cobbler Settings]({% link manuals/2.8.0/3/3_-_Cobbler_Settings.md %}).

{% highlight yaml %}
manage_dhcp: 1
restart_dhcp: 1
{% endhighlight %}

The relevant software packages also need to be present; [Cobbler Check]({% link manuals/2.8.0/3/2/1_-_Check.md %} will
verify this.

### When To Enable DHCP Management

DHCP is closely related to PXE-based installation.  If you are maintaining a database of your systems and what they run,
it can make sense also to manage hostnames and IP addresses. Controlling DHCP from Cobbler can coordinate all this. This
capability is a good fit if you can control DHCP for a lab or datacenter and want to run DHCP from the same server where
you are running Cobbler. If you have an existing configuration of things that cobbler shouldn't be managing, you can
copy them into your `/etc/cobbler/dhcp.template`.

The default behaviour is for cobbler _not_ to manage your DHCP infrastructure. Make sure that in your existing
`dhcp.conf` the next-server entry and filename information are correct to serve up pxelinux.0 to the machines that want
it (for the case of bare metal installations over PXE).

### Setting up

#### ISC considerations

The master DHCP file when run from cobbler is `/etc/cobbler/dhcp.template`, not the more usual `/etc/dhcpd.conf`. Edit
this template file to suit your environment; this is mainly just making sure that the DHCP information is correct. You
can also include anything you may have had from an existing setup.

#### DNSMASQ considerations

If using dnsmasq, the template file is `/etc/cobbler/dnsmasq.template` but it basically works as for ISC (above).
Remember that dnsmasq also provides DNS.

### How It Works

Suppose the following command is given (where &lt;profile name&gt; is an existing profile in cobbler):

{% highlight bash %}
$ cobbler system add --name=foo --profile=<profile name> 
  --interface=eth0 --mac=AA:BB:CC:DD:EE:FF --ip-address=192.168.1.1
{% endhighlight %}

That will take the template file in `/etc/cobbler/dhcp.template`, fill in the appropriate fields, and generate a fuller
configuration file `/etc/dhcpd.conf` that includes this machine, and ensures that when AA:BB:CC:DD:EE:FF asks for an IP,
it gets 192.168.1.1. The `--ip-address=...` specification is optional; DHCP can make dynamic assignments within a
configured range.

To make this active, run:

{% highlight bash %}
$ cobbler sync
{% endhighlight %}

As noted in the [Cobbler Sync]({% link manuals/2.8.0/3/2/2_-_Sync.md %}) section, managing DHCP with the ISC module is
one of the few times you will need to use the full sync via `cobbler sync`.

### Itanium: additional requirements

Itanium-based systems are more complicated and special the other architectures, because their bootloader is not as
intelligent, and requires a "filename" value that references elilo, not pxelinux.

* When creating the distro object, make sure that `--arch=ia64` is specified.
* You need to create system objects, and the `--mac-address` argument is mandatory. (This is due to a deficiency in LILO
where it will ask for an encoded IP address, but will not ask for a PXE configuration file based on the MAC address.)
* You need to specify the `--ip-address=...` value on system objects.
* In `/etc/cobbler/settings`, you must (for now) choose `dhcp_isc`.

Also, sometimes Itaniums tend to hang during net installs; the reasons are unknown.

### ISC and OMAPI for dynamic DHCP updates

OMAPI support for updating ISC DHCPD is actually not supported.  This was a buggy feature (we think OMAPI itself is
buggy) and apparently OMAPI is slated for removal in a future version of ISC dhcpd.

### Static IPs

Lots of users will deploy with DHCP for PXE purposes and then use the Anaconda installer or other mechanism to configure
static networking.  For this, you do not need to use this DHCP Management feature. Instead you can configure your DHCP
to provide a dynamic range, and configure the static addresses by other mechanisms.

For instance `cobbler system ...` can set each interface. Cobbler's default 
[Snippets]({% link manuals/2.8.0/3/6_-_Snippets.md %}) will handle the rest.

Alternatively, if your site uses a [Configuration Management]({% link manuals/2.8.0/4/3_-_Configuration_Management.md %})
system, that might be suitable for such configuration.

### If You Don't Have Any DHCP

If you don't have any DHCP at all, you can't PXE, and you can ignore this feature, but you can still take advantage of
[Build ISO]({% link manuals/2.8.0/3/2/6_-_Build_ISO.md %}) for bare metal installations. This is also good for
 installing machines on different networks that might not have a next-server configured.
