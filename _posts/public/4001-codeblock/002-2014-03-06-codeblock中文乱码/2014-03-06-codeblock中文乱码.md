---
layout: post
permalink: codeblock-wrong-002
title: codeblock中文乱码
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


