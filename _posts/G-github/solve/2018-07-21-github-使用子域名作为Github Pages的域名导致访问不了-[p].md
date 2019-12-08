---
layout: post
permalink: /:year/86f24da1daa848c7b3b0d1634a39635f
title: 2018-07-21-github-使用子域名作为Github Pages的域名导致访问不了
categories: [github]
tags: [git,github]
excerpt: github,子域名,Github Pages
description: github-使用子域名作为Github Pages的域名导致访问不了
catalog: false
author: 林兴洋
---

稍早，把自己在github上面的博客的域名改了。

本来是使用 linxingyang.net，但是这个域名我想用作别处
所以把github中对应的域名改为  blog.linxingyang.net

前面的时候还访问的好好的，这几天突然访问不了了。

* blog.linxingyang.net
* linxingyang.github.io
* 对应的ip形式

都访问不了

但在cmd中使用ping命令，还是ping的通。这，就相当郁闷了。


郁闷中。。。。


百度了一下，看到一些解答说可能github那边刚好我对应仓库的服务器崩了，
导致访问不了，过几天就好了。我想可能是这个原因，也就不着急了，等几天看看。

但过了几天，还是访问不了，就到gitbub上linxingyang.github.io这个库的settings，发现里面有个警告（可能我们程序员容易忽略警告= =，因为错误才意味着你的程序无法运行，警告还不至于怎么样。刚开始我也认为一个警告应该不足以导致访问不了，但想想某本书上叫我们不要忽略警告，就想着把这个警告解决一下），这个警告大致意思是：您使用的是一个子域名blog.linxingyang.net，您的DNS服务使用的是A record来指向[YourGithubName].github.io，但我们建议使用您使用CNAME record 来指向 [YourGithubName].github.io。

看到这我想起我用的是A record，即ip形式（192.168.1.1这样的）。然后屁颠屁颠跑到阿里云控制台，
进去把这条记录改成CNAME record ，如下图

![图](http://image.linxingyang.net/image/G-github/image/2018-07-21/01.png)

从类似上面的A record（记录值为ip形式），改成下面的CNAME（记录值为域名形式）


过了一会，再刷新linxingyang.github.io的settings页面，原先的警告已经不在了，变成了如下红框内的提示。接着访问了一下blog.linxingyang.net，哎呀，可以了~~~。

![图](http://image.linxingyang.net/image/G-github/image/2018-07-21/02.png)
