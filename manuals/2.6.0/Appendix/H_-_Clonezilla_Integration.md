---
layout: manpage
title: Clonezilla integration
meta: 2.6.0
nav: H - Clonezilla Integration
navversion: nav26
---

<p>Since many of us need to support non-linux systems in addition to
Linux systems, some facility for support of these systems is
helpful - especially if your dhcp server is pointing pxe boots to
your cobbler server. PXE booting a clonezilla live CD as an option
under cobbler provides a unified starting point for all system
installation tasks.</p>

<h2>Step-by-step (as of 2.2.2)</h2>

<p> \1. Download clonezilla live image from here here:
 <a href="http://clonezilla.org/downloads.php">http://clonezilla.org/downloads.php</a>
 . I used the ubuntu based "experimental" version because the Debian
 based clonezilla's don't have necessary network drivers for many
 Dell servers.</p>

<p>\2. Unpack the zip file to a location on the machine, and run an add the distribution
  cobbler distro add  --name=clonezilla1-2-22-37 --arch=x86_64 --breed=other --os-version=other --boot-files="'$img_path/filesystem.squashfs'='<path_to_your_folder>/live/filesystem.squashfs'" --kernel=<path_to_your_folder>/live/vmlinuz --initrd=<path_to_your_folder>/live/initrd.img</p>

<p>\3. Set up the kickstart kernel options needed for booting to at least:
  nomodeset edd=on ocs_live_run=ocs-live-general ocs_live_keymap=NONE boot=live vga=788 noswap noprompt nosplash ocs_live_batch=no ocs_live_extra_param ocs_lang=en_US.UTF-8 ocs_lang=None nolocales config fetch=tftp://<Your_TFTP_ServerIP>/images/<your_Profile_NAME>/filesystem.squashfs</p>

<p>\4. You should then be able to create a profile for the clonezilla distro and then add to the kernel options, and be able to customize the startup procedure from there using the clonezilla docs.</p>

<p>\5. Run "cobbler sync" to set up the template for the systems you need.</p>

<h2>Limitations and work needed</h2>

<p>\1. I've seen the download of the squashfs skipped on more than one
 occaision, resulting in a kernel panic. Not sure why this happens,
 but trying again fixes the problem (or could just be because I'm
 still experimenting too much).</p>

<p>\2. Would be nice if clonezilla UI was integrated into cobbler
 somewhat (i.e. it knew the IP of the server saving the images and
 maybe had an ssh key so it could get access without a password).</p>

<p>\3. <strong>Still very experimental.</strong></p>
