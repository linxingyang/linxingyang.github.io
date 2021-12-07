---
layout: post
permalink: /:year/798abc8b2bff498a9d4c4933c0b1d91e/index
title: 2018-11-11-mqtt-mosquitto系列07之配置用户名密码验证
categories: [mqtt]
tags: [post, mqtt, mosquitto]
date: 2018-11-10 21:19:53 +8
place: 福州软件园
editdate: 2021-09-22 21:19:53 +8
eidtplace: 福州软件园
excerpt: mqtt, mosquitto, 用户名密码验证
description: mosquitto系列07之配置用户名密码验证
catalog: true
author: 林兴洋
---

# mosquitto

## 配置用户名密码验证

mosquitto配置文件中指定密码文件，此处使用最简单的账号密码登录，不涉及TLS等加密选项。

### 修改配置文件

修改mosquitto.conf

```shell
# vi /etc/mosquitto/mosquitto.conf
# 关闭匿名模式
allow_anonymous false
# 指定密码文件
password_file /etc/mosquitto/pwfile.conf
```

### 修改用户名密码文件

如何创建密码可参考[2018-11-10-mqtt-mosquitto系列06之mosquitto_passwd设置密码](http://linxingyang.net/2018/linxingyangwriteat20210919114504/)

```shell
# touch /etc/mosquitto/pwfile.conf

// 使用mosquitto_passwd命令创建用户，第一个lxy是用户名，第二个lxy是密码
# mosquitto_passwd -b /etc/mosquitto/pwfile.conf lxy lxy

// 重启mosquitto
# service mosquitto restart
```


### 订阅测试

此时订阅主题需要用密码，不用密码的话会提示not authorised。

```
root@ubuntu:~# mosquitto_sub -t "#" 

Connection Refused: not authorised.

root@ubuntu:~# mosquitto_sub -t "#" -u lxy -P lxy -v
notifications129 0
notifications130 1
notifications131 1
```

### 发布测试

发布消息也需要用密码

```
root@ubuntu:/etc/mosquitto# mosquitto_pub -t "topic/128" -m "i'm 128, msg to 128"
Connection Refused: not authorised.
Error: The connection was refused.

root@ubuntu:/etc/mosquitto# mosquitto_pub -t "topic/128" -m "i'm 128, msg to 128" -u lxy -P lxy
```



