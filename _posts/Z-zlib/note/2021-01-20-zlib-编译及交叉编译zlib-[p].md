---
layout: post
permalink: /:year/bd7886a8b31e4fae9b51795b33d1zlib/index
title: 2021-01-20-zlib-编译及交叉编译zlib
categories: [zlib]
tags: [zlib,编译,交叉编译]
excerpt: zlib,编译,交叉编译
description: zlib-编译及交叉编译zlib
catalog: true
---

# 编译zlib


## linux-X86
```shell
./configure --prefix=./__install_x86
make && make isntall
```

## 交叉编译linux-A7
```shell
# 它的configure不支持CC选项，所以要单独export出来
export CC=/opt/toolchain/a7/bin/arm-linux-gnueabihf-gcc
export CXX=/opt/toolchain/a7/bin/arm-linux-gnueabihf-g++ 
./configure --prefix=./__install_a7 
make && make isntall
```

## 交叉编译linux-A8
```shell
export CC=/opt/toolchain/a8/bin/arm-arago-linux-gnueabi-gcc
export CXX=/opt/toolchain/a8/bin/arm-arago-linux-gnueabi-g++
./configure --prefix=./__install_a8
```

## 交叉编译linux-ARM9
```
export CC=/opt/toolchain/arm9/bin/arm-nuvoton-linux-uclibceabi-gcc
export CXX=/opt/toolchain/arm9/bin/arm-nuvoton-linux-uclibceabi-g++
./configure --prefix=./__install_arm9
```

## windows

需要安装cmake，安装完之后操作如下：

* 1、选择源码路径
* 2、选择生成项目路径
* 3、不要勾选这两项，会生成失败
* 4、点击confiure检查配置项。**此时会弹框提示要编译成32、64、ARM，根据需要选择32还是64位，不知道为啥32和64不能相通。**
* 5、点击generate生成项目

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/Z-zlib/image/2021-01-20/01.png)



* 6、打开项目，直接右键“解决方案”->“生成解决方案”

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/Z-zlib/image/2021-01-20/02.png)



* 7、最后就可以在Debug或者Release中生成对应的lib库和dll库

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/Z-zlib/image/2021-01-20/03.png)




## 参考

* [zlib源码下载](http://www.zlib.net/)

