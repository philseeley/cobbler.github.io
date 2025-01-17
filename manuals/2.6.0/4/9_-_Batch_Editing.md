---
layout: manpage
title: Batch Editing
meta: 2.6.0
nav: 9 - Batch Editing
navversion: nav26
---

<p>Do you want to apply a change to a lot of cobbler objects at once?</p>

<p>Try using xargs combined with "cobbler list" commands, such as:</p>

<pre><code>cobbler profile list | xargs -n1 --replace cobbler profile edit --virt-bridge=xenbr1 --name={} 
</code></pre>

<p>The above example sets the virtual bridge used by every cobbler
profile to 'xenbr1'.</p>

<p>You can filter the profile list by sticking a "grep" commmand in
there as a pipe before the xargs.</p>

<p>See also <a href="Command%20Line%20Search">Command Line Search</a></p>
