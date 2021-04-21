---
layout: post
permalink: /:year/bc5a8c01c1664643be595e8c828mqtts/index
title: 2019-12-18-mqtt-mosquitto-几个信号量
categories: [mqtt]
tags: [c,c++,mqtt,mosquitto,mosquitto系列,信号量]
relative-tags: [mosquitto系列]
excerpt: mosquitto,几个信号量
description: mosquitto-几个信号量
catalog: true
author: 林兴洋
---

# mosquitto

常用几个MQTT信号如下：

## 停止程序

```
kill -s SIGINT  [mosquito pid]
kill -s SIGTERM [mosquito pid]
```

## 重新加载配置文件，注意有一些是没有重新加载的

```
kill -s SIGHUB [mosquito pid]
```

## 打印当前订阅树结构

```
kill -s SIGUSR2	[mosquitto PID]
```



## SIGUSR1 持久化

当收到该信号，mosquitto将会把持久层数据库的数据写到磁盘中。只有当开启 persistence功能时，才会执行该操作

```
获得ps获得mosquitto的pid
ps -ef | grep mosquitto 
kill -s SIGUSR [mosquitto的pid]
```

## SIGUSR2

打印当前的订阅树，打印到指定日志输出的地点（stdout,stderr,log），仅作为一个测试特性，将来可能移除

```
获得ps获得mosquitto的pid
ps -ef | grep mosquitto 
kill -s SIGUSR2 [mosquitto的pid]
```


## 重启  SIGHUP

```
获得ps获得mosquitto的pid
ps -ef | grep mosquitto 
根据pid来重启
kill -s SIGHUP [mosquitto的pid]
```



## 停止mosquitto

```
root@ubuntu:~# service mosquitto stop
```



