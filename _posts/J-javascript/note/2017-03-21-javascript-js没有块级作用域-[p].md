---
layout: post
permalink: /:year/7d8cf5dda21cexpcxxa3174ceaec9e85/index
title: 2017-03-21-javascript-js没有块级作用域
categories: [javascript]
tags: [javascript,块作用域]
excerpt: javascript,块作用域
description: javascript没有块级作用域
catalog: true
author: 林兴洋
---


# js没有块级作用域

在java中，有方法作用域也有块作用域

```java
public void methodA(arr) {
    // java 有方法作用域
    for(int i = 0; i < arr.length; i++) {
        // java有块作用域,i只作用于这里面
    }
    // 在后面无法继续引用i
    // System.out.println(i); 
}
```

而在js中，只有方法作用域，没有块作用域
```javascript
function methodB() {
    // js有方法作用域
    var arr = [1,2,3,4,5]; 
    for(var i = 0; i < arr.length; i++) {
        // js没有块作用域，
    } 
    // 此处仍能获取i的值
    alert(i); // 5   
}
methodB();
```

即使我们定义了 var i 但是仍然是没用的，i的作用域会被提上去，上面这段代码等同于下面：

```javascript
function methodB() {
    // js有方法作用域
    var i;
    var arr = [1,2,3,4,5]; 
    for(i = 0; i < arr.length; i++) {
        // js没有块作用域，
    }
    alert(i); // 5
}
```
