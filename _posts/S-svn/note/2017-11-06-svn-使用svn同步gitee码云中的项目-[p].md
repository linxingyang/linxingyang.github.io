---
layout: post
permalink: /:year/4c2a681fcb4e4114be84d1f5a774f494
title: 2017-11-06-svn-使用svn同步gitee码云中的项目
categories: [工具]
tags: [svn,gitee]
excerpt: 问题解决,svn,gitee,码云
description: 使用svn同步码云(gitee)中的项目
gitalk-id: 4c2a681fcb4e4114be84d1f5a774f494
toc: true
---

# 使用svn同步码云中的项目

## 创建码云账号 

[https://gitee.com/](https://gitee.com/)

## 下载个svn客户端并安装

安装客户端版本的svn即可。

## 用svn客户端从码云上导出我们的项目，SVN连接如下获得。

![图](http://image.linxingyang.net/image/S-svn/image/2017-11-06/getSvnLinkk.png)


## 导出我们的项目

### 装完svn，右键有个浏版本库， 
    
![图](http://image.linxingyang.net/image/S-svn/image/2017-11-06/svnBroswerVersionn.png)

### 复制刚刚那个链接，然后用码云的账号登录

![图](http://image.linxingyang.net/image/S-svn/image/2017-11-06/export66.png)

### 右键检出

![图](http://image.linxingyang.net/image/S-svn/image/2017-11-06/export33.png)

### 导出到指定文件夹

![图](http://image.linxingyang.net/image/S-svn/image/2017-11-06/export44.png)

### 导出成功

![图](http://image.linxingyang.net/image/S-svn/image/2017-11-06/export55.png)

## 提交新文件

![图](http://image.linxingyang.net/image/S-svn/image/2017-11-06/uploadd.png)

### 码云中能够看到提交上去的文件

![图](http://image.linxingyang.net/image/S-svn/image/2017-11-06/seeGitt.png)
