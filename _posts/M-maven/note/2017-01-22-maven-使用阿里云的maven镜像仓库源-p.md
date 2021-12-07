---
layout: post
permalink: /:year/aly7ggg2a1mv49c2be51444cab4d2aqw/index
title: 2017-01-22-maven-使用阿里云的maven镜像仓库源
categories: [maven]
tags: [post, maven]
date: 2017-01-22 09:15:15 +8
place: 福建工程学院
editdate: 2021-09-24 09:15:15 +8
eidtplace: 福州软件园
excerpt: maven, 阿里云, maven镜像仓库源
description: maven-使用阿里云的maven镜像仓库源
catalog: false
author: 林兴洋
---

使用阿里云的镜像，体验飞一般的下载速度。打开maven安装/解压目录下的conf/settings.xml中，找到其中的<mirrors/>标签，加入下面阿里云的镜像源即可：

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

