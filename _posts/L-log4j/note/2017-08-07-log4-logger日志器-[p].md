---
layout: post
permalink: /:year/bb97a16f894321aaab09bc92c3785ccf
title: 2017-08-07-log4j-Logger日志器
categories: [log4j]
tags: [java,log4j,log4j系列]
relative-tags: [log4j系列]
excerpt: java,log,log4j,日志,源码,日志器,logger
description: java,log,log4j,日志,源码,日志器,logger
catalog: true
author: 林兴洋
---

基于log4j版本：1.2.17

# 1. Log4j #


## 4. 日志器 ##

日志器Logger，我们调用它的debug,info...方法来打印日志，一个日志器拥有多个Appender用于输出到不同终端，拥有一个Level，该logger所打印的日志要高于或等于该Level。

### 4.1 类图结构 ###

![https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/L-log4j/image/2017-08-05/loggerstruct.png](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/L-log4j/image/2017-08-05/loggerstruct.png)

### 4.2 AppenderAttachable 接口 ###

一个日志器可以拥有多个Appender，用于向不同的终端输出日志。该接口定义了一些日志器处理Appender的接口。

* addAppender 添加一个Appender
* removeAppender  移除一个Appender
* isAttachAppender 判断该日志器是否包含一个指定的Appender
* ...

### 4.3 Category ###

这个类是Logger的父类，官方文档不建议使用这个Category。估计Category是之前命名不好的坑，所以使用Logger来使得命名更加清晰，在log4j1.2中仍然支持但不推荐使用Category，比如我们就可以在log4j.properties中

```xml

log4j.rootLogger=debug,console
# 改成如下，log4j内部也是有处理的。
log4j.rootCategory=debug,console

```



### additivity



additivity表示着当前的日志器是否要利用父亲的appender进行输出。

```
additivity=true表示是
additivity=false表示否。
```

例如现在有两个日志器 ：rootLogger以及自己定义的 logtest.LogTest
他们各有两个输出的appender，都是一个console一个file。

现在如果没有配置这一行

```

log4j.additivity.logtest.LogTest=false

```

log4j.logger.logtest.LogTest的父日志器log4j.rootLogger也会打印其要打印的内容。



```properties
log4j.rootLogger=debug, c1, A1

log4j.appender.c1=org.apache.log4j.ConsoleAppender

log4j.appender.c1.layout=org.apache.log4j.PatternLayout

log4j.appender.c1.layout.ConversionPattern=[${clientId}]%d{yyyy-MM-dd HH\:mm\:ss} [%p] %m [%t] %c [%l]%n

log4j.appender.A1=org.apache.log4j.FileAppender

log4j.appender.A1.File=log.txt

log4j.appender.A1.Append=true

log4j.appender.A1.layout=org.apache.log4j.SimpleLayout

```

如果配置了这一行，则其父不会打印。



```properties
log4j.logger.logtest.LogTest=error, c2, A2

log4j.additivity.logtest.LogTest=false

log4j.appender.c2=org.apache.log4j.ConsoleAppender

log4j.appender.c2.layout=org.apache.log4j.PatternLayout

log4j.appender.c2.layout.ConversionPattern=[${clientId}]%d{yyyy-MM-dd HH\:mm\:ss} [%p] %m [%t] %c [%l]%n

log4j.appender.A2=org.apache.log4j.FileAppender

log4j.appender.A2.File=log222.txt

log4j.appender.A2.Append=true

log4j.appender.A2.layout=org.apache.log4j.SimpleLayout

```





### 4.4 Logger 日志器 ###

Logger类是log4j的中心类，除了解析配置，大多数日志操作是通过这个类完成的。

### 4.5 RootLogger,RootCategory，根日志器 ###

根日志器。这两个其实可以看做是同一个，估计也是命名的坑，RootCategory被标记为 @deprecated了。


#### 为什么要有根日志器？ ####

这里得讲讲log4j日志器的复用，详细请看看前一篇博客[自定义日志器](/2017/bb97a16f894d42aaab09bc92c3785fcf)，从中我们知道有必要对日志器进行复用，在那篇博客中，最终通过复用Output达到复用的效果。


在Log4j中，它的复用机制跟Log4j的日志器仓库（后面会讲到）也有关系，但是这里我们只讲Log4j默认的日志器仓库 Hierarchy---层次结构的仓库。在Hierarchy这个层次结构的仓库中，日志器是以名称为层次结构存储的。而我们java类和包的结构就是层次的。因此log4j提供了层次仓库，通过class获得类的全限定名，以此作为日志器名称。

如下有三个类，分别
* com.linxingyang.Test1.java
* com.linxingyang.a.Test2.java
* com.linxingyang.b.Test3.java

类图层次结构结构如下：

* com
  * linxingyang
    * a
      * Test2.java
    * b
      * Test3.java
    * Test1.java


例如我们在com.linxingyang.Test1.java中，定义了日志器

```java

Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
}

```

这个操作会创建一个日志器。这个日志器的名称就是  com.linxingyang.Test1，（log4j内部是通过class.getName()获取日志器名称的）。

那么这个日志器的父亲就是com.linxingyang, 

com.linxingyang的父亲就是com,

那com的父亲是谁？就是根日志器了。类似于Object是所有类的祖先一样，根日志器是所有日志器的祖先。

#### 为什么要使用继承的结构？ ####
想想java为什么要有继承，前面也说过，为了复用。复用父类的Appender,Level等。

```

log4j.rootLogger=debug,console

```

我们在根日志器中定义的Level和这个console（Appender），都可以被rootLogger的子类复用。这就是为什么要有根日志器的存在。

#### 那是不是必须要配置根日志器？ ####

不必，根日志器的存在是为了复用，还是以这个类包结构为例

* com
  * linxingyang
    * a
      * Test2.java
    * b
      * Test3.java
    * Test1.java

* 如果我们在配置文件中com这个日志器，那么com.linxingyang.Test1这个日志器就会复用com这个日志器的Appender和Level等，

* 如果我们配置com和com.linxingyang这两个日志器，那么com.linxingyang.Test1就会复用这两个日志器的Appender和Level。

#### 是否必须要/会复用父类的东西？ ####

不必，可以配置 additivity=false ，这样就不会使用父类的Appender。

同样，如果设置了自己的Level，也不会使用父类的Leven。


#### 测试代码 ####

如下，没有配置根日志器，只配置了一个com日志器。

```xml

log4j.logger.com=debug, console
log4j.additivity.com=false
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=abcd%d{yyyy-MM-dd HH\:mm\:ss} [%p] %m [%t] %c [%l]%n

```

进行测试，打印一句话。

```java

package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("message  from Test1 ");
	}
}

```

测试结果，看到是可以正常打日志的。

```xml

abcd2017-12-06 12:31:22 [DEBUG] message  from Test1  [main] com.linxingyang.Test1 [com.linxingyang.Test1.main(Test1.java:8)]

```

### 4.6 NOPLogger ###

No-operation ,这个日志中的debug等方法不做任何操作的日志器。为了在不想做任何输出的时候，Log4j系统能够正常的运行。


