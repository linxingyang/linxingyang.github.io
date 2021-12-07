---
layout: post
permalink: /:year/4cxx9xxxx0274vsc8622d47e658vxdsd/index
title: 2018-04-12-jsp-jsp中session为什么可以分辨不同客户端
categories: [jsp]
tags: [java,jsp,session]
excerpt:  java,jsp,session,可以分辨不同客户端
description: java,jsp,session,可以分辨不同客户端
catalog: false
author: 林兴洋
---



虽然Session保存在服务器，对客户端是透明的，它的正常运行仍然需要客户端浏览器的支持。这是因为Session需要使用Cookie作为识别标志。HTTP协议是无状态的，Session不能依据HTTP连接来判断是否为同一客户，因此服务器向客户端浏览器发送一个名为JSESSIONID的Cookie，它的值为该Session的id（也就是HttpSession.getId()的返回值）。Session依据该Cookie来识别是否为同一用户。

该Cookie为服务器自动生成的，它的maxAge属性一般为–1，表示仅当前浏览器内有效，并且各浏览器窗口间不共享，关闭浏览器就会失效。

因此同一机器的两个浏览器窗口访问服务器时，会生成两个不同的Session。但是由浏览器窗口内的链接、脚本等打开的新窗口（也就是说不是双击桌面浏览器图标等打开的窗口）除外。这类子窗口会共享父窗口的Cookie，因此会共享一个Session。

注意：新开的浏览器窗口会生成新的Session，但子窗口除外。子窗口会共用父窗口的Session。例如，在链接上右击，在弹出的快捷菜单中选择“在新窗口中打开”时，子窗口便可以访问父窗口的Session。

如果客户端浏览器将Cookie功能禁用，或者不支持Cookie怎么办？例如，绝大多数的手机浏览器都不支持Cookie。Java Web提供了另一种解决方案：URL地址重写。就是在原来的URL地址后加上JSESSIONID。比如：

```
http://xxxx/a.jsp?JSESSIONID=xx
```



## 参考

* [https://www.cnblogs.com/zhouhbing/p/4204132.html](https://www.cnblogs.com/zhouhbing/p/4204132.html)