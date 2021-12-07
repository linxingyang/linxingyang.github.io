---
layout: post
permalink: /:year/4cxx9988502743b68622d47estruts11/index
title: struts-关于web.xml
categories: [struts]
tags: [post, struts]
date: 2015-07-21 21:01:13 +8
place: 福建工程学院
editdate: 2021-12-03 21:01:13 +8
eidtplace: 福州软件园
excerpt: struts2,web.xml
description: struts2,web.xml
catalog: true
author: 林兴洋
---


```xml
<filter>
   <filter-name>struts2</filter-name>
   <filter-class>org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter</filter-class>
</filter>
<filter-mapping>
   <filter-name>struts2</filter-name>
   <url-pattern>/*</url-pattern>
</filter-mapping>
```

* 1、自从Struts2.1.3以后 ,FilterDispatcher已经标注为过时了
* 2、在StrutsPrepareAndExecuteFilter的init()方法将会读取类路径下默认的配置文件struts.xml完成初始化操作。
struts2读取到struts.xml的内容后，以javabean形式存放在内存中，以后struts对用户的每次请求处理将使用内存中的数据，而不是每次都读取struts.xml文件所以每次更改了struts.xml文件后，都要重启tomcat服务器

