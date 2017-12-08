---
layout: post
permalink: /:year/627df980b17e475bbed4027db194dc37
title: 2017-11-06-linux-解决vi中backspace无法删除字符
categories: [问题解决,vi,linux]
tags: [问题解决,vi,linux]
excerpt: linux,解决vi中backspace无法删除字符
description: linux解决vi中backspace无法删除字符

---

[TOC "z-index:10000;right:0px;position:fixed;overflow-y: scroll;height: 500px;top: 0px;"]


## 转载 ##

最近在学linux的vi编辑器，结果 backspace 不能删老不习惯里。百度了一下，下面这个可以用。

Ubuntu的vi不支持方向键和退格键，所以要想加入这些功能配置如下：

```

vi /etc/vim/vimrc.tiny
将 set compatible 
改为set nocompatible
加入一句：set backspace=2

```