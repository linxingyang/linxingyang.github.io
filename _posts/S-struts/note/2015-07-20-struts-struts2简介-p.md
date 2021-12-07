---
layout: post
permalink: /:year/4cxx9988502743b68622d47estrutsd0/index
title: struts-struts2简介
categories: [struts]
tags: [post, struts]
date: 2015-07-20 20:54:36 +8
place: 福建工程学院
editdate: 2021-12-03 20:54:36 +8
eidtplace: 福州软件园
excerpt: struts2,简介
description: struts2,简介
catalog: true
author: 林兴洋
---

# struts

## 介绍

struts2是在webwork上发展过来的，是mvc模式。 但是推荐使用springmvc作为控制层 ^ _ ^，因为江湖传闻struts漏洞多。

## 优点

struts2提供了
* 拦截器，可以进行AOP编程，如实现权限拦截
* 类型转换器，把特殊的请求参数转化成需要的类型。
* 多种表现层技术技术，如JSP，freemarker,velocity等
* 输入校验可以可以对指定方法进行校验
* 提供了全局范围，包范围，和Action范围的国际化资源文件管理实现。


## 开发struts2最少需要的jar文件

* struts2-core-2.x.x.jar, struts2框架的核心类库
* xwork-2.x.x.jar XWork类库，struts2在其上构建
* ognl-2.6.x.jar 对象图导航语言，Struts2框架通过其读写对象的属性
* freemarker-2.3.x.jar   Struts的ui标签模板使用freemarkder编写
* commons-logging-1.1.x.jar, ASF出品的日志包，struts2框架使用这个日志包来支持log4和jdk1.4+的日志记录
* commons-fileupload-1.2.1.jar 文件上传组件，2.1.6版本后必须加入此文件

### 推荐使用maven做包管理

不建议单独下载jar包，推荐直接使用maven来管理包
* 可以避免包冲突问题，自己弄各个包版本不匹配可能会冲突，有些包天然就冲突，Maven已经帮我们很好的规避了冲突。
* 可以使得开发时项目比较小，因为依赖包都在maven仓库中
* 不必再为找包而烦恼

## struts2的处理流程

StrutsPrepareAndExecuteFilter是struts2的核心控制器，它负责拦截由`<url-pattern>/*</url-pattern>`指定的所有用户请求。

* 拦截用户所有请求，留下用户请求的后缀名为.action或者没有后缀名继续处理，其它的视情况而定（比如获取静态资源等等）
* 经过拦截器链，有默认的拦截器，我们也可以自定义拦截器添加上去
* 在经过action，action就是我们主要做业务的地方
* action处理后会返回一个字符串的返回类型，根据这个字符串在struts.xml中找到对应的视图进行返回


![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/S-struts/image/2015-07-20/e29b4e1763b16c8ea2b96fa4bebb0986.png)


## struts1和struts2的区别

* struts1和servlet，服务器整个生命周期内只会存在一个实例，单例模式
* ruts2 每次访问都新建一个，原型模式。

