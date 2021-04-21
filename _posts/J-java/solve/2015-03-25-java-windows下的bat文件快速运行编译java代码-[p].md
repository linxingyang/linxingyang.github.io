---
layout: post
permalink: /:year/bb97ax6f894d42aaab09bc92c3785fcs/index
title: 2015-03-25-java-windows下的bat文件快速运行编译java代码
categories: [java]
tags: [java,编译]
excerpt: java,windows,编译
description: java-windows下的bat文件快速运行编译java代码
catalog: false
author: 林兴洋
---


常用文本编辑器编写Java代码，
* 编写的都是一个Foo.txt文件，
* 需要改名为Foo.java，
* 然后用javac命令编译Foo.java生成Foo.class，
* 最后用java命令运行Foo.class。

下面直接用一个bat脚本来完成上面步骤，创建一个Compile.bat文件，内容如下：
```bat
@ECHO txt -> java
@copy %~n1.txt %~n1.java
@ECHO java -> class
@javac %~n1.java
@ECHO run class
@ECHO --------------------------------------------------
@java %~n1
@ECHO --------------------------------------------------
pause
```

这样在编写完Foo.txt之后，直接拖入到Compile.bat文件中就可以完成上面步骤了。

