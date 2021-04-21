---
layout: post
permalink: /:year/5b849418e8ce4e3785cb179f21b11112/index
title: 2020-11-16-c++-mfc-error-C1189-windows和afxv_w32的冲突
categories: [c/c++]
tags: [c/c++,mfc,C1189]
excerpt: c/c++,mfc,C1189
description: c++-mfc-error-C1189-windows和afxv_w32的冲突
catalog: false
---


```
error C1189: #error :  WINDOWS.H already included.  MFC apps must not #include <windows.h> ...\vc\atlmfc\include\afxv_w32.h	16
```

能找到/想到的几种方法

1，让她（Windows.h）晚点出现

在加载afxv_w32.h头文件后加载windows.h，即把windows.h头文件放在所有头文件之后。但如果头文件多且杂，可能就把自己玩die了。同时要注意afxv_w32.h中的某些定义会被windows.h覆盖，详细看参考那篇文章。



2，不要让她们（afxv_w32.h和windows.h）两个碰面

在需要用到Window.h的源文件(.c .cpp)中引用windows.h，而不要在头文件中引用，这样不会把对windows.h的引用“传播”开来。



3，不引入windows.h

虽然没有细看代码，不过这上面提示给的很清楚，在MFC程序中MUST NOT(不是SHOULD NOT) 引入windows.h，这两还是不要一起用的好。（婆媳可能不应该在一栋房子里住着一个道理，没问题的时候不咋地，有问题了就Orz了.）


既然MFC在这里提示不要用windows.h，那么肯定在某处可以找到程序需要引入的头文件来替代windows.h，所以感觉还是这方法靠谱。

上面是自己引入的windows.h的情况，我遇到的是更蛋疼的情况：愉快的引用了第三方库（MQTT），第三方库中愉快的引入了Windows.h。用第二种方法，让她们两个见不着面了。噫吁嚱，逃过一劫。




## 参考

[fatal error C1189](https://blog.csdn.net/qq_26988127/article/details/78855266)


