---
layout: post
permalink: /:year/4c589988502743b68622d47e6587b2d0/index
title: 2018-03-06-typescript-ts中引入使用jquery插件
categories: [typescript]
tags: [javascript,typescript,jquery]
excerpt:  typescript,jquery,插件
description: typescript中引入jquery插件
catalog: false
author: 林兴洋
---



命令行输入：

```typescript
// typescript2.0+推荐使用这种。
npm install --save-dev @types/jquery

npm install jquery 

// 安装typing，用于获取jquery的d.ts文件。
// 这步过后你的根目录会多一个typings.json文件
install typings

// 获取d.ts文件
// 这步过后，在typings/globals文件夹中就可以看到jquery了
typings install dt~jquery --global --save
```



然后在你的ts文件中引用

```typescript
import $ = require("jquery");

$.each(['a','b','c'], function (index, value) {
    console.log(index + " " + value);
})

console.log($('#greeting').html());
```

其中`Hellox from ts` 是 `div#greeting`中的html。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/T-typescript/image/2018-03-06/01.png)
