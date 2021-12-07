---
layout: post
permalink: /:year/linxingyangwriteat20211208032441/index
title: maven-单元测试报错ClassNotFoundException
categories: [maven]
tags: [post, maven]
date: 2017-03-27 03:24:41 +8
place: 福州软件园
editdate: 2021-12-08 03:24:41 +8
eidtplace: 福州软件园
excerpt: 问题解决,junit,eclipse,maven
description: 解决maven test命令时console出现中文乱码乱码
catalog: true
author: 林兴洋
---

使用maven构建的项目，在使用junit单元测试报错java.lang.ClassNotFoundException，

先使用maven的maven test命令，生成测试类的class文件，然后再在测试类中进行单独方法的测试。但这样修改了测试类中的参数后，再次测试还是原来的参数，即需要重新编译测试类，这样很麻烦。

后面发现在 pom.xml中配置 testOutputDirectory指定测试类二进制文件生成的路径就可以了。

```xml
<build>
   	 	<finalName>cwgl</finalName>
   	 	<testOutputDirectory>src/main/webapp/WEB-INF/classes</testOutputDirectory>
</build>
```