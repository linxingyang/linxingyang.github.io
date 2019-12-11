---
layout: post
permalink: /:year/6f6178430d6848e19e2ab9720c1c616a
title: 2017-08-21-eclipse-没有部署文件到tomcat的webapps目录下
categories: [eclipse]
tags: [java,jsp,tomcat,eclipse]
excerpt: myeclipse,部署,项目,tomcat,webapps
description: myeclipse没有部署项目的所有文件到tomcat的webapps目录下
catalog: false
author: 林兴洋
---

问题：myeclipse对项目进行部署后，在tomcat目录下，仅看到部分的文件夹，其它一些文件夹没有部署到tomcat中。

```
项目右键->properties-> myeclipse->deployment assembly 
```

在这里进行配置项目目录与部署目录。使用add目录可以增加条目

![图](http://image.linxingyang.net/image/E-eclipse/image/2017-08-21/01.png)
