---
layout: manpage
title: Cobbler Manual
meta: 2.8.0
nav: 10 - Moving to a new server
navversion: nav28
---

## About

What if you have Cobbler installed on Box A, and decide it really needs to be on Box B? Without doing everything from
scratch again, how would you accomplish the move? (Some of these instructions may also be useful for backing up a
cobbler install as well).

## Suggested Process

1.  Install Cobbler on the new system.
2.  on the new box, run "cobbler replicate". See [Replication](Replication) for instructions and make sure you use the
    right flags to transfer scripts and data.
3.  Try installing some systems to make sure everything works like you would expect.

