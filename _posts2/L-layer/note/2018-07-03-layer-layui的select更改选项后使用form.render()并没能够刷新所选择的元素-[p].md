---
layout: post
permalink: /:year/4206c3a0444146d8a3f84442e9804747/index
title: 2018-07-03-layer-layui的select更改选项后使用form.render()并没能够刷新所选择的元素
categories: [layer]
tags: [layui,layer]
excerpt:  layer,layui,select
description: select更改选项后使用form.render()并没能够刷新所选择的元素
catalog: false
author: 林兴洋
---



问题：select更改选项后，使用form.render();并没能够刷新所选择的元素。

在进入页面后会访问服务端加载一些数据，然后根据数据去更改下拉框的选项，第一次加载是对的，而后续加载下拉框的选择就是错误的了。代码如下：

```
$("#payType").find('option').attr("selected", false);
$("#payType").find('option[value="' + model.payType + '"]').attr("selected", true);
form.render();
```

如下页面，支付类型中"未现付"虽然是selected，但是在其后跟随的div中，layui-this的样式仍然在"现付"选项上：

![图1](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/L-layer/image/2018-07-03/01.png)

为什么select中已经选择了“未现付”并且也已经调用了form.render()了但结果不是期望的？初步估计是不是form.render()没有起效果？所以修改代码，其中手动去修改div中的样式，并且在2秒后再调用form.render()，代码如下：

```
$("#payType").find('option').attr("selected", false);
$("#payType").find('option[value="' + model.payType + '"]').attr("selected", true);

var $selectDiv = $("#payType + div");
$selectDiv.find("dl dd").removeClass("layui-this");
var $selectDD = $selectDiv.find('dl dd[lay-value="' + model.payType + '"]');
$selectDD.addClass("layui-this");
$selectDiv.find("div input").val($selectDD.text());

setTimeout(function() {
    console.log("xxx");
    form.render();
}, 2000);
```

更改后在form.render()之前是对的，如下：

![图2](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/L-layer/image/2018-07-03/02.png)

而在2秒后触发setTimeout中的form.render()之后反而变成错的了，如下：

![图3](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/L-layer/image/2018-07-03/03.png)



看来不是form.render()没有执行而且里面有bug吧？所以暂时的解决方案是不使用form.render()，而是如上直接另写代码使选择框成为正常的状态。



对于radio也是有同样的问题，但是因为radio只能有一个选中，所以使用click()事件就可以了。

```
$("#multiCheckbox").find('input[value="' + model.payWay + '"]').click();
```

但是对于checkbox，估计也是要另写代码了。这样感觉挺困扰的，本来是用框架就是要快速构建，反而因为复选框的问题要去调。



后续版本应该会更新吧？ >_<



