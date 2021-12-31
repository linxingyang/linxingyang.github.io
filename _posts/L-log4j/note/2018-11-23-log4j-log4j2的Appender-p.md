---
layout: post
permalink: /:year/linxingyangwriteat20211212121026/index
title: log4j-log4j2的Appender
categories: [log4j]
tags: [post, log4j, java]
date: 2018-11-23 12:10:26 +8
place: 新大陆软件园
editdate: 2021-12-12 12:10:26 +8
eidtplace: 福州软件园
excerpt: log4j,log4j2,appender
description: log4j-log4j2的Appender
catalog: true
author: 林兴洋
---

# log4j2

## Appender

### RollingFileAppender

RollingFileAppender是一个OutputStreamAppender，把日志写到文件中（根据fileName参数），并且根据TriggeringPolicy和RolloverPolicy来翻滚文件。

RollingFileAppender使用RollingFileManager(继承自OutputStreamManager)来实现I/O和文件翻滚。

来自不同配置文件的RolloverFileAppenders不能分享， 但是如果Manager是可以访问的，那么RollingFileManagers是可以共享的。例如：两个web应用程序部署在同一个servlet容器，这两个web应用程序都可以拥有自己的配置，并且如果log4j是他们两个的日志类类加载器，那么它们可以安全的向同一个文件写入日志。

RollingFileAppender需要 TriggeringPolicy和RolloverStrategy。 triggeringpolicy决定一个rollover是否应该运行， rolloverstrategy决定rollover怎么运行。如果没有配置RolloverStratey，RollingFileAppender将会使用DefaultRolloverStrategy，

自从log4j2.5之后， DefaultRolloverStrategy可以配置一个本地的删除行为在rollover时运行。。


自从2.8之后，如果没有配置文件名，那么DirectWriteRolloverStratey将会代替DefaultRolloverStrategy。

自从2.9，DefaultRolloverStrategy中配置的一个本地的POSIX文件可以在rollover时运行，如果没有定义，内置的POSIX将会被应用。

RollingFileAppender不支持文件锁

#### append boolean 追加

当为true，默认值，将会把日志追加到文件的末尾。当为false，文件将会被清除并重写

#### bufferedIO boolean 缓冲IO

true，默认值，设置一个缓冲区，当缓冲满了之后才会写入到磁盘中。如果设置immediateFlush，当写入记录时，文件锁不能和ufferedIO同时用。

性能测试显示使用bufferedI/O将会显著提高性能，即使设置了immediateFlush

#### bufferSize int 缓冲区

默认8192bytes

#### createOnDemand boolean 按需创建文件 

默认false

设为true， 只有在第一个日志事件通过所有filters并且转发到该appender才创建文件。(而不是在log4j2启动的时候就创建日志文件)

#### filter Filter 过滤器

过滤器用来决定一个日志事件是否应该被该appender处理，多个Filter可以使用CompositeFilter

#### fileName String 文件名

写入的文件名，如果父文件夹不存在，那么就创建


#### filePattern String 文件归档名

####  immediateFlush boolean 马上刷新

默认值 ，当为true，马上刷新到disk，但是可能会影响性能

只有当这个appender和synchonous日志器一起用 immediateFlush=true 才有作用。

Asynchoronous 日志器和 appenders 将会在根据它自己的机制将会在存够一定事件后自动的刷新，即使immediateFlush设为false，这也保证了数据更高效的写入到disk

#### Layout Layout 格式

默认使用 %m%n

#### name 日志器的名称

#### ignoreException boolean 忽略错误

默认true，错误会被忽略掉

设为false，异常会被抛出。注意如果使用FailoverAppender包装该Appender，那么此项必须设为false。

#### filePermissions String 文件权限

#### fileOwner String 文件拥有者

#### fileGroup String

#### policy TriggeringPolicy

决定什么时候进行翻滚

##### Composite Trigger Policy 复合触发策略

可以组合多个触发策略，任何一个策略返回true，那么就触发策略。

```xml
<Policies>
  <OnStartupTriggeringPolicy />
  <SizeBasedTriggeringPolicy size="20 MB" />
  <TimeBasedTriggeringPolicy />
</Policies>
```

##### CronTriigerPolicy 定时

###### schedule string 

con表达式，其中配的表达式和 Quartz scheduler 一样。 

详细配置看 [http://logging.apache.org/log4j/2.x/log4j-core/apidocs/org/apache/logging/log4j/core/util/CronExpression.html](http://logging.apache.org/log4j/2.x/log4j-core/apidocs/org/apache/logging/log4j/core/util/CronExpression.html)

###### evaluateOnStartup boolean

启动时对比时间和当前时间判断是否应该马上翻滚

##### OnStartUpTriggeringPolicyParameters 启动就翻滚

###### minSize 

最小可翻滚大小。如果为0的的话，那么即使是一个空文件也会翻滚，默认值是1，将不会翻滚空文件

##### SizeBased Triggering Policy 根据大小触发

文件达到指定的大小时进行翻滚。单位可以是 KB,MB,GB。

##### TimeBasedTriggering Policy

基于日期/时间的策略，根据时间间隔进行翻滚

###### interval 翻滚时间间隔

默认1小时

###### modulate

指示是否应调整该间隔，以便在该间隔边界上发生下一次滚动。

例如当前时间 凌晨3点， interval=4， 那么第一次翻滚时间会在4点，下一次在8点
下一次在下午12点，下下次14点

#### strategy RolloverStrategy 

决定怎么翻滚

##### Default Rollover Strategy 默认翻滚策略

文件名如果以 .gz, .zip, bz2, deflate, pack200 或者 .xz ，那么将会根据后缀名的不同使用不同压缩方式压缩该日志文件

bzip2,deflate,pack200和xz需要 apache commons compress 包， 另外 XZ 需要 XZ for Java。

###### fileIndex String

默认值 max。

假设min值为1，max值为3，日志文件名为foo.log，文件匹配格式为 foo-%i.log。 那么过程如下

fileIndex = min

| 翻滚次数 | 输出目标 | 归档                          | 描述                                                         |
| -------- | -------- | ----------------------------- | ------------------------------------------------------------ |
| 0        | foo.log  | -                             | 所有日志都打印到foo.log                                      |
| 1        | foo.log  | foo-1.log                     | 当 foo.log重命名为foo1.log的时候，一个新的foo.log被创建并且开始被输入 |
| 2        | foo.log  | foo-1.log, foo-2.log          | 第二次翻滚的时候，foo-1.log重命名为foo-2.log，foo.log重命名 foo-1.log，创建foo.log文件被开始输入 |
| 3        | foo.log  | foo-1.log,foo-2.log,foo-2.log | 第三次翻滚，foo-2.log重命名foo-3.log, foo-1.log重命名foo-2.log, foo.log重命名为foo-1.log，并且创建foo.log开始被写入 |
| 4        | foo.log  | foo-1.log,foo-2.log,foo-2.log | foo-3.log将会被删除，foo-2.log重命名foo-3.log, foo-1.log重命名foo-2.log, foo.log重命名为foo-1.log，并且创建foo.log开始被写入 |

相对的，当fileIndex属性设置为 max，但是其他所有的配置都相同，那么情况如下

| 翻滚次数 | 输出目标 | 归档                          | 描述                                                         |
| -------- | -------- | ----------------------------- | ------------------------------------------------------------ |
| 0        | foo.log  | -                             | 所有日志都打印到foo.log                                      |
| 1        | foo.log  | foo-1.log                     | 当 foo.log重命名为foo1.log的时候，一个新的foo.log被创建并且开始被输入 |
| 2        | foo.log  | foo-1.log, foo-2.log          | 第二次翻滚的时候，foo.log重命名为foo-2.log，创建foo.log文件被开始输入 |
| 3        | foo.log  | foo-1.log,foo-2.log,foo-2.log | 第三次翻滚，foo.log重命名foo-3.log,并且创建foo.log开始被写入 |
| 4        | foo.log  | foo-1.log,foo-2.log,foo-2.log | 第四次翻滚，foo-1.log将会被删除。foo-2.log重命名为foo-1.log， foo-3.log重命名为foo-2.log，foo.log重命名为foo-3.log。并且创建foo.log开始被写入 |

fileIndex=nomax

最后，在release.28版本，如果fileIndex设置为 nomax，那么min和max将会在翻滚的时候被忽略，每次翻滚都是+1，

使用max和min那么将会如前表格所述，那种翻滚方式如果配置成 nomax，那么将无限增加。

如下配置了`<DefaultRolloverStrategy fileIndex="nomax"/>` 将会导致无上限的日志翻滚文件，如果想要手动处理过旧的历史日志文件可以使用这个来。

```xml
<RollingFile name="projectAErrorRollingFile" fileName="e:/log/projectAError.log"
             filePattern="e:/log/$${date:yyyy-MM}/serverERROR-%d{MM-dd-yyyy}-%i.log.gz">
    <PatternLayout pattern="%d{yyyy-MM-dd 'at' HH:mm:ss z} %-5level %class{36} %L %M - %msg%xEx%n"/>
    <SizeBasedTriggeringPolicy size="10KB"/>
    <DefaultRolloverStrategy fileIndex="nomax"/>
</RollingFile>
```

###### min integer 最小值

默认值1

###### max integer 最大值

默认值7

###### compressionLevel integer 压缩比

取值范围 0-9， 

0=none 不压缩, 1=best speed 最快压缩速度，最小压缩时间, ... 9=best compression 最好压缩比

只有实现ZIP格式


###### tempCompressedFilePatter String

压缩后文件存放的文件夹

##### DirectWriteRolloverStrategy

直接写入策略，根据这个策略，日志将被直接写入文件，文件重命名策略无效。

###### maxFiles String

指定最大文件数量，超过该数量时，最早先的文件将会被删除，。如果设置为0或者省略该配置，那么将不限制数量

###### compressionLevel integer 压缩比

###### tempCompressFilePattern

##### 配置例子

###### 第一个例子

下面的例子展示了 基于时间和大小来翻滚文件策略。

因为文件夹命名为 年份+月份的方式，所以每个文件夹下将会存放最多7份日志文件（因为默认使用DefaultRolloverStrategy，他的max默认值是7），同时因为后缀名是.gz，所以使用giz来压缩这些日志文件。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="warn" name="MyApp" packages="">
  <Appenders>
    <RollingFile name="RollingFile" fileName="logs/app.log"
                 filePattern="logs/$${date:yyyy-MM}/app-%d{MM-dd-yyyy}-%i.log.gz">
      <PatternLayout>
        <Pattern>%d %p %c{1.} [%t] %m%n</Pattern>
      </PatternLayout>
      <Policies>
        <TimeBasedTriggeringPolicy />
        <SizeBasedTriggeringPolicy size="250 MB"/>
      </Policies>
    </RollingFile>
  </Appenders>
  <Loggers>
    <Root level="error">
      <AppenderRef ref="RollingFile"/>
    </Root>
  </Loggers>
</Configuration>
```

###### 第二个例子

在第一个例子的基础上，展示了使用DefaultRolloverStrategy设置文件最大数量。那么现在一个文件夹中可以有20个历史日志文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="warn" name="MyApp" packages="">
  <Appenders>
    <RollingFile name="RollingFile" fileName="logs/app.log"
                 filePattern="logs/$${date:yyyy-MM}/app-%d{MM-dd-yyyy}-%i.log.gz">
      <PatternLayout>
        <Pattern>%d %p %c{1.} [%t] %m%n</Pattern>
      </PatternLayout>
      <Policies>
        <TimeBasedTriggeringPolicy />
        <SizeBasedTriggeringPolicy size="250 MB"/>
      </Policies>
      <DefaultRolloverStrategy max="20"/>
    </RollingFile>
  </Appenders>
  <Loggers>
    <Root level="error">
      <AppenderRef ref="RollingFile"/>
    </Root>
  </Loggers>
</Configuration>
```

###### 第三个例子

基于 time和size的触发策略，每个文件夹下会有最多7个旧的历史日志文件，并且使用gzip压缩。

同时使用 time策略，每6个小时翻滚一次。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="warn" name="MyApp" packages="">
  <Appenders>
    <RollingFile name="RollingFile" fileName="logs/app.log"
                 filePattern="logs/$${date:yyyy-MM}/app-%d{yyyy-MM-dd-HH}-%i.log.gz">
      <PatternLayout>
        <Pattern>%d %p %c{1.} [%t] %m%n</Pattern>
      </PatternLayout>
      <Policies>
        <TimeBasedTriggeringPolicy interval="6" modulate="true"/>
        <SizeBasedTriggeringPolicy size="250 MB"/>
      </Policies>
    </RollingFile>
  </Appenders>
  <Loggers>
    <Root level="error">
      <AppenderRef ref="RollingFile"/>
    </Root>
  </Loggers>
</Configuration>
```

###### 第四个例子  CronTriggerPolicy

使用cron策略，每小时备份一次，每达到250MB备份一次。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="warn" name="MyApp" packages="">
  <Appenders>
    <RollingFile name="RollingFile" filePattern="logs/app-%d{yyyy-MM-dd-HH}-%i.log.gz">
      <PatternLayout>
        <Pattern>%d %p %c{1.} [%t] %m%n</Pattern>
      </PatternLayout>
      <Policies>
        <CronTriggeringPolicy schedule="0 0 * * * ?"/>
        <SizeBasedTriggeringPolicy size="250 MB"/>
      </Policies>
    </RollingFile>
  </Appenders>
  <Loggers>
    <Root level="error">
      <AppenderRef ref="RollingFile"/>
    </Root>
  </Loggers>
</Configuration>
```

###### 第五个例子 CronTriggerPolicy

和第四个例子相同，只不过增加了 最大文件数为10

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="warn" name="MyApp" packages="">
  <Appenders>
    <RollingFile name="RollingFile" filePattern="logs/app-%d{yyyy-MM-dd-HH}-%i.log.gz">
      <PatternLayout>
        <Pattern>%d %p %c{1.} [%t] %m%n</Pattern>
      </PatternLayout>
      <Policies>
        <CronTriggeringPolicy schedule="0 0 * * * ?"/>
        <SizeBasedTriggeringPolicy size="250 MB"/>
      </Policies>
      <DirectWriteRolloverStrategy maxFiles="10"/>
    </RollingFile>
  </Appenders>
  <Loggers>
    <Root level="error">
      <AppenderRef ref="RollingFile"/>
    </Root>
  </Loggers>
</Configuration>
```

###  RollingRandomAccessFileAppender

RollingRandomAccessFileAppender 和  RollingFileAppender 很像，区别是：RollingRandomAccessFileAppender总是开启缓冲（可以关闭），并且它内部使用的是ByteBuffer + RandomAccessFile 代替 BufferedOutputStream。 

官方测试，相对于RollingFileAppender ,RollingRandomAccessFileAppender有20-200%的性能。

RollingRandomAccessFileAppender和RollingFileAppender 的属性一样。

### AsyncAppedner

要了解这个，提升打印效率，但是多线程来打印，也会耗费资源。 如果当前日志速度够用，就不用增加AsyncAppender，使用一段时间使用看看
