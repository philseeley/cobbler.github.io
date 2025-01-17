---
layout: manpage
title: Management Classes
meta: 2.6.0
nav: 6 - Management Classes
navversion: nav26
---

Management classes allow cobbler to function as a configuration management system. The lego blocks of configuration
management, resources are grouped together via Management Classes and linked to a system. Cobbler supports two (2)
resource types, which are configured in the order listed below:

1. [Package Resources]({% link manuals/2.6.0/3/1/8_-_Package_Resources.md %})
2. [File Resources]({% link manuals/2.6.0/3/1/7_-_File_Resources.md %})

To add a Management Class, you would run the following command: 
`$ cobbler mgmtclass add --name=string --comment=string [--packages=list] [--files=list]`

### name

The name of the mgmtclass. Use this name when adding a management class to a system, profile, or distro. To add a
mgmtclass to an existing system use something like
(`cobbler system edit --name="madhatter" --mgmt-classes="http mysql"`).

### comment

A comment that describes the functions of the management class.

### packages

Specifies a list of package resources required by the management class.

### files

Specifies a list of file resources required by the management class.
