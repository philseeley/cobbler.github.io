---
layout: manpage
title: Anaconda Monitoring
meta: 2.6.0
nav: E - Anaconda Monitoring
navversion: nav26
---

<p>This page details the <strong>Ana</strong>conda <strong>Mon</strong>itoring service available in cobbler.  As anamon is rather distribution specific, support for it is considered deprecated at this time.</p>

<h2>History</h2>

<p>Prior to Cobbler 1.6 , remote monitoring of installing systems was
limited to distributions that accept the the boot argument
<em>syslog=</em>. While this is supported in RHEL-5 and newer Red Hat
based distributions, it has several shortcomings.</p>

<h4>Reduces available kernel command-line length</h4>

<p>The kernel command-line has a limited amount of space, relying on <em>syslog=somehost.example.com</em> reduces available argument space. Cobbler has smarts to not add the <em>syslog=</em> parameter if no space is available. But doing so disables remote monitoring.</p>

<h4>Only captures syslog</h4>

<p>The <em>syslog=</em> approach will only capture syslog-style messages. Any command-specific output (<code>/tmp/lvmout</code>, <code>/tmp/ks-script</code>, <code>/tmp/X.config</code>) or installation failure (<code>/tmp/anacdump.txt</code>) information is not sent.</p>

<h4>Unsupported on older distros</h4>

<p>While capturing syslog information is key for remote monitoring of installations, the <a href="http://fedoraproject.org/wiki/Anaconda">anaconda</a> installer only supports sending syslog data for RHEL-5 and newer distributions.</p>

<h2>What is Anamon?</h2>

<p>In order to overcome the above obstacles, the <em>syslog=</em> remote monitoring has been replaced by a python service called <strong>anamon</strong> (Anaconda Monitor). Anamon is a python daemon (which runs inside the installer while it is installing) that connects to the cobbler server via XMLRPC and uploads a pre-determined set of files. Anamon will continue monitoring files for updates and send any new data to the cobbler server.</p>

<h2>Using Anamon</h2>

<p>To enable anamon for your Red Hat based distribution installations, edit <em>/etc/cobbler/settings</em> and set:</p>

<p><figure class="highlight"><pre><code class="language-yaml" data-lang="yaml">anamon_enabled: 1</code></pre></figure></p>

<p><strong>NOTE:</strong> Enabling anamon allows an xmlrpc call to send create and update log files in the anamon directory, without authentication, so enable only if you are ok with this limitation. It could be potentially used by users to flood the log files or fill up the server, which you probably don't want in an untrusted environment.  However, even so, it may be good for debugging complex installs.</p>

<p>You will also need to update your kickstart templates to include the following snippets.</p>

<p><figure class="highlight"><pre><code class="language-bash" data-lang="bash">%pre
$SNIPPET(&#39;pre_anamon&#39;)</code></pre></figure></p>

<p>Anamon can also send <code>/var/log/messages</code> and <code>/var/log/boot.log</code> once your provisioned system has booted. To also enable post-install boot notification, you must enable the following snippet:</p>

<p><figure class="highlight"><pre><code class="language-bash" data-lang="bash">%post
$SNIPPET(&#39;post_anamon&#39;)</code></pre></figure></p>

<h2>Where Is Information Saved?</h2>

<p>All anamon logs are stored in a system-specific directory under <em>/var/log/cobbler/anamon/systemname</em>. For example,</p>

<p><figure class="highlight"><pre><code class="language-bash" data-lang="bash">$ ls /var/log/cobbler/anamon/vguest3
anaconda.log  boot.log  dmesg  install.log  ks.cfg  lvmout.log  messages  sys.log</code></pre></figure></p>

<h2>Older Distributions</h2>

<p>Anamon relies on a %pre installation script that uses a python <em>xmlrpc</em> library. The installation image used by Red Hat Enterprise Linux 4 and older distributions for <strong>http://</strong> installs does not provide the needed python libraries. There are several ways to get around this ...</p>

<ol>
<li>Always perform a graphical or <strong>vnc</strong> install - installing graphically (or by vnc) forces anaconda to download the <em>stage2.img</em> that includes graphics support <strong>and</strong> the required python xmlrpc library.</li>
<li>Install your system over nfs - nfs installations will also use the <em>stage2.img</em> that includes python xmlrpc support</li>
<li>Install using an <em>updates.img</em> - Provide the missing xmlrpc library by building an updates.img for use during installation. To construct an <em>updates.img</em>, follow the steps below:</li>
</ol>


<p><figure class="highlight"><pre><code class="language-bash" data-lang="bash">$ dd if=/dev/zero of=updates.img bs=1k count=1440
$ mke2fs updates.img
$ tmpdir=<code>mktemp -d</code>
$ mount -o loop updates.img $tmpdir
$ mkdir $tmpdir/cobbler
$ cp /usr/lib64/python2.3/xmlrpclib.<em> $tmpdir/cobbler
$ cp /usr/lib64/python2.3/xmllib.</em> $tmpdir/cobbler
$ cp /usr/lib64/python2.3/shlex.<em> $tmpdir/cobbler
$ cp /usr/lib64/python2.3/lib-dynload/operator.</em> $tmpdir/cobbler
$ umount $tmpdir
$ rmdir $tmpdir</code></pre></figure></p>

<p>More information on building and using an <em>updates.img</em> is available from <a href="http://fedoraproject.org/wiki/Anaconda/Updates">http://fedoraproject.org/wiki/Anaconda/Updates</a>.</p>
