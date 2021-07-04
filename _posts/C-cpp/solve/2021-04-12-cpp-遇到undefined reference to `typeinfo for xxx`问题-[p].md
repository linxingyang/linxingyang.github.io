---
layout: post
permalink: /:year/631f75673d9e4fa0ba743acpptypeinfo/index
title: 2021-04-12-cpp-遇到undefined reference to `typeinfo for xxx`问题
categories: [cpp]
tags: [cpp]
excerpt: cpp,undefined reference to `typeinfo for xxx`,问题
description: cpp-遇到undefined reference to `typeinfo for xxx`问题
author: 林兴洋
---

自己在写一个子类继承父类的时候，遇到了这么个问题：undefined reference to `typeinfo for xxx`。
百度上大多是说定义了虚函数（构造函数，析构函数）未实现，但是我明明实现了，后面再仔细看一下，原来是自己漏了=0（第二种情况）


## 第一种情况：父类作为接口，定义了虚函数未实现

```cpp
/**
 * @details 作为一个抽象类
 */
class CFather
{
public:
    CFather() {};           /* 需要加上中括号 */
    virtual ~CFather() {};  /* 需要加上中括号 */
}

class CSon : public CFather
{
public:
    CSon(); 
    virtual ~CSon();
}

CSon::CSon()
{
}

CSon::~CSon()
{
}
```



## 第二种情况：父类中定义了虚接口但是少了 = 0

```cpp

/**
 * @details 作为一个抽象类
 */
class CFather
{
public:
    CFather() {};
    virtual ~CFather() {};
    virtual string getName() = 0;   /* 完整格式 */
    virtual int getAge();           /* 定义为虚接口没有加 = 0 */
}

class CSon : public CFather
{
public:
    CSon(); 
    virtual ~CSon();
    string getName();
    int getAge();
}

CSon::CSon()
{
}

CSon::~CSon()
{
}

string CSon::getName()
{
}

int CSon::getAge()
{
}
```

半路出家C++，太糗了。



## 参考

* [接口类编译时提示未定义错误：undefined reference to `typeinfo for](https://blog.csdn.net/caojinlei_91/article/details/103274918)

