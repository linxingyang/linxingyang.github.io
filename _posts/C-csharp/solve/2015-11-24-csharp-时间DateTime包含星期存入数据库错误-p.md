---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab4d2add/index
title: csharp-时间DateTime包含星期存入数据库错误
categories: [csharp]
tags: [post, csharp, promotion]
date: 2015-11-24 01:19:46 +8
place: 福建工程学院
editdate: 2021-12-05 01:19:46 +8
eidtplace: 福州软件园
excerpt: csharp,mysql,问题解决,时间错误
description: csharp时间DateTime包含星期存入mysql数据库错误
catalog: true
author: 林兴洋
---

# csharp时间DateTime包含星期存入mysql数据库错误

## 问题

往mysql中插入日期字段，mysql报错说时间格式不正确，通过弹框出来发现要存到数据库中的时间DateTime中间多了星期，如下图：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-11-24/01.png)

用如下几个方法，弹出来的时间都带着日期

```csharp
MessageBox.Show(DateTime.Now.().ToString());
MessageBox.Show(DateTime.Now.ToLongTimeString().ToString());
MessageBox.Show(DateTime.Now.ToLongDateString().ToString());
MessageBox.Show(DateTime.Now.ToShortDateString().ToString());
```


用如下方法，虽然弹出来的时间没有带着日期，但是我数据库那边写的是DateTime型的参数，~~所以C#代码这边也应该存入一个DateTime类型的，而不是string类型的~~，这里也应该给一个日期类型的而不是字符串类型的。

```csharp
MessageBox.Show(DateTime.Now().ToString("yyyy/MM/dd hh:mm:ss"));
```



当尝试将字符串的时间再次强转为DateTime的时候，还是带了日期， -_-  好无奈~。

```csharp
MessageBox.Show((Convert.ToDateTime(dt1.Date.ToString("yyyy/MM/dd hh:mm:ss")).ToString()));
```



## 原因

原来和我PC设置有关系，我之前设置的时候把星期给带上了（这种情况其实很多见，比如国外的每周的第一天是周日，而我们通常是周一，很多软件--通常是日程安排类的，是直接根据本机设置的每周第一天作为它自己的每周第一天），所以在这里，把这个格式改成不带日期的就没问题了。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-11-24/03.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-11-24/04.png)





## 解决方法一：直接修改本机时间格式

将这里的时间格式改成如下格式，则时间不带星期了。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-11-24/05.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-11-24/06.png)



下面这个方法也只能更改时间，而不能更改系统显示时间的格式

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-11-24/07.png)



## 解决方法二：修改注册表

注册表，还真是万能的。。。

上面那种修改挺简便的，但是如果是客户的机器上设置了 显示日期，总不能也叫他这样修改吧。这个方法的思路是一开始进入程序的时候就设置系统时间的格式，将系统时间设置成我们想要的格式。

通过修改注册表中的   `HKEY_CURRENT_USER → Control Panel → International`



![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-11-24/08.png)

```csharp
// 通过注册表修改当前的系统日期格式
public static void Main(string[] args)
{
    // 在注册表中修改完时间格式之后，没有办法立刻在 任务栏 刷新，必须杀死explorer进程，然后重新开启，才行。。。
    // 不知道有没有办法刷新那个任务栏。平常我们改时间格式的时候是可以马上看到修改后的效果的。。。
    RegistryKey rkInternational = Registry.CurrentUser.OpenSubKey(@"Control Panel\International", true);
    rkInternational.SetValue("sShortDate", "yyyy/MM/dd dddd");
    
    // 得到所有名为explorer的进程，把他干掉
    Process[] ps = Process.GetProcessesByName("explorer");
    foreach (Process p in ps) {
        p.Kill();       // 将其杀死
        // p.Refresh(); // Refresh()没有用。。。
    }
    
    // 然后重新运行explorer
    Process.Start("explorer.exe");
    Console.WriteLine("成功");
    Console.ReadKey();
}
```

