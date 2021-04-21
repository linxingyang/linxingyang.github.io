---
layout: post
permalink: /:year/e11d12fafce649158abf9c18ee687ac7/index
title: 2014-03-28-java-windows下jdk环境变量配置
categories: [java]
tags: [java,jdk,windows]
excerpt: windows下jdk环境变量配置
description: windows下jdk环境变量配置
catalog: true
author: 林兴洋
---



# windows下配置JDK

## 1，下载JDK

先下载JDK，oracle官网下载贼慢，到[清华JDK镜像](https://mirrors.tuna.tsinghua.edu.cn/AdoptOpenJDK/)下会快一点，选一个合适的版本下载之。

## 2，配置环境变量JAVA_HOME

在进行下一步之前，找到JDK安装的位置，复制之。手动输入路径很容易出错，直接像下面这样复制就不会有错了。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/J-java/image/2014/2014-03-28/01.png)



在“我的电脑”上右键 --> 选择“属性” --> 选择"高级系统设置" --> 系统属性选项卡中选择"高级" --> 点击“环境变量”按钮 --> 点击“新建”。如图

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/J-java/image/2014/2014-03-28/06.png)

新建名为`JAVA_HOME`的环境变量，填入JDK安装的路径。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/J-java/image/2014/2014-03-28/07.png)

## 3，往Path变量中添加JAVA_HOME



![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/J-java/image/2014/2014-03-28/08.png)

如图，选择“系统变量”中变量名为“Path”的环境变量，双击该变量，把下面一段填在**最后面**即可，注意第一个封号，别忘了。

```
;%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin;
```


## 4，测试是否配置成功

`win+r` 输入`cmd` 按回车进入命令行，输入如下两个命令，如果显示如下则成功，如果提示：不是内部或外部命令， 那说明哪里配置有误了，基本上是路径的问题，再次检查JDK的路径以及JAVA_HOME和Path的配置。

测试`java`命令

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/J-java/image/2014/2014-03-28/04.jpeg)

测试`javac`命令

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/J-java/image/2014/2014-03-28/05.jpeg)



## 参考

* [国内首家JDK下载镜像上线了！](https://zhuanlan.zhihu.com/p/111022749)