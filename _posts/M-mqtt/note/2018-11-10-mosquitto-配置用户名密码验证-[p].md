---
layout: post
permalink: /:year/798abc8b2bff498a9d4c4933c0b1d91e
title: 2018-11-10-mosquitto-配置用户名密码验证
categories: [mqtt]
tags: [c,c++,mqtt,mosquitto,mosquitto系列]
relative-tags: [mosquitto系列]
excerpt:  mosquitto,配置用户名密码验证
description: mosquitto,配置用户名密码验证
catalog: true
author: 林兴洋
---

# mosquitto

## 登录需要密码测试

指定密码文件，此处使用最简单的账号密码登录，不涉及TLS等加密

修改mosquitto.conf

```
# 关闭匿名模式
allow_anonymous false
# 指定密码文件
password_file /etc/mosquitto/pwfile.conf
```

对于passworf_file，可以复制一份模板，或者创建一个空文件

```

touch /etc/mosquitto/pwfile.conf
# 使用mosquitto_passwd命令创建用户，第一个lxy是用户名，第二个lxy是密码
mosquitto_passwd -b /etc/mosquitto/pwfile.conf lxy lxy

```

重启mosquitto

此时订阅主题需要用密码

```
root@ubuntu:~# mosquitto_sub -t "#" 

Connection Refused: not authorised.
root@ubuntu:~# mosquitto_sub -t "#" -u lxy -P lxy -v
notifications129 0
notifications130 1
notifications131 1

```

发布消息也需要用密码

```

root@ubuntu:/etc/mosquitto# mosquitto_pub -t "topic/128" -m "i'm 128, msg to 128"
Connection Refused: not authorised.
Error: The connection was refused.
root@ubuntu:/etc/mosquitto# mosquitto_pub -t "topic/128" -m "i'm 128, msg to 128" -u lxy -P lxy

```



