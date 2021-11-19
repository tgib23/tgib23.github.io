---
layout: post
title: "install npm package from npm pack-ed file using ansible"
slug: install-npm-package-from-npm-pack-ed-file-using-ansible
date: 2016-03-20 22:28:10 +0900
comments: true
tags: [ansible, npm]
---

In case you want to install npm package file, created by "npm pack" command, just specify the path to the file to "name".
```
description: Install "sample" node.js package, created by "npm pack", located at /tmp/sample.tar.gz
- npm: name=/tmp/sample.tar.gz path=/app/location
```

That's it.
