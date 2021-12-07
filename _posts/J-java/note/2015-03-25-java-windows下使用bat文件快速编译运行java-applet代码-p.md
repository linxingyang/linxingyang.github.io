---
layout: post
permalink: /:year/bb97ax6f894d42aaab09bc92c3785fcs/index
title: java-windows下使用bat文件快速编译运行java-applet
categories: java
tags: [post, java, windows]
date: 2015-03-25 10:43:37 +8
place: 福建工程学院
editdate: 2021-12-03 10:43:37 +8
eidtplace: 福州软件园
excerpt: java, windows,bat,applet
description: java-windows下使用bat文件快速编译运行java-applet
catalog: true
author: 林兴洋
---

# Java

## 石器年代

在使用IDE之前，当年手撸Java代码流程
* 编写的都是一个Test.txt文件，
* 需要改名为Test.java，
* 然后用javac命令编译Test.java生成Test.class，
* 最后用java命令运行Test.class。

现在也要念着IDE的好处啊，save life。但也不能忘了如何手动编译。= =。

## 改成bat方式

改成使用bat文件的方式完成这一流程。

创建一个Compile.bat文件，内容如下：
```bat
@copy %~n1.txt %~n1.java
@ECHO 编译 .java文件...
@javac %~n1.java
@ECHO 运行 .class文件...
@ECHO --------------------------------------------------
@java %~n1
@ECHO --------------------------------------------------
pause
```

在txt中写完java代码后

![1](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/J-java/image/2014/2014-01-03/01.png)

将Test.txt拖入Compile.bat即可编译运行，运行结果如下

![2](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/J-java/image/2014/2014-01-03/02.png)

## applet

下面这一段是快速编译运行applet的。

```
@copy %~n1.txt %~n1.java
@ECHO 编译 .java文件...
@javac %~n1.java
@ECHO 运行 .class文件...
@ECHO --------------------------------------------------
@appletviewer %~n1.html
@ECHO --------------------------------------------------
pause
```


