---
layout: post
permalink: /:year/linxingyangwriteat20210919114125/index
title: 2018-11-08-mqtt-mosquitto系列04之mosquitto_sub订阅
categories: [mqtt]
tags: [post, mqtt, mosquitto]
date: 2018-11-08 11:41:25 +8
editdate: 2021-08-22 11:41:25 +8
eidtplace: 福州软件园
excerpt: mosquitto,mosquitto_pub,mosquitto_sub
description: mosquitto,mosquitto_pub,mosquitto_sub
catalog: true
author: 林兴洋
---


# mosquitto

## mosquitto_sub 订阅

mosquitto提供了简便的客户端订阅发布命令`mosquitto_sub`和`mosquitto_pub`，我们一般用这两个命令来做一些简单的连接、订阅、发布测试，以及在一些脚本中去调用这些命令。实际开发的客户端没有基于这个，不过倒可以使用mosquitto提供的客户端库libmosquitto，`mosquitto_sub`也是基于这个客户端库。

### 例子

平常使用看那么多参数没用，基本几个使用例子知道就可以了。

```shell
// 订阅一个主题，-t指出主题名称，本机可不指定host和port
# mosquitto_sub -t "topic"

// 指定本机host和port
# mosquitto_sub -t "topic" -h 127.0.0.1 -p 1883

// 需要用户名密码，注意密码的P是大写，因为小写的p已经被port使用了
# mosquitto_sub -t "topic" -u myUsername -P myPassword

// 单向证书认证，指定insecure用于不验证服务端的证书中的域名和当前访问服务端的域名相同。
# mosquitto_sub -t "topic" --cafile /path/to/ca.crt --insecure

// 双向证书认证
# mosquitto_sub -t "topic" --cafile /path/to/ca.crt --cert /path/to/client.crt --key /path/to/client.key --insecure 

// 带遗嘱的订阅
# mosquitto_sub -t "topic" --will-topic "topic/leaving/" --will-payload "i'm leaving now"
```


### 格式 & 参数

#### -h 主机 默认localhost
#### -p 端口
#### -u 用户名
#### -P 密码
#### -t 话题

#### -q --qos

QoS等级，默认0

#### -v verbose 打印的信息比较全

#### -c --disable-clean-session

不要清空会话，当客户端断开时，服务端不要清空与该客户端的会话。在发送QoS1和QoS2消息时如果网络或者其他原因中断连接了，当客户端重连后，会收到这些消息，要使用这个配置项，必须要手动使用 `--id`选项来设置 clientid。

#### -A 指定绑定本地IP或者主机名

#### -C 当收到指定条数消息后断开连接。

#### --quiet 沉默

所有运行时错误将不会被打印，但不包括如 using --port 但是没有提供 port这种用户输入错误

#### -R 不展示保留信息

保留位被设置的消息将不会打印。有一些之前的消息都不知道什么时候发布的，当使用通配符订阅话题，可能会收到一堆保留消息。使用该项不展示这些保留信息

#### --retained-only 只展示保留信息

和-R刚好相反，只展示保留信息，当收到第一个条非保留信息，客户端就会退出

#### -L URL 

一次性指定一些参数

```
mqtt(s)://[username[:password]@]host[:port]/topic
```

#### --unix 连接到unix本地文件

连接到本地文件，比如`mosquitt_sub --unix /tmp/mosquitto.sock`。

#### -T --filter-out 过滤

如 `mosquitto_sub -t bbc/# -T bbc/radio3` ，监听所有的`bbc/`下面的内容，但是过滤`bbc/radio3`的内容。

#### -V 指定协议版本

可指定`mqttv5`、`mqttv311`、`mqttv31`。默认`mqttv311`

#### -W 提供一个int型的数值作为超时时间（秒）

mosquitto_sub将会在超过该时间后停止处理消息并且断开连接。计时从该客户端连接上mosquitto开始。

#### -k --keepalive

默认60秒发送一个ping给服务器。

#### -d --debug 启用调试信息

#### -i --id 客户端ID

#### -I --id-prefix 客户端前缀

#### SSL/TLS登录

mosquitto_sub支持TLS加密连接，使用CA证书来实现TLS连接，`--cafile`或者`--capath`选项必须提供，使用TLS-PSK来实现TLS连接，`--psk` 和 `--psk-identity`选项必须提供。

##### --cafile ca文件

##### --capath ca路径

##### --cert 

##### --tls-version tls的版本

可用tlsv1.2（默认）， tlsv1.1， tlsv1。需要和服务端使用的tls版本匹配

##### --cipher

##### --key

##### --insecure

测试环境中有用，并且建议只在测试环境中用，生产环境中不应该使用。

##### --keyform 

私钥的类型，默认"pem"，可以设置为"engine"

#### -F format格式

该项将会覆盖-v配置项，但是不会覆盖 -N配置项

##### 输出格式

有三种输出方式

1，payload-only默认的就是只输出payload内容

2，Verbose 冗长模式，带个参数 -v开启，打印该消息的话题topic以及他的内容payload，以空格分割

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


##### --will-payload 遗嘱内容

当客户端异常的断开连接后将会被发送。需要和--will-topic合用

##### --will-qos 遗嘱QoS

qos等级等级，默认0。需要和--will-topic合用


##### --will-retain 保留位

如果给定这个参数，那么当客户端异常的断开连接后，消息将会被当做保留消息发送。需要和--will-topic合用

##### --will-topic

遗嘱的话题

