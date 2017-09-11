---
layout: post
permalink: /:year/a57166ac481f42d49a831f17e2fffd5d
title: oracle启动后一闪而过
categories: [数据库]
tags: [oracle,错误,软件]
excerpt: oracle,一闪而过
description: oracle,一闪而过
picUrl: images\public\1002\003
---

[TOC]

## 问题 启动后，一闪而过，或者进入安装主界面后也是一闪而过，非兼容性引起 ##

![http://note.youdao.com/yws/public/resource/f42b41d5c3252e4e90510e738ec7edcf/xmlnote/55CAA30CB54D44F18F4911D0A73CB1E7/59735](http://note.youdao.com/yws/public/resource/f42b41d5c3252e4e90510e738ec7edcf/xmlnote/55CAA30CB54D44F18F4911D0A73CB1E7/59735)


## 原因：可能是因为有两个图形处理器的原因 ##

![http://note.youdao.com/yws/public/resource/f42b41d5c3252e4e90510e738ec7edcf/xmlnote/8A3BF4BEE28E4F2D83132B5D94EB18CF/59737](http://note.youdao.com/yws/public/resource/f42b41d5c3252e4e90510e738ec7edcf/xmlnote/8A3BF4BEE28E4F2D83132B5D94EB18CF/59737)


## 解决方法 ##

就在nvidia控制面板3D设置里把默认首选图形处理器设置选成高性能nvidia处理器了。我试着选集成图形，结果久违的图形界面真的出来了，居然是这个原因，我的天，折腾我这么久，我试着把3D设置改回默认的自动选择了，图形界面一样可以出来，原来用高性能显卡ORACLE的图形界面居然不能显示，这个，咋滴回事

![http://note.youdao.com/yws/public/resource/f42b41d5c3252e4e90510e738ec7edcf/xmlnote/C991C015BBAA4828A700A7ACE579AD2A/59736](http://note.youdao.com/yws/public/resource/f42b41d5c3252e4e90510e738ec7edcf/xmlnote/C991C015BBAA4828A700A7ACE579AD2A/59736)


--- 
参考博客地址：
[http://blog.csdn.net/trampwind/article/details/11203203](http://blog.csdn.net/trampwind/article/details/11203203)
