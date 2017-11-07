---
layout: post
permalink: /:year/a57166ac481f42d49a831f17e2fffd5d
title: 2015-03-28-oracle-启动后一闪而过
categories: [问题解决]
tags: [oracle,错误,软件]
excerpt: oracle,一闪而过
description: oracle,一闪而过
picUrl: images\public\1002\003
---

[TOC]

## 问题 启动后，一闪而过，或者进入安装主界面后也是一闪而过，非兼容性引起 ##

![http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-28-oracle/01.png](http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-28-oracle/01.png)


## 原因：可能是因为有两个图形处理器的原因 ##

![http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-28-oracle/02.jpeg](http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-28-oracle/02.jpeg)



## 解决方法 ##

就在nvidia控制面板3D设置里把默认首选图形处理器设置选成高性能nvidia处理器了。我试着选集成图形，结果久违的图形界面真的出来了，居然是这个原因，我的天，折腾我这么久，我试着把3D设置改回默认的自动选择了，图形界面一样可以出来，原来用高性能显卡ORACLE的图形界面居然不能显示，这个，咋滴回事

![http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-28-oracle/03.jpeg](http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-28-oracle/03.jpeg)


--- 
参考博客地址：
[http://blog.csdn.net/trampwind/article/details/11203203](http://blog.csdn.net/trampwind/article/details/11203203)
