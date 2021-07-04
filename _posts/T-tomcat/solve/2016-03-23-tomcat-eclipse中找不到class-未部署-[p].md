---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab4d2agg/index
title: 2016-03-23-tomcat-eclipse中找不到class-未部署
categories: [tomcat]
tags: [java,tomcat,eclipse]
excerpt: myeclipse,tomcat找不到class,未部署
description: myeclipse,tomcat找不到class,未部署
catalog: true
author: 林兴洋
---

# tomcat找不到class未部署

## 故障:在打开Tomcat的情况下，访问不到类。

## 原因,没有部署

因为我刚开始学习JSP的时候，是将myeclipse的工作空间
直接设置到了`tomcat\webapps`下，这样呢，JSP可以
访问的到，但是因为没有部署，所以在src目录下的.java类
并没有经过编译并且发送到 WEB-INF\classes 目录下，导致了错误

## 解决

### 新建一个目录，将你的项目移到这个文件夹下。

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/01.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/01.png)

### 改变myclipse的工作空间到上面的路径

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/02.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/02.png)

### 使用Import导入项目LYB

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/03.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/03.png)

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/04.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/04.png)

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/05.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/05.png)

###  配置Tomcat 6.x，也可以使用Myeclipse自带的tomcat，配置过程省略。

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/06.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/06.png)

### 点击最左边的这个按钮进入部署

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/07.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/07.png)

### 选择要部署的项目，点击Add，选中 Tomcat 6.x，点Finish退出

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/08.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/08.png)

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/09.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/09.png)

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/10.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/10.png)

### 此时myeclipse就会将你的项目发到Tomcat目录下。

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/11.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-tomcat/image/2017-03-23/11.png)

### 然后启动服务就可以访问到了
