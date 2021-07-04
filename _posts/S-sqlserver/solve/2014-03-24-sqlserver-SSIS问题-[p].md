---
layout: post
permalink: /:year/a000318540b7457fa23cc20a3acdfcb6/index
title: 2014-03-24-sqlserver-SSIS问题
categories: [sqlserver]
tags: [数据库,sqlserver,sql]
excerpt: sqlserver,sqlserver2008,SSIS,数据库
description: sqlserver2008,ETL实验SSIS出错解决
catalog: true
author: 林兴洋
---

# ETL实验的时候碰到的问题

## 问题一：没有 SQL Server Bussiness Intelligence Development Studio

### 解决方法

下载了一个  SqlServer2008R2，安装的时候，勾选了那个服务，安装完后就有了
或者也可以直接往SqlServer2008添加功能

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/S-sqlserver/image/2014-03-24/01.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/S-sqlserver/image/2014-03-24/02.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/S-sqlserver/image/2014-03-24/03.png)

## 问题二：新建 Integration Services项目，点击确定后报错，无法保存包，加载类型库/DLL 出错

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/S-sqlserver/image/2014-03-24/04.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/S-sqlserver/image/2014-03-24/05.png)

### 解决方法

#### 方法一：在 开始菜单-运行 中 依次输入并运行以下命令：

```
regsvr32 scrrun.dll  
regsvr32 jscript.dll 
regsvr32 vbscript.dll
```

如果上述方法仍然不行可尝试下面方法 

#### 方法二：重新注册系统中所有dll文件 

系统中有未注册的dll文件,可能引起各种各样不可知的问题，比如出现上面的错误，无法打开二级链接，经常出现“内存不能为read或written”等错误。必须注册所有dll文件。 

点击:开始-->运行,在运行框中输入cmd，即在弹出的命令提示符下输入：

```
for %1 in (%windir%\system32\*.dll) do regsvr32.exe /s %1
```

[参考文章](http://blog.csdn.net/qianqianstd/article/details/50083231)

## 问题三：进入项目后，发现SSIS包时打叉的（如图）

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/S-sqlserver/image/2014-03-24/06.png)

### 解决方法

1. 开始->运行，输入dcomcnfg.exe
2. 打开组件服务器->计算机->我的电脑->DCOM配置；
3. 找到Microsoft Office Excel或者Microsoft Office Word点击右键->属性
4. 选择安全，将启动和激活权限、访问权限、配置权限全部选择自定义，之后编辑，添加everyone用户，给它所有的权限
5. 点击确定。

[参考文章](http://blog.csdn.net/naujuw/article/details/5591621)

## 问题四：无法保存包，无法保存数据流对象

新建一个 Integration Services Project ，添加  数据流任务  控件后，点击保存，提示无法保存保存数据流工具，无法保存包。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/S-sqlserver/image/2014-03-24/07.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/S-sqlserver/image/2014-03-24/08.png)

### 解决方法

安装  MSXML4.0 [下载地址](https://www.microsoft.com/zh-cn/download/details.aspx?id=19662 )，安装完就可保存了，后面也不出错了。

说明：
MSXML4.0是微软的xml语言解析器，用来解释xml语言。就好像html文本下载到本地，浏览器会检查html的语法，解释html文本然后显示出来一样。要使用xml文件就一定要用到xml parser。不过不仅仅微软有，像ibm,sun都有自己的xml parser。

[参考文章](http://blog.csdn.net/qianqianstd/article/details/50090557)



