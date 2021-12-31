---
layout: post
permalink: /:year/bb97a16f8945544aab09bc92c3785ccf/index
title: log4j-Layout布局
categories: [log4j]
tags: [post, log4j, java]
date: 2017-08-08 03:42:52 +8
place: 新大陆软件园
editdate: 2021-12-12 03:42:52 +8
eidtplace: 福州软件园
excerpt: java,log,log4j,日志,源码,layout,布局
description: java,log,log4j,日志,源码,layout,布局
catalog: true
author: 林兴洋
---

# Log4j

## 5. Layout

输出日志的格式

### 5.1 类图结构

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/L-log4j/image/2017-08-05/layoutclassdiagram.png)

### 5.2 OptionHandler 接口

这个接口中只有一个方法 `void activateOptions();` 用于当前类的需要的所有配置项配置完成后调用。

延迟激活直到所有的配置项设置完毕，这对于那些有关系的配置项是很有必要的。例如 FileAppender有setFile和setApppend两个选项，只有这两项都加载完了，FileAppender才能正常工作，而在使用前，我们没办法知道这两个配置是否已经都加载完了，所以定义了一个激活配置项的方法，调用这个方法后，说明所有必须的配置都被加载完毕。

### 5.3 Layout

Layout接口，这个接口中最重要的一个抽象方法就是这个format，格式化日志事件成指定的格式并返回字符串。

```
abstract public String format(LoggingEvent event);
```

### 5.4 SimpleLayout 简单布局

只是在加了日志等级以及一个横杆。例如

#### 测试代码 

配置
```properties
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.SimpleLayout
```

代码中使用
```java
log.debug("hello world");
```

输出结果
```
DEBUG - hellow world
```

### 5.5 PatterLayout 格式化输出布局

代码中有一些同步和其他问题，这些问题在EnhancedPatternLayout中已经被解决。所以应该使用EnhancedPatternLayout代替PatternLayout。

#### % 百分号

在 PatternLayout中，使用百分号作为转换格式符的前缀。如果两个`%%`同时出现，那么就是转义了。

#### %c %c{数字} 输出日志器的名称 

输出日志器名称。%c输出完整的日志器名称，若日志器名称`com.linxingyang.Test1` 那么 `%c{2}` 那么就只会输出`linxingyang.Test1`。

##### 测试代码

配置

```properties
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

```properties
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

##### log4j自定义的几个日期格式

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

```properties
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

```properties
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

```properties
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

#### %l 打印出打印志类的详细信息

打印出全限定名以及行号。这个很有用但是同样的，如果应用比较在乎速度，不要使用这个。

##### 测试代码

配置

```properties
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

```properties
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

```properties
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

```properties
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

```properties
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

```properties
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

```properties
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

```properties
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

```properties
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

```properties
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

测试结果（因为jekyll语法，删除了一个左中括号）
```
{a,obja}} - 111
{a,obja}} - 111
{c,objc}} - 333
{c,objc}} - 333
{b,objb}} - 222
{b,objb}} - 222
```

配置，也可以%X{key}，

```properties
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

```properties
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

```properties
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

### 5.6 EnhancedPatternLayout

正如在PatterLayout中所说的，因为代码中有一些同步和其他问题，这些问题在EnhancedPatternLayout中已经被解决。所以应该使用EnhancedPatternLayout代替PatternLayout。

EnhancedPatternLayout大部分内容与PatternLayout相同，但有些地方不同，下面就列出不同的地方。

#### %c

%c{数字}， 数字部分现在支持不同了。提供的是命名省略模式，如下示例：

```
日志器名称：com.linxingyang.Test1

%c{2} 从输出后面两个元素 -->  linxingyang.Test1
%c{-2} 移除两个元素 --> Test1
%c{1.} --> c.l.Test1
%c{2.} --> co.li.Test1
%c{3.} --> com.lin.Test1
%c{3.1} --> com.l.Test1
%c{1.3} --> c.lin.Test1
```

#### %C

这个的修改也和上面的%c一样。使用%c,%C会影响速度，如果介意勿用。


#### %properties %properties{key}  查看日志事件的属性

这个 PatternLayout是不支持的。

%properties 以 { {key1, value1}, {key2, value2}}的方式输出所有包的属性值的键值对。发现好像和MDC指向了同一个地方。后面测试代码说明

%properties{key}  指定键输出值。

##### 测试代码

配置，配置说明，因为RewriteAppender只能使用xml配置方式。这里有3个console,都是向控制台输出，不同点是，console1输出`[%%X]`，是MDC， console2输出全部属性 %properties, console3输出指定属性 %properties{name}

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
	<appender name="console1" class="org.apache.log4j.ConsoleAppender">
		<layout class="org.apache.log4j.EnhancedPatternLayout">
			<param name="ConversionPattern" value="console1 -- [%%X]%X %m %n"/>
		</layout>
	</appender>
	<appender name="console2" class="org.apache.log4j.ConsoleAppender">
		<layout class="org.apache.log4j.EnhancedPatternLayout">
			<param name="ConversionPattern" value="console2 -- [%%properties]%properties %m %n"/>
		</layout>
	</appender>
	<appender name="console3" class="org.apache.log4j.ConsoleAppender">
		<layout class="org.apache.log4j.EnhancedPatternLayout">
			<param name="ConversionPattern" value="console3 -- [%%properties{name}]%properties{name} %m %n"/>
		</layout>
	</appender>
	<appender name="rewrite" class="org.apache.log4j.rewrite.RewriteAppender">
		<appender-ref ref="console1"/>
		<appender-ref ref="console2"/>
		<appender-ref ref="console3"/>
		<rewritePolicy class="org.apache.log4j.rewrite.PropertyRewritePolicy">
			<param name="properties" value="name=linxingyang,age=24,from=fuding"/>
		</rewritePolicy>
	</appender>
	
	<root>
		<level value="debug"></level>
		<appender-ref ref="rewrite"/>
	</root>
</log4j:configuration>
```

java代码，测试代码比较简单，就是输出两个日志。

```java
package com.linxingyang;

import java.io.FileNotFoundException;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException, InterruptedException {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		int i = 0;
		log.debug(sdf.format(Calendar.getInstance().getTime()) + "name debug message  " + i++);
		log.fatal(sdf.format(Calendar.getInstance().getTime()) + "fatal message  " + i++);
		LogManager.shutdown();
	}
}
```

结果，可以看到  %X，%properties 输出了全部属性，%properties{name}输出类指定属性。

```
console1 -- [%X]{age,24}{name,linxingyang}{from,fuding}} 2017-12-14 11:22:30name debug message  0 
console2 -- [%properties]{age,24}{name,linxingyang}{from,fuding}} 2017-12-14 11:22:30name debug message  0 
console3 -- [%properties{name}]linxingyang 2017-12-14 11:22:30name debug message  0 
console1 -- [%X]{age,24}{name,linxingyang}{from,fuding}} 2017-12-14 11:22:30fatal message  1 
console2 -- [%properties]{age,24}{name,linxingyang}{from,fuding}} 2017-12-14 11:22:30fatal message  1 
console3 -- [%properties{name}]linxingyang 2017-12-14 11:22:30fatal message  1 
```

#### %throwable 控制输出错误

这个PatternLayout是不支持的。如果我们的日志带了一个throwable，例如

```java
try {
    throw new NullPointerException("空指针了");
} catch(NullPointerException e) {
    log.error("空指针错误", e);
}
```

* %throwable 可以让我们对这里的 e 输出的堆栈信息进行控制。
* %throwable   不带参数，则默认显示全部堆栈。
* %throwable{none}, %throwable{0} 不显示错误日志
* %throwable{short}, %throwable{1} 显示错误堆栈的首行
* %throwable{n} 显示n行错误堆栈

##### 测试代码

配置， 不显示错误堆栈

```properties
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%throwable{none} %m%n
```

java代码

```java
package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		m1();
		
	}
	private static int i = 0;
	private static void m1() {
		
		if (i < 10) {
			i++;
			m1();
		} else {
			try {
				throw new NullPointerException("空指针了");
			} catch(NullPointerException e) {
				log.error("空指针错误", e);
			}
		}
	}
}
```

结果 

```
空指针错误
```

修改配置成，输出全部错误信息

```properties
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%throwable %m%n
```

结果 ,显示错误信息及堆栈信息

```

java.lang.NullPointerException: 空指针了
	at com.linxingyang.Test1.m1(Test1.java:19)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.main(Test1.java:8)
 空指针错误

```


修改配置成，输出5行错误信息

```properties
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%throwable{5} %m%n
```

结果，输出五行堆栈信息

```
java.lang.NullPointerException: 空指针了
	at com.linxingyang.Test1.m1(Test1.java:19)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.m1(Test1.java:16)
	at com.linxingyang.Test1.m1(Test1.java:16)
 空指针错误
```

### 5.7 HTMLLayout

将输出的日志设置为html格式。

它有两个属性可以配置
#### title : html文档的标题
#### locationInfo ： 如果设置为true，将会显示打印日志所在的文件以及行号

#### 测试代码

配置

```properties
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.HTMLLayout
log4j.appender.console.layout.title=hello HtmlLayout
log4j.appender.console.layout.locationInfo=true
```

测试 

```java
package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("111");
		log.info("111");
		log.warn("111");
		log.error("111");
		log.fatal("111");
	}
}
```

结果  其中title为我们设定的title

```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>hello HtmlLayout</title>
<style type="text/css">
<!--
body, table {font-family: arial,sans-serif; font-size: x-small;}
th {background: #336699; color: #FFFFFF; text-align: left;}
-->
</style>
</head>
<body bgcolor="#FFFFFF" topmargin="6" leftmargin="6">
<hr size="1" noshade>
Log session start time Thu Dec 07 11:28:33 CST 2017<br>
<br>
<table cellspacing="0" cellpadding="4" border="1" bordercolor="#224466" width="100%">
<tr>
<th>Time</th>
<th>Thread</th>
<th>Level</th>
<th>Category</th>
<th>File:Line</th>
<th>Message</th>
</tr>

<tr>
<td>0</td>
<td title="main thread">main</td>
<td title="Level"><font color="#339933">DEBUG</font></td>
<td title="com.linxingyang.Test1 category">com.linxingyang.Test1</td>
<td>Test1.java:8</td>
<td title="Message">111</td>
</tr>

<tr>
<td>4</td>
<td title="main thread">main</td>
<td title="Level">INFO</td>
<td title="com.linxingyang.Test1 category">com.linxingyang.Test1</td>
<td>Test1.java:9</td>
<td title="Message">111</td>
</tr>

<tr>
<td>4</td>
<td title="main thread">main</td>
<td title="Level"><font color="#993300"><strong>WARN</strong></font></td>
<td title="com.linxingyang.Test1 category">com.linxingyang.Test1</td>
<td>Test1.java:10</td>
<td title="Message">111</td>
</tr>

<tr>
<td>5</td>
<td title="main thread">main</td>
<td title="Level"><font color="#993300"><strong>ERROR</strong></font></td>
<td title="com.linxingyang.Test1 category">com.linxingyang.Test1</td>
<td>Test1.java:11</td>
<td title="Message">111</td>
</tr>

<tr>
<td>5</td>
<td title="main thread">main</td>
<td title="Level"><font color="#993300"><strong>FATAL</strong></font></td>
<td title="com.linxingyang.Test1 category">com.linxingyang.Test1</td>
<td>Test1.java:12</td>
<td title="Message">111</td>
</tr>
```

红框圈起来之处是  locationInfo=true的效果。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/L-log4j/image/2017-08-05/htmllayout.png)

### 5.8 XMLLayout

XML布局。

#### locationInfo 和 HTMLLayout的locationInfo属性一样

#### properties ： 这个还不懂，因为涉及到了properties

#### 测试代码

配置

```properties
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.xml.XMLLayout
log4j.appender.console.layout.locationInfo=true
```

测试代码 

```java
package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("111");
		log.info("111");
		log.warn("111");
		log.error("111");
		log.fatal("111");
	}
}
```

结果，对结果进行预览。

```xml
<log4j:event logger="com.linxingyang.Test1" timestamp="1512618193134" level="DEBUG" thread="main">
<log4j:message><![CDATA[111]]></log4j:message>
<log4j:locationInfo class="com.linxingyang.Test1" method="main" file="Test1.java" line="8"/>
</log4j:event>

<log4j:event logger="com.linxingyang.Test1" timestamp="1512618193139" level="INFO" thread="main">
<log4j:message><![CDATA[111]]></log4j:message>
<log4j:locationInfo class="com.linxingyang.Test1" method="main" file="Test1.java" line="9"/>
</log4j:event>

<log4j:event logger="com.linxingyang.Test1" timestamp="1512618193140" level="WARN" thread="main">
<log4j:message><![CDATA[111]]></log4j:message>
<log4j:locationInfo class="com.linxingyang.Test1" method="main" file="Test1.java" line="10"/>
</log4j:event>

<log4j:event logger="com.linxingyang.Test1" timestamp="1512618193140" level="ERROR" thread="main">
<log4j:message><![CDATA[111]]></log4j:message>
<log4j:locationInfo class="com.linxingyang.Test1" method="main" file="Test1.java" line="11"/>
</log4j:event>

<log4j:event logger="com.linxingyang.Test1" timestamp="1512618193140" level="FATAL" thread="main">
<log4j:message><![CDATA[111]]></log4j:message>
<log4j:locationInfo class="com.linxingyang.Test1" method="main" file="Test1.java" line="12"/>
</log4j:event>
```

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/L-log4j/image/2017-08-05/xmllayout.png)

### 5.9 DateLayout

这是一个抽象类，关注所有与时间相关选项和时间格式化。

#### timeZone 可以设置时区

时区，可以用这段代码打印出所有可用的timeZone

```java
package com.linxingyang;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

public class Test1 {
	public static void main(String[] args) {
		
        Calendar c = new GregorianCalendar();  
        c.setTime(new Date());  
        String s [] = c.getTimeZone().getAvailableIDs();  
        for(int i = 0; i < s.length;i++){  
           System.out.println(s[i]);  
        }  
	}
}
```

#### dateFormat 日期格式（是个DateFormat类）

DateFormat属性应该是  

```
SimpleDateFormat的一个参数，或者以下字符串之一

"NULL",  -- 不打印时间
这几个都在  PatternLayout中的%d里介绍过了。
"RELATIVE", 
"ABSOLUTE", 
"DATE"  
"ISO8601"
```

#### dateFormatOption（不可配置） 日期格式
我们在配置的时候使用的是 dateFormat，但是这个是个字符串，最后这个字符串会被放入dateFormatOption中,然后用于创建dateFormat对象。


### 5.10 TTCCLayout ###

该类继承DateFormat。

TTCC 由  time, thread, category 和 ndc 组成，所以得名  ttcc。
这四个属性都可以单独设置， time的格式依赖于  DateFormat。

不要在多个appender中使用同一个TTCCLayout实例，因为不是线程安全的。但是如果仅在一个appender中使用TTCCLayout实例，那是相当安全。

#### threadPrinting  默认true，打印线程名称
#### categoryPrefixing  默认true，打印日志器名称
#### contextPrinting 默认true，打印NDC相关信息


#### 测试代码

配置，配置的比较少，仅指定时间格式，其他都有默认值，时间格式没有默认值。如果不设置将不会打印时间。

```properties
log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.TTCCLayout
log4j.appender.console.layout.dateFormat=ISO8601
```

测试代码

```java
package com.linxingyang;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) {
		log.debug("111");
		log.info("111");
		log.warn("111");
		log.error("111");
		log.fatal("111");
	}
}
```

测试结果

```language
2017-12-08 11:03:14,529 [main] DEBUG com.linxingyang.Test1 - 111
2017-12-08 11:03:14,530 [main] INFO com.linxingyang.Test1 - 111
2017-12-08 11:03:14,530 [main] WARN com.linxingyang.Test1 - 111
2017-12-08 11:03:14,530 [main] ERROR com.linxingyang.Test1 - 111
2017-12-08 11:03:14,530 [main] FATAL com.linxingyang.Test1 - 111
```


配置,时间格式还是ISO8601，不打印线程名称，不打印日志器名称，不打印NDC的内容。时区选择  欧洲 柏林

```properties
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.TTCCLayout
log4j.appender.console.layout.dateFormat=ISO8601
log4j.appender.console.layout.threadPrinting=false
log4j.appender.console.layout.categoryPrefixing=false
log4j.appender.console.layout.contextPrinting=false

#log4j.appender.console.layout.timeZone=Asia/Tokyo
#log4j.appender.console.layout.timeZone=Asia/ShangHai
log4j.appender.console.layout.timeZone=Europe/Berlin
```

结果 ，当前时间为2017-12-08 11:06，下面打印的是柏林时间

```
2017-12-08 04:04:58,001 DEBUG - 111
2017-12-08 04:04:58,001 INFO - 111
2017-12-08 04:04:58,001 WARN - 111
2017-12-08 04:04:58,001 ERROR - 111
2017-12-08 04:04:58,001 FATAL - 111
```

