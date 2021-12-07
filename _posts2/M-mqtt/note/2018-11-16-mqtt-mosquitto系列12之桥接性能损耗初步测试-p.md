---
layout: post
permalink: /:year/linxingyangwriteat20210922222338/index
title: 2018-11-16-mqtt-mosquitto系列12之桥接性能损耗初步测试
categories: [mqtt]
tags: [post, mqtt, mosquitto]
date: 2018-11-16 22:23:38 +8
place: 福州软件园
editdate: 2021-09-22 22:23:38 +8
eidtplace: 福州软件园
excerpt: mqtt, mosquitto, 桥接性能损耗初步测试
description: mqtt-mosquitto系列12之桥接性能损耗初步测试
catalog: true
author: 林兴洋
---

# mosquitto

## 桥接性能损耗初步测试

### 不配置桥接测试

不配置桥接中心的情况，3个mosquitto服务端，3个mqtt客户端。3个客户端分别连接到3个mosquitto服务器，客户端全速发送，每秒发送4W条128byte的数据。

![](attachments/2021-09-22_18-02-27.jpg)

资源情况：
* 3个客户端150%CPU
* 3个mosquitto服务端42%CPU，此时每个mosquitto承受4W条数据进来.


### 配置桥接测试

在前面的基础上加了1个mosquitto服务端只用来做桥接中心。

```

# =================================================================
# Bridges
# =================================================================

connection bridge2801
address 127.0.0.1:2801
topic # both 0
#bridge_bind_address
#bridge_attempt_unsubscribe true
#bridge_protocol_version mqttv311
#cleansession false
#idle_timeout 60
#keepalive_interval 60
#local_clientid
#notifications true
#notification_topic
remote_password wecon_wecon
remote_username wecon
remote_username wecon
#restart_timeout 5 30
#round_robin false
#start_type automatic
#threshold 10
#try_private true
#bridge_outgoing_retain true
#bridge_max_packet_size 0


connection bridge2802
address 127.0.0.1:2802
topic # both 0
#bridge_bind_address
#bridge_attempt_unsubscribe true
#bridge_protocol_version mqttv311
#cleansession false
#idle_timeout 60
#keepalive_interval 60
#local_clientid
#notifications true
#notification_topic
remote_password wecon_wecon
remote_username wecon
remote_username wecon
#restart_timeout 5 30
#round_robin false
#start_type automatic
#threshold 10
#try_private true
#bridge_outgoing_retain true
#bridge_max_packet_size 0


connection bridge2803
address 127.0.0.1:2803
topic # both 0
#bridge_bind_address
#bridge_attempt_unsubscribe true
#bridge_protocol_version mqttv311
#cleansession false
#idle_timeout 60
#keepalive_interval 60
#local_clientid
#notifications true
#notification_topic
remote_clientid bridge2803
remote_password wecon_wecon
remote_username wecon
#restart_timeout 5 30
#round_robin false
#start_type automatic
#threshold 10
#try_private true
#bridge_outgoing_retain true
#bridge_max_packet_size 0

```

![](attachments/2021-09-22_18-04-02.jpg)

资源情况：
* 3个客户端150%CPU不变
* 3个mosquitto从42%CPU升到了69%CPU，每个mosquitto承受 12W（客户端进来4W，桥接进来8W）条数据进来，4W条数据出去（给桥接）。
* 桥接mosquitto则达到了100%CPU，此时桥接承受12W（4W X 3）条数据进来，24W（8W X 3）条数据出去。


### 总结

mosquitto桥接肯定会多消耗一些服务端资源，这是不可避免的，因为服务端多做事情了嘛。

由于mosquitto是单线程这一特点，通常情况下，桥接中心肯定是先达到100%CPU，所以你可以根据你的实际情况，测试一下在你业务数据顶峰的并发量下，mosquitto桥接中心的CPU资源占用率，如果没有达到100%，那说明可以运用这套。即使达到了100%，也可以根据实际情况（比如有无丢失数据，桥接转发的数据延迟是否很高，客户端是否连接被断开），因为有时候CPU占用率在100%不是处理不过来，可能是刚刚好处理的过来。



