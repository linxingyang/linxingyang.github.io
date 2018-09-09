---
layout: post
permalink: /:year/c7461a25fd414ea6938cdb0bf554c94d
title: 2018-07-25-project-selfmanager个人管理系统v1.1
categories: [project]
tags: [project,selfmanager]
excerpt:  project,selfmanager
description: project-selfmanager个人管理系统v1.1
header-img: "img/post/bg-cup.jpg"
---

[TOC]


# 1.1版本

## 演示/源码地址


[演示地址](http://selfmanager.linxingyang.net/selfmanager/)

[github地址](https://github.com/linxingyang/selfmanager)


## Bug Fixed

- BUG1-左侧菜单栏的显示问题：进入页面后，判断哪个左侧菜单栏应该展开有个bug。已修复。
- BUG2-图书管理界面的一个bug：更改状态后会把该图书对应的标签删除。已修复。


## 新增修改


### 新增长期任务明细页面



之前长期任务没有任务明细，当时使用的是一个文本框填写长期任务，我一般写个简短任务内容。



每一周周末，先看看有哪些正在进行的长期任务，然后根据这些长期任务中制定下周计划Plan，然后具体在每一天中去完成。下一周周末的时候，进行周任务的Check，把完成的再反馈到长期任务中。



like this : 长期任务->下一周周任务（Plan）->天任务->下一周周末：周任务（Check）->长期任务



之前这样写在考虑长期任务的时候很方便，只需要大致列出要我能想的到，需要做的东西。但是经过几周的使用，我发现麻烦的地方在于，我每次要从长期任务中copy本周要做的到周任务，然后周任务中汇集了一周要做的，再把周任务中的任务安排到天任务中，最后周末的时候，我还得回顾本周哪些任务完成了，从天任务反方向回到长期任务。这个过程挺繁琐的，所以最后还是考虑来一个长期任务明细。



#### 用法

在长期任务中有一个任务明细列表，在这里我们可以添加对应长期任务的任务明细

![图](http://image.linxingyang.net/image/note/2018-07-25-selfmanager/04.png)



进入selfmanager这个长期任务，安排了一个日期为2018-07-25的任务。（注意这里安排日期很重要，如果一个任务还没有安排好时间，那就不要选择安排日期。）

![图](http://image.linxingyang.net/image/note/2018-07-25-selfmanager/05.png)



在周任务页面，本周是2018-07-23到2018-07-29（下图2），进入该周的本周任务列表（下图3）

![图](http://image.linxingyang.net/image/note/2018-07-25-selfmanager/07.png)



进入任务明细后，你可以看到，所有日期在2018-07-23到2018-07-29的长期任务明细，都会在这里展示，如下就有我们刚刚创建的2018-07-25的那个任务。

（PS：因为有时候有的周任务不属于长期任务的，可以通过右上角的添加进行添加不属于长期任务的周任务）

![图](http://image.linxingyang.net/image/note/2018-07-25-selfmanager/08.png)



此时，我们到天任务界面，就能够看到那个任务。（我原本想把长期任务通过后台转成天任务，但是这样很麻烦，需要同步两个任务之间的状态等信息，所以就在天任务界面加入了当天长期任务需要完成的任务列表）

![图](http://image.linxingyang.net/image/note/2018-07-25-selfmanager/09.png)



此时如果我完成了该任务，那么在天任务界面点击"完成"后，那么周任务列表、长期任务列表中该任务也是"完成"状态的，如下图。这样就不需要在周末回顾哪些任务是否已经完成了，一目了然。

![图](http://image.linxingyang.net/image/note/2018-07-25-selfmanager/10.png)

![图](http://image.linxingyang.net/image/note/2018-07-25-selfmanager/11.png)



### 天任务页面

- 新增：在"天任务"列表界面新增"安排新任务"按钮（只是把添加任务和安排任务合并在一个页面）。下图1处


- 修改：把任务安排移动到"天任务"界面，点击"安排已有任务"打开。（注意：要停用配置中菜单（menu）中的"任务安排"菜单项）。下图2处
- 修改："天任务"页面，数据表格列新增"优先级"一列。（涉及后台代码改动）。下图3处

![图](http://image.linxingyang.net/image/note/2018-07-25-selfmanager/03.png)


### 部分页面新增上一项下一项

* 新增：日记、账单等页面中修改/查看页面中新增上一项下一项。用于便捷查看**本页**（仅限本页）的数据。

![图](http://image.linxingyang.net/image/note/2018-07-25-selfmanager/01.png)

### 停用url连接管理

* 修改： url(链接管理)用来配置太麻烦了所以不再使用。菜单仍然是配置的

update config set state=1 where type='url'


### 其它

基本上所有页面js代码调整，页面HTML调整


## Sql脚本


执行mysql_script下的selfmanagerV1.1.sql

