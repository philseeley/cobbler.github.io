---
layout: manpage
title: Alternative Storage Backends - CouchDB
meta: 2.8.0
nav: 1 - CouchDB
navversion: nav28
---

<div class="alert alert-info alert-block">
    <b>Warning:</b> This feature has been deprecated and will not be available in Cobbler 3.0.
</div>

Cobbler 2.0.x introduced support for CouchDB as alternate storage backend, primarily as a proof of concept for NoSQL
style databases. Currently, support for this backend is ALPHA-quality as it has not received significant testing.

Currently, CouchDB must be configured and running on the same system as the cobblerd daemon in order for Cobbler to
connect to it successfully. Additional SELinux rules may be required for this connection if SELinux is set to enforcing
mode.

### Serializer Setup

Add or modify the following section in the `/etc/cobbler/modules.conf` configuration file:

{% highlight ini %}
[serializers]
settings = serializer_catalog
distro = serializer_couchdb
profile = serializer_couchdb
system = serializer_couchdb
repo = serializer_couchdb
etc...
{% endhighlight %}

**NOTE** Be sure to leave the settings serializer set to serializer_catalog.
