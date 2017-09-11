---
layout: post
permalink: /:year/d82539d76f8245f4b9fd25494dfeb872
title: mysql数据库备份（备份 data文件夹）
categories: [数据库]
tags: [sql,mysql,备份,mysql数据库备份]
excerpt: sql,mysql,备份,mysql数据库备份
description: sql,mysql,备份,mysql数据库备份
---


[TOC]

直接备份data文件夹的方式备份mysql数据库。

该方法适合要重装mysql前进行备份mysql数据库。



---
# 1 #
找到如下路径，如果是默认安装会在如下路径

* data 文件夹中就是数据库中的数据
* my.ini 是配置文件

![http://note.youdao.com/yws/public/resource/744235b40c5391940db2eaf218a9c1be/xmlnote/3EF05C59F93A47F885DC88F40633AD9F/59643](http://note.youdao.com/yws/public/resource/744235b40c5391940db2eaf218a9c1be/xmlnote/3EF05C59F93A47F885DC88F40633AD9F/59643)

# 2 #
打开my.in ，其中  datadir指示的是数据的目录。

可以通过更改该路径切换数据库。。。

![http://note.youdao.com/yws/public/resource/744235b40c5391940db2eaf218a9c1be/xmlnote/7262BA5692B343D29B7F93116560A326/59644](http://note.youdao.com/yws/public/resource/744235b40c5391940db2eaf218a9c1be/xmlnote/7262BA5692B343D29B7F93116560A326/59644)


# 3 #

我们可以直接复制data文件夹进行备份。
后面重新安装完mysql之后，再次载入这个目录。



