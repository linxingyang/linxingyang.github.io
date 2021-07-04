---
layout: post
permalink: /:year/7ee1888d047f4edebd44d7e23a4d34cd/index
title: 2020-05-08-openvpn-openvpn一直处于ASSIGN_IP状态
categories: [openvpn]
tags: [openvpn]
relative-tags: [openvpn]
excerpt: openvpn,ASSIGN_IP
description: openvpn一直处于ASSIGN_IP状态
catalog: false
---

在一台win10 64位专业版的windows上出现了openvpn启动后一直处于ASSIGN_IP的状态。

检查发现是以管理员权限运行openvpn的没有理由不能给虚拟网卡设置IP啊。在其它机器测了没有这个问题。


最后找到的解决方法：

1,按win键-->输入cmd-->右键管理员权限运行.

2,在命令行窗口输入下面两行，
```
netsh winsock reset catalog
netsh int ipv4 reset reset.log
```

3,然后重启电脑即可。
