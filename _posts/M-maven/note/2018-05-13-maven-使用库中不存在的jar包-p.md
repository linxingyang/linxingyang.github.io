---
layout: post
permalink: /:year/linxingyangwriteat20211208043538/index
title: maven-使用库中不存在的jar包
categories: [maven]
tags: [post, maven]
date: 2018-05-13 04:35:38 +8
place: 新大陆软件园
editdate: 2021-12-08 04:35:38 +8
eidtplace: 福州软件园
excerpt: maven-使用库中不存在的jar包
description: maven-使用库中不存在的jar包
catalog: true
author: 林兴洋
---

要在maven中使用库中不存在的jar包。

* 1、首先下载jar包
* 2、通过maven命令将jar包安装到本地。

命令格式
```cmd
mvn install:install-file -Dfile="jar包的绝对路径" -Dpackaging="文件打包方式" -DgroupId=groupid名 -DartifactId=artifactId名 -Dversion=jar版本 
```

在有sqljdbc4.jar包的文件夹下，通过shift+右键的方式--》此处打开命令窗口，然后执行以下maven命令

```cmd
mvn install:install-file -Dfile=sqljdbc4.jar -Dpackaging=jar -DgroupId=com.microsoft.sqlserver -DartifactId=sqljdbc4 -Dversion=4.0
```
　　
* 3、在pom.xml中引入

```xml
<dependency>
    <groupId>com.microsoft.sqlserver</groupId>
    <artifactId>sqljdbc4</artifactId>
    <version>4.0</version>
</dependency>
```

