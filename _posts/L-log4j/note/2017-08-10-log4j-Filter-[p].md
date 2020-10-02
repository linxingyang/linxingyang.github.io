---
layout: post
permalink: /:year/bb97a16f894d42aaab09bc92c3785ccf
title: 2017-08-10-log4j-filter
categories: [log4j]
tags: [java,log4j,log4j系列]
relative-tags: [log4j系列]
excerpt: java,log,log4j,日志,源码,filter
description: java,log,log4j,日志,源码,filter
catalog: true
author: 林兴洋
---


基于log4j版本：1.2.17


# 1. Log4j #



## 7.Filter ##



### 7.0 类图 ###

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/L-log4j/image/2017-08-05/01.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/L-log4j/image/2017-08-05/01.png)



### 7.1 Filter<abstract> ###



过滤器，在threshold的基础上，用于实现进一步的过滤。

可以在一个Appender上添加多个过滤器。

```java

    // 返回
    // -1 不打印这个日志，不用经过下一个日志器判断
    // 0 不决定，调用下一个过滤器
    // 1 直接打印这个日志，不用经过下一个日志器判断
 abstract public int decide(LoggingEvent event);

  public void setNext(Filter next) {
    this.next = next;
  }


  public Filter getNext() {
        return next;
  }
```


### 7.2 DenyAllFilter ###

不打印所有的日志，可以与其他配合使用
```java
  public int decide(LoggingEvent event) {
    return Filter.DENY;
  }
```


### 7.3 LevelMatchFilter ##

匹配levelToMatch所对应的日志等级，若
* acceptOnMatch=false 则不打印
* acceptOnMatch=true 则打印
```
#log4j.appender.c1.filter.F=org.apache.log4j.varia.LevelMatchFilter
#log4j.appender.c1.filter.F.acceptOnMatch=false
#log4j.appender.c1.filter.F.levelToMatch=WARN
```

### 7.4 LevelRangeFilter ###

匹配范围，不在范围内的不打印。若在范围内
* acceptOnMatch = true 则直接打印
* acceptOnMatch = false 则调用下一个filter判断是否打印

```
#log4j.appender.c1.filter.F=org.apache.log4j.varia.LevelRangeFilter
#log4j.appender.c1.filter.F.LevelMin=INFO
#log4j.appender.c1.filter.F.LevelMax=ERROR
#log4j.appender.c1.filter.F2.acceptOnMatch=true
```

### 7.5 StringMatchFilter ###

字符串匹配过滤器。根据stringToMatch所指定的字符串，如果匹配到该字符串，若
* acceptOnMatch = true 则打印
* acceptOnMatch = false 则不打印

此处配合DenyAllFilter，使得只打印日志中包含 lxylog 的日志，在大型项目中，我们只负责部分模块开发，则这样设置就可以不用打出大量的别人的日志了。当然一些底层框架的日志也无法显示了。不过都可以过滤，比如想要hibernate的日志，可以相应的配置一个即可（未尝试，设想，因为所有Hibernate的日志都有Hibernate的标识）。


```
log4j.appender.c1.filter.G=org.apache.log4j.varia.DenyAllFilter

log4j.appender.c1.filter.F2=org.apache.log4j.varia.StringMatchFilter
log4j.appender.c1.filter.F2.acceptOnMatch=true
log4j.appender.c1.filter.F2.stringToMatch=lxylog

```

**此处需要注意的一点就是，由于log4j载入这两个过滤器（如上是G和F2）不是按照配置的顺序，而是按照ABC字母顺序（即先配置A，后B，最后C）这样的顺序，所以上面DenyAllFilter过滤器的名字为G而StringMatchFilter为F2，因为F2会在G之前被读取配置，如果DenyAllFilter为F2，StringMatchFilter为G，那么就不会打印出日志了。**


