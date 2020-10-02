---
layout: post
permalink: /:year/5b849418e8ce4e3785cb179f21b53ce9
title: 2019-12-21-c++-windows中调用system报错命令不存在
categories: [c++]
tags: [c,c++,windows,c问题解决]
relative-tags: [c问题解决]
excerpt: c++,com,system,命令不存在
description: c++在windows中调用system报错命令不存在
category: false
---

在windows中，调用system去执行命令，但是因为命令中包含空格

```
c:\Program Files\path\to\some.exe --config c:\Program Files\path\to\some.conf
```

在CMD中我们可以

```
"c:\Program Files\path\to\some.exe" --config "c:\Program Files\path\to\some.conf"
```

但是在c++中这样调用，却是失败的
```
string sCmd("\"c:\Program Files\path\to\some.exe\" --config \"c:\Program Files\path\to\some.conf\"");
system(sCmd.c_str());
```

要这样，再在外面加一层双引号包含整个命令
```
string sCmd("\"\"c:\Program Files\path\to\some.exe\" --config \"c:\Program Files\path\to\some.conf\"\"");
system(sCmd.c_str());
```

## 参考

* [windows-c-system-call-with-spaces-in-command](https://stackoverflow.com/questions/2642551/windows-c-system-call-with-spaces-in-command)