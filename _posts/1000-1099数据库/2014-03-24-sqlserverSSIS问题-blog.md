---
layout: post
permalink: /:year/a000318540b7457fa23cc20a3acdfcb6
title: sqlserverSSIS的问题
categories: [数据库]
tags: [sqlserver2008,错误,SSIS]
excerpt: sqlserver2008,错误,SSIS
description: sqlserver2008,错误,SSIS
---

[TOC]

---

ETL实验的时候碰到的问题

---
## 问题一：没有 SQL Server Bussiness Intelligence Development Studio ##

### 解决方法 ###

下载了一个  SqlServer2008R2，安装的时候，勾选了那个服务，安装完后就有了
或者也可以直接往SqlServer2008添加功能

![http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/A4ED3B85E8B74D398D3FE42D4B5FD5B1/60009](http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/A4ED3B85E8B74D398D3FE42D4B5FD5B1/60009)

![http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/740DEDF12E6E4922B47BAC4839202CE2/60008](http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/740DEDF12E6E4922B47BAC4839202CE2/60008)

![http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/1BEBF685CE574DC89F2C3BC10AFBC0AF/60006](http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/1BEBF685CE574DC89F2C3BC10AFBC0AF/60006)


---
## 问题二：新建 Integration Services项目，点击确定后报错，无法保存包，加载类型库/DLL 出错 ##

![http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/B4F0E53EB5E2499FA292E09AE0ECB452/60002](http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/B4F0E53EB5E2499FA292E09AE0ECB452/60002)

![http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/BFE6C95E71F84CC58EDA698E5F5EF2E2/60004](http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/BFE6C95E71F84CC58EDA698E5F5EF2E2/60004)

### 解决方法 ###

* 方法一:在 开始菜单-运行 中 依次输入并运行以下命令：
```
regsvr32 scrrun.dll  
regsvr32 jscript.dll 
regsvr32 vbscript.dll
```
 
如果上述方法仍然不行可尝试下面方法 

* 方法二：重新注册系统中所有dll文件  

系统中有未注册的dll文件,可能引起各种各样不可知的问题，比如出现上面的错误，无法打开二级链接，经常出现“内存不能为read或written”等错误。必须注册所有dll文件。 

点击:开始-->运行,在运行框中输入cmd，即在弹出的命令提示符下输入：
```
for %1 in (%windir%\system32\*.dll) do regsvr32.exe /s %1
```

引用自 [http://blog.csdn.net/qianqianstd/article/details/50083231](http://blog.csdn.net/qianqianstd/article/details/50083231)



---
## 问题三：进入项目后，发现SSIS包时打叉的（如图） ##

![http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/BD3B1D3C799048B5ADF271997EE6E807/60003](http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/BD3B1D3C799048B5ADF271997EE6E807/60003)

### 解决方法 ###

1. 开始->运行，输入dcomcnfg.exe
2. 打开组件服务器->计算机->我的电脑->DCOM配置；
3. 找到Microsoft Office Excel或者Microsoft Office Word点击右键->属性
4. 选择安全，将启动和激活权限、访问权限、配置权限全部选择自定义，之后编辑，添加everyone用户，给它所有的权限
5. 点击确定。

引用自：[http://blog.csdn.net/naujuw/article/details/5591621](http://blog.csdn.net/naujuw/article/details/5591621)


---
## 问题四：无法保存包，无法保存数据流对象 ##

新建一个 Integration Services Project ，添加  数据流任务  控件后，点击保存，提示无法保存保存数据流工具，无法保存包。

![http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/FFEFFACA7F5C47A88FFE665DDDCECE96/60005](http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/FFEFFACA7F5C47A88FFE665DDDCECE96/60005)

![http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/887370DD5CF7486888FC0F4899D82385/60007](http://note.youdao.com/yws/public/resource/6c342a9fb920ad4cb9b99b3194a15895/xmlnote/887370DD5CF7486888FC0F4899D82385/60007)

### 解决方法 ###

安装  MSXML4.0[https://www.microsoft.com/zh-cn/download/details.aspx?id=19662 ](https://www.microsoft.com/zh-cn/download/details.aspx?id=19662 )，安装完就可保存了。后面也不出错了。

说明：

MSXML4.0是微软的xml语言解析器，用来解释xml语言。就好像html文本下载到本地，浏览器会检查html的语法，解释html文本然后显示出来一样。要使用xml文件就一定要用到xml parser。不过不仅仅微软有，像ibm,sun都有自己的xml parser。

引用自：[http://blog.csdn.net/qianqianstd/article/details/50090557](http://blog.csdn.net/qianqianstd/article/details/50090557)




