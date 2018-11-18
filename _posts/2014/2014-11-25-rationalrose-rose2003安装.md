---
layout: post
permalink: /:year/6c0b81367bf34f7993411edf108929ae
title: 2014-11-25-rationalrose-rose2003安装
categories: [rationalrose]
tags: [rationalrose,rationalrose2003,软件安装]
excerpt: rationalrose,rationalrose2003,软件安装
description: rationalrose2003安装

---

# 步骤 #

## 1.工具 ##

* 虚拟光驱
* rationalrose2007安装包

## 2. 文件夹保存位置，点击next下一步 ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/01.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/01.png)

## 2.下一步 ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/02.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/02.png)

## 3. 选择第二项，点击下一步 ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/03.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/03.png)

## 4. 默认选择，点击下一步 ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/04.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/04.png)

## 5. 下一步 ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/05.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/05.png)

## 6. 选择“i accept...” ，点击Next ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/06.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/06.png)

## 7. 点击Next,默认安装就无需改变路径。（目标文件夹路径，将Ration Rose安装在这个文件夹）
 ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/07.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/07.png)

## 8. 点击Next ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/08.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/08.png)

## 9. 点击Install ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/09.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/09.png)


## 10. 如果有弹出这个页面是要求重启电脑才能继续安装的，选择YES马上重启，选择NO稍后重启。 ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/10.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/10.png)

## 11. 重启后进入安装界面，等待安装完成 ##

## 12. 这里要求输入那个证书，勾选下面的复选框，然后点击取消 ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/12.jpg](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/12.jpg)

## 13. 去掉两个勾选，点击Finish ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/13.jpg](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/13.jpg)

## 14. 打开如下路径（如果你是默认路径安装，否则可以看你第7步将软件装在哪里了。） ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/14.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/14.png)

## 15. 用这下面的rational_perm文件覆上面目录下的rational_perm文件 ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/15.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/15.png)

## 16.进入软件  ##
（进入的时候弹出一个 ClassNoFound错误。退出的时候弹出一个 NullPointer错误，解决方法在最后面）

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/16.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/16.png)

## 17. 进入 Help->About Ration Rose... 查看是否已经破解 ##

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/17.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/17.png)

## 18. 已经破解了。 ##

This prduct is licensed

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/18.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/18.png)

----

## ClassNoFound NullPointer 错误解决 ##
进入的时候弹出一个 ClassNoFound错误。退出的时候弹出一个 NullPointer错误，解决方法

### 1 ###
win+r 运行， 输入 regedit

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/19.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/19.png)

### 2 ###

找到HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Java VM表项

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/20.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/20.png)

### 3 ###

找到图中选中的这个（如果没有，就新建），双击。并将下面那串复制粘贴进去。

```

c:\windows\java\trustlib;c:\windows\java\trustlib\rosedatamodeler.zip;c:\windows\java\trustlib\comwrappers.zip;c:\windows\java\trustlib\xerces.jar;c:\programfiles\rational\rose\web modeler\xerces.jar

```

![http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/21.png](http://image.linxingyang.net/image/note/2014-11-25-rationalrose2003/21.png)

