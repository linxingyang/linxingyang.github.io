---
layout: post
permalink: /:year/7d8cf5dda21c409484a3174ceaec9e85
title: 2017-02-22-jquery-选择器带特殊字符出错-需要转义
categories: [问题解决]
tags: [jquery,选择器,特殊字符出错,转义]
excerpt: jquery,选择器,特殊字符出错,转义
description: jquery,选择器,特殊字符出错,转义
picUrl: images\public\1002\003
---



使用jquery的选择器时，给出的条件不能包含特殊字符,但是我在界面上用到了jid  : node@domain\resourc
 使用jquery选择器时报错，所以需要用以下函数来转义一下。
 
 
```javascript
/**
 * 使用jquery的选择器时，给出的条件不能包含特殊字符
 * 但是我在界面上用到了jid  : node@domain\resourc
 * 使用jquery选择器时报错，所以需要用以下函数来转义一下。
 */
escapeJquery : function(srcString) {  
    // 转义之后的结果  
    var escapseResult = srcString;  
  
    // javascript正则表达式中的特殊字符  
    var jsSpecialChars = ["\\", "^", "$", "*", "?", ".", "+", "(", ")", "[",  
            "]", "|", "{", "}"];  
	      
// jquery中的特殊字符,不是正则表达式中的特殊字符  
var jquerySpecialChars = ["~", "`", "@", "#", "%", "&", "=", "'", "\"",  
        ":", ";", "<", ">", ",", "/"];  

for (var i = 0; i < jsSpecialChars.length; i++) {  
    escapseResult = escapseResult.replace(new RegExp("\\"  
                            + jsSpecialChars[i], "g"), "\\"  
                    + jsSpecialChars[i]);  
}  

for (var i = 0; i < jquerySpecialChars.length; i++) {  
    escapseResult = escapseResult.replace(new RegExp(jquerySpecialChars[i],  
                    "g"), "\\" + jquerySpecialChars[i]);  
}  

return escapseResult;  
}, 
	    
```