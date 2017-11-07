---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab4d2a6f
title: 2015-03-27-环境变量path的值超过1023字符，无法设置改值
categories: [问题解决]
tags: [数据库,oracle,软件安装,错误]
excerpt: oracle,软件安装,错误
description: oracle,软件安装,错误
---

[TOC]

# 问题：环境变量path的值超过1023字符，无法设置改值 #



![http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-27-oracle/01.png](http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-27-oracle/01.png)


# 解决步骤 #

## 1 ##

WIN7  我的电脑--》右键属性--》高级系统设置--》选择 高级选项卡
--》点击 环境变量 --》 在系统变量中找到 path 

![http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-27-oracle/02.png](http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-27-oracle/02.png)

![http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-27-oracle/03.png](http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-27-oracle/03.png)

## 2 ##

小心点这步，别把变量值搞没了，把将变量值 剪切出来，放
到新建文件本里面，然后copy一小段放回去，（因为path
不允许没有值）

![https://github.com/linxingyang/images/blob/master/1003-oracle-002/04.png?raw=true](https://github.com/linxingyang/images/blob/master/1003-oracle-002/04.png?raw=true)

## 3 ##

点击重试，就可以继续了

![https://github.com/linxingyang/images/blob/master/1003-oracle-002/05.png?raw=true](https://github.com/linxingyang/images/blob/master/1003-oracle-002/05.png?raw=true)



## 4 ##

完成安装后，再将path的变量值复制出来

会发现多了这段：
```
C:\oracle\product\10.2.0\db_2\bin;
```
把增加的这部分复制到下面那个大块里去，然后把path的变量值清空，将大块的值复制到path变量中。

![http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-27-oracle/06.png](http://oyqsej5zi.bkt.clouddn.com/image/note/2015-03-27-oracle/06.png)
