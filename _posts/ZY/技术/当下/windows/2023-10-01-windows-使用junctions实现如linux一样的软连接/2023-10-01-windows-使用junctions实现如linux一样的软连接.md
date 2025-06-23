---
title: 
description: 
published: true
date: 2023-11-22T09:53:06.157Z
tags:
  - ZY/技术/windows
editor: markdown
dateCreated: 
location:
---

在windows，如果对一个文件夹右键创建快捷方式，进入文件夹后，再进入子文件夹就会跳到原路径。比如`d:\the\real\path\dir1\a.txt`
```
d:\quicklink -> d:\the\real\path // 创建快捷方式

cd d:\quicklink // 没问题
cd d:\quicklink\dir // 就变成 d:\the\real\path\dir1
```

要实现linux软连接的效果，可以用junctions工具，下载地址在参考[1]，如何使用参考[2]、[3]

语法：
```powershell
ln -s 目标文件/目标文件夹 源文件/源文件夹
ln -s d:\quicklink d:\the\real\path
```

我自己用这个工具来规划自己在windows中的固定工具文件夹（目标文件夹），但是源文件夹是可调整的。


# 参考

* 1、[junction download](https://learn.microsoft.com/zh-cn/sysinternals/downloads/junction)
* 2、[Creating Symbolic Links (Symlinks) in Windows](https://woshub.com/create-symlink-windows/)
* 3、[window下实现软连接，像linux一样的软链接_windows有没有像linux一样的软连接-CSDN博客](https://blog.csdn.net/zhanlanmg/article/details/44194103)
