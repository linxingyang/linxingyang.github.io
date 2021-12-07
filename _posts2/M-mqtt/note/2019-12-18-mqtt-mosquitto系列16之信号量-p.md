---
layout: post
permalink: /:year/bc5a8c01c1664643be595e8c828mqtts/index
title: 2019-12-18-mqtt-mosquitto系列16之信号量
categories: [mqtt]
tags: [post, mqtt, mosquitto]
date: 2019-12-18 09:06:48 +8
place: 福州软件园
editdate: 2021-10-05 11:55:47 +8
eidtplace: 福州软件园
excerpt: mqtt, mosquitto, 信号量
description: mqtt-mosquitto系列之信号量
catalog: true
author: 林兴洋
---

# mosquitto

## 信号量

### 获取mosquitto pid

两种方式
```shell
ps -ef | grep mosquitto
```


```shell
cat /var/run/mosquitto.pid  
```


### SIGINT SIGTERM 停止程序

发信号
```shell
kill -s SIGINT  [mosquito pid]
kill -s SIGTERM [mosquito pid]
```

用命令
```shell
root@ubuntu:~# service mosquitto stop
```

### SIGHUP 重新加载配置文件

注意有一些配置是无法重新加载的，比如桥接配置
```shell
kill -s SIGHUP [mosquito pid]
```

### SIGUSR1 持久化

当收到该信号，mosquitto将会把持久层数据库的数据写到磁盘中。只有当开启 persistence功能时，才会执行该操作
```shell
kill -s SIGUSR [mosquitto的pid]
```

### SIGUSR2

打印当前的订阅树，打印到指定日志输出的地点（stdout,stderr,log），仅作为一个测试特性，将来可能移除
```shell
kill -s SIGUSR2 [mosquitto的pid]
```

