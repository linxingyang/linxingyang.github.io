---
layout: post
permalink: /:year/7d8cf5dda21cexp484a3174ceaec9512/index
title: javascript-当窗体获得焦点时刷新窗体
categories: [javascript]
tags: [post, javascript]
date: 2016-05-08 20:48:50 +8
place: 福建工程学院
editdate: 2021-12-07 20:48:50 +8
eidtplace: 福州软件园
excerpt: javascript,焦点,刷新
description: javascript-当窗体获得焦点时刷新窗体
catalog: true
author: 林兴洋
---


需求是这样的，我点击父窗体的超链接`<a href="_blank"></a>`弹出子窗体，我想子窗体关闭后，回到父窗体时刷新一下父窗体中的数据。

第一次使用如下代码
```javascript
<script type="text/javascript">
    window.onfocus = function() {
        console.log("获得焦点");
         window.location.reload();
    };
    window.onblur = function() {
        console.log("失去焦点");

    };
</script>
```

结果发现，子窗体关闭后，父窗体会一直刷新。

原因是：子窗体关闭后，返回父窗体触发了window.onfocus，然后调用了 window.location.reload();   之后，页面从上往下再次执行的时候，是会再次进入window.onfocus中的，所以又再次调用了 window.location.reload();。 就这样一直循环，所以页面一直在刷新


解决方法，设置一个hidden标签，用它的value来控制是否刷新。
```javascript
<script type="text/javascript">
    window.onfocus = function() {
        if($("#freshflag").value == "fresh"){ // 表示要刷新 {
            window.location.reload();
            $("#freshflag").value = "";
        };    
        console.log("获得焦点");
    };
    window.onblur = function() {
        console.log("失去焦点");
        $("#freshflag").value = "fresh";
    };
</script>
    <!--  用来防止多次刷新页面 -->
    <input type="hidden" id="freshflag" value="fresh" />
```

