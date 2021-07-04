---
layout: post
permalink: /:year/86f24da1daa848c7b3b0d1634a3963ee/index
title: 2015-08-10-hibernate-hibernate找不到org.hibernate.Session类可能原因
categories: [hibernate]
tags: [hibernate]
excerpt: hibernate,org.hibernate.Session
description: hibernate找不到org.hibernate.Session类可能原因
catalog: false
author: 林兴洋
---

这个问题可能是因为，我们在直接使用 myeclipse自带的hibernate容器的时候，没有将其hibernate包导入到我们项目的WEB-INF下，如下图：

![图](https://img-blog.csdnimg.cn/img_convert/becb4949029c4ca1766dc85b996eead0.png)



可以把自动加包的给删掉（hibernate 3.2Axxxx  和  hibernate 3.2 core xxx 这两个都要删掉）然后

* 手动加包到lib
* 重新自动加包，然后如上图勾选，记得不要创建hibernate.cfg.xml以免覆盖

![图](https://img-blog.csdnimg.cn/img_convert/f6923cb6422dcbf425c9fce18e9500ff.png)

