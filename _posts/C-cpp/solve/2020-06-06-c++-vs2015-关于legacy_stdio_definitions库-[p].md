---
layout: post
permalink: /:year/22c11cc145be47b5b439cd5e039c0488/index
title: 2020-06-06-c++-vs2015-关于legacy_stdio_definitions库
categories: [c++]
tags: [c,c++,关于legacy_stdio_definitions库]
excerpt: c++,c,关于legacy_stdio_definitions库,vs2015
description: vs2015-关于legacy_stdio_definitions库
catalog: false
---


今天在将一个VS2015的程序移植到VS2013的时候，发现这个程序依赖了一个legacy_stdio_definitions.lib 库，而VS2013却没有这个库。
```
LNK1104 cannot open file 'legacy_stdio_definitions.lib'
```

搜了一下，原因如下：


缺少 legacy_stdio_definitions.lib 包。这个是由于VS2015中将printf()和scanf()之类的方法改为内联函数。为了兼容用到了之前的printf()和scanf()的程序和库，所以创建了legacy_stdio_definitions.lib。在2015中引用这个库即可。

在低于VS2015版本的VS中打开这个程序时，直接删掉对于这个库的引用即可。

