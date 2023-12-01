---
layout: post
toc: true
title: oracle-windows中安装oracle
description: 
published: true
date: 2015-03-11T14:19:28.157Z
tags: R02/日记
editor: markdown
dateCreated: 
location:
---

2020-10-28： 这是当年Oracle的安装过程了，现在应该大不同了吧，也许久没碰oracle数据库了 

# 1、选择数据包

![图01](/R02/纪年/2015/2015-03-11-oracle-windows中安装oracle/assets/01.png)

下载安装包

* database 如果安装数据库服务器的话肯定需要安装database了，我们一般是装这个
* clicnet 如果你要连接远程的服务器，而不想在本地安装oracle服务器，就可以安装client
* clusterware是集群软件，也就是做oracle rac才能用到

# 2、安装

![图02](/R02/纪年/2015/2015-03-11-oracle-windows中安装oracle/assets/02.png)

* 如果是xp直接点击setup
* 如果是win7,win8安装包解压完，右键setup.exe选择“属性”，在“兼容性”一项中如下选择：


![图03](/R02/纪年/2015/2015-03-11-oracle-windows中安装oracle/assets/03.png)

然后安装的时候就是密码第一个字符不能是数字，其他没有什么要注意的了，就是下一步什么之类的。


# 安装过程中碰到的错误

* oracle-环境变量path的值超过1023字符，无法设置改值
* 启动后一闪而过
