---
layout: post
permalink: /:year/bb97ax6f894d42aaab09bc92c3785fcs
title: 2015-03-25-java-windows下的bat文件快速运行编译java代码
categories: [编程]
tags: [java]
excerpt: java-windows下的bat文件快速运行编译java代码
description: java-windows下的bat文件快速运行编译java代码
gitalk-id: bb97ax6f894d42aaab09bc92c3785fcs
toc: true
---

以下内容 新建一个文本文件后，贴入以下代码，修改文件后缀 txt为 bat； 文件名随便起。
使用：在txt中写完java代码后，将此txt文件拖入.bat文件中即可编译运行

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
将 Test.txt 拖入 java编译运行.bat即可