---
layout: post
permalink: tomcat-deployment-error-cannot-deploy-all-file
title: myeclipse没有部署项目的所有文件到tomcat的webapps目录下
categories: [错误]
tags: [tomcat,java,javaweb,myeclipse]
excerpt: myeclipse没有部署项目的所有文件到tomcat的webapps目录下
description: myeclipse没有部署项目的所有文件到tomcat的webapps目录下
picUrl: images\public\1000\002
---

问题：
myeclipse对项目进行部署后，在tomcat目录下，仅看到部分的文件夹，其它一些文件夹没有部署到tomcat中。

```
项目右键->properties-> myeclipse->deployment assembly 

```
在这里进行配置项目目录与部署目录。我是因为 WebRoot下的东西没有发布到tomcat下，加上最后一条就行了，其他的类推。


![01.png]({{site.baseurl}}/{{ page.picUrl }}/01.png)
