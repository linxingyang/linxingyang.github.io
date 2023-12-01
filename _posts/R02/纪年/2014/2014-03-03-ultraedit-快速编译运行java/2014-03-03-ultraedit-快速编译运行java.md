---
layout: post
toc: true
title: ultraedit-快速编译运行java
description: 
published: true
date: 2014-03-03T14:28:31.157Z
tags: R02/日记
editor: markdown
dateCreated: 
location:
---

# 1、ue视图如下

![图](/R02/纪年/2014/2014-03-03-ultraedit-快速编译运行java/assets/01.jpeg)

# 2、配置java编译

在菜单栏中选择，高级->工具配置->插入

![图](/R02/纪年/2014/2014-03-03-ultraedit-快速编译运行java/assets/02.jpeg)

![图](/R02/纪年/2014/2014-03-03-ultraedit-快速编译运行java/assets/03.jpeg)

![图](/R02/纪年/2014/2014-03-03-ultraedit-快速编译运行java/assets/04.jpeg)

# 3、配置java运行

前面部分一样

![图](/R02/纪年/2014/2014-03-03-ultraedit-快速编译运行java/assets/05.jpeg)

# 4、如果乱码了

`javac %n%e`  本来只要这样设置，但是这样输出会乱码，再加上中间那部分输出英文不会乱码

![图](/R02/纪年/2014/2014-03-03-ultraedit-快速编译运行java/assets/06.jpeg)

# 5、如果要设置快捷键

想要如下效果：

![图](/R02/纪年/2014/2014-03-03-ultraedit-快速编译运行java/assets/07.jpeg)

配置过程：在高级->配置->键映射， 找到如图`AdvanceUserTool1` 和 `AdvanceUserTool2` ，将其改为你想要的快捷键。

![图](/R02/纪年/2014/2014-03-03-ultraedit-快速编译运行java/assets/08.jpeg)

# 6、个人配置 - 弹出DOS窗口

java运行设置成前面那样
* 1、中文乱码，这点很头疼
* 2、当要求与用户交互的时候，这样子没办法输入数据

勾选“显示DOS窗口”，这样的话就弹出DOS界面，可以解决上面两个问题

![图](/R02/纪年/2014/2014-03-03-ultraedit-快速编译运行java/assets/09.png)

