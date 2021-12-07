---
layout: post
permalink: /:year/linxingyangwriteat20210922215556/index
title: 2018-11-14-mqtt-mosquitto系列10之配置桥接用户名密码验证
categories: [mqtt]
tags: [post, mqtt, mosquitto]
date: 2018-11-14 21:55:56 +8
place: 福州软件园
editdate: 2021-09-22 21:55:56 +8
eidtplace: 福州软件园
excerpt: mqtt, mosquitto,配置桥接用户名密码验证
description: mqtt-mosquitto系列10之配置桥接用户名密码验证
catalog: true
author: 林兴洋
---


# mosquitto

## 基于用户名密码的桥接

基于前一篇[2018-11-13-mqtt-mosquitto系列09之配置桥接](http://linxingyang.net/2018/bf6b45256d9d48c3a0ae55e318d077f4/)，接着来看看桥接设置用户名密码。

### 桥接设置用户名密码

主机128是桥接中心，129，130，131是三个普通broker。

订阅128和129需要用户名密码验证，130和131的配置不变。

#### 给128添加用户名密码验证

修改128主机的mosquitto.conf，如何创建密码可参考[2018-11-10-mqtt-mosquitto系列06之mosquitto_passwd设置密码](http://linxingyang.net/2018/linxingyangwriteat20210919114504/)

```shell
# vim /etc/mosquitto/mosquitto.conf

...

# 关闭匿名模式
allow_anonymous false
# 指定密码文件
password_file /etc/mosquitto/pwfile.conf

...

```

128的登录账号密码
```shell
# mosquitto_passwd -b /etc/mosquitto/pwfile.conf lxy128 lxy128
```


#### 给129添加用户名密码验证

修改129主机的mosquitto.conf

```shell
# vim /etc/mosquitto/mosquitto.conf

...

# 关闭匿名模式
allow_anonymous false
# 指定密码文件
password_file /etc/mosquitto/pwfile.conf

...

```

129的登录账号密码

```shell
# mosquitto_passwd -b /etc/mosquitto/pwfile.conf lxy129 lxy129
```


#### 桥接中心

128还是作为桥接中心，注意此时还没有配置对应的用户名密码，是为了看一下不设置用户名密码情况下的情况。

```shell
# vim /etc/mosquitto/mosquitto.conf

...

# 关闭匿名模式
allow_anonymous false
# 指定密码文件
password_file /etc/mosquitto/pwfile.conf

# 桥接信息
connection bridge129
address 192.168.193.129:1883
cleansession true
topic topic/# both 0
notifications true
notification_topic notifications129

connection bridge130
address 192.168.193.130:1883
cleansession true
topic topic/# both 0
notifications true
notification_topic notifications130

connection bridge131
address 192.168.193.131:1883
cleansession true
topic topic/# both 0
notifications true
notification_topic notifications131

...


```


#### 测试

开始测试，每个主机都启动mosquitto_sub监听。 在128主机中发送两条消息  

```shell
# mosquitto_pub -t "topic/128" -m "i'm 128, msg to 128" -u lxy128 -P lxy128
# mosquitto_pub -t "topic/128" -m "i'm 128, msg to 128" -u lxy128 -P lxy128
```

结果如下：

128能收到消息。同时可以看到，对于notifications，130，131都是1，只有129是0，说明129没连上，多个notifications129 0 说明有重复去连接129主机，为什么连不上129，原因也很简单，因为在128的桥接配置中没有配置129的账号密码。

```shell
root@ubuntu:/etc/mosquitto# mosquitto_sub -t "#" -v -u lxy128 -P lxy128
notifications129 0
notifications130 1
notifications131 1
notifications129 0
notifications129 0
topic/128 i'm 128, msg to 128
notifications129 0
topic/128 i'm 128, msg to 128
notifications129 0
notifications129 0
notifications129 0
notifications129 0
```

129没有收到任何消息

```
root@ubuntu:~# mosquitto_sub -t "#" -v -u lxy129 -P lxy129
```

130正常

```
root@ubuntu:~# mosquitto_sub -t "#" -v
notifications130 1
topic/128 i'm 128, msg to 128
```

131正常

```
root@ubuntu:~# mosquitto_sub -t "#" -v
notifications131 1
topic/128 i'm 128, msg to 128
```

#### 设置密码 remote_username 和 remote_password

在128中mosquitto.conf中配置129的账号密码。

```shell
# vi /etc/mosquitto/mosquitto.conf

...

connection bridge129
address 192.168.193.129:1883
cleansession true
topic topic/# both 0
notifications true
notification_topic notifications129
# 配置用户名密码
remote_username lxy129
remote_password lxy129

...

```

重新启动128的mosquitto服务。

再次测试，128发送消息

```shell
root@ubuntu:~# mosquitto_pub -t "topic/128" -m "i'm 128, msg to 128" -u lxy128 -P lxy128
```

128监听，这里也可以看到notifications129 1， 说明129连接正常

```shell
root@ubuntu:/etc/mosquitto# mosquitto_sub -t "#" -v -u lxy128 -P lxy128
notifications129 1
notifications130 1
notifications131 1
topic/128 i'm 128, msg to 128
```

129监听， 128配置中设置了账号密码之后就可以正常收到消息了。

```shell
root@ubuntu:~# mosquitto_sub -t "#" -v -u lxy129 -P lxy129
notifications129 1
topic/128 i'm 128, msg to 128
```

