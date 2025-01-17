---
layout: manpage
title: Cobbler Manual
meta: 2.8.0
nav: 9 - Batch Editing
navversion: nav28
---

## Batch Editing

Do you want to apply a change to a lot of cobbler objects at once?

Try using xargs combined with "cobbler list" commands, such as:

    cobbler profile list | xargs -n1 --replace cobbler profile edit --virt-bridge=xenbr1 --name={} 

The above example sets the virtual bridge used by every cobbler profile to 'xenbr1'.

You can filter the profile list by sticking a "grep" commmand in there as a pipe before the xargs.

See also [Command Line Search](Command Line Search)
