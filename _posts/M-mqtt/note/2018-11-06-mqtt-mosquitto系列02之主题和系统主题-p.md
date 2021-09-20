---
layout: post
permalink: /:year/67756e86d8834aac97b1530csystopic/index
title: 2018-11-06-mqtt-mosquitto系列02之主题和系统主题
categories: [mqtt]
tags: [post, mqtt, mosquitto, mosquitto系列]
date: 2018-11-06 11:37:35 +8
editdate: 2021-07-10 11:37:35 +8
eidtplace: 福州软件园
excerpt: mosquitto,mqtt,主题,系统主题
description: mqtt-mosquitto-主题和系统主题
catalog: true
author: 林兴洋
---

# mosquitto

mosquitto是订阅发布类型的服务器，不同客户端可以往特定主题上发送消息，然后订阅该主题的所有客户端将收到该消息，为此我们需要了解一些mosquitto主题的相关知识。

## 基本订阅

如下就是最基本的订阅主题例子，例子中客户端订阅了主题`device001`：

```shell
# mosquitto_sub -t "device001"
```

如下是发布一条消息"hello zhang san"到主题`device001`，所有订阅主题`device001`的客户端将收到该消息。（当然消息不是直接从一个客户端直接传递到另一个客户端，而是经过mosquitto服务器，mosquitto服务端接收到客户端的发布到主题`device001`的消息，复制消息副本发送给所有订阅主题`device001`的客户端）。

```shell
# mosquitto_pub -t "device001" -m "hello zhang san"
```

### 分层

主题存在分层概念（可以理解为文件/文件夹路径一样，有层级），如下：

```shell
# mosquitto_sub -t "wecon/vbox/device001"
```

### 通配符

有时候我们需要大批量订阅某些主题，总不能傻傻的一个个订阅，为了客户端能够订阅指定的一些主题，mosquitto支持两种通配符

- （+）通配一层
- （#）通配所有

需要注意一下几点

* 后面讲到的系统主题，`$SYS` 不会被 `#`匹配到，如果想要观察整个`$SYS`，使用 `$SYS/#`
* 通配符只能单独使用，因此订阅`a/b+/c`不能有效地使用通配符，单独使用即占单独的一层，就是两个反斜杠的中间或者末尾，如下

```
a/b+/c          不能通配，错误
a/+/c/d         通配订阅, a/任意主题/c/d
a/+/c/+         通配订阅，a/任意主题/c/d
a/b/c/+         通配订阅
a/b/c/d         普通订阅
a/whatever/c/d  普通订阅
```

* `#` 通配符只能用作订阅的最后一个字符，表示通配后面所有。


```
如 a/# 可以通配
a/b/c/d
a/whatever
```

#### 例子

订阅所有的话题

```shell
# mosquitto_sub -h test.mosquitto.org -t "#"
```

订阅所有的\$SYS主题

```shell
# mosquitto_sub -t "\$SYS/broker/#"
```

订阅所有以'lxy/'开头的话题

```shell
# mosquitto_sub -h test.mosquitto.org -t "lxy/#"
helloA
helloC
helloWhatever
```

发送消息，可以看到，上面收到了哪些。

```shell
# mosquitto_pub -h test.mosquitto.org -t "lxy/A" -m "helloA"  
# mosquitto_pub -h test.mosquitto.org -t "lxyB" -m "helloB"  
# mosquitto_pub -h test.mosquitto.org -t "lxy/CCCCC" -m "helloC" 
# mosquitto_pub -h test.mosquitto.org -t "lxy/whatever" -m "helloWhatever"
```

## 系统主题

这里需要特别介绍的是系统主题，对于MQTT管理员来说，可以通过系统主题检查当前MQTT服务器的一些状态情况。

### 关于转义

在linux系统中，`$SYS/...` 会被认为是环境变量，所以需要加一个反斜杠来转义 ，例：`\$SYS/...`

### bytes 

#### $SYS/broker/bytes/received 启动后接收的字节数

查看自启动后，mosquitto收到的总字节数

```shell
# mosquitto_sub -h test.mosquitto.org -t "\$SYS/broker/bytes/received"
216753582
216885620
217015805
```

#### $SYS/broker/bytes/sent 启动后的发送字节数

### clients 关于客户端的一些信息

#### $SYS/broker/clients/connected 当前连接数

#### $SYS/broker/clients/disconnected 当前断开连接数

#### $SYS/broker/clients/expired 超时移除用户数

根据persistent_client_expiration 设置的超时时间被移除的用户

#### $SYS/broker/clients/maximum 历史上同时连接过最大数客户端数量

#### $SYS/broker/clients/total 所有活跃或者不活跃的用户


#### $SYS/broker/connection/#


### 堆空间

#### $SYS/broker/heap/current size 当前使用的堆空间

mosquitto使用的堆空间，注意该项是根据编译时选项决定，所以可能不可用

#### $SYS/broker/heap/maximum size 最大使用的堆空间

同上

### 负载相关

#### $SYS/broker/load/connections/+ 每分钟收到的包数

不同时间间隔计算出来的每分钟收到的包数，1分钟，5分钟和15分钟。

```shell
# mosquitto_sub -h test.mosquitto.org -t "\$SYS/broker/load/connections/+"
1689.45 // 分别代表1分钟收到的包数
1700.82 // 5分钟收到的包数/5
1716.97 // 15分钟收到的包数/15
```

#### $SYS/broker/load/bytes/received/+  每分钟收到的byte数

也是以1,5,15分钟作为时间间隔
```shell
# mosquitto_sub -h test.mosquitto.org -t "\$SYS/broker/load/bytes/received/+"
704272.68
704121.33
708344.36
```

#### $SYS/broker/load/bytes/sent/+ 每分钟发送的字节数

同上

#### $SYS/broker/load/messages/received/+ 每分钟的接收 MQTT消息数量

```shell
# mosquitto_sub -h test.mosquitto.org -t "\$SYS/broker/load/messages/received/+"
10797.11
10786.62
10831.87
```

#### $SYS/broker/load/messages/sent/+ 每分钟的发送 MQTT消息数量

同上


#### $SYS/broker/load/publish/received/+ 每分钟收到的发布消息

#### $SYS/broker/load/publish/sent/+ 每分钟发送的发布消息

```shell
# mosquitto_sub -h test.mosquitto.org -t "\$SYS/broker/load/publish/received/+"
3364.83
3273.47
3274.06
```


#### $SYS/broker/load/sockets/+ 连接的socket数量


```shell
# mosquitto_sub -h test.mosquitto.org -t "\$SYS/broker/load/sockets/+"
1973.11
1973.11
1979.76
```

### message 消息相关

#### $SYS/broker/messages/inflight

QoS>0并且在等待确认的消息数量

#### $SYS/broker/messages/received 启动后发送的消息数量


#### $SYS/broker/messages/sent 启动后收到的消息数量

#### $SYS/broker/publish/messages/dropped 丢弃的消息数


因为 inflight/queuing limits而抛弃的消息数量

inflight : 等待中

queuing limits：队列上限

查看配置文件中  max_inflight_message 和 max_queued_messages两项


#### $SYS/broker/publish/messages/received 接收的publish消息数量


#### $SYS/broker/publish/messages/sent 发送的publish消息数量


#### $SYS/broker/retained messages/count 保留的消息数量


#### $SYS/broker/store/messages/count 当前存储的消息的数量

包括： 保留的消息和消息队列中排队的消息

### 其它

#### $SYS/broker/subscriptions/count 活跃的订阅者数量

#### $SYS/broker/version 查看版本

```shell
root@ubuntu:~# mosquitto_sub -h test.mosquitto.org -t "\$SYS/broker/version"
mosquitto version 1.5.3
```


## 推荐的软件

这里推荐一款软件 MQTT Explorer，不错，可以方便的来订阅主题，搜一下就有。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/100.png)


## 参考

* [系统主题](https://github.com/mqtt/mqtt.github.io/wiki/SYS-Topics)
* [mosquitto命令](http://mosquitto.org/man/mosquitto-8.html)

