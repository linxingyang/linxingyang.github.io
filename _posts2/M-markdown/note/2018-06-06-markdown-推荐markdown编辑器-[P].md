---
layout: post
permalink: /:year/4cxx9vvvv0sssssc8622d47e658vxdbb/index
title: 2018-06-06-markdown-推荐markdown编辑器
categories: [markdown]
tags: [markdown,推荐工具系列]
relative-tags: [推荐工具系列]
excerpt: markdown,markdown编辑器
description: markdown-推荐markdown编辑器
catalog: true
author: 林兴洋
---



2019-09-27更新了一把

现在markdown编辑器越来越多了，自己主要用typora，没怎么去挖掘其它的。当初为了找一款喜欢好用的markdown编辑器，也是翻来覆去的找啊。对markdown编辑器的要求就是要有固定的目录（TOC）展示的地方，字数多的时候不能卡。



# 推荐的markdown

## typora

* 目录（大纲）模式
* 集合输入界面和预览界面于一体，不用左边输入右边预览，既扩大了输入区域，写的时候也不用特地去看右边的效果了。对于我这台14寸的笔记本，感觉是福音，不喜欢看代码的时候由于代码过长，要拉动下面的滚动条才能去看后面被挡住的部分。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-markdown/image/2018-06-06/03.png)



## vscode

最近用vscode写代码越来越喜欢了 :-) 

* 优点
  * 和写代码一样，有颜色看起来比较舒服
  * 支持TOC
  * 和项目一样，可以打开某个文件夹
  * 支持文件夹下所有文件的搜索
  * 各种markdown插件支持

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-markdown/image/2018-06-06/07.png)



## HBuilderX

这个也是最近才发现的，是一个前端编辑器。但同时也支持和提倡使用markdown语法。

它基本和vscode一样，支持的功能差不多。但是有个不爽的地方，打开另一个markdown文件就要重新打开一次toc，`alt + w`这里快捷键不知道是否冲突，也没起作用；

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-markdown/image/2018-06-06/05.png)



## haroopad

韩国人开发的这款还不错。可以设置vim模式输入，这点挺喜欢的。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-markdown/image/2018-06-06/02.png)

但是它没有目录模式，图示的目录效果固定在右边是写css来设置的。
```
[TOC "z-index:10000;right:0px;position:fixed;overflow-y: scroll;height: 500px;top: 0px; width: 200px; background-color: black"]
```



## cuteMarkdownEd

cuteMarkdownEd挺不错的

* 优点
  * 左侧目录
* 缺点
  * 字数一多也有点卡。
  * 同时左侧的目录有时候会失灵，点击了无效或者定位到了错误的位置。除了这两点其他还是不错的。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-markdown/image/2018-06-06/01.png)



# 关于图库

既然用了markdown，那就不可避免的要用到图床，白嫖方案也有，推荐从上到下

## 白嫖 gitee or coding

直接拉个git仓库，在gitee上或者coding上创建一个公开的，然后通过raw的url去访问，如我的图片仓库就在gitee上，前面你看到的图就是在gitee的仓库里面，链接类似[https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-markdown/image/2018-06-06/01.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-markdown/image/2018-06-06/01.png) 这种的，gitee唯一的限制是个人的仓库不能到达5G还是多少，不过妥妥啦，我现在图片也不过百兆。



## 白嫖七牛云

我之前是白嫖七牛云的图床，但是因为之前七牛发了个通知说七牛云的免费域名有期限，不能使用了，要求自定义域名。我当时以为都不能用了，就撤了。。。撤的有点快。。它的意思原来是要自己绑定一个已经备案的域名才行。。

考虑2个原因再使用七牛云：

1，它需要一个使用者自己绑定的域名。虽然我有备案的域名，就是你现在访问的这个，linxingyang.net，不过我怕我那天挂了，这个域名没人续费，这静态博客的图片统统地都裂了，这可不是我想要的。

2，如果是学生党或者只是玩玩还要自己要花点钱买域名，去备案，玩玩的话有点不合算。



## 白嫖CSDN/其它博客

在CSDN中创建文章，然后上传图片，这样你就可以得到CSDN生成的一个链接，你直接用这个链接就可以了。直接白嫖CSND，其实许多博客都可以这么做，直接白嫖博客的图床，不过图片大小，或者每天上传的图片总大小一般有限制就是了，还不如白嫖gitee这种来的爽快。

题外话1：由于我很早之前就开始用CSDN了，我之前整理的时候发现很早之前的图片都裂开了，我合理怀疑CSDN认为之前的保存图片方案不合理重新拆了重建，导致用户的图片丢失了~~，这点很淦。所以我不保证现在这中白嫖方式结果会如何。

题外话2：本来想说下定主意在CSDN上面写博客，可是新版特么的什么鬼审核。淦，算了，跑路。 还是自由自在的写点自己想写的东西最自在。



# 其他

## web上的markdown编辑器

web上的markdown编辑器也用过，感觉不方便（习惯性常按ctrl+s，老是跳出保存网页的对话框以及其他的一些问题），后面就专找PC上的markdown编辑器了。

## 有道云笔记自带的markdown编辑器 （放弃）

* 优点
  * 方便，内置于有道云笔记中。
  * 写完直接同步云端，现在写markdown都是typora写完，copy到有道云中保存。
  * 可以通过关键字搜索文件内容
* 缺点 
  * [toc]只能置于顶端，我比较喜欢固定在左端的，这样可以看当前文章大概的情况。
  * 一旦字数一多，同时打开预览的情况下，输入的时候就各种卡顿了。

发现一个大问题和小问题。小问题是保存某一文件夹，如果文件夹里面包含如a.pdf文件，那么保存到本地之后，变成了a.pdf.pdf。

大问题是移动某一文件到另一个地方，如果这个文件夹或者它的子文件夹中包含多个markdown文件并且内容较多，那么有几率某一个markdown文件的内容就被另外一个markdown文件的内容覆盖了。这种情况出现了好几次，反馈过客服。但是截至我上一次看有道云，还没有新的版本发布，也就没有再去尝试了。

现在已经放弃有道云作为保存笔记的地方了。用 vscode(写笔记) + svn(备份笔记) 来构建一个fake有道云了，至少不丢数据了。在使用vscode之前，用的是 typora + svn + filelocator(文件内容搜索)，因为vscode也有文件内容搜索，所以就改用vscode了，而且各种快捷键也是比较熟悉。

## atom中的markdown插件

atom通过插件来支持的markdown，而且好像插件比较多。

* 缺点
  * 为了找一款喜欢的插件挺费劲的，当时装插件的时候好像还装失败了，搞得挺麻烦
  * 用起来也是会卡。

## 小书匠markdown编辑器，

* 优点
  * 渲染出来的效果很华丽，比较喜欢
* 缺点    
  * 感觉功能太多，反而不好用了。内置配置图床服务，保存数据库等等，用起来比较繁琐。
  *  它的目录（TOC）用起来不是很舒服，不如cuteMarkdownEd和typora那样的简单明了，需要手动点开，然后不用的时候要手动收起。

## eclipse中的markdown插件

* 缺点
  * 几个插件版本对eclipse有版本要求，我使用的eclipse kepler版本不满足要求。。
  * 字数一多也比较卡（eclipse本来就卡）。。

eclipse还是用来好好写代码吧 :)

## notepad++中的markdown插件

找到一个markdown插件，没有展示目录，直接放弃了。。渲染效果一般
