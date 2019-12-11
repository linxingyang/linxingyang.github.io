---
layout: post
permalink: /:year/4206c3a0444146d8a3f84442e9804747
title: 2018-07-03-layer-layui的select更改选项后使用form.render()并没能够刷新所选择的元素
categories: [layer]
tags: [layui,layer]
excerpt:  layer,layui,select
description: select更改选项后使用form.render()并没能够刷新所选择的元素
catalog: false
author: 林兴洋
---

问题：select更改选项后，使用form.render();并没能够刷新所选择的元素。

在进入页面后，会访问服务端加载一些数据。
然后根据数据去更改下拉框的选项，

```
$("#payType").find('option').attr("selected", false);
$("#payType").find('option[value="' + model.payType + '"]').attr("selected", true);
form.render();
```

第一次加载是对的，然后在该页面中可能会有接下来的几次请求，也会执行如上代码。
而后续加载多次，下拉框的选择就是错误的了。

如下页面，支付类型中，"未现付"虽然是selected，但是在其后跟随的div中，layui-this的样式仍然在"现付"选项上

![图1](http://image.linxingyang.net/image/L-layer/image/2018-07-03/01.png)


为什么select中已经选择了“未现付”并且也已经调用了form.render()了,但结果不是期望的。
-->初步估计是不是form.render()没有起效果。

迫不得已，我只能手动去修改上面图片中div中的样式。

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

更改成如上代码之后，在form.render()之前，是对的

![图2](http://image.linxingyang.net/image/L-layer/image/2018-07-03/02.png)

而在2秒后触发setTimeout中的form.render()之后

![图3](http://image.linxingyang.net/image/L-layer/image/2018-07-03/03.png)

反而变成错的了。

-->看来不是form.render()没有执行，而且里面有bug吧？

所以暂时的解决方案是不使用form.render()。而是如上另写代码使选择框成为正常的状态。

另外
对于radio，也是有同样的问题，但是因为radio只能有一个选中，所以使用click()事件就可以了。

```
$("#multiCheckbox").find('input[value="' + model.payWay + '"]').click();
```

但是对于checkbox，估计也是要另写代码了。


这样感觉挺困扰的，本来是用框架就是要快速构建，反而因为复选框的问题要去调。
后续版本应该会更新吧？

如果大家已经有解决方法了，希望告诉我一下。可以留言或者发邮箱：linxingy@foxmail.com

-----------------

来自 layui社区 @岁月小偷 的回复

| 换个思路看看可行不，不需要去操作option的属性，而是把值设置给select，$(想要设置值的select).val(值);form.render();如果要操作option的话可以试一下attr('selected', null)而不是false我记得以前用false没有效果，后来是用null去掉属性，或者用prop('selected',false);最后form.render()这个是需要加上的。

----------------

我的回复：

感谢 @岁月小偷 

改成这样确实可以了： $(想要设置值的select).val(值);

```
$("#payType").val(model.payType);
```
不过改成attr('selected', null)和attr('selected', false)，效果一样，都是不行。

-----------------

我的回复：

感谢大家的回复！

最后改成 $(想要设置值的select).val(值); 来解决这个问题。

但有个小问题，虽然正确的显示的“未现付”，但是select中“未现付”那个option并没有selected属性，如下图


![图4](http://image.linxingyang.net/image/L-layer/image/2018-07-03/04.png)