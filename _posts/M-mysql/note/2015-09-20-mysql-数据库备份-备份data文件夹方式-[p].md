---
layout: post
permalink: /:year/d82539d76f8245f4b9fd25494dfeb872
title: 2015-09-20-mysql-数据库备份-备份data文件夹方式
categories: [mysql]
tags: [数据库,mysql,sql]
excerpt: sql,mysql,备份,mysql数据库备份
description: mysql备份数据库，备份data文件夹
catalog: true
author: 林兴洋
---

直接备份data文件夹的方式备份mysql数据库。该方法适合要重装mysql前进行备份mysql数据库。

# 1

找到如下路径，如果是默认安装会在如下路径

* data 文件夹中就是数据库中的数据
* my.ini 是配置文件

![图](http://image.linxingyang.net/image/M-mysql/image/2015-09-20/01.png)

# 2

打开my.in ，其中  datadir指示的是数据的目录。可以通过更改该路径切换数据库。。。

![图](http://image.linxingyang.net/image/M-mysql/image/2015-09-20/02.png)

# 3

我们可以直接复制data文件夹进行备份。后面重新安装完mysql之后，再次载入这个目录。
