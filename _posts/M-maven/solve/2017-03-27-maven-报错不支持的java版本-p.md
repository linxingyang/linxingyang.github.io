---
layout: post
permalink: /:year/linxingyangwriteat20211208032403/index
title: maven-报错不支持的java版本
categories: [maven]
tags: [post, maven]
date: 2017-03-27 03:24:03 +8
place: 福建工程学院
editdate: 2021-12-08 03:24:03 +8
eidtplace: 福州软件园
excerpt: 问题解决,jdk,eclipse,maven
description: maven项目 Unsupported major.minor version 51.0
catalog: true
author: 林兴洋
---

maven项目 Unsupported major.minor version 51.0，JDK的版本与maven中配置的不一样。新增一个本地支持的版本。

```        
      <plugin>
		<groupId>org.apache.maven.plugins</groupId>
		<artifactId>maven-compiler-plugin</artifactId>
		<version>3.6.1</version>
		<configuration>
			<source>1.7</source>
			<target>1.7</target>
		</configuration>
	  </plugin>
```