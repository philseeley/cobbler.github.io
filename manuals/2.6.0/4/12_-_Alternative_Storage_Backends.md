---
layout: manpage
title: Alternative Storage Backends
meta: 2.6.0
nav: 12 - Alternative storage backends
navversion: nav26
---

<p>Cobbler saves object data via serializers implemented as Cobbler <a href="/manuals/2.6.0/4/4/2_-_Modules.html">Modules</a>. This means Cobbler can be extended to support other storage backends for those that want to do it. Today, cobbler ships two such modules alternate backends: MongoDB and CouchDB.</p>

<p>The default serializer is <strong>serializer_catalog</strong> which uses JSON in <code>/var/lib/cobbler/config/&amp;lt;object&amp;gt;</code> directories, with one file for each object definition. It is very fast, however people with a large number of systems can still experience slowness, especially if cobbler lives on a disk partition that is slow or heavily utilized. Users with such setups should ensure <code>/var/lib/cobbler</code> is mounted on a dedicated disk that offers higher performance (15K SAS or a SAN LUN for example).</p>

<p>An older legacy serializer, "serializer_yaml" is deprecated and is only around to support older installs that have not yet upgraded to serializer_catalog by changing the serializer values in <code>/etc/cobbler/modules.conf</code> and restarting cobblerd.</p>

<h3>Details</h3>

<p>Here's what the relavant parts of modules.conf look like:</p>

<p><figure class="highlight"><pre><code class="language-ini" data-lang="ini">[serializers]
settings = serializer_catalog
distro = serializer_catalog
profile = serializer_catalog
system = serializer_catalog
repo = serializer_catalog
etc...</code></pre></figure></p>

<p><strong>NOTE</strong> Be sure to add a line for every object type supported in your version of cobbler. Read the <a href="/manuals/2.6.0/3/1_-_Cobbler_Primitives.html">Cobbler Primitives</a> section for more details.</p>

<p>Suppose, however, that you (just to be contrary), want to save everything in Marshalled XML because you liked angle brackets a whole lot (we don't!). Easy enough, just write a new serializer module that did this and then could change the file to:</p>

<p><figure class="highlight"><pre><code class="language-ini" data-lang="ini">[serializers]
settings = serializer_catalog
distro = serializer_xml
profile = serializer_xml
system = serializer_xml
repo = serializer_xml
etc...</code></pre></figure></p>

<p>This is all just an example -- in your environment, you may have more complex needs -- or even some weird ones.</p>

<p>Often folks ask about whether we can save and read from LDAP, though currently such a serializer is not implemented, though we might be interested in it if it was performant enough.</p>

<h3>One Note of Warning</h3>

<p>The "settings" serializer should always be "serializer_catalog", or at least should read <code>/var/lib/cobbler/settings</code> and treat it as a YAML file. Don't change it unless you know what you are doing, as that file (in YAML format) is packaged as part of the Cobbler RPM.</p>

<p>Future versions of Cobbler may change this default, and revert to using the YAML config only if no JSON config is found.</p>

<h3>Notes on serializer_catalog</h3>

<p>Serializer catalog will save individual files in:</p>

<p><figure class="highlight"><pre><code class="language-bash" data-lang="bash">/var/lib/cobbler/config/distros.d
/var/lib/cobbler/config/profiles.d
/var/lib/cobbler/config/systems.d
etc...</code></pre></figure></p>

<p>Files are named after the name of each object, for instance:</p>

<p><figure class="highlight"><pre><code class="language-bash" data-lang="bash">/var/lib/cobbler/config/systems.d/foo.json</code></pre></figure></p>

<p>On EL 4 and before, the simplejson implementation has some unicode issues, so YAML is still the default on those systems. YAML is significantly slower, so this is more reason to install Cobbler on EL 5 and later. (Or rather, json is 300x faster!)</p>

<p>The filenames for YAML files do not have an extension.</p>

<p><figure class="highlight"><pre><code class="language-bash" data-lang="bash">/var/lib/cobbler/config/systems.d/foo</code></pre></figure></p>

<p>Cobbler knows how to upgrade YAML files to JSON if it is running on a platform that can use JSON, and will do so transparently.</p>
