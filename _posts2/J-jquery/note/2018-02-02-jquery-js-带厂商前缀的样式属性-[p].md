---
layout: post
permalink: /:year/4c58xxvv502743b68622d47e6587b2d0/index
title: 2018-02-02-jquery-js-带厂商前缀的样式属性
categories: [jquery]
tags: [jquery,javascript]
excerpt: jquery,带厂商前缀的样式属性
description: js带厂商前缀的样式属性
catalog: true
author: 林兴洋
---

经常在页面调试的时候看到指定浏览器才有的样式。

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/J-jquery/image/2018-02-02/01.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/J-jquery/image/2018-02-02/01.png)

### 带厂商前缀的样式属性

浏览器厂商在引入实验性的样式属性时，通常会在实现达到css规范要求之前，在属性名前添加一个前缀。等到实现和规范都稳定之后，这些属性的前缀就会被去掉，让开发人员使用标准的名称。因此我们经常看到类似下面的css声明：
* -webkit-property-name: value;
* -moz-property-name: value;
* -ms-property-name: value;
* -o-peoperty-name: value;
* property-name: value;

如果在js中设置这些属性，需要检测它们在DOM中是否存在，从propertyName到WebKitPropertyName...都要检测。但在jQuery中我们可以使用标准的属性名，比如：.css('propertyName', 'value')，如果样式对象中不存在这个属性，jQuery就会依次检测所有带前缀(Webkit,o,Moz,ms)的属性，然后使用第一个找到的那个属性。
