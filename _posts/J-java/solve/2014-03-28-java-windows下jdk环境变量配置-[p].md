---
layout: post
permalink: /:year/e11d12fafce649158abf9c18ee687ac7
title: 2014-03-28-java-windows下jdk环境变量配置
categories: [编程]
tags: [java,jdk]
excerpt: windows下jdk环境变量配置
description: windows下jdk环境变量配置
gitalk-id: e11d12fafce649158abf9c18ee687ac7
toc: true
---

# 配置JDK，步骤

## 1.HOME

右键我的电脑--属性--高级--环境变量

## 2.配置JAVA_HOME

新建*系统变量*

```
变量名：JAVA_HOME
变量值：your_jdk_path\jdk1.7.0  
```

如果你是64位的windows但是你装了32位的JDK，并且JDK装在了默认路径下，那么要看清楚。

直接像下面这样复制就不会有错了。

![图](http://image.linxingyang.net/image/J-java/image/2014/2014-03-28/01.png)

![图](http://image.linxingyang.net/image/J-java/image/2014/2014-03-28/02.jpeg)

## 3.往 path变量中添加JAVA_HOME

选择“系统变量”中变量名为“Path”的环境变量，双击该变量，把JDK安装路径中bin目录的绝对路径，添加到Path变量的值中，并使用半角的分号和已有的路径进行分隔。

```
变量名：Path
变量值：;%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin;
```

## 4.测试是否配置成功

`win+r -> 输入 cmd  回车 进入命令行`

输入如下两个命令，如果显示如下则成功，如果提示：不是内部或外部命令... 那说明哪里配置有误了。

* 测试java命令

![图](http://image.linxingyang.net/image/J-java/image/2014/2014-03-28/04.jpeg)

* 测试javac命令

![图](http://image.linxingyang.net/image/J-java/image/2014/2014-03-28/05.jpeg)
