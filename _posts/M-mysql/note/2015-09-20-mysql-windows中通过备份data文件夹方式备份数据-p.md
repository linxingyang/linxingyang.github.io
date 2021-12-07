---
layout: post
permalink: /:year/d82539d76f8245f4b9fd25494dfeb872/index
title: mysql-windows中通过备份data文件夹方式备份数据
categories: [mysql]
tags: [post, mysql, windows]
date: 2015-09-20 00:19:28 +8
place: 福建工程学院
editdate: 2021-12-04 00:19:28 +8
eidtplace: 福州软件园
excerpt: sql,mysql,备份,mysql数据库备份
description: mysql备份数据库，备份data文件夹
catalog: true
author: 林兴洋
---

# windows中备份mysql数据库

直接备份data文件夹的方式备份mysql数据库，该方法比较适合要重装mysql前进行备份mysql数据库。

## 1、备份数据

找到如下路径，如果是默认安装会在如下路径

* data 文件夹中就是数据库中的数据，直接将整个data文件夹进行备份
* my.ini 是配置文件

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mysql/image/2015-09-20/01.png)


## 2、重新安装mysql之后，通过设置datadir指向我们备份的data文件夹

打开my.ini ，其中datadir指示的是数据的目录，可以通过更改该路径切换数据库。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mysql/image/2015-09-20/02.png)






