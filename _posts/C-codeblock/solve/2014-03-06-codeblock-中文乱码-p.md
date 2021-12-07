---
layout: post
permalink: /:year/0a4926e9dd684d038e9b9fb5cc22c326/index
title: codeblock-中文乱码
categories: [codeblock]
tags: [post, codeblock]
date: 2014-03-06 02:32:26 +8
place: 福建工程学院
editdate: 2021-11-29 02:32:26 +8
eidtplace: 福州软件园
excerpt: codeblock,中文乱码
description: codeblock-中文乱码
catalog: false
author: 林兴洋
---

* 1、第一步 settings -> editor -> General settings ->others settings ->   Encoding一项选择 WINDOWS-936

* 2、第二步 settings ->complier settings -> Global compiler settings -> Others options 选项卡中输入以下内容
```
-fexec-charset=GBK
-finput-charset=WINDOWS-936
```
