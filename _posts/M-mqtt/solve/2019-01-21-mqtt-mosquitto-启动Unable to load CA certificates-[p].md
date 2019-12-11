---
layout: post
permalink: /:year/d5ca4f7648d44f9f94062af23e748f50
title: 2019-01-21-mqtt-mosquitto-启动Unable to load CA certificates
categories: [mqtt]
tags: [c,c++,mqtt,mosquitto]
excerpt: mosquitto-启动Unable to load CA certificates
description: mosquitto-启动Unable to load CA certificates
catalog: false
author: 林兴洋
---

今天搞了一波mosquitto服务迁移，从A移到B。

把必要的配置文件拷到B后`/etc/mosquitto/`目录下后，启动mosquitt

虽说没有消息是好消息，但是这里没有报任何错，明显就不对了，我又没有加 `-d` 参数让它后台运行。

```
[root@localhost mosquitto]# mosquitto -c /etc/mosquitto/mosquitto.conf 
[root@localhost mosquitto]#
```

想要看一眼日志，查看了`mosquitto.conf`配置文件，发现日志是有配置的，但是没有看到任何日志输出

```
log_dest file /etc/mosquitto/logs/mqttlogs.log
```

发现`/etc/mosquitto`目录下没有logs文件夹，要注意mosquitto不会帮你创建日志文件夹及文件，我们手动创建一下
在`/etc/mosquitto/`目录下

```
mkdir logs
cd logs
touch mqttlogs.log
```

然后在此启动mosquitto，再去看输出的日志信息
```
1548041779: mosquitto version 1.4 (build date 2018-03-07 13:56:50+0800) starting
1548041779: Config loaded from /etc/mosquitto/mosquitto.conf.
1548041779: Opening ipv4 listen socket on port 1883.
1548041779: Opening ipv6 listen socket on port 1883.
1548041779: Opening ipv4 listen socket on port 8883.
1548041779: Opening ipv6 listen socket on port 8883.
1548041779: Error: Unable to load CA certificates. Check cafile " /etc/mosquitto/ca.crt".
```


也没发现该文件有什么问题，文件是存在啊，而且之前也是用的这一份，运行的好好的。

把对应的配置注释掉，是可以正常启动的，那就是这一块的问题了

结果再详看日志 
```
" /etc/mosquitto/ca.crt" 
```
日志中，``/etc/mosquitto/ca.crt`前面多了一个空格，这是什么鬼。。。

到`mosquitto.conf`发现，配置是这样的
```
cafile  /etc/mosquitto/ca.crt
```

也就是键值对之间隔了两个空格，程序内部没有处理去两侧空格的操作，，，导致这样的结果。
将其改成一个空格 
```
cafile /etc/mosquitto/ca.crt
```

启动就可以了。。。

低级错误。告辞。


可是相同的配置，在原来的那台机子上，跑的没问题啊。。看了一下，A服务器上跑的mosquitoo版本是`1.4.12` ,B服务器上跑的版本`1.4`。可能是版本更新了一些东西吧~
