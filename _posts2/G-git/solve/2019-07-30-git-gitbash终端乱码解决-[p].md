---
layout: post
permalink: /:year/89671ce9dfcd4acdbf8f8ac450c0b511/index
title: 2019-07-30-git-gitbash终端乱码解决
categories: [git]
tags: [git,乱码]
excerpt: git,gitbash,终端乱码解决
description: git-gitbash终端乱码解决
catalog: true
author: 林兴洋
---

# git bash 乱码问题

Windows的默认编码为GBK,Linux的默认编码为UTF-8，在Windows克隆linux中的库可能会有乱码这些问题。

## git bash 终端乱码问题

在git bash 命令行窗口右键->options->Text-> 找到右侧locale下拉框选择 zh_CN，另一个Character set 下拉框找到utf8，点击apply即可。

如果utf8还乱码，可能Linux终端本身就不是设置utf8的。可以再选择character set下拉框，选择gbk或者其它编码进行尝试，也可以改变终端的编码，参看linux笔记修改终端编码。


## git log/git status 乱码

界面上显示数字

```
274\232\350\200\273\347\273\256\256\346
```

在bash提示符下输入：

```
git config --global core.quotepath false
```

若还是乱码：

```
LANG=zh_CN.UTF-8
```

若还是乱码：

```
git config --global gui.encoding UTF-8
git config --global i18n.logoutputencoding UTF-8
```
