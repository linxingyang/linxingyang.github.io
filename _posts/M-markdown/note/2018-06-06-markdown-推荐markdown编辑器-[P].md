---
layout: post
permalink: /:year/4cxx9vvvv0sssssc8622d47e658vxdbb
title: 2018-06-06-markdown-推荐markdown编辑器
categories: [工具]
tags: [markdown,推荐工具]
excerpt:  markdown,推荐markdown编辑器
description: markdown-推荐markdown编辑器
gitalk-id: 4cxx9vvvv0sssssc8622d47e658vxdbb
toc: true
---

2019-09-27更新了一把，现在markdown编辑器越来越多了，自己主要用vscode和typora，没怎么去挖掘其它的。


当初为了找一款喜欢好用的markdown编辑器，也是翻来覆去的找啊。对markdown编辑器的要求就是要有固定的目录（TOC）展示的地方，字数多的时候不能卡。

# 推荐的markdown

## vscode

现在主要用vscode来写markdown了，虽然vscode主要用来写代码，但是看起来写markdown的体验还不错。（最近用vscode写代码越来越喜欢了 :-) ）

* 优点
  * 和写代码一样，有颜色看起来比较舒服
  * 支持TOC
  * 和项目一样，可以打开某个文件夹
  * 支持文件夹下所有文件的搜索
  * 各种markdown插件支持

![图](http://image.linxingyang.net/image/M-markdown/image/2018-06-06/07.png)

## typora

* 目录（大纲）模式
* 集合输入界面和预览界面于一体，不用左边输入右边预览，既扩大了输入区域，写的时候也不用特地去看右边的效果了。对于我这台14寸的笔记本，感觉是福音，不喜欢看代码的时候由于代码过长，要拉动下面的滚动条才能去看后面被挡住的部分。

![图](http://image.linxingyang.net/image/M-markdown/image/2018-06-06/03.png)

## HBuilderX

这个也是最近才发现的，是一个前端编辑器。但同时也支持和提倡使用markdown语法。

它基本和vscode一样，支持的功能差不多。但是有个不爽的地方，打开另一个markdown文件就要重新打开一次toc，`alt + w`这里快捷键不知道是否冲突，也没起作用；

![图](http://image.linxingyang.net/image/M-markdown/image/2018-06-06/05.png)

## haroopad

韩国人开发的这款还不错。可以设置vim模式输入，这点挺喜欢的。

![图](http://image.linxingyang.net/image/M-markdown/image/2018-06-06/02.png)

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

![图](http://image.linxingyang.net/image/M-markdown/image/2018-06-06/01.png)

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
