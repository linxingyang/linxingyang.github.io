---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab4d2agg
title: 2016-03-23-tomcat-eclipse中找不到class-未部署
categories: [问题解决,java,eclipse,tomcat]
tags: [问题解决,java,tomcat,eclipse,未部署]
excerpt: myeclipse,tomcat找不到class,未部署
description: myeclipse,tomcat找不到class,未部署

---

[TOC "z-index:10000;right:0px;position:fixed;overflow-y: scroll;height: 500px;top: 0px; width: 400px"]

# tomcat找不到class未部署 #

## 故障:在打开Tomcat的情况下，访问不到类。 ##

## 原因,没有部署 ##

因为我刚开始学习JSP的时候，是将myeclipse的工作空间
直接设置到了`tomcat\webapps`下，这样呢，JSP可以
访问的到，但是因为没有部署，所以在src目录下的.java类
并没有经过编译并且发送到 WEB-INF\classes 目录下，导致了错误

## 解决 ##
### 新建一个目录，将你的项目移到这个文件夹下。 ###
![http://image.linxingyang.net/image/note/2017-03-23-tomcat/01.png](http://image.linxingyang.net/image/note/2017-03-23-tomcat/01.png)

2017-03-23-tomcat

### 改变myclipse的工作空间到上面的路径   ###
![http://image.linxingyang.net/image/note/2017-03-23-tomcat/02.png](http://image.linxingyang.net/image/note/2017-03-23-tomcat/02.png)

### 使用Import导入项目LYB， ###
![http://image.linxingyang.net/image/note/2017-03-23-tomcat/03.png](http://image.linxingyang.net/image/note/2017-03-23-tomcat/03.png)
![http://image.linxingyang.net/image/note/2017-03-23-tomcat/04.png](http://image.linxingyang.net/image/note/2017-03-23-tomcat/04.png)
![http://image.linxingyang.net/image/note/2017-03-23-tomcat/05.png](http://image.linxingyang.net/image/note/2017-03-23-tomcat/05.png)


###  配置Tomcat 6.x，也可以使用Myeclipse自带的tomcat，配置过程省略。 ###
![http://image.linxingyang.net/image/note/2017-03-23-tomcat/06.png](http://image.linxingyang.net/image/note/2017-03-23-tomcat/06.png)


### 点击最左边的这个按钮进入部署 ###
![http://image.linxingyang.net/image/note/2017-03-23-tomcat/07.png](http://image.linxingyang.net/image/note/2017-03-23-tomcat/07.png)

### 选择要部署的项目，点击Add，选中 Tomcat 6.x，点Finish退出 ###

![http://image.linxingyang.net/image/note/2017-03-23-tomcat/08.png](http://image.linxingyang.net/image/note/2017-03-23-tomcat/08.png)
![http://image.linxingyang.net/image/note/2017-03-23-tomcat/09.png](http://image.linxingyang.net/image/note/2017-03-23-tomcat/09.png)
![http://image.linxingyang.net/image/note/2017-03-23-tomcat/10.png](http://image.linxingyang.net/image/note/2017-03-23-tomcat/10.png)

### 此时myeclipse就会将你的项目发到Tomcat目录下。 ###
![http://image.linxingyang.net/image/note/2017-03-23-tomcat/11.png](http://image.linxingyang.net/image/note/2017-03-23-tomcat/11.png)

###  然后启动服务就可以访问到了。###


