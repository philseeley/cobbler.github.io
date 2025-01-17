---
layout: manpage
title: Extending Cheetah
meta: 2.6.0
nav: 3 - Extending Cheetah
navversion: nav26
---

<p>Cobbler uses Cheetah for it's templating system, it also wants to support other
choices and may in the future support others.</p>

<p>It is possible to add new functions to the templating engine, much
like snippets, that provide the ability to do macro-based things
in the template. If you are new to Cheetah, see the documentation at
<a href="http://www.cheetahtemplate.org/learn.html">http://www.cheetahtemplate.org/learn.html</a>
and pay special attention to the #def directive.</p>

<p>To create new functions, add your Cheetah code to
<code>/etc/cobbler/cheetah_macros</code>. This file will be sourced in all
Cheetah templates automatically, making it possible to write custom
functions and use them from this file.</p>

<p>You will need to restart cobblerd after changing the macros file.</p>
