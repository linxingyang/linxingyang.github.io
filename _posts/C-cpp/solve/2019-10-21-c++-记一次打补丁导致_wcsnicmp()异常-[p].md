---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab191021/index
title: 2019-10-21-c++-记一次打补丁导致_wcsnicmp()异常
categories: [c]
tags: [c,c++,windows,打补丁,lightopc,问题解决]
relative-tags: [问题解决]
excerpt: _wcsnicmp,打补丁,lightopc
description: 记一次windows打补丁导致_wcsnicmp()异常
catelog: false
---

前方来报，在windows打完windows系统补丁之后，OPC客户端便无法从我们的OPC服务器获取数据了。

通过测试发现确实是这样，不过很奇怪的现象就是Debug和Release表现不同

两台电脑，一台是打补丁的，一台是没有打补丁的。
* 没有打补丁的机器上，Debug和Release都表现正常。
* 在打了补丁的机器上，Debug表现正常，Release表现不正常。


通过排查追踪，定位是一个系统函数_wcsnicmp在作怪


我们是这么掉用它的，下面wstrncmp指向_wcsnicmp
```
BOOL bool = !se->wstrncmp(tail, name, len)
```
调用时参数name是NULL，在Release的时候返回0，在debug的时候返回1


去看它的值
```
int res = se->wstrncmp(tail, name, len)
```
* 在Debug的时候打断点，res值是0
* 在Release的时候打断点，res值是2147483647



单独写一段小程序，
```
int main()
{
  wchar_t * str1 = L"test_状态";
  wchar_t * str2 = NULL;
  // wchar_t * str2 = L"x";
  int len = 0;
  int res = _wcsnicmp(str1, str2, len);
  printf("%d\n", res);
  scanf_s("%d", &len);
  return 0;
}
```

单独写一段小程序测试_wcsnicmp方法，与在前面测试中观察到的现象一致。
* 在打过补丁的机器上，以Debug运行正常，以Release运行，程序直接退出或者卡死。
* 在没有打补丁的机器上，以Debug运行正常，以Release运行正常。


大佬说，原来能够传入NULL，会判断，可能微软认为是个漏洞，会被别人利用来攻击，所以新补丁把NULL值这直接返回异常。

哎呀，这么玩，非得玩死不可。躲在角落瑟瑟发抖。。。。
