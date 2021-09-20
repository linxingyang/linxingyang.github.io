---
layout: post
permalink: /:year/linxingyangwriteat20210919114242/index
title: 2018-11-09-mqtt-mosquitto系列05之mosquitto-pub发布
categories: [mqtt]
tags: [post, mqtt, mosquitto, mosquitto系列]
date: 2018-11-09 11:42:42 +8
editdate: 2021-09-19 11:42:42 +8
eidtplace: 福州软件园
excerpt: mosquitto,mosquitto_pub,mosquitto_sub
description: mqtt-mosquitto系列05之mosquitto-pub发布
catalog: true
author: 林兴洋
---

# mosquitto

## mosquitto_pub 发布

### 例子

和订阅差不多，就是发布要带一条消息。

```
# 本机可不指定host和port
mosquitto_pub -t "topic" -m "message"

# 指定本机host和port
mosquitto_pub -t "topic" -m "message" -h 127.0.0.1 -p 1883

# 需要用户名密码，注意密码的P是大写，因为小写的p已经被port使用了
mosquitto_pub -t "topic" -m "message" -u myUsername -P myPassword

# 单向证书认证，指定insecure用于不验证服务端的证书中的域名和当前访问服务端的域名相同。
mosquitto_pub -t "topic" -m "message" --cafile /path/to/ca.crt --insecure

# 双向证书认证
mosquitto_pub -t "topic" -m "message" --cafile /path/to/ca.crt --cert /path/to/client.crt --key /path/to/client.key --insecure 

# 带遗嘱
 mosquitto_pub -t "topic" -m "message" --will-topic "topic/leaving/" --will-payload "i'm leaving now"
```


### 格式 & 参数

#### -h 主机名，默认localhost
#### -p 端口
#### -m 消息
#### -n null message空消息
#### -t topic话题
#### -d 启动debug消息

#### -f 发送文件中的内容作为消息的内容

例：发送 data中的内容到 my/topic话题
```shell
# mosquitto_pub -t my/topic -f ./data
# mosquitto_pub -t my/topic -s < ./data
```

#### -i --id
客户端使用的id，如果没有给定，那么默认是 mosquitto_pub_ 加上 客户端的处理序号id，不能和 -I 一起使用

#### -I --id-prefix
id的前缀，当mosquitto代理中配置了使用 clientid_prefixes选项，那这个配置就有用了。不能和 -i一起使用

#### -k --keepalive
两次发送ping命令之间的时间间隔，默认60秒

#### --key

#### -L URL 

一次性指定一些参数
```
mqtt(s)://[username[:password]@]host[:port]/topic
```

之前做过的连接`test.mosquitto.org`
```shell
# mosquitto_sub -h test.mosquitto.org -t "#"
```
也可以这么写
```shell
# mosquitto_sub -L mqtt://test.mosquitto.org/#
```

#### -l --stdin-line
从stdin中发送消息，空白行不会被发送（但是我测试发现空白行还是被发送了）
```
mosquitto_pub -t "test" -l 
```
这样就可以在控制台中手动输入东西发送到mosquitto。ctrl+d退出

#### -s --stdin-file
从stdin发送消息，所有输入作为单条信息发送. ctrl+d退出

#### -u username 指定用户名

#### -P password 指定密码
如果只指定password而没有指定username，那么也是无效的

#### -q --qos 消息质量的等级，可选有0,1,2  默认0

#### -A 如果想要和指定的网络通信，可以指定一个ip address/hostname

#### --quiet 沉默，

所有运行时错误将不会被打印，但不包括如 using ##### --port 但是没有提供 port这种用户输入错误

#### -r --retain

#### -v --protocol-version
可以是mqttv311或者mqttv31，默认mqttv311

#### SSL/TLS登录

##### --cafile ca证书
##### --capath ca路径
##### --insecure
当使用基于ca证书的验证，这个选项让客户端不验证服务器端证书
建议：仅在测试环境中可以使用这个变量，否则CA验证毫无意义

##### --psk
##### --psk-identity
##### --tls-version tls版本
选择tls的版本，可选项有tlsv1.2,tlsv1.1,tlsv1，默认的是tlsv1.2， 

#### 遗言

##### --will-payload
##### --will-qos
##### --will-retain
##### --will-topic

