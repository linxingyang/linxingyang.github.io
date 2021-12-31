---
layout: post
permalink: /:year/linxingyangwriteat20211212120021/index
title: log4j-log4j2和log4j的区别
categories: [log4j]
tags: [post, log4j, java]
date: 2018-11-19 12:00:21 +8
place: 新大陆软件园
editdate: 2021-12-12 12:00:21 +8
eidtplace: 福州软件园
excerpt: log4j2,log4j,区别
description: log4j-log4j2和log4j的区别
catalog: true
author: 林兴洋
---


# log4j2

## log4j2和log4j不同

log4j2和log4j的区别。官网上说

>Apache Log4j 2 is an upgrade to Log4j that provides significant improvements over its predecessor, Log4j 1.x, and provides many of the improvements available in Logback while fixing some inherent problems in Logback’s architecture.

log4j2在log4j1的基础上有了重大的改进。提供许多和logback一样的功能并改善了logback中存在的架构的上的问题。可认为日志器的优略：log4j2 > logback > log4j

架构上的话，感觉是拆出去很多包。相比于log4j一个包走天下，log4j2拆分了，将包都分出去。类似和spring的思想吧，要用的时候就加入那个包，不用就不要加。

之前有说过一个门面日志器，slf4j。它就像JDBC，后面可以接Mysql,Sqlsever,Oracle。所以，对于使用slf4j而不是直接使用log4j会有更好的移植性。

log4j是通过一个.properties的文件作为主配置文件的，而现在的log4j 2则已经弃用了这种方式，采用的是.xml，.json或者.jsn这种方式来做，可能这也是技术发展的一个必然性，毕竟properties文件的可阅读性真的是有点差。但按照官网说的，还是支持properties文件的。
> one for JSON, one for YAML, one for properties, and one for XML. 

感觉上，YAML文件用的越来越多了。

