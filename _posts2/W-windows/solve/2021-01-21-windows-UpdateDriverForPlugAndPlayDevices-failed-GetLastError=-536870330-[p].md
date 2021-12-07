---
layout: post
permalink: /:year/bc5a8c01c1664643be595e8c82321321/index
title: 2021-01-21-windows-UpdateDriverForPlugAndPlayDevices-failed-GetLastError=-536870330
categories: [windows]
tags: [windows]
excerpt: windows,UpdateDriverForPlugAndPlayDevices,failed,GetLastError=-536870330
description: windows-UpdateDriverForPlugAndPlayDevices-failed-GetLastError=-536870330
catalog: true
author: 林兴洋
---

在windows中安装设备驱动，结果报了一个错：UpdateDriverForPlugAndPlayDevices failed, GetLastError=-536870330

解决方法：
* 1、打开注册表
* 2、找到注册表项
```
\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DeviceInstall\Parameters
```
* 3、把注册表项中的DeviceInstallDisabled值从1改成0
* 4、重启电脑


SOP：一般window上遇到这种问题，我们把这个十进制的错误转成十六进制（此例是-536870330转成十六进制的E0000246），然后到谷歌（没梯子就用bing）或者MSDN官网去搜一搜，一般是能找到对应解决方案。

## 参考

* [Error 0xe0000246 in installing driver](https://social.msdn.microsoft.com/Forums/en-US/ae757663-1d0b-41f7-b216-3a1df00de1ab/error-0xe0000246-in-installing-driver?forum=wdk)