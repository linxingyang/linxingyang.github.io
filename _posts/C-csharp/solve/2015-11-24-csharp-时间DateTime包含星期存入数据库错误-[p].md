---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab4d2add
title: 2015-11-24-csharp-时间DateTime包含星期存入数据库错误
categories: [编程]
tags: [c#]
excerpt: csharp,mysql,问题解决,时间错误
description: csharp时间DateTime包含星期存入mysql数据库错误
gitalk-id: 8b072ff2a1da49c2be51643cab4d2add
toc: true
---

# csharp时间DateTime包含星期存入mysql数据库错误

## 问题

发现我要存到数据库中的时间DateTime中间多了星期 ，即 （2015/11/24 星期二 21:48:54 ）这种格式的时间，mysql报错说格式时间不正确。

![图](http://image.linxingyang.net/image/C-csharp/image/2015-11-24/01.png)

我用如下方法，弹出来的时间都带着日期，

```csharp
MessageBox.Show(DateTime.Now.().ToString());
MessageBox.Show(DateTime.Now.ToLongTimeString().ToString());
MessageBox.Show(DateTime.Now.ToLongDateString().ToString());
MessageBox.Show(DateTime.Now.ToShortDateString().ToString());
```

我用如下方法，虽然弹出来的时间没有带着日期，但是我数据库那边写的是DateTime型的参数，所以C#代码这边也应该存入一个DateTime类型的，而不是string类型的

```
MessageBox.Show(DateTime.Now().ToString("yyyy/MM/dd hh:mm:ss"));
```

当我将上面string再次强转为DateTime的时候，还是带了日期。

```csharp
MessageBox.Show((Convert.ToDateTime(dt1.Date.ToString("yyyy/MM/dd hh:mm:ss")).ToString()));
```

![图](http://image.linxingyang.net/image/C-csharp/image/2015-11-24/02.png)

## 原因

后来我发现，原来我的时间我之前设置的时候把星期给带上了，所以这边会一直弹出时间。

![图](http://image.linxingyang.net/image/C-csharp/image/2015-11-24/03.png)

![图](http://image.linxingyang.net/image/C-csharp/image/2015-11-24/04.png)

## 问题解决

### 解决方法一

将这里的时间格式改成如下格式，则时间不带星期了。

![图](http://image.linxingyang.net/image/C-csharp/image/2015-11-24/05.png)

![图](http://image.linxingyang.net/image/C-csharp/image/2015-11-24/06.png)

下面这个方法也只能，更改时间，而不能更改系统显示时间的格式

![图](http://image.linxingyang.net/image/C-csharp/image/2015-11-24/07.png)

### 解决方法二

上面那种修改挺简便的，但是如果是客户的机器上设置了 显示日期，总不能也叫他这样修改吧。
这个方法的思路是一开始进来就设置系统时间的格式，将系统时间设置成我们想要的格式。
通过修改注册表中的   `HKEY_CURRENT_USER → Control Panel → International`

![图](http://image.linxingyang.net/image/C-csharp/image/2015-11-24/08.png)

```csharp
 //通过注册表修改当前的系统日期格式
        public static void Main(string[] args)
        {
            //我发现，在注册表中修改完时间格式之后，没有办法立刻在 任务栏 刷新，必须杀死任务栏进程，然后重新开启，才行。。。不知道有没有办法刷新那个任务栏。应该平常我们改时间格式的时候是可以马上看到修改后的效果的。。。
            RegistryKey rkInternational = Registry.CurrentUser.OpenSubKey(@"Control Panel\International", true);
            rkInternational.SetValue("sShortDate", "yyyy/MM/dd dddd");
            //得到所有名为 explorer （任务栏）的程序
            Process[] ps = Process.GetProcessesByName("explorer");
            foreach (Process p in ps)
            {
                //将其杀死
                p.Kill();
                //Refresh()没有用。。。
                //p.Refresh();
            }
            //然后在重新运行。
            Process.Start("explorer.exe");
            Console.WriteLine("成功");
            Console.ReadKey();
        }
```
