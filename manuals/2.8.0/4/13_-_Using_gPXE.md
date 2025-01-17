---
layout: manpage
title: Using gPXE
meta: 2.8.0
nav: 13 - Using gPXE
navversion: nav28
---

Support for gPXE (and by extension, iPXE) was added in 2.2.3 for booting ESXi5 installations, however it can be used for
other installations as well.

<div class="alert alert-info alert-block">
    <b>Note:</b> gPXE/iPXE support is still somewhat experimental, so use it only when required.
</div>

## Setup

First, install the gpxe/ipxe boot images package for your OS (for RHEL variants and Fedora, the package name is
gpxe-bootimgs or ipxe-bootimgs). Cobbler sync does not currently copy the undionly.kpxe file to the TFTP root directory.
Again, for RHEL/Fedora you'd do something like this:

{% highlight bash %}
$ cp /usr/share/ipxe/undionly.kpxe /var/lib/tftpboot/
{% endhighlight %}

## Configuring Systems/Profiles

Via the CLI or Web UI, just enable the gpxe option. For example:

{% highlight bash %}
$ cobbler system edit --name=foo --enable-gpxe=1 --interface=eth0 --static=1
{% endhighlight %}

When using `manage_dhcp`, a new entry for systems with static interfaces will be created as follows (following a
"cobbler sync"):

{% highlight bash %}
    host generic1 {
        hardware ethernet xx:xx:xx:xx:xx:xx;
        if exists user-class and option user-class = "gPXE" {
            filename "http://<cobbler server ip>/cblr/svc/op/gpxe/system/foo";
        } else {
            filename "undionly.kpxe";
        }
        next-server <next-server setting>;
    }
{% endhighlight %}

Profiles and systems that use DHCP for addresses are handled by the default network block included in the
`dhcp.template`.

If you're not using DHCP locally, you can just use the URL above with your custom gPXE/iPXE script:
`http://<cobbler server ip>/cblr/svc/op/gpxe/system/foo`.

Here is a sample of the rendered configuration:

{% highlight bash %}
#!gpxe
kernel http://<cobbler server ip>/cobbler/images/centos6.3-x86_64/vmlinuz
imgargs vmlinuz  ksdevice=bootif lang= text kssendmac  ks=http://<cobbler server ip>/cblr/svc/op/ks/system/foo
initrd http://192.168.122.1/cobbler/images/centos6.3-x86_64/initrd.img
boot
{% endhighlight %}

## Templates

The templates for gPXE are stored with the other PXE templates for cobbler, in `/etc/cobbler/pxe`. The default for
systems/profiles is `/etc/cobbler/pxe/gpxe_system_linux.template`, which you can see is the source for the above output:

{% highlight bash %}
$ cat /etc/cobbler/pxe/gpxe_system_linux.template 
#!gpxe
kernel http://$server/cobbler/images/$distro/$kernel_name
imgargs $kernel_name $append_line
initrd http://$server/cobbler/images/$distro/$initrd_name
boot
{% endhighlight %}

As with all PXE templates, the `$append_line` variable is generated internally by cobbler, and contains the kopts
arguments as well as other distro defaults that may be configured.
