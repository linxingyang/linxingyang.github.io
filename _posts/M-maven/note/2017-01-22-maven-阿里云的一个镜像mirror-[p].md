---
layout: post
permalink: /:year/aly7ggg2a1mv49c2be51444cab4d2aqw
title: 2017-01-22-maven-阿里云的一个镜像mirror
categories: [maven]
tags: [maven]
excerpt: 阿里云,镜像,mirror,maven
description: 阿里云的一个镜像mirror
catalog: false
author: 林兴洋
---

使用阿里云的镜像，体验飞一般的下载速度哈哈，和原来的那个不一样的感觉啊。

在maven的settings.xml中，找到其中的<mirrors/>标签，加入下面阿里云的镜像
```xml
<mirrors>
    <mirror>
        <id>alimaven</id>
        <name>aliyun maven</name>
        <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
        <mirrorOf>central</mirrorOf>        
    </mirror>
</mirrors>
```