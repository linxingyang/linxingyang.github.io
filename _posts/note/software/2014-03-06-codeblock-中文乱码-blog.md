---
layout: post
permalink: /:year/0a4926e9dd684d038e9b9fb5cc22c326
title: 2014-03-06-codeblock中文乱码
categories: [软件]
tags: [codeblock,软件错误]
excerpt: codeblock中文乱码
description: codeblock中文乱码
---

* 1）
settings -> editor -> General settings
->others settings ->   Encoding一项选择 WINDOWS-936

* 2)
settings ->complier settings -> Global compiler settings
-> Others options 选项卡 中输入以下内容
```
-fexec-charset=GBK
-finput-charset=WINDOWS-936
```


