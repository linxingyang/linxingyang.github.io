---
layout: post
permalink: /:year/631f75673d9e4fa0ba743acpplibxxso6/index
title: 2021-04-19-cpp-libstdc++.so.6-GLIBXX_3.4.20
categories: [cpp]
tags: [cpp,libstdc++.so.6]
excerpt: cpp,libstdc++.so.6,GLIBXX_3.4.20
description: 2021-04-19-cpp-libstdc++.so.6-GLIBXX_3.4.20
author: 林兴洋
---

# libstdc++.so.6 GLIBCXX_3.4.20 not found 问题

运行程序的时候，出现了下面这个问题：

```
/usr/lib64/libstdc++.so.6: version `GLIBCXX_3.4.20' not found
```


方法一是按照[解决类似运行报错： /usr/lib64/libstdc++.so.6: version `GLIBCXX_3.4.21‘ not found 的问题](https://blog.csdn.net/feikudai8460/article/details/113699655)的方式来解决。


方法二，编译gcc。

对于方法一，我面对着一个新安装的系统，里面根本没几个libstdc++.so.6，看了一下最高也就到GLIBCXX_3.4.19，所以没办法这么做。

通过查看rpm仓库对应信息发现，CentOS7安装的libstdc++.so.6支持到GLIBCXX_3.4.19，而CentOS8安装的libstdc++.so.6支持到GLIBCXX_3.4.24。

没找到什么方法可以在centos7中安装centos8中的库，没有去尝试是否可以修改库源（从centos7到centos8）这条路。



找到一个方法就是编译gcc7.3版本，编译完里面有一个libstdc++.so.6符合要求。

```shell
// 下载gcc
# wget https://mirrors.ustc.edu.cn/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.gz
# tar -zxvf gcc-7.3.0.tar.gz
# cd gcc-7.3.0

// 下载依赖后解压需要lbzip2，所以先安装libzip2
# yum install lbzip2
# ./contrib/download_prerequisites 
# 

// 编译
# mkdir build
# cd build
# ../configure --enable-checking=release --enable-languages=c,c++ 
# make // 非常久！！！有兴趣可以找下是否有简单的编译方式。找一些小的包进行编译

// 寻找libstdc++.so.6库
# find ./ -name *ibstdc++.so.6*
# strings ./x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6.0.24 | grep GLIBCXX
# cp x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6.0.24 /usr/lib64/
# ln -s /usr/lib64/libstdc++.so.6.0.24 /usr/lib64/libstdc++.so.6
```


具体信息：
```shell
[root@localhost build]# find ./ -name *ibstdc++.so.6*
./x86_64-pc-linux-gnu/32/libstdc++-v3/src/.libs/libstdc++.so.6.0.24
./x86_64-pc-linux-gnu/32/libstdc++-v3/src/.libs/libstdc++.so.6
./x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6.0.24
./x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6
./stage1-x86_64-pc-linux-gnu/32/libstdc++-v3/src/.libs/libstdc++.so.6.0.24
./stage1-x86_64-pc-linux-gnu/32/libstdc++-v3/src/.libs/libstdc++.so.6
./stage1-x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6.0.24
./stage1-x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6
./prev-x86_64-pc-linux-gnu/32/libstdc++-v3/src/.libs/libstdc++.so.6.0.24
./prev-x86_64-pc-linux-gnu/32/libstdc++-v3/src/.libs/libstdc++.so.6
./prev-x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6.0.24
./prev-x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6


[root@localhost build]# strings ./x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6.0.24 | grep GLIBCXX
GLIBCXX_3.4
GLIBCXX_3.4.1
GLIBCXX_3.4.2
GLIBCXX_3.4.3
GLIBCXX_3.4.4
GLIBCXX_3.4.5
GLIBCXX_3.4.6
GLIBCXX_3.4.7
GLIBCXX_3.4.8
GLIBCXX_3.4.9
GLIBCXX_3.4.10
GLIBCXX_3.4.11
GLIBCXX_3.4.12
GLIBCXX_3.4.13
GLIBCXX_3.4.14
GLIBCXX_3.4.15
GLIBCXX_3.4.16
GLIBCXX_3.4.17
GLIBCXX_3.4.18
GLIBCXX_3.4.19
GLIBCXX_3.4.20
GLIBCXX_3.4.21
GLIBCXX_3.4.22
GLIBCXX_3.4.23
GLIBCXX_3.4.24
```


libstdc++.so.6对应GCC版本
```shell
GCC 4.9.0: libstdc++.so.6.0.20
GCC 5.1.0: libstdc++.so.6.0.21
GCC 6.1.0: libstdc++.so.6.0.22
GCC 7.1.0: libstdc++.so.6.0.23
GCC 7.2.0: libstdc++.so.6.0.24
GCC 8.0.0: libstdc++.so.6.0.25
```



## 参考

* [解决类似运行报错： /usr/lib64/libstdc++.so.6: version `GLIBCXX_3.4.21‘ not found 的问题](https://blog.csdn.net/feikudai8460/article/details/113699655)
* [/usr/lib64/libstdc++.so.6: version `GLIBCXX_3.4.21' not found 问题解决](https://www.linuxidc.com/Linux/2017-10/147621.htm)
* [libstdc++.so.6: version `GLIBCXX_3.4.20' not found](https://stackoverflow.com/questions/44773296/libstdc-so-6-version-glibcxx-3-4-20-not-found)



