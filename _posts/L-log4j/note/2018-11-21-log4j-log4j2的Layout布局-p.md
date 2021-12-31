---
layout: post
permalink: /:year/linxingyangwriteat20211212120836/index
title: log4j-log4j2的Layout布局
categories: [log4j]
tags: [post, log4j, java]
date: 2018-11-21 12:08:36 +8
place: 新大陆软件园
editdate: 2021-12-12 12:08:36 +8
eidtplace: 福州软件园
excerpt: log4j,log4j2,layout
description: log4j-log4j2的Layout布局
catalog: true
author: 林兴洋
---

# log4j2

## Layout

### PatternLayout 格式化输出布局 

PatternLayout内容来自之前整理的log4j，不是log4j2的，不过差不多。

代码中有一些同步和其他问题，这些问题在EnhancedPatternLayout中已经被解决。所以应该使用EnhancedPatternLayout代替PatternLayout。

#### % 百分号

在 PatternLayout中，使用百分号作为转换格式符的前缀。如果两个`%%`同时出现，那么就是转义了。

#### %c %c{数字} 输出日志器的名称

输出日志器名称。%c输出完整的日志器名称，若日志器名称`com.linxingyang.Test1` 那么 `%c{2}` 那么就只会输出`linxingyang.Test1`。

##### 测试代码

配置

```xml
log4j.appender.console.layout.ConversionPattern=%c | %c{1} | %c{2} | %c{3} | %c{4}
```

结果：%c{1}只输出类名，%c{2}输出了类名以及上一级包名，%c{3}输出了类名以及前两级包名。

```
com.linxingyang.Test1 | Test1 | linxingyang.Test1 | com.linxingyang.Test1 | com.linxingyang.Test1
```

####  %C %C{数字} 输出调用者的名称

我们的一个名为`com.linxingyang.Test1` 的日志器，它不仅可以被`com.linxingyang.Test1`自身使用，也可能被其它类使用。比如 我们在`com.linxingyang.a.Test2`中使用到了它。

##### 测试代码

配置如下，注意第一个c是小写的，后面c都是大写的

```xml
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%c | %C | %C{1} | %C{2} | %C{3} | %C{4}
```

测试代码，`com.linxingyang.a.Test2`类中使用`com.linxingyang.Test1`这个类的class作为获取日志器的key。

```java
package com.linxingyang.a;

import org.apache.log4j.Logger;
import com.linxingyang.Test1;

public class Test2 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("message  from Test2 ");
	}
}
```

从结果可以看出，第一个c打印结果为 com.linxingyang.Test1 ，其后大写的C打印的都是Test2.另外C{数字}和c{数字}的作用是一样的。

```
com.linxingyang.Test1 | com.linxingyang.a.Test2 | Test2 | a.Test2 | linxingyang.a.Test2 | com.linxingyang.a.Test2
```

#### %d 输出打印日志的日期时间

##### log4j自定义的几个日期格式 #####

log4j自己本身也有实现几个日志格式
* org.apache.log4j.helpers.ISO8601DateFormat
* org.apache.log4j.helpers.DateTimeDateFormat
* org.apache.log4j.helpers.AbsoluteTimeDateFomat

我们可以简便的使用它们
* %d{ISO8601}
* %d{DATE}
* %d{ABSOLUTE}

如果我们使用%d并且后面什么都不跟，那么默认就是使用 %d{ISO8601}

###### 测试代码

配置

```xml
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=[%%d][%d] --- [%%d{ABSOLUTE}][%d{ABSOLUTE}] --- [%%d{ISO8601}][%d{ISO8601}] --- [%%d{DATE}][%d{DATE}]
```

代码

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

测试结果，可以看到%d和%d{ISO8601}结果是一样的。

```
[%d][2017-12-06 20:52:50,157] --- [%d{ABSOLUTE}][20:52:50,157] --- [%d{ISO8601}][2017-12-06 20:52:50,157] --- [%d{DATE}][06 十二月 2017 20:52:50,157]
```

##### 使用适用于SimpleDateFormat的格式

在%d后面可以跟和SimpleDateFormat中可以解析的日期格式串，例如%d{HH:mm:ss, SSS}，只要能够同样用SimpleDateFormat进行初始化的就行。

```java
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
```

###### 测试代码

配置

```xml
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss}
```

结果

```
2017-12-06 21:51:19
```

#### %F 输出文件名

输出文件名。使用%F会影响程序的速度。如果速度有要求的程序，不要使用，如果速度不是问题，可以使用这个。

##### 测试代码

```xml
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%F
```

```java
package com.linxingyang.a;

import org.apache.log4j.Logger;

import com.linxingyang.Test1;

public class Test2 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("message  from Test2 ");
	}
}
```

输出

```
Test2.java
```

#### %l 打印出打印日志类的详细信息

打印出全限定名以及行号。这个很有用但是同样的，如果应用比较在乎速度，不要使用这个。

##### 测试代码

配置

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%l
```

java代码

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

结果

```
com.linxingyang.a.Test2.main(Test2.java:10)
```

#### %L 输出行号

这个只输出行号，同样的，使用这个是比较慢的，所以如果在追求速度的程序中，不要使用这个。

##### 测试代码

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%L
```

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

输出

```
8
```

#### %n 换行

换行符  \n  \r\n。 默认打出日志是不会换行的，使用 %n 进行换行。测试代码和%m整合在一起了。

#### %m 输出日志内容

##### 测试代码

配置

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%m
```

java代码

```java
package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("message  from Test1 ");
		
		method1();
		method2();
	}
	public static void method1() {
		log.debug("message  from Test1 ");
		
	}
	public static void method2() {
		
		log.debug("message  from Test1 ");
	}
}
```

输出结果

```
message  from Test1 message  from Test1 message  from Test1
```

发现输出结果都记在一行里面，下面使用 %n

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%m %n
```

输出结果，%n使之换行了。

```
message  from Test1  
message  from Test1  
message  from Test1  
```

#### %M 输出日志的方法名

同样的，使用这个是比较慢的，所以如果在追求速度的程序中，不要使用这个。

##### 测试代码

配置

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%M %m %n
```

java代码

```java
package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("message  from Test1 ");
		
		method1();
		method2();
	}
	public static void method1() {
		log.debug("message  from Test1 ");
		
	}
	public static void method2() {
		
		log.debug("message  from Test1 ");
	}
}
```

输出结果，可以看到，打印出了输出日志的方法名。

```
main message  from Test1  
method1 message  from Test1  
method2 message  from Test1  
```

#### %p 输出日志的优先级/等级

因为Level继承类 Priority，所以说优先级等同于等级。

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%p %n
```

java代码

```java
package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("message  from Test1 ");
		
		method1();
		method2();
	}
	public static void method1() {
		log.info("message  from Test1 ");
		
	}
	public static void method2() {
		
		log.error("message  from Test1 ");
	}
}
```

输出结果

```
DEBUG 
INFO 
ERROR 
```

#### %r Layout创建到日志输出的时间

输出layout的创建直到日志事件的创建用了多少毫秒

##### 测试代码

配置

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%r %n
```

java代码

```java
package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("message  from Test1 ");
		
		method1();
		method2();
	}
	public static void method1() {
		try {
			Thread.sleep(1 * 2000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		log.info("message  from Test1 ");
		
	}
	public static void method2() {
		try {
			Thread.sleep(1 * 1000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		log.error("message  from Test1 ");
	}
}
```

测试结果，可以看出，第一个日志马上打印，第二个日志隔了2秒，第三个隔了3秒（第二个日志的两秒+自己的1秒=3秒）。

```language
0 
2000 
3000 
```

#### %t 打印输出日志的线程

##### 测试代码

配置

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%t %n
```

测试代码

```java
package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("message  from Test1 ");
		
		
		new Thread(new Runnable() {
			@Override
			public void run() {
				method1();
			}
		}).start();
		
		new Thread(new Runnable() {
			@Override
			public void run() {
				method2();
			}
		}).start();
	}
	public static void method1() {
		log.info("message  from Test1 ");
		
	}
	public static void method2() {
		log.error("message  from Test1 ");
	}
}
```

结果

```language
main 
Thread-0 
Thread-1 
```

#### %x NDC

x是为NDC准备的。 注意，如果没有NDC，但是还是用了%x，将会输出null

##### 测试代码

配置

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%x - %m%n
```

java代码

```java
package com.linxingyang;

import org.apache.log4j.Logger;
import org.apache.log4j.NDC;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		new Thread(new Runnable() {
			@Override
			public void run() {
				NDC.push("cline_a");
				log.debug("111");
				log.fatal("111");
				System.out.println("111调用pop结果是" + NDC.pop());
				NDC.remove();
			}
		}).start();
		new Thread(new Runnable() {
			@Override
			public void run() {
				NDC.push("client_b");
				log.debug("222");
				log.fatal("222");
				System.out.println("2222调用pop方法，返回的值是 : " + NDC.pop());
				System.out.println("2222如果再次调用pop，结果是：" + NDC.pop());
				NDC.remove();
			}
		}).start();
		new Thread(new Runnable() {
			@Override
			public void run() {
				NDC.push("cline_c");
				log.debug("333");
				log.fatal("333");
				System.out.println("3333调用pop结果是" + NDC.pop());
				NDC.remove();
			}
		}).start();
	}
}
```

测试结果

```
cline_c - 333
cline_c - 333
3333调用pop结果是cline_c
client_b - 222
client_b - 222
2222调用pop方法，返回的值是 : client_b
2222如果再次调用pop，结果是：
cline_a - 111
cline_a - 111
111调用pop结果是cline_a
```

#### %X MDC

X是为MDC准备的

##### 测试代码

配置，直接使用 %X

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%X - %m%n
```

测试代码

```java
package com.linxingyang;

import org.apache.log4j.Logger;
import org.apache.log4j.MDC;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		new Thread(new Runnable() {
			@Override
			public void run() {
				MDC.put("a", "obja");
				log.debug("111");
				log.fatal("111");
				MDC.remove("a");
			}
		}).start();
		new Thread(new Runnable() {
			@Override
			public void run() {
				MDC.put("b", "objb");
				log.debug("222");
				log.fatal("222");
				MDC.remove("b");
			}
		}).start();
		new Thread(new Runnable() {
			@Override
			public void run() {
				MDC.put("c", "objc");
				log.debug("333");
				log.fatal("333");
				MDC.remove("c");
			}
		}).start();
	}
}
```

测试结果

```
{{a,obja}} - 111
{{a,obja}} - 111
{{c,objc}} - 333
{{c,objc}} - 333
{{b,objb}} - 222
{{b,objb}} - 222
```


配置，也可以%X{key}，

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%X{b} - %m%n
```

java代码同上，测试结果,发现其他日志也有输出，但是key为b的日志输出了其value，增加辨识度。

```
objb - 222
 - 333
 - 111
 - 333
objb - 222
 - 111
```

#### %m 左右对其，最大最小宽度

* %m   百分号和转换字符之间可以指定最大最小宽度，以及对其时，若不足在左边还是右边填充空格。
* %20m 该例数字代表最小字符为20字符，默认填充是左填充。
* %-20m 该例数字代表最小字符为20字符，填充是右填充。
* %20.30m  该例代表最小字符为20字符，最大为30字符，左填充
* %-20.30m 该例代表最小20字符，最大30字符，右填充

当所输出的字符小于最小字符时，填充空格。当输出的字符大于最大字符时，进行截取，从字符串前面开始移除多出的字符。

##### 测试最小宽度，左右填充

配置

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=[%20m] [%-20m] %n
```

测试代码

```java
package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("123456789");
	}
}
```

输出结果，可以看到第一个输出左边填充。 第二个输出右边填充。

```

[                     123456789] [123456789                     ]

```

##### 测试最大宽度，左右填充

配置

```xml
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=[%5.5m] [%-5.5m] %n
```

测试代码

```java
package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
    	log.debug("1234");
		log.debug("123456789");
	}
}
```

测试结果，可以看出，超过长度，从字符串开头开始截取。

```
[ 1234] [1234 ] 
[56789] [56789] 
```


### JSONLayout

来来，看看可以设置的属性

#### charset String 编码

默认使用UTF-8

#### eventEol boolean 行尾换行

如果为true，给每条记录添加换行符，默认false

eventEol=ture 配合 compact=true 来实现 一条记录一行的效果


#### properties boolean 属性

如果为true，那么将会生成线程的上下文JSON数据，加入到要打印的日志中，

默认false


#### propertiesAsList boolean

配合上面的 properties使用。

如果为true，线程上下文的键值对作为会作为键值对，每个键值对会映射成JSON中的键值对


这里两个例子只是我手动举例，就是这个意思，格式不一定对

```
"contextMap" : {a:1, b:2 },
```


默认false，那么所有键值对，只会映射成一个键值对。


```
"contextMap" : "a=1,b=2",
```


#### locationInfo boolean  位置信息

如果为true， 将会包含位置信息，

默认为false，因为开启这个需要消耗额外的操作和性能，谨慎使用

没有添加locationInfo
```
{
  "thread" : "main",
  "level" : "ERROR",
  "loggerName" : "net.linxingyang.test.log4j2.Test",
  "message" : "{age=18, name=lxy}",
  "endOfBatch" : false,
  "loggerFqcn" : "org.apache.logging.log4j.spi.AbstractLogger",
  "instant" : {
    "epochSecond" : 1542858026,
    "nanoOfSecond" : 772000000
  },
  "contextMap" : { },
  "threadId" : 1,
  "threadPriority" : 5
}
```

添加了locationInfo，多了一个source
```
{
  "thread" : "main",
  "level" : "ERROR",
  "loggerName" : "net.linxingyang.test.log4j2.Test",
  "message" : "{age=18, name=lxy}",
  "endOfBatch" : false,
  "loggerFqcn" : "org.apache.logging.log4j.spi.AbstractLogger",
  "instant" : {
    "epochSecond" : 1542858439,
    "nanoOfSecond" : 206000000
  },
  "contextMap" : { },
  "threadId" : 1,
  "threadPriority" : 5,
  "source" : {
    "class" : "net.linxingyang.test.log4j2.Test",
    "method" : "main",
    "file" : "Test.java",
    "line" : 33
  }
}
```

#### includeStacktrace boolean 包含栈追溯

如果为真，将会把Throwable的完整的堆栈打印出来

默认false ，但是不建议啊，，，这个错误链太长了。。要传输的数据感觉会增长不少

```json 
{
  "thread" : "main",
  "level" : "ERROR",
  "loggerName" : "net.linxingyang.test.log4j2.Test",
  "message" : "java.lang.ArithmeticException: / by zero\r\n\tat net.linxingyang.test.log4j2.Test2.test1(Test2.java:11)\r\n\tat net.linxingyang.test.log4j2.Test2.test2(Test2.java:14)\r\n\tat net.linxingyang.test.log4j2.Test2.test3(Test2.java:6)\r\n\tat net.linxingyang.test.log4j2.Test.main(Test.java:35)\r\n",
  "thrown" : {
    "commonElementCount" : 0,
    "localizedMessage" : "/ by zero",
    "message" : "/ by zero",
    "name" : "java.lang.ArithmeticException",
    "extendedStackTrace" : [ {
      "class" : "net.linxingyang.test.log4j2.Test2",
      "method" : "test1",
      "file" : "Test2.java",
      "line" : 11,
      "exact" : false,
      "location" : "classes/",
      "version" : "?"
    }, {
      "class" : "net.linxingyang.test.log4j2.Test2",
      "method" : "test2",
      "file" : "Test2.java",
      "line" : 14,
      "exact" : false,
      "location" : "classes/",
      "version" : "?"
    }, {
      "class" : "net.linxingyang.test.log4j2.Test2",
      "method" : "test3",
      "file" : "Test2.java",
      "line" : 6,
      "exact" : false,
      "location" : "classes/",
      "version" : "?"
    }, {
      "class" : "net.linxingyang.test.log4j2.Test",
      "method" : "main",
      "file" : "Test.java",
      "line" : 35,
      "exact" : true,
      "location" : "classes/",
      "version" : "?"
    } ]
  },
  "endOfBatch" : false,
  "loggerFqcn" : "org.apache.logging.log4j.spi.AbstractLogger",
  "instant" : {
    "epochSecond" : 1542864841,
    "nanoOfSecond" : 818000000
  },
  "contextMap" : { },
  "threadId" : 1,
  "threadPriority" : 5,
  "source" : {
    "class" : "net.linxingyang.test.log4j2.Test",
    "method" : "main",
    "file" : "Test.java",
    "line" : 38
  }
}

```

#### stacktraceAsString boolean 完美解决堆栈过长的问题

但是数据量好像没有缩小很多。不过这样子，打印那个 thrown中的exntedsStrackTrace会很方便。

```json
{
  "thread" : "main",
  "level" : "ERROR",
  "loggerName" : "net.linxingyang.test.log4j2.Test",
  "message" : "java.lang.ArithmeticException: / by zero\r\n\tat net.linxingyang.test.log4j2.Test2.test1(Test2.java:11)\r\n\tat net.linxingyang.test.log4j2.Test2.test2(Test2.java:14)\r\n\tat net.linxingyang.test.log4j2.Test2.test3(Test2.java:6)\r\n\tat net.linxingyang.test.log4j2.Test.main(Test.java:35)\r\n",
  "thrown" : {
    "commonElementCount" : 0,
    "localizedMessage" : "/ by zero",
    "message" : "/ by zero",
    "name" : "java.lang.ArithmeticException",
    "extendedStackTrace" : "java.lang.ArithmeticException: / by zero\n\tat net.linxingyang.test.log4j2.Test2.test1(Test2.java:11) ~[classes/:?]\n\tat net.linxingyang.test.log4j2.Test2.test2(Test2.java:14) ~[classes/:?]\n\tat net.linxingyang.test.log4j2.Test2.test3(Test2.java:6) ~[classes/:?]\n\tat net.linxingyang.test.log4j2.Test.main(Test.java:35) [classes/:?]\n"
  },
  "endOfBatch" : false,
  "loggerFqcn" : "org.apache.logging.log4j.spi.AbstractLogger",
  "instant" : {
    "epochSecond" : 1542865105,
    "nanoOfSecond" : 812000000
  },
  "contextMap" : { },
  "threadId" : 1,
  "threadPriority" : 5,
  "source" : {
    "class" : "net.linxingyang.test.log4j2.Test",
    "method" : "main",
    "file" : "Test.java",
    "line" : 38
  }
}

```


#### includeNullDelimiter boolean 是否包含一个null字节作为分隔符

是否在每个事件后包含一个NULL字节作为分隔符。默认false

#### objectMessageAsJsonObject boolean 是否把日志消息作为JSON消息

#### 包含本地键值对

注意，要和ObjectMessage合用。如下例子

```java
import org.apache.logging.log4j.message.ObjectMessage;

// 如下这个LogMessage是我的日志对象
LogMessage logMessagex = new LogMessage();
logMessagex.setMsg("xxxxx");
// 使用log4j2提供的ObjectMessage来封装自己的LogMessage对象，然后就可已打印键值对的消息了
ObjectMessage objectMessage = new ObjectMessage(logMessagex);
logger.debug(objectMessage);
```

还支持本地键值对,其中value的值支持lookup查找。详细查看lookup查找[http://logging.apache.org/log4j/2.x/manual/lookups.html](http://logging.apache.org/log4j/2.x/manual/lookups.html)

```
  <JsonLayout>
    <KeyValuePair key="additionalField1" value="constant value"/>
    <KeyValuePair key="additionalField2" value="$${ctx:key}"/>
  </JsonLayout>
```

#### complete boolean 完整格式的JSON VS JOSN片段

如果设置 complete=true，将会输出完整格式的JSON

默认complete=false，将会输出json片段

完整格式的JSON和JSON片段的区别就在于： 完整格式的JSON会在开头输出 `[` 在结尾输出 `]` 并且其中的JSON片段都是使用 `,` 隔开

json日志

```json

{
  "instant" : {
    "epochSecond" : 1493121664,
    "nanoOfSecond" : 118000000
  },
  "thread" : "main",
  "level" : "INFO",
  "loggerName" : "HelloWorld",
  "marker" : {
    "name" : "child",
    "parents" : [ {
      "name" : "parent",
      "parents" : [ {
        "name" : "grandparent"
      } ]
    } ]
  },
  "message" : "Hello, world!",
  "thrown" : {
    "commonElementCount" : 0,
    "message" : "error message",
    "name" : "java.lang.RuntimeException",
    "extendedStackTrace" : [ {
      "class" : "logtest.Main",
      "method" : "main",
      "file" : "Main.java",
      "line" : 29,
      "exact" : true,
      "location" : "classes/",
      "version" : "?"
    } ]
  },
  "contextStack" : [ "one", "two" ],
  "endOfBatch" : false,
  "loggerFqcn" : "org.apache.logging.log4j.spi.AbstractLogger",
  "contextMap" : {
    "bar" : "BAR",
    "foo" : "FOO"
  },
  "threadId" : 1,
  "threadPriority" : 5,
  "source" : {
    "class" : "logtest.Main",
    "method" : "main",
    "file" : "Main.java",
    "line" : 29
  }
}

```

#### compact 美化和压缩

默认JSON Layout 是不压缩的，即默认 compact=false，

如果compact=true，那么就没有换行已经缩进了。

