---
layout: post
permalink: /:year/e1dd8005822b4f539d9842044a3f47e2/index
title: 2020-04-10-openvpn-记一次Openvpn与西门子软件碰撞引发的断言错误
categories: [openvpn]
tags: [openvpn,断言错误,西门子]
relative-tags: [openvpn]
excerpt: openvpn,西门子,断言错误
description: 记一次Openvpn与西门子软件碰撞引发的断言错误
catalog: false
---


在技术部一些安装了西门子PLC软件的电脑上，启动openvpn穿透的时候，就会有这个问题。如图：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openvpn/image/2020-04-10/01.png)

上了西门子的官网去找解决方法（话说这个官网给我一种几十年前网站的感觉）


方法一：在services.msc中禁用西门子对应的两个服务：S7TraceserviceX 和 SIMATIC IEPG Help service两项服务

但是，这里我们用VPN就是为了穿透去远程PLC软件好吧，把这两个服务禁了，不就直接访问不了PLC软件了么，玩笑开大了。


方法二：启动控制面板，打开"set PG/PC"，然后取消LLDP/DCP 和 PNIO-Adapter 中所有的勾选框，接着重启。 这个方法，亲测无效。^ v ^

方法三：打开网络连接，把蓝牙、本地连接、无线连接属性里，把simatic ... 和profinet都勾除！不用禁止任何服务和进程，然后重启。

喏，就是这个东西，装了西门子的软件后，你网卡的属性页会多一些东西，就是这几个，把它勾选去掉即可。不过注意的是，不能把所有的网卡都取出勾选，就vpn的这个网卡去除勾选即可，我们这里几台机器验证了，这种是可行的。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openvpn/image/2020-04-10/02.png)


