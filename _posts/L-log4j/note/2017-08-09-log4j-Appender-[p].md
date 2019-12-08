---
layout: post
permalink: /:year/bb91234f894d42aaab09bc92c3785ccf
title: 2017-08-09-log4j-Appender
categories: [log4j]
tags: [java,log4j,log4j系列]
relative-tags: [log4j系列]
excerpt: java,log,log4j,日志,源码,Appender
description: java,log,log4j,日志,源码,Appender
catalog: true
author: 林兴洋
---

# LOG4J #

## 6. Appender ##

Appender是用来指定输出目标的类，你可以叫它目的地。上面我们使用的ConsoleAppender就是用来向控制台输出的目的地。常用的目的地有：
* ConsoleAppender：向控制台输出日志；
* FileAppender：向文件输出日志
* DailyRollingFileAppender：向文件输出日志，每天一个日志文件；
* RollingFileAppender：向文件输出日志，当文件大小达到指定大小后，生成新文件；
* ...

### 6.1 类图 ###

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/appenderClassDiagram.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/appenderClassDiagram.png)


### 6.2 Appender ###

Appender 接口定义了一些方法。

* doAppend() 打日志方法
* set/getFilter 添加删除过滤器方法，后面我们会讨论到过滤器。
* set/getLayout 一个Appender用有一个Layout.
* set/getName Appender的名称
* set/getErrorHandler 错误处理，当日志器本身出错的处理，后面会讨论到
* requiresLayout 判断是否需要布局。
  * 需要的
    * AysncAppender
    * JMSAppender
    * LF5Appender
    * SMTPAppender
    * SyslogAppender
    * TelnetAppender
    * WriterAppender（及其子类）
  * 不需要的
    * JDBCAppender
    * NTEventLogAppender
    * NullAppender
    * RewriteAppender
    * SocketAppender
    * SocketHubAppender
* ...

### 6.3 OptionHandler ###

前面已经介绍过了，它是用于激活配置的。

### 6.4 AppenderSkeleton ###

AppenderSkeleton 日志器的骨架，是个抽象类，该类提供了一些可共用的方法。

#### threshold ####

其中有这么个属性，设置Appender的日志等级，小于这个等级的日志将不会被打印，这个可以在配置文件进行配置。

### 6.5 AppenderAttachable ###

#### 在日志那一节中，我们知道AppenderAttachable是日志器中用来处理Appender提供的接口，那么为什么这个接口会出现在Appender自己的类图中呢？ ####

因为有些Appender，它自己本身不打印东西，它把东西再交给别的Appender去打印，那么它就有必要处理这些Appender，所以就导致了，部分Appender类实现了Appender接口。

### 6.6 UnrecognizedElementHandler ###

当一个需要被DOMConfigurator解析的对象实现了该类，当解析过程中遇到了无法解析的子元素时，该方法（parseUnrecognizedElement） 将会被调用。

如果日志仓库支持这个接口，那么log4j:configuration中无法解析的子元素将会被转发到日志仓库。

* parseUnrecognizedElement(Element element, Properties props) 通知解析过程中遇到了一个无法解析的子元素


### 6.7 WriteAppender ###

该类和 AppenderSkeleton 差不多，是写文件，写到控制台的骨架类吧。它本身虽然不是抽象类，但是将其配置在，进行输出，是不行的。

#### 测试代码 ####

配置

```xml

log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.WriterAppender
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%X{b} - %m%n

```

结果 提示不能输出。没有输出的流。

```

log4j:ERROR No output stream or file set for the appender named [console].

```

#### encoding 设置编码格式 ####

编码格式，如果没有设置，默认使用所在系统的默认编码格式。

因为WriteAppender本身不能用，所以使用ConsoleAppender做例子。如下使用iso-8859-1编码来输出中文，结果是乱码的。

##### 测试代码 #####

```xml

log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.encoding=iso-8859-1
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%X{b} - %m%n

```

```java

package com.linxingyang;

import java.io.FileNotFoundException;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException {
		log.debug("a中文");
		log.info("b中文");
		log.warn("c");
		log.error("d");
		log.fatal("e");
	}
}

```

结果

```

 - a??
 - b??
 - c
 - d
 - e

```

#### immediateFlush 立即打印 ####

如果为true，那么马上打印日志。如果为false，不会打印日志，如果设置为false，必须要覆盖WriterAppedner中的shouldFlush(LoggingEvent)方法，否则 shouldFlash恒返回false，日志是不会被打印的。

```java

protected boolean shouldFlush(final LoggingEvent event) {
		return immediateFlush;
	}
    
```

##### 测试代码 #####

配置如下，这个就不写测试了，结果是没有输出日志。

```xml

log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.immediateFlush=false
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%X{b} - %m%n

```

### 6.8 ConsoleAppender 输出到控制台 ###

前面我们测试都是使用的这个ConsoleAppender。输出到 System.out 或者 System.err，默认是System.out.。只能这两个选一个。

#### target ####

上面说过，可以输出到System.out或者System.err。默认是System.out通过设置target可以切换到System.err。

##### 测试代码 #####

```xml

log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.target=System.err
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%m%n

```

java代码

```java

package com.linxingyang;

import java.io.FileNotFoundException;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException, InterruptedException {
		log.debug("a中文");
		log.info("b中文");
		log.warn("c");
		log.error("d");
		log.fatal("e");
	}
}

```

结果 

```

a中文
b中文
c
d
e

```

#### follow ####

有时候我们可能会想要使用System.setOut()方法重定向System.out的输出终端。
但是这个时候，日志还是打印在控制台中。测试如下：

##### 测试代码 #####

配置

```xml

log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%m%n

```

代码中，我们重定向了System.out的输出到文件中。

```java

package com.linxingyang;

import java.io.FileNotFoundException;
import java.io.PrintStream;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException {

		PrintStream ps = new PrintStream("d:/logs/syso.txt");
		System.setOut(ps);
		System.out.println("控制台打印 aaaa");
		log.debug("日志打印 a");
		log.info("日志打印  b");
		log.fatal("日志打印  c");
		System.out.println("控制台打印  bbbb");
		System.out.println("控制台打印  cccc");
	}
}

```

结果：虽然System.out.println()已经被重定向到了文件中，但是发现Log4j日志打印的还是在控制台中。

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/consoleAppenderFollowResult1.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/consoleAppenderFollowResult1.png)


这个follow属性就是用来设置如果更改了System.out的输出终端，是否“跟随”变化。

```xml

log4j.rootLogger=debug,console

log4j.appender.console.follow=true
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.console.layout.ConversionPattern=%m%n

```

如下代码。在输出依旧控制台打印，和一句日志打印后修改了System.out的输出终端

```java

package com.linxingyang;

import java.io.FileNotFoundException;
import java.io.PrintStream;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException {

		System.out.println("控制台打印 aaaa");
		log.debug("日志打印 a");
		PrintStream ps = new PrintStream("d:/logs/syso.txt");
		System.setOut(ps);
		log.info("日志打印  b");
		log.fatal("日志打印  c");
		System.out.println("控制台打印  bbbb");
		System.out.println("控制台打印  cccc");
	}
}
	

```

结果，可以看到设置了follow=true后，日志也重定向了。

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/consoleAppenderFollowResult2.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/consoleAppenderFollowResult2.png)


实现原理，如下是ConsoleAppender中的激活配置方法。可以看到，如果follow为false的时候，直接使用的是System.out和System.err，这个时候System.out和System.err只是一个引用，假设指向A对象，所以赋予writer只是一个引用，指向了A对象。当我们使用System.setOut()或者System.setErr()重定向控制台/控制台错误的输出终端时，是将System.out和System.err指向另一个对象，假设B对象，此时writer还是指向了A对象，所以对writer来说，他还是向A对象输出，而非新定义的B对象。

```java

public void activateOptions() {
        if (follow) {
            if (target.equals(SYSTEM_ERR)) {
               setWriter(createWriter(new SystemErrStream()));
            } else {
               setWriter(createWriter(new SystemOutStream()));
            }
        } else {
            if (target.equals(SYSTEM_ERR)) {
               setWriter(createWriter(System.err));
            } else {
               setWriter(createWriter(System.out));
            }
        }

        super.activateOptions();
  }
  
```

再看 follow=true的时候。新建了SystemOutStream对象，该类是ConsoleAppender中的一个静态内部类，源码如下。可以看到它重写了write方法，并直接调用了System.out对象，由此日志也会输出到新定义的终端。

```java

private static class SystemOutStream extends OutputStream {
        public SystemOutStream() {
        }

        public void close() {
        }

        public void flush() {
            System.out.flush();
        }

        public void write(final byte[] b) throws IOException {
            System.out.write(b);
        }

        public void write(final byte[] b, final int off, final int len)
            throws IOException {
            System.out.write(b, off, len);
        }

        public void write(final int b) throws IOException {
            System.out.write(b);
        }
    }
    
```


### 6.9 FileAppender 输出到文件 ###

#### file 文件名 必须设置 ####

输出到文件的文件名，可以是绝对路径。可以是相对路径，相对路径以项目根目录开始的。

##### 测试代码 #####

配置，输出到 d:/logs/file1.txt该文件中。

```xml

log4j.rootLogger=debug,file

log4j.appender.file=org.apache.log4j.FileAppender
log4j.appender.file.file=d:/logs/file1.txt
log4j.appender.file.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.file.layout.ConversionPattern=%m%n

```

java代码

```java

package com.linxingyang;

import java.io.FileNotFoundException;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException {

		log.debug("日志打印 a");
		log.info("日志打印  b");
		log.fatal("日志打印  c");
	}
}

```

文件中的结果

```

日志打印  b
日志打印  c
控制台打印  bbbb
控制台打印  cccc

```

#### append ####

是否以追加的方式打印日志。默认为true

上面一个测试调用多次，打开文件，可以发现输出了多次

```

日志打印 a
日志打印  b
日志打印  c
日志打印 a
日志打印  b
日志打印  c
日志打印 a
日志打印  b
日志打印  c

```

修改为false，进行测试

```xml

log4j.rootLogger=debug,file

log4j.appender.file=org.apache.log4j.FileAppender
log4j.appender.file.file=d:/logs/file1.txt
log4j.appender.file.append=false
log4j.appender.file.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.file.layout.ConversionPattern=%m%n

```

```java

package com.linxingyang;

import java.io.FileNotFoundException;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException {

		log.debug("日志打印 a");
		log.info("日志打印  b");
		log.fatal("日志打印  ca");
	}
}

```

结果，原来file1.txt中是前面打印的日志的，append=false之后，调用打印日志，发现之前的日志不见了。

```

日志打印 a
日志打印  b
日志打印  ca

```


#### bufferedIO 是否缓冲 ####
#### bufferedSize 缓冲区大小 ####

bufferedIO和bufferedSize是配套使用的。bufferedIO用来设置是否需要是否设置缓冲区，默认为false。bufferedSize用来设置该缓冲区的大小，默认8KB

缓冲区的作用很明显，设立一个缓冲区这样就不用频繁的进行写操作，只需在缓冲区满时写一次。

但是有个问题，如果开启了bufferedIO，要缓冲区满8KB才会进行打印，但是大多数情况下当程序结束的时候，缓冲区存在不足8KB的日志，这些日志没有打印出来，造成丢失。


##### 测试代码 #####

配置如下，开启缓冲区。

```xml

log4j.rootLogger=debug,file

log4j.appender.file=org.apache.log4j.FileAppender
log4j.appender.file.file=d:/logs/file1.txt
log4j.appender.file.bufferedIO=true
log4j.appender.file.append=false
log4j.appender.file.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.file.layout.ConversionPattern=%m%n

```

测试代码，代码只打印一条日志后退出程序，该日志存在了缓冲区。

```java

package com.linxingyang;

import java.io.FileNotFoundException;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException, InterruptedException {
		log.debug("日志打印 axxxxx");
	}
}

```

结果，文件中没有任何日志信息。说明缓冲区中的日志没有输出到文件中。

log4j提供了LogManager.shutdown();来显式停止log4j，在该方法中，最后会使得WriterAppender及其子类关闭它的流，此时缓冲区的数据将会被写入终端，而后关闭流。
> java核心技术卷2：关闭一个输出流的同时还会冲刷用于该输出流的缓冲区，所有被临时置于缓冲区中，以便使用更大的包的形式传递的字符在关闭输出流时都将被送出。特别的，如果不关闭文件，那么写出字节的最后一个包可能将永远也得不到传递（就是在退出程序的时候，缓冲区中的还有数据，但是我们没有手动调用flush或者close掉）。

修改测试代码，添加LogManager.shutdown();，最后发现日志正常输出了。

```java

package com.linxingyang;

import java.io.FileNotFoundException;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException, InterruptedException {
		log.debug("日志打印 axxxxx");
		LogManager.shutdown();
	}
}

```

### 6.10 RollingFileAppender ###

RollingFileAppender是FileAppender的子类，它的作用是当日志文件大小超出文件大小大限时，会把日志文件转换成备份文件，然后再生成一个新的日志文件。

例如日志文件名为log.txt，设置文件大小上限为1KB，当log.txt文件的大小超出了1KB后，把log.txt的名称转换成log.txt.1，然后再生成一个log.txt，新的日志会写入到新的log.txt文件中。当log.txt的大小再次达到1KB时，把log.txt.1名称修改成log.txt.2，把log.txt修改成log.txt.1，然后再生成一个新的log.txt文件。

还可以设置文件的个数，当设置备份文件的个数为3时，表示最多可以有3个文件。当文件达到3后，再次达到1KB时，那么会删除最后一个文件。例如当前已经存在log.txt、log.txt.1、log.txt.2，这时如果log.txt又达到了1KB时，那么删除log.txt.2，然后把log.txt.1修改成log.txt.2，再把log.txt修改成log.txt.1，然后再创建log.txt文件。

#### MaxFileSize : 指定文件大小上限,单位byte ####
#### MaxBackupIndex : 文件最多备份个数 ####

##### 测试代码 #####

配置，文件大小设置为1KB，最多有3个备份文件。

```xml

log4j.rootLogger=debug,file

log4j.appender.file=org.apache.log4j.RollingFileAppender
log4j.appender.file.file=d:/logs/fileRoll.txt
# 1KB
log4j.appender.file.maxFileSize=1024
log4j.appender.file.maxBackupIndex=3
log4j.appender.file.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.file.layout.ConversionPattern=%m%n

```

java代码

```java

package com.linxingyang;

import java.io.FileNotFoundException;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException, InterruptedException {
		for (int i = 0; i < 10 * 1000; i++) {
			log.debug("okok" + i);
		}
	}
}


```

测试结果，最多存在3个备份文件，每个备份文件1KB。

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/RollFileAppenderResult1.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/RollFileAppenderResult1.png)


### 6.11 ExternallyRolledFileAppender ###

这个扩展的滚动文件Appender，监听一个端口，当收到消息时，日志文件马上滚动备份并且会返回一个确认消息。这种方法触发滚动的好处是 独立于系统，快速，可靠.

注意调用者没有进行身份认证，任何人都可以触发这滚动备份，在生产环境中，建议做一些保护措施。

org.apache.log4j.varia.Roller这个类Roller用于发送滚动备份信息给这个Appender。然这个Appender进行备份，并且返回一个消息

#### 测试代码 ####

```xml

log4j.rootLogger=debug,file

log4j.appender.file=org.apache.log4j.varia.ExternallyRolledFileAppender
log4j.appender.file.file=d:/logs/extRoll.txt
log4j.appender.file.port=7899
log4j.appender.file.maxBackupIndex=3
log4j.appender.file.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.file.layout.ConversionPattern=%m%n

```

我们让日志器每秒钟输出一条日志。

```java

package com.linxingyang;

import java.io.FileNotFoundException;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException, InterruptedException {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		while (true) {
			Thread.sleep(1 * 1000);
			log.debug(sdf.format(Calendar.getInstance().getTime()) + " message ");
		}
	}
}

```


使用Roller进行测试，在这里我对Roller类进行类一些改造，因为发送和接受都是在本机上做，而Roller会加载配置文件，从而导致再次启动ExternallyRolledFileAppender，这样就导致配置文件中`log4j.appender.file.port=7899`这个端口被使用类两次，会报错。改造就是把Roller中设计log4j的全部去掉或替换成自己的东西。


```java

package org.apache.log4j.varia;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;

public class Roller {
  static String host;
  static int port;

  // Static class.
  Roller() {
  }

  public 
  static 
  void main(String argv[]) {
	  argv = new String[]{"127.0.0.1", "7899"};
	  
  //   BasicConfigurator.configure();
    

    if(argv.length == 2) 
      init(argv[0], argv[1]);
    else 
      usage("Wrong number of arguments.");
    
    roll();
  }

  static
  void usage(String msg) {
    System.err.println(msg);
    System.err.println( "Usage: java " + Roller.class.getName() +
			"host_name port_number");
    System.exit(1);
  }

  static 
  void init(String hostArg, String portArg) {
    host = hostArg;
    try {
      port =  Integer.parseInt(portArg);
    }
    catch(java.lang.NumberFormatException e) {
      usage("Second argument "+portArg+" is not a valid integer.");
    }
  }

  static
  void roll() {
    try {
      Socket socket = new Socket(host, port);
      DataOutputStream dos = new DataOutputStream(socket.getOutputStream());
      DataInputStream dis = new DataInputStream(socket.getInputStream());
      dos.writeUTF(ExternallyRolledFileAppender.ROLL_OVER);
      System.out.println("roll" + socket.getLocalPort());
      String rc = dis.readUTF();
      if(ExternallyRolledFileAppender.OK.equals(rc)) {
    	  System.out.println("Roll over signal acknowledged by remote appender");
//	cat.info("Roll over signal acknowledged by remote appender.");
      } else {
	// cat.warn("Unexpected return code "+rc+" from remote entity.");
    	  System.out.println("Unexpected return code "+rc+" from remote entity.");
	System.exit(2);
      }
    } catch(IOException e) {
    	System.out.println("Could not send roll signal on host "+host+" port "+port+" .");
      // cat.error("Could not send roll signal on host "+host+" port "+port+" .",
		//e);
      System.exit(2);
    }
    System.exit(0);
  }
}

```


现在先运行 Test1代码。稍微等几秒钟。调用Roller中的main方法。再过一会，再调用一次。 可以发现，生成了两个备份文件。

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/ExternallyRolledFileAppenderResult.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/ExternallyRolledFileAppenderResult.png)



### 6.12 DailyRollingFileAppender ###

#### datePattern ####

默认按天生成日志

DailyRollingFileAppender会根据设定的时间频率生成备份文件。时间格式只要是SimpleDateFormat能够转换的格式即可。

```

当时间频率为yyyy-MM：按月生成备份文件；
当时间频率为yyyy-ww：按周生成备份文件；
当时间频率为yyyy-MM-dd：按天生成备份文件；
当时间频率为yyyy-MM-dd-a：每天生成两次备份；
当时间频率为yyyy-MM-dd-HH：按小时生成备份文件；
当时间频率为yyyy-MM-dd-HH-mm：按分钟生成备份文件。

时间频率也是备份文件的后缀名，例如：log.txt.2013-05-06，如果没有给出’.’，那么就是log.txt2013-05-06

在DatePattern配置项中不要使用 “:”，这个符号在URL协议中被解读为另一种意思。

```

##### 测试代码 #####

设置为每分钟生成日志文件。

```xml

log4j.rootLogger=debug,file

log4j.appender.file=org.apache.log4j.DailyRollingFileAppender
log4j.appender.file.file=d:/logs/dailyRoll.txt
log4j.appender.file.datePattern='.'yyyy-MM-dd-HH-mm
log4j.appender.file.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.file.layout.ConversionPattern=%m%n

```

代码中， 每10秒输出一次日志，共140秒，2分钟20秒。

```java

package com.linxingyang;

import java.io.FileNotFoundException;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException, InterruptedException {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		for (int i = 0; i < 14; i++) {
			Thread.sleep(10 * 1000);
			log.debug(sdf.format(Calendar.getInstance().getTime()) + " " + i);
		}
	}
}

```

结果如图：2分钟20秒，会生成两个备份文件，

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/dailyRollResult1.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/dailyRollResult1.png)


### 6.13 SMTPAppender 发送邮件Appender ###

默认的实现是当遇到error,fatal就会马上发送邮件。

#### to 接收者 ####
#### cc 抄送 ####
#### bcc 暗抄送 ####
#### from 发送者账号 ####
#### replyTo 回复到 ####
#### subject 主题  ####
#### SMTPHost 服务器 ####
#### SMTPPort 端口 ####
#### SMTPUsername 用户名 ####
#### SMTPPassword 密码 ####
#### SMTPProtocol 协议 ####

为空或者smtps(安全的smtp)

#### locationInfo 发生错误所在位置 ####

这个会影响程序速度。

#### bufferSize logging event事件数。 ####

当发送邮件时，截取从当前要发送的日志事件到前面bufferSize个日志事件。

##### 测试代码 #####

配置

```xml

log4j.rootLogger=debug,smpt

log4j.appender.smpt=org.apache.log4j.net.SMTPAppender
log4j.appender.smpt.to=linxingy@foxmail.com
log4j.appender.smpt.from=linxingyang@linxingyang.net
log4j.appender.smpt.subject=log from log4j
log4j.appender.smpt.SMTPHost=smtp.mxhichina.com
log4j.appender.smpt.SMTPPort=465
log4j.appender.smpt.SMTPUsername=linxingyang@linxingyang.net
log4j.appender.smpt.SMTPPassword=马赛克
log4j.appender.smpt.SMTPProtocol=smtps
log4j.appender.smpt.bufferSize=30
log4j.appender.smpt.layout=org.apache.log4j.EnhancedPatternLayout
log4j.appender.smpt.layout.ConversionPattern=%m%n

```

java代码，这个测试 

* 1先输出  2 * 3 = 6 条error等级以下的日志，
* 2然后输出一条等级为error日志，
* 3再输出   30 * 3 = 90 条error等级以下的日志，
* 4最后输出两条等级为error日志。

```java

package com.linxingyang;

import java.io.FileNotFoundException;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException, InterruptedException {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		
		int i = 0;
         // 1
		for (int j = 0; j < 2; j++) {
			log.info(sdf.format(Calendar.getInstance().getTime()) + "info message " + i++);
			log.debug(sdf.format(Calendar.getInstance().getTime()) + "debug message  " + i++);
			log.warn(sdf.format(Calendar.getInstance().getTime()) + "warn message  " + i++);
		}
         // 2
		log.error(sdf.format(Calendar.getInstance().getTime()) + "error message  " + i++);
         // 3
		for (int j = 0; j < 30; j++) {
			log.info(sdf.format(Calendar.getInstance().getTime()) + "info message " + i++);
			log.debug(sdf.format(Calendar.getInstance().getTime()) + "debug message  " + i++);
			log.warn(sdf.format(Calendar.getInstance().getTime()) + "warn message  " + i++);
		}
         // 4
		log.error(sdf.format(Calendar.getInstance().getTime()) + "error message  " + i++);
		log.error(sdf.format(Calendar.getInstance().getTime()) + "error message  " + i++);
		System.out.println(i);
	}
}

```

测试结果。会收到3封邮件

第一封：说明遇到error/fatal就会发送邮件

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/smtpResult1.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/smtpResult1.png)

第二封 ： 每个框框中都是10条 logging event。因为 `log4j.appender.smpt.bufferSize=30`该项配置了30条，所以当需要发送邮件时，会获取bufferSize条（即30条）日志事件来发送。

同时我们可以看到，第一封邮件的数字是6，而第二封是从68开始的，说明中间多余的debug/info/warn消息都被忽略了。发送的是从当前error/fatal往前数30条记录。


![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/smtpResult2.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/smtpResult2.png)

第三封 : 发送的是最后一条error消息。

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/smtpResult3.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/smtpResult3.png)


### 6.14 JDBCAppender 输出到数据库 ###

发送日志事件到数据库中。 警告： 这个版本的JDBCAppender在未来很有可能被完全替代，而且，它不记录异常。打日志事件会被放到ArrayList缓存中，当缓存区满了之后，日志事件将会被sql语句替代并且执行。

#### locationInfo ####
#### sql ####

sql语句，sql语句中可以使用PatternLayout的符号来显示日志相应的内容，但是要要小心不要放入引号。，例如

```sql

insert into LogTable (msg) values ("%m")

insert into LogTable (Thread, Class, Message) values ("%t", "%c", "%m").

```

#### user ####
用户名
#### password ####
密码
#### bufferSize ####
缓冲日志事件的条数。默认为1，即产生一条日志马上插入数据库这样很消耗内存，我们可以适当的调大buffferSize，当积累到一定条数的时候再插入数据库。但是和前面的FileAppender的BufferSize一样，在程序结束前如果缓冲区中还是存在部分日志事件，那么会丢失，同样也是使用关闭日志器来处理。

```java

LogManager.shutdown();

```

#### driver ####

驱动名称，首先要加一个驱动包（后面测试我使用的是mysql数据库，mysql-connector-java-5.1.25-bin.jar），测试过程中也发现，加入一个驱动包后，不配置driver，也可以正常运行。但是最好显式配置一下，免的忘了。

```

log4j:ERROR Failed to excute sql
java.sql.SQLException: No suitable driver found for jdbc:mysql://localhost:3306/test
	at java.sql.DriverManager.getConnection(DriverManager.java:602)
	at java.sql.DriverManager.getConnection(DriverManager.java:185)
	at org.apache.log4j.jdbc.JDBCAppender.getConnection(JDBCAppender.java:261)
	at org.apache.log4j.jdbc.JDBCAppender.execute(JDBCAppender.java:225)
	at org.apache.log4j.jdbc.JDBCAppender.flushBuffer(JDBCAppender.java:299)
	at org.apache.log4j.jdbc.JDBCAppender.append(JDBCAppender.java:196)
	at org.apache.log4j.AppenderSkeleton.doAppend(AppenderSkeleton.java:242)
	at org.apache.log4j.helpers.AppenderAttachableImpl.appendLoopOnAppenders(AppenderAttachableImpl.java:66)
	at org.apache.log4j.Category.callAppenders(Category.java:210)
	at org.apache.log4j.Category.forcedLog(Category.java:398)
	at org.apache.log4j.Category.info(Category.java:639)
	at com.linxingyang.Test1.main(Test1.java:14)

```

##### 测试代码 #####

首先现在mysql数据库建一个表

```sql

DROP TABLE  log_table;
CREATE TABLE log_table
(
log_id INT PRIMARY KEY AUTO_INCREMENT,
logger_name VARCHAR(100), -- %c 日志器名称
log_time VARCHAR(30), -- %d 打印时间，使用默认值
log_detail VARCHAR(100),  -- %l 所在类和所在行
log_thread VARCHAR(30), -- %t 打印日志的线程
log_priority VARCHAR(5), -- %p 优先级
log_message VARCHAR(300) -- %m 日志消息
-- create_date datetime,
-- modify_date datetime 
)

```

配置

```xml

log4j.rootLogger=debug,jdbc

log4j.appender.jdbc=org.apache.log4j.jdbc.JDBCAppender
log4j.appender.jdbc.URL=jdbc:mysql://localhost:3306/test
log4j.appender.jdbc.user=root
log4j.appender.jdbc.password=马赛克
log4j.appender.jdbc.sql=INSERT INTO log_table(logger_name, log_time, log_detail, log_thread, log_priority, log_message) VALUES('%c', '%d', '%l', '%t', '%p', '%m')
log4j.appender.jdbc.driver=com.mysql.jdbc.Driver
log4j.appender.jdbc.bufferSize=5
log4j.appender.jdbc.layout=org.apache.log4j.PatternLayout
log4j.appender.jdbc.layout.ConversionPattern=%m%n

```

java代码，总共打印 3 * 4 = 12 条日志。

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
		for (int j = 0; j < 4; j++) {
			log.info(sdf.format(Calendar.getInstance().getTime()) + "info message " + i++);
			log.debug(sdf.format(Calendar.getInstance().getTime()) + "debug message  " + i++);
			log.warn(sdf.format(Calendar.getInstance().getTime()) + "warn message  " + i++);
		}
		LogManager.shutdown();
	}
}
	

```

结果，从log_time上大致可以看出，前5条差不多是同时打印，6-10条也差不多同时打印。 看log_detail可以很明显看出最后两条的和前面10条不同，这是因为bufferSize=5，前10条分两次插入数据库，而最后两条，在程序结束时还是在缓存中，我们调用类LogManager.shutdown();才让其得以插入数据库。所以其显示的信息才是xxx.shutdown而不是xxx.main。

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/jdbcAppenderResult.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/jdbcAppenderResult.png)

### 6.15 NullAppender ###

和 NOPLogger一个性质，不做任何事，就是占个位，让我们在不想输出任何日志的时候，让log4j日志系统能够正常的走流程。

### 6.16 SocketAppender ###

发送日志事件到远程的日志机器，通常是一个SockentNode 套接字节点。SocketAppender本身不需要Layout，因为它本身不打印日志，而是将日志传送到远方，由远方进行打印。

#### remoteHost ip地址 ####
#### port 端口 ####
默认：4560
#### locationInfo 详细信息 ####
#### application ####
打日志的应用的名称，如果在System.property中已经设置类，就可以不用设置了。
#### reconnectionDelay 重连间隔时间  ####
默认重连间隔30秒


#### 使用 SimpleSocketServer 进行测试 ####

使用org.apache.log4j.net.SimpleSocketServer进行测试。该类基于SocketNode实现了这个是个简单的服务。前面说了，SocketAppender本身不打印日志，由远端接收了处理，所以SimpleSocketServer这个类收到类日志，需要根据log4j的配置对日志进行打印处理。

首先先将log4.properties文件内容改成如下

```xml

log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d %m%n

```

然后启动SimpleSocketServer中的main方法，这个时候可以看到控制台有一个程序启动了。

```java

public class SimpleSocketServer  {

  static Logger cat = Logger.getLogger(SimpleSocketServer.class);

  static int port;

  public
  static
  void main(String argv[]) {
	  
	  argv = new String[]{"4445", "c:/linxingyangWorkSpace/testLog/config/log4j.properties"};
    if(argv.length == 2) {
      init(argv[0], argv[1]);
    } else {
      usage("Wrong number of arguments.");
    }
    
    try {
      cat.info("Listening on port " + port);
      ServerSocket serverSocket = new ServerSocket(port);
      while(true) {
	cat.info("Waiting to accept a new client.");
	Socket socket = serverSocket.accept();
	cat.info("Connected to client at " + socket.getInetAddress());
	cat.info("Starting new socket node.");
	new Thread(new SocketNode(socket,
				  LogManager.getLoggerRepository()),"SimpleSocketServer-" + port).start();
      }
    } catch(Exception e) {
      e.printStackTrace();
    }
  }


  static void  usage(String msg) {
    System.err.println(msg);
    System.err.println(
      "Usage: java " +SimpleSocketServer.class.getName() + " port configFile");
    System.exit(1);
  }

  static void init(String portStr, String configFile) {
    try {
      port = Integer.parseInt(portStr);
    } catch(java.lang.NumberFormatException e) {
      e.printStackTrace();
      usage("Could not interpret port number ["+ portStr +"].");
    }
   
    if(configFile.endsWith(".xml")) {
      DOMConfigurator.configure(configFile);
    } else {
      PropertyConfigurator.configure(configFile);
    }
  }
}

```


修改xml中的配置为，配置类一个SocketAppender

```xml

log4j.rootLogger=debug,socket

log4j.appender.socket=org.apache.log4j.net.SocketAppender
log4j.appender.socket.remoteHost=127.0.0.1
log4j.appender.socket.port=4445
log4j.appender.socket.locationInfo=true

```

测试代码Test1,

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
		for (int j = 0; j < 4; j++) {
			Thread.sleep(1 * 1000);
			log.info(sdf.format(Calendar.getInstance().getTime()) + "info message " + i++);
			log.debug(sdf.format(Calendar.getInstance().getTime()) + "debug message  " + i++);
			log.warn(sdf.format(Calendar.getInstance().getTime()) + "warn message  " + i++);
			log.error(sdf.format(Calendar.getInstance().getTime()) + "error message  " + i++);
			log.fatal(sdf.format(Calendar.getInstance().getTime()) + "fatal message  " + i++);
		}
		LogManager.shutdown();
	}
}
	

```

启动Test1，控制台会切换到当前运行的程序，如图在切回到SimpleSocketServer。可以看到已经接收到日志了。

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/SimpleSocketServerResult.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/SimpleSocketServerResult.png)


#### 使用SocketServer进行测试 ####

SocketServer相较于SimpleSocketServer，有些许不同的地方。

SocketServer要求提供port,configFile,configDir三个初始值。
其中，port就是SocketServer监听的端口，configFile就是日志配置文件，SocketServer本身处理过程产生的日志（例如某个客户端连接类）根据这个配置进行打印。

configDir中，存放着多个配置文件，这些配置文件以.lcf结尾，当一个新连接被打开，比如 foo.bar.net，然后，SocketServer将会在配置文件夹configDir下搜索名为 foo.bar.net.lfc的配置文件。

如果能找到，那么一个新的层次结构日志仓库将会根据这个配置文件被实例化。当foo.bar.net打开另外一个新的连接，那么该配置也将被那个连接使用。

如果在configDir下没有 foo.bar.net.lcf这个文件，那么通用的配置文件将会被使用。通用的层次结构的使用configDir下的generic.lcf作为配置文件，如果没有这个文件，那么将会使用默认的log4j配置文件（即configFile指定的文件）。

configDir的作用是不同的客户端使用不同的配置文件，保证了各个客户端之间的日志独立性。 但是如果是台机器上的两个完全独立的应用，虽然使用起来没问题，但是无法区分具体属于哪个应用程序的。


* port:4445

* configFile:log4j配置文件所在路径,注意是log4j2.properties不是log4j.properties `c:/linxingyangWorkSpace/testLog/config/log4j2.properties`

其内容
```xml

log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=SocketServer -- %d %m%n

```

* configDir:新建的lcf文件夹`c:/linxingyangWorkSpace/testLog/config/lcf`

在lcf文件夹下放两个文件，一个是 generic.lcf（通用）,一个是.lcf（代表本地IP127.0.0.1）。

---

为什么.lcf代表本地？
// We assume that the toSting method of InetAddress returns is in the format hostname/d1.d2.d3.d4 e.g. torino/192.168.1.1
代码中认为InetAddress返回如下格式： hostname/d1.d2.d3.d4， 例如 torino/192.168.1.1。 那么会在配置目录下查找  torino.lcf文件。
但是本地的hostname，经过测试为空，即 `/127.0.0.1`。所以就是  `.lcf`文件。

---

generic.lcf中的配置

```xml

log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=generic -- %d %m%n

```

.lcf中的配置

```xml

log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=127.0.0.1 -- %d %m%n

```

SocketServer代码如下，大部分没动，就是修改了main方法中的参数argv。启动main方法。

```java

public class SocketServer  {

  static String GENERIC = "generic";
  static String CONFIG_FILE_EXT = ".lcf";

  static Logger cat = Logger.getLogger(SocketServer.class);
  static SocketServer server;
  static int port;

  // key=inetAddress, value=hierarchy
  Hashtable hierarchyMap;
  LoggerRepository genericHierarchy;
  File dir;

  public
  static
  void main(String argv[]) {
	  argv = new String[]{"4445", "c:/linxingyangWorkSpace/testLog/config/log4j.properties", "c:/linxingyangWorkSpace/testLog/config/lcf"};
    if(argv.length == 3)
      init(argv[0], argv[1], argv[2]);
    else
      usage("Wrong number of arguments.");

    try {
      cat.info("Listening on port " + port);
      ServerSocket serverSocket = new ServerSocket(port);
      while(true) {
	cat.info("Waiting to accept a new client.");
	Socket socket = serverSocket.accept();
	InetAddress inetAddress =  socket.getInetAddress();
	cat.info("Connected to client at " + inetAddress);

	LoggerRepository h = (LoggerRepository) server.hierarchyMap.get(inetAddress);
	if(h == null) {
	  h = server.configureHierarchy(inetAddress);
	}

	cat.info("Starting new socket node.");
	new Thread(new SocketNode(socket, h)).start();
      }
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }


  static
  void  usage(String msg) {
    System.err.println(msg);
    System.err.println(
      "Usage: java " +SocketServer.class.getName() + " port configFile directory");
    System.exit(1);
  }

  static
  void init(String portStr, String configFile, String dirStr) {
    try {
      port = Integer.parseInt(portStr);
    }
    catch(java.lang.NumberFormatException e) {
      e.printStackTrace();
      usage("Could not interpret port number ["+ portStr +"].");
    }

    PropertyConfigurator.configure(configFile);

    File dir = new File(dirStr);
    if(!dir.isDirectory()) {
      usage("["+dirStr+"] is not a directory.");
    }
    server = new SocketServer(dir);
  }


  public
  SocketServer(File directory) {
    this.dir = directory;
    hierarchyMap = new Hashtable(11);
  }

  // This method assumes that there is no hiearchy for inetAddress
  // yet. It will configure one and return it.
  LoggerRepository configureHierarchy(InetAddress inetAddress) {
    cat.info("Locating configuration file for "+inetAddress);
    // We assume that the toSting method of InetAddress returns is in
    // the format hostname/d1.d2.d3.d4 e.g. torino/192.168.1.1
    String s = inetAddress.toString();
    int i = s.indexOf("/");
    if(i == -1) {
      cat.warn("Could not parse the inetAddress ["+inetAddress+
	       "]. Using default hierarchy.");
      return genericHierarchy();
    } else {
      String key = s.substring(0, i);

      File configFile = new File(dir, key+CONFIG_FILE_EXT);
      if(configFile.exists()) {
	Hierarchy h = new Hierarchy(new RootLogger(Level.DEBUG));
	hierarchyMap.put(inetAddress, h);

	new PropertyConfigurator().doConfigure(configFile.getAbsolutePath(), h);

	return h;
      } else {
	cat.warn("Could not find config file ["+configFile+"].");
	return genericHierarchy();
      }
    }
  }

  LoggerRepository  genericHierarchy() {
    if(genericHierarchy == null) {
      File f = new File(dir, GENERIC+CONFIG_FILE_EXT);
      if(f.exists()) {
	genericHierarchy = new Hierarchy(new RootLogger(Level.DEBUG));
	new PropertyConfigurator().doConfigure(f.getAbsolutePath(), genericHierarchy);
      } else {
	cat.warn("Could not find config file ["+f+
		 "]. Will use the default hierarchy.");
	genericHierarchy = LogManager.getLoggerRepository();
      }
    }
    return genericHierarchy;
  }
}

```


启动后，控制台输出两行，代表启动成功，正在等待客户端连接

```

SocketServer -- 2017-12-12 15:28:13,414 Listening on port 4445
SocketServer -- 2017-12-12 15:28:13,431 Waiting to accept a new client.

```

现在我们的log4j.properties的配置为

```xml

log4j.rootLogger=debug,socket

log4j.appender.socket=org.apache.log4j.net.SocketAppender
log4j.appender.socket.remoteHost=127.0.0.1
log4j.appender.socket.port=4445


```

java测试代码如下：

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
		for (int j = 0; j < 4; j++) {
			Thread.sleep(1 * 1000);
			log.info(sdf.format(Calendar.getInstance().getTime()) + "info message " + i++);
			log.fatal(sdf.format(Calendar.getInstance().getTime()) + "fatal message  " + i++);
		}
		LogManager.shutdown();
	}
}
	


```

结果：SocketServer为配置于log4j2.properties配置文件中,127.0.0.1配置于.lcf文件中，从这里可以看出确实使用了.lcf文件中的配置来打印日志。

```

SocketServer -- 2017-12-12 15:28:13,414 Listening on port 4445
SocketServer -- 2017-12-12 15:28:13,431 Waiting to accept a new client.
SocketServer -- 2017-12-12 15:31:15,292 Connected to client at /127.0.0.1
SocketServer -- 2017-12-12 15:31:15,292 Locating configuration file for /127.0.0.1
SocketServer -- 2017-12-12 15:31:15,297 Starting new socket node.
SocketServer -- 2017-12-12 15:31:15,303 Waiting to accept a new client.
127.0.0.1 -- 2017-12-12 15:31:16,334 2017-12-12 15:31:16info message 0
127.0.0.1 -- 2017-12-12 15:31:16,351 2017-12-12 15:31:16fatal message  1
127.0.0.1 -- 2017-12-12 15:31:17,352 2017-12-12 15:31:17info message 2
127.0.0.1 -- 2017-12-12 15:31:17,353 2017-12-12 15:31:17fatal message  3
127.0.0.1 -- 2017-12-12 15:31:18,355 2017-12-12 15:31:18info message 4
127.0.0.1 -- 2017-12-12 15:31:18,357 2017-12-12 15:31:18fatal message  5
127.0.0.1 -- 2017-12-12 15:31:19,359 2017-12-12 15:31:19info message 6
127.0.0.1 -- 2017-12-12 15:31:19,360 2017-12-12 15:31:19fatal message  7
SocketServer -- 2017-12-12 15:31:19,364 Caught java.io.EOFException closing conneciton.

```


#### 使用 chainSaw 来接收日志 ####

chainSaw是基于Swing的界面日志查看器，从Socket接口接收日志，可以进行过滤日志等操作。chainSaw包下有个Main类，根据代码，他默认监听的是4445端口。运行该类main方法，会出来如下窗口。

注意，此时log4j.properties文件中要清空，因为这个Main类也会在如log4j.properties中的配置。

启动chainSaw
![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/socketAppender.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/socketAppender.png)


在log4j.properties中增加xml配置

```xml

log4j.rootLogger=debug,socket

log4j.appender.socket=org.apache.log4j.net.SocketAppender
log4j.appender.socket.remoteHost=127.0.0.1
log4j.appender.socket.port=4445
log4j.appender.socket.locationInfo=true

```

java代码

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
		for (int j = 0; j < 4; j++) {
			Thread.sleep(1 * 1000);
			log.info(sdf.format(Calendar.getInstance().getTime()) + "info message " + i++);
			log.fatal(sdf.format(Calendar.getInstance().getTime()) + "fatal message  " + i++);
		}
		LogManager.shutdown();
	}
}

```

运行Test1。结果如图，收到了日志。我们可以在这个界面上，根据提供的功能进行筛选等操作。

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/chainSawResult1.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/chainSawResult1.png)


### 6.17 SocketHubAppender  ###

SocketHubAppender和SocketAppender很相似，而且大部分都是参考ScoketAppender的。

唯一的不同是：在 SocketAppender中，我们给定一个远程的服务器Ip以及端口，SocketAppender负责将日志发送到该服务器的指定端口。

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/socketHubAppender.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/socketHubAppender.png)

而在SocketHubAppedner中，它是将日志发送到指定的本机端口，多个远程服务器可以连接到本机该端口，这样，本机发送一条日志，可能会有多个远程服务器收到并且做处理。

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/socketHubAppender2.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/socketHubAppender2.png)


和SocketAppender相同的，SocketHubAppender 依赖于tcp协议保证数据包的正确传递。


#### 测试代码 ####

配置

```xml

log4j.rootLogger=debug,socket

log4j.appender.socket=org.apache.log4j.net.SocketHubAppender
log4j.appender.socket.port=4445
log4j.appender.socket.bufferSize=5

```

测试代码，运行该main方法，将一直发送日志信息到端口4445。

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
		for (int j = 0; j < 1000; j++) {
			Thread.sleep(1 * 3000);
			log.info(sdf.format(Calendar.getInstance().getTime()) + "info message " + i++);
			log.fatal(sdf.format(Calendar.getInstance().getTime()) + "fatal message  " + i++);
		}
		LogManager.shutdown();
	}
}
	
```


在Test2中，开启多线程模拟三个服务器端监听接收消息

```java
package com.linxingyang.a;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.net.Socket;
import java.net.UnknownHostException;

import org.apache.log4j.spi.LoggingEvent;

public class Test2 {
	public static void main(String[] args) throws UnknownHostException, IOException {
		Runnable r = new Runnable() {
			@Override
			public void run() {
				Socket socket;
				try {
					socket = new Socket("127.0.0.1", 4445);
					ObjectInputStream ois = new ObjectInputStream(socket.getInputStream());
					System.out.println(ois.available());
					while (socket.isConnected()) {
						LoggingEvent event = (LoggingEvent)ois.readObject();
						System.out.println("模拟服务器端[" + Thread.currentThread().getName() + "]收到日志消息:" + event.getMessage());
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		};
		new Thread(r, "receiver1").start();
		new Thread(r, "receiver2").start();
		new Thread(r, "receiver3").start();
	}
}

```

部分结果

```

模拟服务器端[receiver1]收到日志消息:2017-12-13 09:40:05fatal message  1159
模拟服务器端[receiver3]收到日志消息:2017-12-13 09:40:05fatal message  1159
模拟服务器端[receiver2]收到日志消息:2017-12-13 09:40:05fatal message  1159
模拟服务器端[receiver1]收到日志消息:2017-12-13 09:40:08info message 1160
模拟服务器端[receiver3]收到日志消息:2017-12-13 09:40:08info message 1160
模拟服务器端[receiver2]收到日志消息:2017-12-13 09:40:08info message 1160
模拟服务器端[receiver1]收到日志消息:2017-12-13 09:40:08fatal message  1161
模拟服务器端[receiver3]收到日志消息:2017-12-13 09:40:08fatal message  1161
模拟服务器端[receiver2]收到日志消息:2017-12-13 09:40:08fatal message  1161
模拟服务器端[receiver1]收到日志消息:2017-12-13 09:40:11info message 1162
模拟服务器端[receiver3]收到日志消息:2017-12-13 09:40:11info message 1162
模拟服务器端[receiver2]收到日志消息:2017-12-13 09:40:11info message 1162
模拟服务器端[receiver1]收到日志消息:2017-12-13 09:40:11fatal message  1163
模拟服务器端[receiver3]收到日志消息:2017-12-13 09:40:11fatal message  1163
模拟服务器端[receiver2]收到日志消息:2017-12-13 09:40:11fatal message  1163

```


### 6.18 SyslogAppender 输出到系统日志 ###

发送日志消息到远程的syslog后台线程。

#### header 布尔值，是否显示头信息 ####
默认false，头信息就是时间戳和主机名

#### facilityPrinting 打印设备名称 ####
默认false

#### facility 设备名称 ####
系统日志设备，设备选项有如下这些。大小写不敏感。

```

KERN, USER, MAIL, DAEMON, AUTH, SYSLOG, LPR, NEWS, UUCP,
     CRON, AUTHPRIV, FTP, LOCAL0, LOCAL1, LOCAL2, LOCAL3, LOCAL4,
     LOCAL5, LOCAL6, LOCAL7.

```

#### syslogHost 日志主机，端口 ####

主机ip， 可以设置端口例如

```

127.0.0.1:1234

```


#### 测试代码 ####

为了查看日志，下载一个Visual Syslog Server。可能需要翻墙
[https://sourceforge.net/projects/syslogserverwindows/?source=typ_redirect](https://sourceforge.net/projects/syslogserverwindows/?source=typ_redirect)

配置，此处ip设为本地127.0.0.1,端口设置为8899

```xml

log4j.rootLogger=debug,console

log4j.appender.console=org.apache.log4j.net.SyslogAppender
log4j.appender.console.facility=local1
log4j.appender.console.header=true
log4j.appender.console.facilityPrinting=true
log4j.appender.console.syslogHost=127.0.0.1:8899
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=log4j -- %d %m%n

```

测试例子就一直发送日志。

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
		for (int j = 0; j < 1000; j++) {
			Thread.sleep(1 * 3000);
			System.out.println("输出了日志");
			log.debug(sdf.format(Calendar.getInstance().getTime()) + "debug message  " + i++);
			log.info(sdf.format(Calendar.getInstance().getTime()) + "info message " + i++);
			log.warn(sdf.format(Calendar.getInstance().getTime()) + "warn message  " + i++);
			log.error(sdf.format(Calendar.getInstance().getTime()) + "error message  " + i++);
			log.fatal(sdf.format(Calendar.getInstance().getTime()) + "fatal message  " + i++);
		}
		LogManager.shutdown();
	}
}

```

在 Visual Syslog Sever 中要先设置好和你日志对应的端口号。

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/syslogAppender.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/syslogAppender.png)

结果，可以看到对应的信息展示了出来

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/syslogAppender3.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/syslogAppender3.png)


### 6.19 TelnetAppender 输出到telnet ###

输出到telnet

#### port  端口，默认23 ####

#### 测试代码 ####

配置

```xml

log4j.rootLogger=debug,telnet

log4j.appender.telnet=org.apache.log4j.net.TelnetAppender
log4j.appender.telnet.port=23
log4j.appender.telnet.layout=org.apache.log4j.PatternLayout
log4j.appender.telnet.layout.ConversionPattern=log4j -- %d %m%n

```

测试代码

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
		for (int j = 0; j < 1000; j++) {
			Thread.sleep(1 * 3000);
			System.out.println("输出了日志");
			log.debug(sdf.format(Calendar.getInstance().getTime()) + "debug message  " + i++);
			log.info(sdf.format(Calendar.getInstance().getTime()) + "info message " + i++);
			log.warn(sdf.format(Calendar.getInstance().getTime()) + "warn message  " + i++);
			log.error(sdf.format(Calendar.getInstance().getTime()) + "error message  " + i++);
			log.fatal(sdf.format(Calendar.getInstance().getTime()) + "fatal message  " + i++);
		}
		LogManager.shutdown();
	}
}
	

```


结果: 在windows在cmd命令行中，使用如下命令查看日志

```

telnet 127.0.0.1 23

```

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/telnetAppenderResult.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/telnetAppenderResult.png)


### 6.20 JMSAppender ###



### 6.21 NTEventLogAppender ###

只能使用于windows系统。而且必须要添加 几个dll文件。否则会报错：java.lang.UnsatisfiedLinkError.

我是windows x64 win7 。 在`C:\Windows\SysWOW64`加入`NTEventLogAppender.dll`文件后能够正常打日志。

dll下载地址 [http://www.zhaodll.com/dll/softdown.asp?softid=156272&iz2=2cd42ae73ab38e1a04e0ed884f6bbff1](http://www.zhaodll.com/dll/softdown.asp?softid=156272&iz2=2cd42ae73ab38e1a04e0ed884f6bbff1)

#### 测试代码 ####

配置

```xml

log4j.rootLogger=debug,nteventlog

log4j.appender.nteventlog=org.apache.log4j.nt.NTEventLogAppender
log4j.appender.nteventlog.layout=org.apache.log4j.PatternLayout
log4j.appender.nteventlog.layout.ConversionPattern=log4j -- %d %m%n

```

测试代码

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
		for (int j = 0; j < 1000; j++) {
			Thread.sleep(1 * 3000);
			System.out.println("输出了日志");
			log.debug(sdf.format(Calendar.getInstance().getTime()) + "debug message  " + i++);
			log.info(sdf.format(Calendar.getInstance().getTime()) + "info message " + i++);
			log.warn(sdf.format(Calendar.getInstance().getTime()) + "warn message  " + i++);
			log.error(sdf.format(Calendar.getInstance().getTime()) + "error message  " + i++);
			log.fatal(sdf.format(Calendar.getInstance().getTime()) + "fatal message  " + i++);
		}
		LogManager.shutdown();
	}
}

```

测试结果，打开控制面板->管理工具（小图标的视图下）->事件查看器->Windows日志->应用程序

![http://image.linxingyang.net/image/L-log4j/image/2017-08-05/NTEventAppender.png](http://image.linxingyang.net/image/L-log4j/image/2017-08-05/NTEventAppender.png)


### 6.22 RewriteAppender ###

参考本篇文章[http://www.luohw.com/notes/appender-of-log4j-6.html](http://www.luohw.com/notes/appender-of-log4j-6.html)


> RewriteAppender继承自AppenderSkeleton类，主要目的是对于LoggingEvent中的信息进行修改、过滤等，比如移除密码等敏感信息等。RewriteAppender需要RewritePolicy指定相关的重写策略

> RewritePolicy接口实现类有
> * MapRewritePolicy 针对LoggingEvent的message属性是否java.util.Map的实例，进行属性过滤。如果LoggingEvent的getMessage方法返回对象不是java.util.Map的实例则重写策略是完全不变化原有LoggingEvent；如果是java.util.Map的实例，则重写规则是：新创建一个新的LoggingEvent，新LoggingEvent的message是原有getMessage对象的message属性，其余属性放入新的LoggingEvent的MDC中。
> * PropertyRewritePolicy 针对用户自定义属性key/value的重写规则，对于一个LoggingEvent，如果其MDC中不包含用户配置的属性，则新创建一个LoggingEvent，新的LoggingEvent有原来LoggingEvent和用户自定义的属性。用户配置属性格式为：propname1=propvalue1,propname2=propvalue2
> * ReflectionRewritePolicy 针对反射的重写规则，对于LoggingEvent的message属性，如果其是String类型的实例，则原样输出；如果为非String对象，java.beans.Introspector获取方法信息反射调用。对于message名称的方法，其返回值作为新LoggingEvent的message，其他方法返回值作为新LoggingEvent的MDC。



ReflectionRewritePolicy:
Message对象中(要遵守javabean规范)的属性将会被取得，如果Message对象有个message属性，那么这个message属性将会替代Message对象作为消息，并且message属性不会再被添加到 properties中，
 Message对象中其它的属性将会被放到properties中，以属性为name，以属性值为value，
 如果properties中已经存在了相同的name，那么会被覆盖。





#### 测试代码  PropertyRewritePolicy ####

配置，配置了三个输出终端，区别只是其中的 %X %properties,%properties[name]。然后配置了PropertyRewritePolicy策略，其中属性设置了 `<param name="properties" value="name=linxingyang,age=24,from=fuding"/>`

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

java代码

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

结果

```

console1 -- [%X]{age,24}{name,linxingyang}{from,fuding}} 2017-12-14 11:22:30name debug message  0 
console2 -- [%properties]{age,24}{name,linxingyang}{from,fuding}} 2017-12-14 11:22:30name debug message  0 
console3 -- [%properties{name}]linxingyang 2017-12-14 11:22:30name debug message  0 
console1 -- [%X]{age,24}{name,linxingyang}{from,fuding}} 2017-12-14 11:22:30fatal message  1 
console2 -- [%properties]{age,24}{name,linxingyang}{from,fuding}} 2017-12-14 11:22:30fatal message  1 
console3 -- [%properties{name}]linxingyang 2017-12-14 11:22:30fatal message  1 

```


#### 测试代码 MapRewritePolicy ####


先举一例。
配置，简单的配置输出到控制台。

```xml

<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
	<appender name="console1" class="org.apache.log4j.ConsoleAppender">
		<layout class="org.apache.log4j.EnhancedPatternLayout">
			<param name="ConversionPattern" value=" -- [%%X]%X -- [%%properties]%properties -- [%%properties{name}]%properties{name} -- %m%n"/>
		</layout>
	</appender>
	<root>
		<level value="debug"></level>
		<appender-ref ref="console1"/>
	</root>
</log4j:configuration>

```

测试代码中 debug中的传入的不是一个简单的字符串了，而是一个Map对象。注意第二个fatal的map没有放入messsage。

```java

package com.linxingyang;

import java.io.FileNotFoundException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException, InterruptedException {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Map<String, String> debug = new HashMap<String, String>();
		debug.put("message", "hello debug");
		debug.put("name", "linxingyang");
		debug.put("age", "24");
		debug.put("time", sdf.format(new Date()));
		
		Map<String, String> fatal = new HashMap<String, String>();
		fatal.put("name", "lxy");
		fatal.put("age", "21");
		fatal.put("time", sdf.format(new Date()));
		
		log.debug(debug);
		log.fatal(fatal);
		LogManager.shutdown();
	}
}
	

```

结果如下：可以看到把map中的东西以键值对输出了。

```

 -- [%X]{} -- [%properties]{} -- [%properties{name}] -- {message=hello debug, time=2017-12-14 11:58:48, age=24, name=linxingyang}
 -- [%X]{} -- [%properties]{} -- [%properties{name}] -- {time=2017-12-14 11:58:48, age=21, name=lxy}

```

下面使用 MapRewritePolicy来测试看看。。

配置。

```xml

<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
	<appender name="console1" class="org.apache.log4j.ConsoleAppender">
		<layout class="org.apache.log4j.EnhancedPatternLayout">
			<param name="ConversionPattern" value=" -- [%%X]%X -- [%%properties]%properties -- [%%properties{name}]%properties{name} -- %m%n"/>
		</layout>
	</appender>
	<appender name="rewrite" class="org.apache.log4j.rewrite.RewriteAppender">
		<appender-ref ref="console1"/>
		<rewritePolicy class="org.apache.log4j.rewrite.MapRewritePolicy">
		</rewritePolicy>
	</appender>
	
	<root>
		<level value="debug"></level>
		<appender-ref ref="rewrite"/>
	</root>
</log4j:configuration>

```

java代码，还是一样的。注意第二个fatal的map没有放入messsage。

```java

package com.linxingyang;

import java.io.FileNotFoundException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException, InterruptedException {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Map<String, String> debug = new HashMap<String, String>();
		debug.put("message", "hello debug");
		debug.put("name", "linxingyang");
		debug.put("age", "24");
		debug.put("time", sdf.format(new Date()));
		
		Map<String, String> fatal = new HashMap<String, String>();
		fatal.put("name", "lxy");
		fatal.put("age", "21");
		fatal.put("time", sdf.format(new Date()));
		
		log.debug(debug);
		log.fatal(fatal);
		LogManager.shutdown();
	}
}
	

```


测试结果，可以看到，放入message的debug这个map，被RewriteAppender处理了，而fatal这个map因为没有key为message的键值对，所以message没有替换掉。但是两个的 MDC，properties都是有值的，说明都经过了处理，

```

 -- [%X]{age,24}{name,linxingyang}{time,2017-12-14 12:08:44}} 
 -- [%properties]{age,24}{name,linxingyang}{time,2017-12-14 12:08:44}} 
 -- [%properties{name}]linxingyang -- hello debug
 -- [%X]{age,21}{name,lxy}{time,2017-12-14 12:08:44}} 
 -- [%properties]{age,21}{name,lxy}{time,2017-12-14 12:08:44}}
 -- [%properties{name}]lxy 
 -- {time=2017-12-14 12:08:44, age=21, name=lxy}

```

#### 测试代码  ReflectionRewritePolicy ####

使用RefletionRewritePolicy，自定义了两个测试用的javabean

LogObjectA  没有包含message属性

```java

package com.linxingyang.c;

public class LogObjectA {
	private String name;
	private Integer age;
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public Integer getAge() {
		return age;
	}
	public void setAge(Integer age) {
		this.age = age;
	}
	@Override
	public String toString() {
		return "LogObjectA [name=" + name + ", age=" + age + "]";
	}
	
}

```


LogObjectB 包含了message属性

```java

package com.linxingyang.c;

public class LogObjectB {
	private String name;
	private Integer age;
	private String message;
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public Integer getAge() {
		return age;
	}
	public void setAge(Integer age) {
		this.age = age;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	@Override
	public String toString() {
		return "LogObjectB [name=" + name + ", age=" + age + ", message=" + message + "]";
	}
	
}

```

配置文件

```xml

<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
	<appender name="console1" class="org.apache.log4j.ConsoleAppender">
		<layout class="org.apache.log4j.EnhancedPatternLayout">
			<param name="ConversionPattern" value=" -- [%%X]%X -- [%%properties]%properties -- [%%properties{name}]%properties{name} -- %m%n"/>
		</layout>
	</appender>
	<appender name="rewrite" class="org.apache.log4j.rewrite.RewriteAppender">
		<appender-ref ref="console1"/>
		<rewritePolicy class="org.apache.log4j.rewrite.ReflectionRewritePolicy">
		</rewritePolicy>
	</appender>
	
	<root>
		<level value="debug"></level>
		<appender-ref ref="rewrite"/>
	</root>
</log4j:configuration>

```

测试代码 使用自定义对象，debug还是传入带有message的对象。

```java

package com.linxingyang;

import java.io.FileNotFoundException;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import com.linxingyang.c.LogObjectA;
import com.linxingyang.c.LogObjectB;

public class Test1 {
	private static Logger log = Logger.getLogger(Test1.class);
	public static void main(String[] args) throws FileNotFoundException, InterruptedException {
		LogObjectB debug = new LogObjectB();
		debug.setName("linxingyang");
		debug.setAge(24);
		debug.setMessage("hello debug from LogObjectB");

		LogObjectA fatal = new LogObjectA();
		fatal.setName("lxy");
		fatal.setAge(21);
		
		log.debug(debug);
		log.fatal(fatal);
		LogManager.shutdown();
	}
}
	
```

结果，和MapRewritePolicy差不多的，其感觉Map就是这个的一种特殊情况吧。有message属性的LogObjectB被处理了而没有message属性的LogObjectA虽然也被处理类，但是还是以其整个对象作为日志message输出了。

```

 -- [%X]{age,24}{name,linxingyang}} 
 -- [%properties]{age,24}{name,linxingyang}} 
 -- [%properties{name}]linxingyang -- hello debug from LogObjectB
 -- [%X]{age,21}{name,lxy}} 
 -- [%properties]{age,21}{name,lxy}} 
 -- [%properties{name}]lxy -- LogObjectA [name=lxy, age=21]

```


### 6.23 AsyncAppender ###

AsyncAppender能够让用户异步的打印日志,这个Appender会收集所有发送给它的日志事件，然后分发给所有附加在该Appender上的多个Apedner，

该日志器 使用一个单独的线程服务于它缓存区中的日志事件

重要：该日志器只能使用 DMOConfigurator进行配置。

#### bufferSize 缓冲区大小 ，默认128 ####
默认可以存储128条日志事件。

#### blocking 是否阻塞，默认true ####

当存够了bufferSize大小的日志，此时再有日志进来，是否阻塞？如果不阻塞，那么将会简单的丢弃日志事件。如果阻塞，不会丢弃日志事件，但被阻塞的日志肯定是稍微延迟了一些发送。

#### 测试代码 ####

测试代码

```xml

<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
	
	<appender name="console1" class="org.apache.log4j.ConsoleAppender">
		<layout class="org.apache.log4j.PatternLayout">
			<param name="ConversionPattern" value="console1 -- %m %n"/>
		</layout>
	</appender>
	<appender name="console2" class="org.apache.log4j.ConsoleAppender">
		<layout class="org.apache.log4j.PatternLayout">
			<param name="ConversionPattern" value="console2 -- %m %n"/>
		</layout>
	</appender>
	
	<appender name="async" class="org.apache.log4j.AsyncAppender">
		<param name="blocking" value="false"/>	
		<param name="bufferSize" value="2"/>	
		<param name="locationInfo" value="true"/>	
		<appender-ref ref="console1"/>
		<appender-ref ref="console2"/>
	</appender>
	
	<root>
		<appender-ref ref="async"/>
		<level value="debug"></level>
	</root>
</log4j:configuration>

```

java代码

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
		for (int j = 0; j < 1000; j++) {
			System.out.println("输出了日志");
			log.debug(sdf.format(Calendar.getInstance().getTime()) + "debug message  " + i++);
			log.info(sdf.format(Calendar.getInstance().getTime()) + "info message " + i++);
			log.warn(sdf.format(Calendar.getInstance().getTime()) + "warn message  " + i++);
			log.error(sdf.format(Calendar.getInstance().getTime()) + "error message  " + i++);
			log.fatal(sdf.format(Calendar.getInstance().getTime()) + "fatal message  " + i++);
			Thread.sleep(1 * 3000);
		}
		LogManager.shutdown();
	}
}
	

```

结果,通过设置blocking=false,bufferSize=2 来查看不阻塞，丢弃日志事件的情况。

如果阻塞，那么将不会丢弃日志事件，而是稍后转发到附加的Appender上。

```

输出了日志
console1 -- 2017-12-13 23:52:33debug message  0 
console2 -- 2017-12-13 23:52:33debug message  0 
console1 -- 2017-12-13 23:52:33info message 1 
console2 -- 2017-12-13 23:52:33info message 1 
console1 -- Discarded 3 messages due to full event buffer including: 2017-12-13 23:52:33fatal message  4 
console2 -- Discarded 3 messages due to full event buffer including: 2017-12-13 23:52:33fatal message  4 
输出了日志
console1 -- 2017-12-13 23:52:36debug message  5 
console2 -- 2017-12-13 23:52:36debug message  5 
console1 -- 2017-12-13 23:52:36info message 6 
console2 -- 2017-12-13 23:52:36info message 6 
console1 -- 2017-12-13 23:52:36warn message  7 
console2 -- 2017-12-13 23:52:36warn message  7 
console1 -- 2017-12-13 23:52:36error message  8 
console2 -- 2017-12-13 23:52:36error message  8 
console1 -- 2017-12-13 23:52:36fatal message  9 
console2 -- 2017-12-13 23:52:36fatal message  9 
输出了日志
console1 -- 2017-12-13 23:52:39debug message  10 
console2 -- 2017-12-13 23:52:39debug message  10 
console1 -- 2017-12-13 23:52:39info message 11 
console2 -- 2017-12-13 23:52:39info message 11 
console1 -- Discarded 3 messages due to full event buffer including: 2017-12-13 23:52:39fatal message  14 
console2 -- Discarded 3 messages due to full event buffer including: 2017-12-13 23:52:39fatal message  14 


```

### 6.24 LF5Appender ###

