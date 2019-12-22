---
layout: post
permalink: /:year/4cf65ddff70a4cf6bb5a03abfcf681fa
title: 2019-12-17-tinyxml-打印XMLElement
categories: [tinyxml]
tags: [tinyxml,c,c++]
excerpt: c++,tinyxml,xmlelemnt
description: c++的tinyxml库打印XMLElement
category: false
---

使用tinyxml打印某个XMLElement元素的内容

```c++
int localResultParser(CResult & result, string & sXmlString) {
  
  ...
  
  doc.Parse(sXmlString.c_str());
  doc.Print();
  
  ...
  
  XMLElement * resultElement = doc.FirstChildElement("result");
  
  ...
  
  XMLElement * contentElement = resultElement->FirstChildElement("content");
  
  ...
  
  XMLPrinter printer;
  // contentElement->Print(&printer); // 无法打印，报错没有XMLElement没有Print方法
  contentElement->Accept(&printer); // 使用Accept()方法
  
  printf("print result : %s\n", printer.CStr());  // 打印
  
  // 我们也可以定义一个string来接收
  // string sContent(printer.CStr());
  // printf("print result : %s\n", sContent.c_str());
  
  ...
}
```

输出结果
```
full xml is : 
<result>
    <code>200</code>
    <msg>OK</msg>
    <content>
        <box machineCode="bXml"/>
    </content>
</result>
```

接着输出了其中的content标签。
```
print result : <content>
    <box machineCode="bXml"/>
</content>
```
