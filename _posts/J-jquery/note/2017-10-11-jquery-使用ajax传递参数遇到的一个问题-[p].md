---
layout: post
permalink: /:year/ea124c6e45834a3e86143752cef6aa3f
title: 2017-10-11-jquery-使用ajax传递参数遇到的一个问题
categories: [编程]
tags: [js,jquery]
excerpt:  jquery使用ajax传递参数遇到的一个问题
description: jquery问题,使用ajax传递参数遇到的一个问题
gitalk-id: ea124c6e45834a3e86143752cef6aa3f
toc: true
---

使用ajax传递参数时碰到了一个问题。参数中+^$%等等这些字符到了后台都不见了。

比如参数 `?a=1&b=aa+bb` ，后台读取b的时候，读到的是`aa bb` 中间的+号变成了空格。

```javascript
// 获取数据
var data = {
  	billType	: selector.billType.val(), 
  	item	 	: selector.item.val(), 
  	price 		: selector.price.val(), 
  	billDate 	: selector.billDate.val(),
  	payNow	 	: selector.payNow.val(),
  	payWay 		: selector.payWay.val(),
  	reason 		: selector.reason.val(),
};

// 拼装参数串
var str = "";
for(var key in data) {
  //if(data[key]) {
  str +=  "&" + key + "=" + data[key];
  //}
}

alert(str);

// 调用jquery提供的ajax方法
$.ajax({
  type : "post",
  url : "<c:url value='diary/bill/insert'/>",
  data : str,
  success : function(data) {
  }, error : function(XMLHttpRequest, textStatus, errorThrown) {
  }
});

```

发现alert(str);展示的字符串是没问题的，这些字符都在。但后台接收到的字符串中这些字符就会不见掉。

通过浏览器调试工具查看发送出去的报文，发现发送出去的报文中已经不包含这些字符了。但alert(str)的时候参数是对的，也是包含那些字符的。

通过查看jquery文档，发现除了给data传一个参数串，还可以直接把参数数组传递给ajax方法，这次不手动拼装字符串了，而是直接把参数数组给ajax。

```javascript
// 获取数据
var data = {
  	billType	: selector.billType.val(), 
  	item	 	: selector.item.val(), 
  	price 		: selector.price.val(), 
  	billDate 	: selector.billDate.val(),
  	payNow	 	: selector.payNow.val(),
  	payWay 		: selector.payWay.val(),
  	reason 		: selector.reason.val(),
};

// 调用jquery提供的ajax方法
$.ajax({
  type : "post",
  url : "<c:url value='diary/bill/insert'/>",
  data : data, // 没有手动拼装参数串。
  success : function(data) {
  }, error : function(XMLHttpRequest, textStatus, errorThrown) {
  }
});

```

这次测试发现后台获取到正常的数据了。

自己手动拼装参数字符串不行，而ajax自己拼装的就行。估计ajax方法内在拼装的时候做了一些事。查看了下源码，果然，在其中调用了param方法对参数数组进行处理，原来是有这个encodeURIComponent这个起了作用。

```javascript
jQuery.param = function( a, traditional ) {
	var prefix,
		s = [],
		add = function( key, value ) {
			// If value is a function, invoke it and return its value
			value = jQuery.isFunction( value ) ? value() : ( value == null ? "" : value );
			s[ s.length ] = encodeURIComponent( key ) + "=" + encodeURIComponent( value );
		};

	// Set traditional to true for jQuery <= 1.3.2 behavior.
	if ( traditional === undefined ) {
		traditional = jQuery.ajaxSettings && jQuery.ajaxSettings.traditional;
	}

	// If an array was passed in, assume that it is an array of form elements.
	if ( jQuery.isArray( a ) || ( a.jquery && !jQuery.isPlainObject( a ) ) ) {
		// Serialize the form elements
		jQuery.each( a, function() {
			add( this.name, this.value );
		});

	} else {
		// If traditional, encode the "old" way (the way 1.3.2 or older
		// did it), otherwise encode params recursively.
		for ( prefix in a ) {
			buildParams( prefix, a[ prefix ], traditional, add );
		}
	}

	// Return the resulting serialization
	return s.join( "&" ).replace( r20, "+" );
};
```

返回去，在自己手动拼接字符串的地方用上encodeURIComponent，结果发现也可以了。

```javascript
// 获取数据
var data = {
  	billType	: selector.billType.val(), 
  	item	 	: selector.item.val(), 
  	price 		: selector.price.val(), 
  	billDate 	: selector.billDate.val(),
  	payNow	 	: selector.payNow.val(),
  	payWay 		: selector.payWay.val(),
  	reason 		: selector.reason.val(),
};

// 拼装参数串
var str = "";
for(var key in data) {
  //if(data[key]) {
    // 在此处加上了 encodeURIComponent
  str +=  "&" + encodeURIComponent(key) + "=" + encodeURIComponent(data[key]);
  //}
}

alert(str);
// 调用jquery提供的ajax方法
$.ajax({
  type : "post",
  url : "<c:url value='diary/bill/insert'/>",
  data : str,
  success : function(data) {
  }, error : function(XMLHttpRequest, textStatus, errorThrown) {
  }
});
```

百度了一把 encodeURIComponent 是个什么。

[http://zccst.iteye.com/blog/2152750](http://zccst.iteye.com/blog/2152750)

这篇讲的不错[http://www.cnblogs.com/season-huang/p/3439277.html](http://www.cnblogs.com/season-huang/p/3439277.html)