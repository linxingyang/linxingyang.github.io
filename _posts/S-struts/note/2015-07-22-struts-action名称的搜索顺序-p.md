---
layout: post
permalink: /:year/4cxx9988502743b68622d47estruts12/index
title: struts-action名称的搜索顺序
categories: [struts]
tags: [post, struts]
date: 2015-07-22 21:02:52 +8
place: 福建工程学院
editdate: 2021-12-03 21:02:52 +8
eidtplace: 福州软件园
excerpt: struts2,action
description: struts-action名称的搜索顺序
catalog: true
author: 林兴洋
---



# 根据URL寻找action的流程


## 1、url

例如url是 http://server/struts2/path1/path2/path3/test.action

## 2、寻找namespace为/path1/path2/path3的package

* 如果不存在这个package则执行步骤3
* 如果存在这个package则在这个package找寻名字为test的action，
    * 找到了就结束
    * 找不到action则执行步骤6


## 3、寻找namespace为/path1/path2的package

* 如果不存在这个package则执行步骤4
* 如果存在这个package则在这个package找寻名字为test的action，
    * 找到了就结束
    * 找不到action则执行步骤6

## 4、寻找namespace为/path1的package

* 如果不存在这个package则执行步骤5
* 如果存在这个package则在这个package找寻名字为test的action，
    * 找到了就结束
    * 找不到action则执行步骤6

## 5、寻找namespace为/的Package,

* 如果不存在这个package则执行步骤6
* 如果存在这个package则在这个package找寻名字为test的action，
    * 找到了就结束
    * 找不到action则执行步骤6

## 6、 在默认namespace的package里面寻找action

* 找到了就结束
* 如果还找不到，则提示找不到action



## 测试

在struts.xml中进行如下测试

* a、在默认命名空间下，设置了test.action，访问的是test1.jsp

* b、在/path1/path2下，设置了test.action，访问的是test2.jsp



* 在没有设置命名空间为/path1/path2/path3的package的时候，它访问到的是test2.jsp

即上面步骤的 1->2，就访问到test2.jsp

* 在设置了命名空间为/path1/path2/path3的package的时候，但是其中没有任何action的时候，它访问到的是test1.jsp

即上面步骤的 1->6，就访问到test1.jsp

