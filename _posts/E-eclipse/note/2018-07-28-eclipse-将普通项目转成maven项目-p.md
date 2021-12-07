---
layout: post
permalink: /:year/linxingyangwriteat20211208044049/index
title: eclipse-将普通项目转成maven项目
categories: [eclipse]
tags: [post, maven, eclipse]
date: 2018-07-28 04:40:49 +8
place: 新大陆软件园
editdate: 2021-12-08 04:40:49 +8
eidtplace: 福州软件园
excerpt: eclipse, maven
description: eclipse-将普通项目转成maven项目
catalog: true
author: 林兴洋
---



在eclipse中创建maven项目很简单，但有时候，创建maven项目老是失败，我们可以先创建普通项目，然后将其转成mavne项目在eclipse中

* 1、建一个普通项目
* 2、建pom.xml，定义好构件 
* 3、项目右键菜单，Configure -> Convert to Maven Project 
* 4、注意这些目录和文件不要加入版本控制：.settings, target, .classpath, .project 

但是在myeclipse中，右键没有Configure菜单项，所以我们通过如下路径，勾选 WTP Deprecated则会出现Configure菜单项，接着步骤就和eclipse一样了。

```
Window > Preferences > General > Capabilities > Advanced > MyEclipse Standard Tools > 勾选 WTP (Deprecated).
```