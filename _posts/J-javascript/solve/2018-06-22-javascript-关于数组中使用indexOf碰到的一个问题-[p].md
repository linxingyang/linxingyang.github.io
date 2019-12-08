---
layout: post
permalink: /:year/4cxx5353vv0sssssc8622d47e658vxdbb
title: 2018-06-22-javascript-关于数组中使用indexOf碰到的一个问题
categories: [javascript]
tags: [javascript]
excerpt: 数组,indexOf,问题
description: 关于数组中使用indexOf碰到的一个问题
catalog: false
author: 林兴洋
---

今天碰到一个bug，测试后知道了，indexOf()使用的是严格的 === 比较。

例子是这样的。下图是修改图书界面。然后有一堆图书标签，

![图](http://image.linxingyang.net/image/J-javascript/image/2018-06-22/01.png)

界面操作：点击一个已经勾选的标签，就是要去掉这个标签，该例中去掉一个id为31的标签。


下面是代码中的操作，使用数组的indexOf()判断某个标签是否在该数组中，如果在就移除。

```js
form.on("checkbox(checkbox)", function(data){
    console.log("before:" + globals.configIds);
    console.log("操作的id:" + data.value);
    var index = globals.configIds.indexOf(data.value);
    for (var i = 0; i < globals.configIds.length; i++) {
    	console.log("两个等号：" + globals.configIds[i] + " " + data.value + " " +
                (globals.configIds[i] == data.value));
    	console.log("三个等号：" + globals.configIds[i] + " " + data.value + " " +
    			(globals.configIds[i] === data.value));
    }
    console.log("index:---->" + index);
    if (-1 !== index) {
        globals.configIds.splice(index, 1);
    }
    if (data.elem.checked) {
        globals.configIds.push(data.value);
    }
    console.log("after:" + globals.configIds);
});
```

可以看到控制台打印的结果如下：

![图](http://image.linxingyang.net/image/J-javascript/image/2018-06-22/03.png)

1处，index打印出来的值是-1，所以编号31的标签不会从集合中被移除掉。

2，3处，也说明了前后集合没有变化。

4处，两个等号结果为true，三个等号结果为false。结合1处为-1，可以知道indexOf中使用的是 === 的严格比较。

在代码中再加上typeof来判断二者的类型，结果发现原来界面点击后传过来的数据是string的。

```js
alert(typeof globals.configIds[i]);  // number
alert(typeof data.value); // string
```

这下知道原因（indexOf()中使用严格===，而这两个数据很明显类型不同，所以indeOf()返回-1）了就很好解决了。下面两种方式都可以。

* 1，改变判断方式，不使用indexOf()，直接在for循环内判断。如下

```js
form.on("checkbox(checkbox)", function(data){
    console.log("before:" + globals.configIds);
    console.log("操作的id:" + data.value);
    var index = -1; // globals.configIds.indexOf(data.value);
    for (var i = 0; i < globals.configIds.length; i++) {
    	if (globals.configIds[i] == data.value) {
    		index = i;
    		break;
    	} 
    }
    
    console.log("index:---->" + index);
    if (-1 !== index) {
        globals.configIds.splice(index, 1);
    }
    if (data.elem.checked) {
        globals.configIds.push(data.value);
    }
    console.log("after:" + globals.configIds);
});
```

* 2，强转类型，把string改为number

```js
console.log("init:" + globals.configIds);
form.on("checkbox(checkbox)", function(data){
    console.log("before:" + globals.configIds);
    console.log("操作的id:" + data.value);
    
    var tagIndex = parseInt(data.value);
    var index = globals.configIds.indexOf(tagIndex);
    
    console.log("index:---->" + index);
    if (-1 !== index) {
        globals.configIds.splice(index, 1);
    }
    if (data.elem.checked) {
        globals.configIds.push(data.value);
    }
    console.log("after:" + globals.configIds);
});
```