---
layout: post
permalink: /:year/d1763c9f6a3a40288822e763daa2b7oo/index
title: 2017-06-17-openfire-安装
categories: [openfire]
tags: [openfire,xmpp]
excerpt: openfire,安装
description: openfire安装过程
catalog: true
author: 林兴洋
---

# openfire安装

## 下载openfire安装版

这里演示的是安装版： openfire_4_1_4.exe

## 下一步

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard2.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard2.png)

## 接受协议

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard2.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard3.png)


## 安装目录

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard3.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard14.png)


## 点击安装

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard.png)

## 启动

安装完成后，桌面会多一个openfire的图标，点击启动。

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard6.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard6.png)


## 点击Launch Admin 访问控制台。

点击上图中的 Launch Admin 访问控制台，第一次访问需要进行一些配置

选择中文

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard8.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard8.png)

## 设置域

可任意设置域

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard9.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard9.png)

## 配置数据库

数据库连接，可以使用内置数据库，也可以用sql，但还是比较习惯用外置的，这里用的是mysql

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard15.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard15.png)

## 创建mysql数据库

在配置数据库前，先在mysql中创建一个数据库，作为openfire的数据库。
新建了一个数据库名叫： openfire

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard16.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard16.png)

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard13.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard13.png)

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard11.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard11.png)

## 填入数据库配置

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard7.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard7.png)

## 点击继续

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard12.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard12.png)

## 配置管理员密码

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard5.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard5.png)

## 登录到控制台

安装完成 登录到控制台

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard4.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard4.png)

输入刚刚设置的密码

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard1.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard1.png)

进入控制台后

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard10.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/O-openfire/image/2017-06-17/clipboard10.png)
