---
layout: post
permalink: /:year/905257ae2c16434bae326d58aae9e81f
title: 2018-07-25-github-如何在Github上面创建Release
categories: [工具]
tags: [github,git]
excerpt:  github-如何在Github上面创建Release
description: github-如何在Github上面创建Release
gitalk-id: 905257ae2c16434bae326d58aae9e81f
toc: true
---

自己的个人网站要发布1.1版本，看别的Github项目都有一条类似timeline(时间线)的版本列表，如下

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/15.png)

所以在Github上面摸索了一下，弄好了记录一下。


在项目的页面，如下当前有6个文件，点击release

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/01.png)

点击右侧创建一个release

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/02.png)


填写一些内容，为了方便介绍，我这里写了TestBefore作为Release版本，通常我们使用v1.1、v2这样的版本号。最后点击publish release发布版本

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/03.png)


然后我本地提交一个新文件上去

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/04.png)


此时可以看到后面那个新上传的文件，然后再进入release界面

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/05.png)



然后我们再创建一个新release

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/06.png)


新release版本号为TestAfter

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/07.png)

发布完成后

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/08.png)


然后我们下载TestBefore和TestAfter的source Code

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/09.png)


通过对比下载的源码，可以看到TestAfter版本中多了后面传上去的after.txt文件。

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/10.png)



切记，不能去更新过往版本的release，否则会被更新成最新的内容。

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/11.png)


比如我把after.txt和text.txt删去。

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/14.png)


然后我把TestBefore改成TestBefore2

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/12.png)


再次下载其Source Code，结果发现after.txt和text.txt没了。所以，一旦一个版本发布以后，update要小心。。。

![图](http://image.linxingyang.net/image/G-github/image/2018-07-25/13.png)

