---
layout: post
permalink: /:year/3a7989b061fd44c7a9ff4cdd7be5f8c2
title: 2018-11-08-mosquitto-sub-pub
categories: [mqtt]
tags: [c,c++,mqtt,mosquitto,mosquitto系列]
relative-tags: [mosquitto系列]
excerpt:  mosquitto,mosquitto_pub,mosquitto_sub
description: mosquitto,mosquitto_pub,mosquitto_sub
catalog: true
author: 林兴洋
---

# mosquitto

## mosquitto_sub 订阅

### 加密

mosquitto_sub支持TLS加密连接，强烈建议使用加密连接来代替最基本的连接设置

使用 CA证书来实现TLS连接，--cafile 或者 --capath必须提供

使用TLS-PSK来实现TLS连接，必须要使用--psk 和 --psk-identity选项


### 格式，参数

用来订阅话题



#### 常用

##### -h 主机 默认localhost
##### -p 端口
##### -u 用户名
##### -P 密码
##### -t 话题

##### -q --qos

QoS等级，默认0

##### -v verbose冗长的，打印的信息比较全



#### 其它

##### -c --disable-clean-session

不要清空会话，当客户端断开时，服务端不要清空与该客户端的会话。

将QoS1和QoS2消息放入队列中，当客户端重连后，会收到这些消息


要使用这个配置项，必须要手动使用 --id选项来设置 clientid


##### --quiet 沉默，

所有运行时错误将不会被打印，但不包括如 using --port 但是没有提供 port这种用户输入错误

##### -R 不展示保留信息

保留位被设置的消息将不会打印。

有一些之前的消息都不知道什么时候发布的，当使用通配符订阅话题，可能会收到一堆保留消息。使用该项不展示这些保留信息


##### --retained-only 只展示保留信息

和-R刚好相反，只展示保留信息，当收到第一个条非保留信息，客户端就会退出

##### -S


#### -L URL



##### -T --filter-out 过滤

如 mosquitto_sub -t bbc/# -T bbc/radio3   监听所有的bbc/下面的内容，但是过滤 bbc/radio3的内容。

##### -V 协议版本

##### -W 提供一个int型的数值作为超时时间（秒）

mosquitto_sub将会在超过该时间后停止处理消息并且断开连接。
计时从该客户端连接上mosquitto开始。

##### -k --keepalive

默认60秒发送一个ping给服务器



#### SSL/TSL登录

##### --cafile

详见后面基于 CA的TLS/SSL登录

##### --capath

详见后面基于 CA的TLS/SSL登录

##### --cert

详见后面基于 CA的TLS/SSL登录

##### --tls-version tls的版本

可用tlsv1.2（默认）， tlsv1.1， tlsv1

需要和服务端使用的tls版本匹配

##### --cipher


##### --key

详见后面基于 CA的TLS/SSL登录


##### --insecure

测试环境中有用并且只在测试环境中用，但是生产环境中不应该使用


#### -F format格式

该项将会覆盖-v配置项，但是不会覆盖 -N配置项


##### 输出格式

有三种输出方式



1，payload-only默认的就是只输出payload内容

2， Verbose 冗长模式，带个参数 -v开启，打印该消息的话题topic以及他的内容payload，以空格分割

3，指定输出格式

```
使用 -F format-string 来指定

此处使用%,@和\作为配置的开头

以%开头的序列要么是与正在打印的MQTT消息相关的参数，要么是帮助序列，以避免键入长日期格式字符串(例如)。

以@开头的序列被传递给strftime函数(用% -注意，只有@之后的字符被传递给strftime)。这允许构建各种基于时间的输出。strftime的输出选项因平台而异，所以请检查您的平台有哪些可用选项。mosquitto_sub确实提供了strftime的一个扩展，即@N，可用于获取当前秒内传递的纳秒数。此选项的分辨率因平台而异。

最后一个序列字符是\，它用于输入一些否则很难输入的字符。



```



MQTT相关参数

```

%% 是 %
%l payload长度，单位为字节
%m 消息的id，只有QoS>0的消息才有
%p 内容
%q 消息的QoS
%r 保留位信息
%t 消息的话题
%x 16进制
%X 16进制


```

相关帮助

```
%I ISO-8601格式的日期，如 2016-08-10T09:47:38+0100
%U Unix时间戳，纳秒级 如 1470818943.786368637

%j JSON格式的输出，timestamp时间戳，topic话题，qos质量，retain保留位，payload内容
{"tst":1470825369,"topic":"greeting","qos":0,"retain":0,"payload":"hello world"}

%J JSON输出，对于payload不加双引号以及转义处理，这意味着payload自己必须是正确的JSON格式，如
{"tst":1470825369,"topic":"foo","qos":0,"retain":0,"payload":{"temperature":27.0,"h
umidity":57}}.

```



时间相关参数

```
@@ 是 @
@X 传递x给strftime函数，可选项是根据系统平台决定的
@N 当前秒，已经过了多少毫秒了


mosquitto_sub -F '@Y-@m-@dT@H:@M:@S@z : %t : %x' -t '#'
```

转义字符

```
\\ 是 \
\0 是null字符，用来分开那些可能包含空格的参数（例如topic,payload）是的处理更容易

\a alert/bell
\e 
\n 换行
\r 回车
\t 水平制表符
\v 垂直制表符

```



#### wills 遗嘱

mosquitto可以注册一个消息到代理上，当mosquitto_sub意外的断开连接后，该消息将会被发送出去


##### --will-payload

当客户端异常的断开连接后将会被发送。需要和--will-topic合用

##### --will-qos

qos等级等级，默认0。需要和--will-topic合用


##### --will-retain

如果给定这个参数，那么当客户端异常的断开连接后，消息将会被当做保留消息发送。需要和--will-topic合用

##### --will-topic

遗嘱的话题

```
root@ubuntu:~# mosquitto_sub -t "topic/#" -v --will-topic "topic/leaving/130" --will-payload "i'm leaving, 130"
```

## mosquitto_pub 发布


### 加密

和sub一样，


### 选项

#### 常用
##### -h 主机名，默认localhost
##### -p 端口
##### -m 消息
##### -n null message空消息
##### -t topic话题
##### -d 启动debug消息

##### -f 发送文件中的内容作为消息的内容

例：发送 data中的内容到 my/topic话题
mosquitto_pub -t my/topic -f ./data
mosquitto_pub -t my/topic -s < ./data


##### -i --id
客户端使用的id，如果没有给定，那么默认是 mosquitto_pub_ 加上 客户端的处理序号id
不能和 -I 一起使用

##### -I --id-prefix
id的前缀，当mosquitto代理中配置了使用 clientid_prefixes选项，那这个配置就有用了。
不能和 -i一起使用




##### -k --keepalive
两次发送ping命令之间的时间间隔，默认60秒

##### --key

##### -L 指定链接
 格式：mqtt(s)://[username[:password]@]host[:port]/topic
如果是mqtt那么就访问1883端口，如果是mqtts，就访问8883端口

之前做过的连接test.mosquitto.org
mosquitto_sub -h test.mosquitto.org -t "#"
也可以这么写
mosquitto_sub -L mqtt://test.mosquitto.org/#

##### -l --stdin-line
从stdin中发送消息，空白行不会被发送（但是我测试发现空白行还是被发送了）

mosquitto_pub -t "test" -l 
这样就可以在控制台中手动输入东西发送到mosquitto。ctrl+d退出


##### -s --stdin-file
从stdin发送消息，所有输入作为单条信息发送. ctrl+d退出


##### -u username 指定用户名
##### -P password 指定密码，如果只指定password而没有指定username，那么也是无效的



##### -q --qos 消息质量的等级，可选有0,1,2  默认0

#### 其它

##### -A 如果想要和指定的网络通信，可以指定一个ip address/hostname

##### --quiet 沉默，

所有运行时错误将不会被打印，但不包括如 using ##### --port 但是没有提供 port这种用户输入错误

##### -r --retain

##### -v --protocol-version
可以是mqttv311或者mqttv31，默认mqttv311


#### 证书
-c 
##### --cafile ca证书
##### --capath ca路径

##### --insecure
当使用基于ca证书的验证，这个选项让客户端不验证服务器端证书

建议：仅在测试环境中可以使用这个变量，否则CA验证毫无意义

##### --psk
##### --psk-identity

##### --tls-version tls版本

选择tls的版本，可选项有tlsv1.2,tlsv1.1,tlsv1，默认的是tlsv1.2， 

#### 遗言

##### --will-payload
##### --will-qos
##### --will-retain
##### --will-topic


