---
layout: manpage
title: FreeBSD
meta: 2.8.0
nav: 2 - FreeBSD
navversion: nav28
---

The following steps are required to enable FreeBSD support in Cobbler.

You can grab the patches and scripts from the following github repos:

[git://github.com/jsabo/cobbler\_misc.git](git://github.com/jsabo/cobbler_misc.git)

This would not be possible without the help from Doug Kilpatrick. Thanks Doug!

### Stuff to do once

* Install FreeBSD with full sources

{% highlight bash %}
-   Select "Standard" installation
-   Use entire disk
-   Install a standard MBR
-   Create a new slice and use the entire disk
-   Mount it at /
-   Choose the "Developer" distribution
    -   Full sources, binaries and doc but no games

-   Install from a FreeBSD CD/DVD
-   Setup networking to copy files back and forth
-   In the post install "Package Selection" scroll down and select
    shells
    -   Install bash
    -   chsh -s /usr/local/bin/bash username or vipw
{% endhighlight %}

* Rebuild pxeboot with tftp support

{% highlight bash %}
cd /sys/boot
make clean
make LOADER_TFTP_SUPPORT=yes
make install
{% endhighlight %}

* Copy the pxeboot file to the Cobbler server.

### Stuff to do every supported release

* Patch sysinstall with http install support

-   The media location is hard coded in this patch and has to be updated every release. Just look for 8.X and change it.

The standard sysinstall doesn't really support HTTP. This patch adds full http support to sysinstall.

{% highlight bash %}
cd /usr
patch -p0 < /root/http_install.patch
{% endhighlight %}

* Rebuild FreeBSD mfsroot

We'll use "crunchgen" to create the contents of /stand in a ramdisk image. Crunchgen creates a single statically linked
binary that acts like different normal binaries depending on how it's called. We need to include "fetch" and a few other
binaries. This is a multi step process.

{% highlight bash %}
mkdir /tmp/bootcrunch
cd /tmp/bootcrunch
crunchgen -o /root/boot_crunch.conf
make -f boot_crunch.mk
{% endhighlight %}

Once we've added our additional binaries we need to create a larger ramdisk.

* Create a new, larger ramdisk, and mount it.

{% highlight bash %}
dd if=/dev/zero of=/tmp/mfsroot bs=1024 count=$((1024 * 5))
dev0=`mdconfig -f /tmp/mfsroot`;newfs $dev0;mkdir /mnt/mfsroot_new;mount /dev/$dev0 /mnt/mfsroot_new
{% endhighlight %}

* Mount the standard installer's mfsroot

{% highlight bash %}
mkdir /mnt/cdrom; mount -t cd9660 -o -e /dev/acd0 /mnt/cdrom
cp /mnt/cdrom/boot/mfsroot.gz /tmp/mfsroot.old.gz
gzip -d /tmp/mfsroot.old.gz; dev1=`mdconfig -f /tmp/mfsroot.old`
mkdir /mnt/mfsroot_old; mount /dev/$dev1 /mnt/mfsroot_old
{% endhighlight %}

Copy everything from the old one to the new one. You'll be replacing the binaries, but it's simpler to just copy it all
over.

{% highlight bash %}
(cd /mnt/mfsroot_old/; tar -cf - .) | (cd /mnt/mfsroot_new; tar -xf -)
{% endhighlight %}

Next copy over the new bootcrunch file and create all of the symlinks after removing the old binaries.

{% highlight bash %}
cd /mnt/mfsroot_new/stand; rm -- *; cp /tmp/bootcrunch/boot_crunch ./
for i in $(./boot_crunch 2>&1|grep -v usage);do if [ "$i" != "boot_crunch" ];then rm -f ./"$i";ln ./boot_crunch "$i";fi;done
{% endhighlight %}

Sysinstall uses install.cfg to start the install off. We've created a version of the install.cfg that uses fetch to pull
down another configuration file from the Cobbler server which allows us to dynamically control the install. install.cfg
uses a script called "doconfig.sh" to determine where the Cobbler installer is via the DHCP next-server field.

Copy both install.cfg and doconfig.sh into place.

{% highlight bash %}
cp {install.cfg,doconfig.sh} /mnt/mfsroot_new/stand
{% endhighlight %}

Now just unmount the ramdisk and compress the file

{% highlight bash %}
umount /mnt/mfsroot_new; umount /mnt/mfsroot_old
mdconfig -d -u $dev0; mdconfig -d -u $dev1
gzip /tmp/mfsroot
{% endhighlight %}

Copy the mfsroot.gz to the Cobbler server.

### Stuff to do in Cobbler

* Enable Cobbler's tftp server in modules.conf

{% highlight bash %}
[tftpd]
module = manage_tftpd_py
{% endhighlight %}

* Mount the media

{% highlight bash %}
mount /dev/cdrom /mnt
{% endhighlight %}

* Import the distro

{% highlight bash %}
cobbler import --path=/mnt/ --name=freebsd-8.2-x86_64
{% endhighlight %}

* Copy the mfsroot.gz and the pxeboot.bs into the distro

{% highlight bash %}
cp pxeboot.bs /var/www/cobbler/ks_mirror/freebsd-8.2-x86_64/boot/
cp mfsroot.gz /var/www/cobbler/ks_mirror/freebsd-8.2-x86_64/boot/
{% endhighlight %}

* Configure a system to use the profile, turn on netboot, and off you go.

DHCP will tell the system to request pxelinux.0, so it will.  Pxelinux will request it's configuration file, which will
have pxeboot.bs as the "kernel". Pxelinux will request pxeboot.bs, use the extention (.bs) to realize it's another boot
loader, and chain to it. Pxeboot will then request all the .rc, .4th, the kernel, and mfsroot.gz. It will mount the
ramdisk and start the installer. The installer will connect back to the Cobbler server to fetch the install.cfg (the
kickstart file), and do the install as instructed, rebooting at the end.
