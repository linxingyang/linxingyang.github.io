---
layout: post
permalink: /:year/0a4926e9dd684d038e9b9fb5cc22c326
title: 2014-03-06-codeblock-中文乱码
categories: [codeblock]
tags: [codeblock,问题解决,中文乱码]
excerpt: codeblock,问题解决,中文乱码
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


