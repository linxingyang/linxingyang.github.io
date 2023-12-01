---
layout: post
title: codeblock-中文乱码
description: 
published: true
date: 2014-03-06T14:28:17.157Z
tags: R02/日记
editor: markdown
dateCreated: 
location:
---

* 1、第一步 settings -> editor -> General settings ->others settings ->   Encoding一项选择 WINDOWS-936

* 2、第二步 settings ->complier settings -> Global compiler settings -> Others options 选项卡中输入以下内容
```
-fexec-charset=GBK
-finput-charset=WINDOWS-936
```
