---
layout: post
permalink: /:year/798abc8b2bff498a9d4c4933c0b1d91e/index
title: 2018-11-10-mqtt-mosquitto-配置用户名密码验证
categories: [mqtt]
tags: [c,c++,mqtt,mosquitto,mosquitto系列]
relative-tags: [mosquitto系列]
excerpt: mqtt,mosquitto,配置用户名密码验证
description: mqtt,mosquitto,配置用户名密码验证
catalog: true
author: 林兴洋
---

* [2018-11-05-mqtt-mosquitto-安装启动](http://linxingyang.net/2018/9f841b1490fc46aa8285db2576b1b7e0)
* [2018-11-07-mqtt-mosquiito-配置文件](http://linxingyang.net/2018/be282d30a8dd4b28aa0104a20bf32b3d)
* [2018-11-08-mqtt-mosquitto-mosquitto_sub和mosquitto_pub](http://linxingyang.net/2018/3a7989b061fd44c7a9ff4cdd7be5f8c2)
* [2018-11-09-mqtt-mosquitto-mosquitto_passwd](http://linxingyang.net/2018/60baaf14d2bb4ec89e1a3684d7819b01)
* [2018-11-10-mqtt-mosquitto-配置用户名密码验证](http://linxingyang.net/2018/798abc8b2bff498a9d4c4933c0b1d91e)

---


# mosquitto

## 配置用户名密码验证

指定密码文件，此处使用最简单的账号密码登录，不涉及TLS等加密

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

对于password_file，可以复制一份模板，或者创建一个空文件，如何创建密码参考上一篇文章。

```shell
# touch /etc/mosquitto/pwfile.conf
// 使用mosquitto_passwd命令创建用户，第一个lxy是用户名，第二个lxy是密码
# mosquitto_passwd -b /etc/mosquitto/pwfile.conf lxy lxy
```

重启mosquitto

### 订阅测试

此时订阅主题需要用密码

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



