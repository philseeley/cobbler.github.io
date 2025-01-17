---
layout: manpage
title: Snippets
meta: 2.6.0
nav: Snippets
navversion: nav26
---

<p>Snippets are a way of reusing common blocks of code between kickstarts (though this also works on files other than kickstart templates, but that's a sidenote). For instance, the default Cobbler installation has a snippet called "$SNIPPET('func_register_if_enabled')" that can help set up the application called Func (<a href="http://fedorahosted.org/func">http://fedorahosted.org/func</a>).</p>

<p>This means that every time that this SNIPPET text appears in a kickstart file it is replaced by the contents of <code>/var/lib/cobbler/snippets/func_register_if_enabled</code>. This allows this block of text to be reused in every kickstart template -- you may think of snippets, if you like, as templates for templates!</p>

<p>To review, the syntax looks like:</p>

<pre><code>SNIPPET::snippet_name_here
</code></pre>

<p>Where the name following snippet corresponds to a file in</p>

<pre><code>/var/lib/cobbler/snippets
</code></pre>

<p>with the same name.</p>

<p>Snippets are implemented using a Cheetah function. Although the
legacy syntax ("SNIPPET::snippet_name_here") will still work, the
preferred syntax is:</p>

<pre><code>$SNIPPET('snippet_name_here')
</code></pre>

<p>You can still use the legacy syntax if you prefer, but a small bit
of functionality is lost compared to the new style.</p>

<h2>Advanced Snippets</h2>

<p>If you want, you can use a snippet name across many templates, but
have the snippet be /different/ for specific profiles and/or system
objects. Basically this means you can override the snippet with
different contents in certain cases.</p>

<p>An example of this is if you want to a snippet called
"partition_select" slightly for a certain profile (or set of
profiles) but don't want to change the master template that they
all share.</p>

<p>This could also be used to set up a package list -- for instance,
you could store the base package list to install in
<code>/var/lib/cobbler/snippets/package_list</code>, but override it for
certain profiles and systems. This would allow you to ultimately
create less kickstart templates and leverage the kickstart
templating engine more by just editing the smaller and more easily
readable snippet files. These also help keep your kickstarts
manageable and keep them from becoming too long.</p>

<p>The resolution order for kickstart templating evaluation is to use
the following paths in order, finding the first one if it exists
(per_distro was added in cobbler 2.0).</p>

<pre><code>/var/lib/cobbler/snippets/per_system/$snippet_name/$system_name
/var/lib/cobbler/snippets/per_profile/$snippet_name/$profile_name
/var/lib/cobbler/snippets/per_distro/$snippet_name/$distro_name
/var/lib/cobbler/snippets/$snippet_name
</code></pre>

<p>As with the rest of cobbler, systems override profiles as they are
more specific, though if the system file did not exist, it would
use the profile file. As a general safeguard, always create the
<code>/var/lib/cobbler/snippets/$snippet_name</code> file if you create the
per_system and per_profile ones.</p>

<h2>Subdirectories</h2>

<p>Snippets can be placed in subdirectories for better organization,
and will follow the order of precedence listed above. For example:</p>

<pre><code>/var/lib/cobbler/snippets/$subdirectory/$snippet_name
</code></pre>

<p>This would be referenced in your kickstart template as
$SNIPPET('$subdirectory/$snippet_name').</p>

<p>Replace the dollar sign names with the actual values, such as ...</p>

<pre><code>$SNIPPET('example.org/dostuff')
</code></pre>

<h2>Variable Snippet Names</h2>

<p>Sometimes it is useful to determine which snippet to include at
render time. In Cobbler 1.2, this can be done by omitting the
quotes and using a template variable:</p>

<pre><code>$SNIPPET($my_snippet)
</code></pre>

<p>Note that this DOES NOT work with the legacy syntax:</p>

<pre><code>#set my_snippet = 'foo'
SNIPPET::$my_snippet
</code></pre>

<p>This will not behave as expected. We would like it to include a
snippet named 'foo'; instead, it will search for a snippet named
'$my_snippet'.</p>

<h2>Cobbler SNIPPETs versus Cheetah #include</h2>

<p>It seems that $SNIPPET and #include accomplish the same thing. In
fact, $SNIPPET uses #include in its implementation! While the two
perform similar tasks, there are some important differences:</p>

<ul>
<li>$SNIPPET will search for profile and system-specific SNIPPETS
(See Advanced Snippets)</li>
<li>$SNIPPET will include the namespace of the snippet, so any
functions #def'ed in the snippet will be accessible to the main
kickstart file. #include will not do this.</li>
</ul>


<p>For example:</p>

<p>my_snippet:</p>

<pre><code>#def myfunc()
...
#end def
</code></pre>

<p>my_kickstart:</p>

<pre><code>#include '/var/lib/cobbler/snippets/my_snippet'  ## UGH!
$myfunc()
</code></pre>

<p>Will NOT work. However,</p>

<p>my_kickstart:</p>

<pre><code>$SNIPPET('my_snippet') ## Much better!
$myfunc()
</code></pre>

<p>Will work as expected. It will search for the snippet itself, and
it will make sure myfunc() is callable from my_kickstart.</p>

<h2>Scoping issues</h2>

<p>Cobbler uses Cheetah to implement snippets, so variables in these
snippets are subject to Cheetah's scoping rules (except #def'ed
functions). Variables set inside a snippet cannot be accessed in
the main kickstart file. For example:</p>

<p>my_snippet:</p>

<pre><code>#set dns1 = '192.168.0.1'
</code></pre>

<p>my_kickstart:</p>

<pre><code>$SNIPPET('my_snippet')
echo 'nameserver $dns1' &gt;&gt; /etc/resolv.conf
</code></pre>

<p>Will not work as expected. The variable $dns1 is destroyed as soon
as Cheetah finishes processing my_snippet. To fix this, use the
'global' modifier:</p>

<p>my_snippet:</p>

<pre><code>#set global dns1 = '192.168.0.1'
</code></pre>

<p>Note that the 'global' modifier is not needed on #def directives.
In fact, '#def global' is a syntax error in Cheetah.</p>

<h2>Recursive or Nested Snippets</h2>

<p>Cobbler Snippets can allow for nested snippets. For example:</p>

<p>my_kickstart:</p>

<pre><code>Main content
$SNIPPET('my_snippet')
More main content
</code></pre>

<p>my_snippet:</p>

<pre><code>Snippet content
$SNIPPET('my_subsnippet')
More snippet content
</code></pre>

<p>my_subsnippet:</p>

<pre><code>Subsnippet content
</code></pre>

<p>Will yield:</p>

<pre><code>Main content
Snippet content
Subsnippet content
More snippet content
More main content
</code></pre>

<p>as expected.</p>

<h2>Kickstart Snippet Cookbook</h2>

<p>The rest of this page contains Snippets contributed by users of
Cobbler that provide examples of usage and some quick recipes that
can be used/extended for your environment.</p>

<p>If you come up with any clever tricks, paste them here to share,
and also share them with the cobbler mailing list so we can talk
about them.</p>

<p>Note that some of these rely on cobbler's
<a href="http://cheetahtemplate.org">Cheetah powered</a>
<a href="/cobbler/wiki/KickstartTemplating">KickstartTemplating</a> engine
pretty heavily so they might be a little hard to read at first.
Snippets can just be simple reusable blocks of basic copy and paste
text and can also be simple. Either way works depending on what you
want to do.</p>

<p>NOTE: Content provided here is not part of Cobbler's "core" code so
we may not be able to help you on the mailing list or IRC with
snippets that aren't yet part of cobbler's core distribution.
Cobbler does ship a few in <code>/var/lib/cobbler/snippets</code> that we can
answer questions on, and in general, if you have a good idea, we'd
love to work with you to get it shipped with Cobbler.</p>

<h3>Adding an SSH key to authorized keys</h3>

<pre><code># Install Robin's public key for root user
cd /root
mkdir --mode=700 .ssh
cat &gt;&gt; .ssh/authorized_keys &lt;&lt; "PUBLIC_KEY"
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtDHt4p16wtfUeyzyWBN7R1SXcnjq+R/ojQmiv8HOfYPNM48eCXYdCiNHD4tPCxuizLulqq1zG06B2OPVy9GXXtyXcAXLAQdGaZwDdKU6gHMUplUChSyDpXK6+afdkGimNYoWkQSjqPr9DF1YC4pyWRijxZGvun+yKIv1920wUmS1eqPfAmGYiVPY6ianctEx74PN0E9clenHsPipNDKlYGYeXDx2qewfG3YzJj6W02dCGSkNIaNNefQite3rQcOFHvAYDwzewKZmFSIdTo6nFqAVZtHi8ralyxzP2I7jo9NC5Q6Ivql+hWozlw+x6+zaA2KELcfqY2IMf+7VadtBww== robin@robinbowes.com
PUBLIC_KEY
chmod 600 .ssh/authorized_keys
</code></pre>

<p>Instructions for setup:</p>

<ol>
<li>Decide what to call your snippet. I'll use the name
<code>publickey_root_robin</code>.</li>
<li>Save your code in <code>/var/lib/cobbler/snippets/&lt;snippet name&gt;</code></li>
<li><p>Add your new snippet to your kickstart template, e.g.</p>

<p>%post
SNIPPET::publickey_root_robin
$kickstart_done</p></li>
</ol>


<h3>Disk Configuration</h3>

<p>Contributed by: Matt Hyclak</p>

<p>This snippet makes use of if/else, getVar, and the split()
function.</p>

<p>It provides some additional options for partitioning compared with
the example shipped with Cobbler. If the disk you want to partition
is not sda, then simply set a ksmeta variable for the system (e.g.
cobbler system edit --name=oldIDEbox --ksmeta="disk=hda")</p>

<pre><code>#set $hostname = $getVar('$hostname', None)
#set $hostpart = $getVar('$hostpart', None)
#set $disk = $getVar('$disk', 'sda')

#if $hostname == None
#set $vgname = "VolGroup00"
#else
#if $hostpart == None
#set $hostpart = $hostname.split('.')[0]
#set $vgname = $hostpart + '_sys'
#end if
#end if

clearpart --drives=$disk --initlabel
part /boot --fstype ext3 --size=200 --asprimary
part swap --size=2000 --asprimary
part pv.00 --size=100 --grow --asprimary
volgroup $vgname pv.00
logvol / --vgname=$vgname --size=16000 --name=sysroot --fstype ext3
logvol /tmp --vgname=$vgname --size=4000 --name=tmp --fstype ext3
logvol /var --vgname=$vgname --size=8000 --name=var --fstype ext3

#if $hostpart == "bing"
logvol /var/www --vgname=$vgname --size=16000 --name=www
#else if $hostpart == "build32"
logvol /var/fakedirectory --vgname=$vgname --size=123456789 --name=fake
#end if
</code></pre>

<h3>Another partitioning example</h3>

<p>Use software raid if there are more then one disk present (e.g.
cobbler system edit --name=webServer --ksmeta="disks=sda,sdb")</p>

<p>Contributed by: Harry Hoffman</p>

<pre><code>#set disks = $getVar('$disks', 'sda')
#set count = len($disks.split(','))

#if $count &gt;= 2
part /boot --fstype ext3 --size=100 --asprimary --ondisk=${disks.split(',')[0]}
part /boot2 --fstype ext3 --size=100 --asprimary --ondisk=${disks.split(',')[1]}
part swap --size=1024 --asprimary --ondisk=${disks.split(',')[0]}
part swap --size=1024 --asprimary --ondisk=${disks.split(',')[1]}

part raid.10 --size=1 --grow --ondisk=${disks.split(',')[0]}
part raid.11 --size=1 --grow --ondisk=${disks.split(',')[1]}
raid pv.01 --fstype "physical volume (LVM)" --level=RAID1 --device=md0 raid.10 raid.11
#else
part /boot --fstype ext3 --size=100 --asprimary --ondisk=${disks.split(',')[0]}
part swap --size=1024 --asprimary --ondisk=${disks.split(',')[0]}
part pv.01 --size=1 --grow --ondisk=${disks.split(',')[0]}
#end if

volgroup internal_hd --pesize=32768 pv.01

logvol / --name=slash --vgname=internal_hd --fstype ext3 --size=4096
logvol /tmp --name=tmp --vgname=internal_hd --fstype ext3 --size=1024
logvol /var --name=var --vgname=internal_hd --fstype ext3 --size=8192
logvol /usr --name=usr --vgname=internal_hd --fstype ext3 --size=8192
</code></pre>

<h3>Package Selection by hostname</h3>

<p>Contributed by: Matt Hyclak</p>

<p>NOTE: Advanced Snippets in all recent versions of Cobbler make this
unneccessary (this is an older snippet), but it's still a neat
trick to learn some Cheetah skills.</p>

<p>This snippet makes use of if/else, getVar, the split() function,
include, and try/except.</p>

<p>This snippet allows the administrator to create a file containing
the package selection based on hostname and includes it if
possible, otherwise it fallse back to a default.</p>

<pre><code>#set $hostname = $getVar('$hostname', None)

#if $hostname == None
%packages
@base
#else
#set $hostpart = $getVar('$hostpart', None)
#if $hostpart == None
#set $hostpart = $hostname.split('.')[0]
#end if
#set $sourcefile = "/var/lib/cobbler/packages/" + $hostpart

%packages
#try
  #include $sourcefile
#except
@base
#end try
#end if
</code></pre>

<h3>Package Selection by profile name</h3>

<p>Contributed by: Luc de Louw</p>

<p>This snippet add or removes packages depending on the profile name.
Assuming you have profiles named rhel5, rhel5-test, rhel4 and
rhel4-test. You need to install packages depending if it a test
system or not.</p>

<pre><code>#if 'test' in $profile_name
#Test System selected, adding some more packages
compat-gcc-32
compat-gcc-32-c++
compat-libstdc++-296
compat-libstdc++-33.i386
compat-libstdc++-33.x86_64
libstdc++.i386
libstdc++.x86_64

#else
#Non-test System detected, removing some packages
-openmotif

#end if
</code></pre>

<p>Add $SNIPPET('snippetname') at the %packages section in the
kickstart template</p>

<h3>Root Password Generation</h3>

<p>Contributed by: Matt Hyclak</p>

<p>This snippet makes use of if/else, getVar, and demonstrates how to
import and use python modules directly.</p>

<p>This snippet generates a password from a pattern of the first 4
characters of the hostname + "andsomecommonpart", creates an
appropriate encrypted string with a random salt, and outputs the
appropriate rootpw line. (mdehaan warns -- this snippet isn't
secure as the variable 'hostname' can still be easily read from
Cobbler XMLRPC, if systems have access to it. Credentials are NOT
required to read metadata variables like the hostname, and in this
case, the hostname isn't hard to guess either)</p>

<pre><code>#set $hostname = $getVar('$hostname', None)

#if $hostname
#set $distinct = $hostname[0:4]
#set $rootpw = $distinct + "andsomecommonpart"

#from crypt import crypt
#from whrandom import choice
#import string

#set $salt_pop = string.letters + string.digits + '.' + '/'
#set $salt = ''

#for $i in range(8)
#set $salt = $salt + choice($salt_pop)
#end for

#set $salt = '$1$' + $salt
#set $encpass = crypt($rootpw, $salt)
rootpw --iscrypted $encpass
#end if
</code></pre>

<h3>VMWare Detection</h3>

<p>Contributed by: Matt Hyclak</p>

<p>This snippet makes use of if/else, getVar, and demonstrates how to
make multiple comparisons in an if statement.</p>

<p>This snippet detects if the host is a VMWare guest, and adds a
special kernel repository.</p>

<pre><code>#set $mac_address = $getVar('$mac_address', None)
#if $mac_address
#set $mac_prefix = $mac_address[0:8]

#if $mac_prefix == "00:0c:29" or $mac_prefix == "00:05:69" or $mac_prefix == "00:50:56" 

cat &lt;&lt; EOF &gt;&gt; /etc/yum.repos.d/vmware-kernels.repo
[vmware-kernels]
name=VMWare 100Hz Kernels
baseurl=http://people.centos.org/~hughesjr/vmware-kernels/4/`uname -m`/
enabled=1
gpgcheck=0
priority=2
EOF

yum -y install kernel

#end if
#end if
</code></pre>

<h3>RHEL Installation Keys</h3>

<p>Contributed by: Wil Cooley</p>

<p>RHEL uses keys (also called <em>Installation Number</em>) to determine the
appropriate packages to install. To fully automate a RHEL
installation, the kickstart needs a <em>key</em> option, either setting
the key or explicitly skipping it.</p>

<p>This is not to be confused with
<a href="/cobbler/wiki/TipsForRhn">TipsForRhn</a>, which includes registration
instructions for RHN Hosted and Satellite. Cobbler actually is
happy with "key --skip" in most cases.</p>

<p>See also:</p>

<ul>
<li><a href="http://kbase.redhat.com/faq/FAQ_103_8967.shtm">http://kbase.redhat.com/faq/FAQ_103_8967.shtm</a></li>
<li><a href="http://www.redhat.com/docs/manuals/enterprise/RHEL-5-manual/Installation_Guide-en-US/s1-kickstart2-options.html#id3080516">http://www.redhat.com/docs/manuals/enterprise/RHEL-5-manual/Installation_Guide-en-US/s1-kickstart2-options.html#id3080516</a></li>
</ul>


<p>Add this to the kickstart template:</p>

<pre><code># RHEL Install Key
key $getVar('rhel_key', '--skip')
</code></pre>

<p>Then you can specify the key in the <em>ksmeta</em> system definition:</p>

<pre><code># cobbler system edit --name=00:02:55:fa:6b:2b --ksmeta="rhel_key=xxx"
</code></pre>

<p>If <em>rhel_key</em> is not specified, then it will fall back to
<em>--skip</em>.</p>

<h3>Configure Timezone Based on Hostname</h3>

<p>Contributed by: <a href="http://www.digitalprognosis.com">Jeff Schroeder</a></p>

<p>This snipped will print the correct timezone line for your
kickstart based on the system's hostname. It is highly dependent on
a consistent naming scheme and will have to be edited for each
environment. Using multiple lines to set the associative array
seemed like the sanest way to do this to make adding and removing
new locations easy.</p>

<pre><code>#if $getVar("system_name","") != ""
    #set foo = {}
    #set foo['nyc'] = 'America/New_York'
    #set foo['lax'] = 'America/Los_Angeles'
    #set foo['sin'] = 'Asia/Singapore'
    #set foo['tyo'] = 'Asia/Tokyo'
    #set foo['syd'] = 'Australia/Sydney'
    #set foo['dc'] = 'America/New_York'
    #set hostname = $getVar('system_name').split('.')
    #import re
## Work on hosts with funky hostnames like test001.lab01.lax07.int
    #if re.match('^lab', $hostname[1])
        #del $hostname[1]
    #end if

    #if $len($hostname) == 3  ## ie: ns1.lax07.int
        #set cluster = re.match('^[a-z]+', $hostname[1].lower()).group()

timezone $foo[cluster]
    #else:
# Could not autodetect hostname
timezone --utc 
    #end if
#end if
</code></pre>

<h3>Install HP Proliant Support Pack (PSP)</h3>

<p>Contributed by: Dave Hatton</p>

<p>This snippet automatically installs the HP Proliant Support Pack
(PSP). You may wish to adjust the location that the tarball is
downloaded and uncompressed to, and remove the install package
after installation.</p>

<pre><code> mkdir -p /software

 /usr/bin/wget -O /software/psp-8.00.rhel5.x86_64.en.tar.gz http://@@server@@/cblr/localmirror/psp-8.00.rhel5.x86_64.en.tar.gz

 cd /software &amp;&amp; /bin/tar -xzf psp-8.00.rhel5.x86_64.en.tar.gz


 /bin/cat &gt;&gt;/etc/rc3.d/S99install-hppsp &lt;&lt;EOF
#!/bin/sh
#This script will install the HP PSP 
#set -xv

 /bin/echo "Starting PSP Install: "
 cd /software/compaq/csp/linux &amp;&amp; ./install800.sh --nui --silent

 /bin/rm -f $0

 exit 0
EOF

 /bin/chmod 755 /etc/rc3.d/S99install-hppsp
</code></pre>
