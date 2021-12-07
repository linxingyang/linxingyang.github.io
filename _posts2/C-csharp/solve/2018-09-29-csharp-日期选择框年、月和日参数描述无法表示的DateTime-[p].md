---
layout: post
permalink: /:year/e0e942079b25429b9187e4b77632bba6/index
title: 2018-09-29-csharp-日期选择框年、月和日参数描述无法表示的DateTime
categories: [csharp]
tags: [csharp,日期,选择框]
excerpt: csharp,日期,选择框
description: 日期选择框年、月和日参数描述无法表示的DateTime
catalog: true
author: 林兴洋
---



错误： ArgumentOutOfRangeException， 年、月和日参数描述无法表示的DateTime。



这几天在做一个C#的项目，里面有个日期范围选择按钮，需求是只能选择年月，如下：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2018-09-29/01.png)

在控件属性中对其进行如下的设置

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2018-09-29/02.png)


结果今天运行的，点击输入2月， 结果程序直接崩了，

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2018-09-29/03.png)



科学了一下，原来是这个原因

> 假如当前日期为2012年03月30日。当输入2月的时候，虽然年月日的日没有显示，但是实际存在，但是2月份没有30号，所以会报错。把日期设置为每月的第一天问题就解决啦。

看了一下今天的日期是9月29，MMP，恍然大悟，这控件太不人性了。。。 这东西没有考虑到。





过程中还碰到一个坑，当选择的月份是 12月，要获得下个月的日期，如下图

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2018-09-29/04.png)

使用AddMonth(1)没有问题。而使用new DateTime()的形式，就会因为 12+1=13，没有13月，所以就报错了。 他不会把13转成1，然后前面的年再加1，（这头猪脑筋不会急转弯）。

不过这样做也有好处吧，防止一些错误的值被设置吧。

但这种地方报错着实不爽。



## 参考

* [参考](https://blog.csdn.net/qq1010726055/article/details/7411729)