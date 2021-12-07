---
layout: post
permalink: /:year/431c7db254664c329cce301a1d72168f/index
title: oracle-windows中安装oracle
categories: [oracle]
tags: [post, oracle, windows]
date: 2015-03-11 10:35:48 +8
place: 福建工程学院
editdate: 2021-12-03 10:35:48 +8
eidtplace: 福州软件园
excerpt: oracle,windows,oracle,安装
description: oracle-windows中安装oracle
catalog: true
author: 林兴洋
---


# 安装oracle


这是当年Oracle的安装过程了，现在应该大不同了吧，也许久没碰oracle数据库了  -- 2020-10-28 18:50



## 1、选择数据包

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-oracle/image/2015-03-11/01.png)

下载安装包

* database 如果安装数据库服务器的话肯定需要安装database了，我们一般是装这个
* clicnet 如果你要连接远程的服务器，而不想在本地安装oracle服务器，就可以安装client
* clusterware是集群软件，也就是做oracle rac才能用到

## 2、安装

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-oracle/image/2015-03-11/02.png)

* 如果是xp直接点击setup
* 如果是win7,win8安装包解压完，右键setup.exe选择“属性”，在“兼容性”一项中如下选择：



![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-oracle/image/2015-03-11/03.png)

然后安装的时候就是密码第一个字符不能是数字，其他没有什么要注意的了，就是下一步什么之类的。



## 安装过程中碰到的错误

* [2015-03-27-oracle-环境变量path的值超过1023字符，无法设置改值](/2015/8b072ff2a1da49c2be51643cab4d2a6f)

* [2015-03-28-oracle-启动后一闪而过](/2015/a57166ac481f42d49a831f17e2fffd5d)