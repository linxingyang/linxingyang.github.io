---
layout: post
permalink: /:year/f7d0cea0a1ee48e28f0eae17b394e1b6/index
title: 2018-09-11-linux-各种下载命令的区别-wget-yum-apt-get
categories: [linux]
tags: [linux,下载命令]
excerpt:  linux,下载命令,区别
description: linux,下载命令,wget,yum,apt-get
catalog: true
author: 林兴洋
---



# linux系统分类

一般来说linux系统基本上分两大类：
* 1 RedHat系列：Redhat、Centos、Fedora等
    * 1 常见的安装包格式 rpm 包，安装rpm包的命令是 “rpm -参数”
    * 2 包管理工具 yum
    * 3 支持tar包
* 2 Debian系列：Debian、Ubuntu等
    * 1 常见的安装包格式 deb 包，安装deb包的命令是 “dpkg -参数”
    * 2 包管理工具 apt-get
    * 3 支持tar包

所以再Ubuntu中不该用yum 该用apt-get。

## wget下载

wget 类似于迅雷，是一种下载工具，通过HTTP、HTTPS、FTP三个最常见的TCP/IP协议下载，并可以使用HTTP代理名字是World Wide Web”与“get”的结合。


```
使用wget加上下载地址，就可以下载指定的东西
wget http://download.redis.io/releases/redis-4.0.11.tar.gz
```

## yum安装

```
yum install tcl
```

rpm: 软件管理; redhat的软件格式 rpm     r=redhat  p=package   m=management。用于安装 卸载 .rpm软件

yum: 是redhat, centos 系统下的软件安装方式，基于Linux，全称为 Yellow dog Updater, Modified，是一个在Fedora和RedHat以及CentOS中的Shell前端软件包管理器，基于RPM包管理，能够从指定的服务器自动下载RPM包并且安装，可以自动处理依赖性关系，并且一次安装所有依赖的软件包。

串联下：

使用wget下载一个 rpm包, 然后用 rpm -ivh  xxx.rpm安装这个软件，嫌麻烦的话，就可以直接用  yum  install  sqoop 来自动下载和安装依赖的rpm软件。

## apt-get 安装

```
apt-get install tcl
```

apt-get是ubuntu下的一个软件安装方式，它是基于debain。



## 参考

* [网页链接](https://segmentfault.com/q/1010000013108975)

* [博客链接](https://blog.csdn.net/ziju125521/article/details/52575715)