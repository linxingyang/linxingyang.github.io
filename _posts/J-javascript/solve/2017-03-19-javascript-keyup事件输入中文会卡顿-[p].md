---
layout: post
permalink: /:year/7d8cf5dda21cexp484a3174ceaec9e85
title: 2017-03-19-javascript-keyup事件输入中文会卡顿
categories: [编程]
tags: [js]
excerpt: js,keyup,输入中文会卡顿
description: keyup事件输入中文会卡顿
gitalk-id: 7d8cf5dda21cexp484a3174ceaec9e85
toc: true
---

在webim中做到搜索的时候，使用keyup事件，输入英文倒没事，但输入中文将会导致卡顿。

百度后发现可以用  focus + setInterval 配合来解决。

伪代码如下：

```javascript
Xxx.focus(function() {
    var interval = setInterval(function() {
    Xxx.one('blur', function() {
        clearInteravl(interval);
    }
    // 做事
    }, 100);
})
```

![图](http://image.linxingyang.net/image/J-javascript/image/2017-03-19/01.png)

![图](http://image.linxingyang.net/image/J-javascript/image/2017-03-19/02.png)
