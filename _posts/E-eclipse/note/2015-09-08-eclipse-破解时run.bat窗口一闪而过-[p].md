---
layout: post
permalink: /:year/d702789dd6a84ac7a09165d1d7b9dd35/index
title: 2015-09-08-eclipse-破解时run.bat窗口一闪而过
categories: [eclipse]
tags: [eclipse,破解]
excerpt: eclipse,myeclipse破解
description: myeclipse破解
catalog: false
author: 林兴洋
---

在进行myeclipse10.7.1破解的过程中,在运行run.bat时窗口一闪而过

在以文本个格式打开run.bat时，将javaw 修改成java, 然后在可以查看到在运行的过程能够中报异常如下：
Exception in thread "main" java.lang.ClassNotFoundException: com.sun.java.swing. plaf.nimbus.NimbusL

这个原因是因为电脑上安装的jdk版本低于破解文件里面使用的版本
，jdk的版本升级到了jdk1.6.0_10或以上，
