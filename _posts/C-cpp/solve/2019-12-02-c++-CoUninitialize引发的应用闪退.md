---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab191202
title: 2019-12-02-c++-CoUninitialize引发的应用闪退
categories: [c]
tags: [c,c++,com组件,问题解决]
relative-tags: [问题解决]
excerpt: c++,com,组件,注销,闪退
description: c++的com组件注销引发的应用闪退
category: false
---

情况是这么个情况。在部分win10上，右键我们的OPC服务端工具的托盘栏图标的时候，会出现闪退。


我在5台物理机win10,3台虚拟机win10中装了OPC服务端工具，只有两台物理机出现了这个问题。其中一台还是测试MM的，我总不能占着人家的电脑做排查，多不好意思，还好另外一台电脑出问题了，就在这台上调试程序。

这种部分机器上出现的问题真是令人抓狂啊，谁也不知道这些电脑上到底装了什么软件和这个软件犯冲。一开始我也是照着这个方向去排查。但是这范围海了去了，什么中文路径，什么中文用户名，关掉大部分程序，但是没看到什么特别的。。感觉找问题的方向不对。

就是如下这段和百度上百分百雷同的代码
```
  CMenu menu;
  menu.LoadMenu(IDR_MENU1);
  LA_SetMenuStrings(menu.m_hMenu, IDR_MENU1, LANG_MODULE_LOGIN);
  CMenu *pPopUp = menu.GetSubMenu(0);
  CPoint pt;
  GetCursorPos(&pt);
  this->SetForegroundWindow();
  pPopUp->TrackPopupMenu(TPM_RIGHTBUTTON, pt.x, pt.y, this);
  PostMessage(WM_NULL, 0, 0);
```

在这两句，注释掉这两句就都没事，这两句其中一句被调用了就崩。
报一个 access violation 错误，这两个英文单词我认识，访问了不改访问的地址了，或者说访问的东西它原来在，后来不在了。
```
  this->SetForegroundWindow();
  pPopUp->TrackPopupMenu(TPM_RIGHTBUTTON, pt.x, pt.y, this);
```

这种情况下，还是构建一个与之类似的小Demo最实用了，因为是右键托盘栏菜单闪退，构建了一个相同的MFC程序，就只有右键托盘栏菜单的功能，测试之，并没有发现问题。

推测那这可能是程序的其他部分把这东西资源给释放了。可是我拿着这个对象的变量名去找，也没找到它的释放方法在某个不应该调用的地方被调用了。


最后，采用了简单的折半查找法= =，我从登录之后缩小到托盘栏这段期间的代码，注释掉其它的，只留缩小到托盘栏，以及右键弹出菜单的代码。结果没出问题，心里乐开了花，问题就出在被注释掉的这些代码中，然后开放一半代码，接着测，如此反复。

找到了，在登录时，会调用到OPCServer代码的初始化方法，调用到CoUninitialize()，然后再调用CoInitializeEx()初始化。

问题就出现在CoUninitialize()方法上，CoUninitialize这个方法会将当前线程的资源释放。Closes the COM library on the current thread, unloads all DLLs loaded by the thread, frees any other resources that the thread maintains, and forces all RPC connections on the thread to close. 这个可能导致资源被释放了，后面右键菜单的时候，就无法访问到了。

真佛了。。。还有这种操作？？？

解决方法就是启动单独的线程去调用这个方法。

但是也留下了一个疑问，为什么其它一些win10不会出现这种情况？


这个OPC服务端，= =，没事老来这种BUG，让我好找


参考 [CoUninitialize问题](https://blog.csdn.net/parfait/article/details/2059400?%3E)




