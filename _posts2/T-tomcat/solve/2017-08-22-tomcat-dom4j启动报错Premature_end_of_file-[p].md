---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab4d2ttt/index
title: 2017-08-22-tomcat-dom4j启动报错Premature_end_of_file
categories: [tomcat]
tags: [dom4j,java,jsp,tomcat]
excerpt: org.dom4j.DocumentException Error on line 1 of document Premature end of file. Nested exception Premature end of file.
description: org.dom4j.DocumentException Error on line 1 of document  Premature end of file. Nested exception Premature end of file.
catalog: false
author: 林兴洋
---

项目中碰到tomcat启动报错：

```
org.dom4j.DocumentException: Error on line 1 of document  : Premature end of file. Nested exception: Premature end of file.
```

tomcat部署的目录不要放在 C:\Program Files (x86) 目录下。

简直有毒啊这种问题。	