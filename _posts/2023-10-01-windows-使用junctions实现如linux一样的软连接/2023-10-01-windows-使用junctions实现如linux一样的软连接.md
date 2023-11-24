---
layout: post
comments: true
title: windows-使用junctions实现如linux一样的软连接
description: 
published: true
date: 2023-11-22T09:53:06.157Z
tags:
  - R02/日记
  - windows
editor: markdown
dateCreated: 2023-10-01T09:53:06.157Z
location:
comments: true
toc: true
---




在windows，如果对一个文件夹右键创建快捷方式，进入文件夹后，再进入子文件夹就会跳到原路径。

比如`d:\the\real\path\dir1\a.txt`，创建快捷方式`d:\quicklink` 指向 `d:\the\real\path`，进入`d:\quicklink`是没问题的，但再进入`d:\quicklink\path`，就会变成`d:\the\real\path`

这个时候可以用到这个junctions工具，下载地址在参考[1]，如何使用参考[2]、[3]


```
语法：
ln -s 目标文件/目标文件夹 源文件/源文件夹

ln -s d:\linxingyang\note d:\linxy_everywhere
ln -s d:\linxingyang\workspace\wecon-2022-09-22-Hmi_Cloud D:\linxingyang_repo\mirror\wecon\wecon-2022-09-22-Hmi_Cloud
```

# 参考
1、[交接点 - Sysinternals | Microsoft Learn](https://learn.microsoft.com/zh-cn/sysinternals/downloads/junction)

2、[Creating Symbolic Links (Symlinks) in Windows](https://woshub.com/create-symlink-windows/)

3、[window下实现软连接，像linux一样的软链接_windows有没有像linux一样的软连接-CSDN博客](https://blog.csdn.net/zhanlanmg/article/details/44194103)
