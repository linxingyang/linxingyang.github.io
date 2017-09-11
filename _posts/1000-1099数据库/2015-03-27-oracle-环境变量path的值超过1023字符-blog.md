---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab4d2a6f
title: oracle环境变量path的值超过1023字符，无法设置改值
categories: [数据库]
tags: [oracle,软件安装,错误]
excerpt: oracle,软件安装,错误
description: oracle,软件安装,错误
---

[TOC]

# 问题：环境变量path的值超过1023字符，无法设置改值 #



![http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/19B6824A43924B88AC0075B85FF4AB6C/59706](http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/19B6824A43924B88AC0075B85FF4AB6C/59706)


# 解决步骤 #

## 1 ##

WIN7  我的电脑--》右键属性--》高级系统设置--》选择 高级选项卡
--》点击 环境变量 --》 在系统变量中找到 path 

![http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/11C88532C7F6452D84C8D89ECAF1C722/59707](http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/11C88532C7F6452D84C8D89ECAF1C722/59707)

![http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/7D804E4AC0CA4491A260C7E098FD45D7/59709](http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/7D804E4AC0CA4491A260C7E098FD45D7/59709)


## 2 ##

小心点这步，别把变量值搞没了，把将变量值 剪切出来，放
到新建文件本里面，然后copy一小段放回去，（因为path
不允许没有值）

![http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/0408AABB92EF4180A1BED9FF662818BF/59708](http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/0408AABB92EF4180A1BED9FF662818BF/59708)

## 3 ##

点击重试，就可以继续了

![http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/3EC8BDF382374B99A59818C6A6CC987A/59704](http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/3EC8BDF382374B99A59818C6A6CC987A/59704)



## 4 ##

完成安装后，再将path的变量值复制出来

会发现多了这段：
```
C:\oracle\product\10.2.0\db_2\bin;
```
把增加的这部分复制到下面那个大块里去，然后把path的变量值清空，将大块的值复制到path变量中。

![http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/14359667013440C38B4C466DDDE09358/59705](http://note.youdao.com/yws/public/resource/03f895611ee8ebdf3a2a706aaa14595c/xmlnote/14359667013440C38B4C466DDDE09358/59705)

