---
layout: post
permalink: /:year/bf6b45256d9d48c3a0ae55e318d077f4/index
title: 2018-11-13-mqtt-mosquitto系列09之配置桥接
categories: [mqtt]
tags: [post, mqtt, mosquitto]
date: 2018-11-12 11:44:45 +8
place: 福州软件园
editdate: 2021-09-22 11:44:45 +8
eidtplace: 福州软件园
excerpt: mqtt, mosquitto, 桥接
description: 2018-11-12
catalog: true
author: 林兴洋
---

# mosquitto

## 桥接

### 配置文件

mosquitto.conf中桥接相关配置请参考[2018-11-07-mqtt-mosquitto系列03之配置文件](http://linxingyang.net/2018/be282d30a8dd4b28aa0104a20bf32b3d/#bridges-%E6%A1%A5%E6%8E%A5)

这里贴一份完整的配置，连接了三个broker。

```shell

#================================================

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
remote_clientid bridge2801
remote_password wecon_wecon
remote_username wecon
#restart_timeout 5 30
#round_robin false
#start_type automatic
#threshold 10
#try_private true
#bridge_outgoing_retain true
#bridge_max_packet_size 0

#bridge_cafile
#bridge_capath
#bridge_alpn
#bridge_insecure false
#bridge_certfile
#bridge_keyfile
#bridge_identity
#bridge_psk


#================================================

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
remote_clientid bridge2802
remote_password wecon_wecon
remote_username wecon
#restart_timeout 5 30
#round_robin false
#start_type automatic
#threshold 10
#try_private true
#bridge_outgoing_retain true
#bridge_max_packet_size 0

#bridge_cafile
#bridge_capath
#bridge_alpn
#bridge_insecure false
#bridge_certfile
#bridge_keyfile
#bridge_identity
#bridge_psk


#================================================

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

#bridge_cafile
#bridge_capath
#bridge_alpn
#bridge_insecure false
#bridge_certfile
#bridge_keyfile
#bridge_identity
#bridge_psk

```


### 单个桥接中心

#### 配置

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/mosquitto.png)

如图让128主机作为桥接中心，在128主机上配置mosquitto.conf，增加如下三个配置，分别是129，130，131的主机。

* connection指定名字
* address指定了ip地址和端口号
* topic # 订阅所有话题（注意#在这里可不是注释的意思）， both 消息方向为双向， 0 消息的QoS。

```shell
# vim /etc/mosquitto/mosquitto.conf

...

connection bridge129
address 192.168.193.129:1883
topic # both 0

connection bridge130
address 192.168.193.130:1883
topic # both 0

connection bridge131
address 192.168.193.131:1883
topic # both 0

...
```


#### 测试

现在128（桥接中心）和130各发送两条信息。

1、128给自己和129各发送一条：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/05.png)

2、130给自己和128各发送一条：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/06.png)


各个主机收到消息的情况如下：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/01.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/02.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/03.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/04.png)


可以看到所有主机都收到消息了，桥接就是这样的，大家互通有无。特别注意：
* 如果把128主机的mosquitto进程kill掉，桥接就停了，因为它是桥接中心。
* 如果把131主机的mosquitto进程kill掉，桥接仍然正常，因为它不是桥接中心。
* mosquitto桥接高度依赖桥接中心，玩集群还需要借助别的东西来实现，本身支持有限。


#### cleansession的两个坑

##### 第一个坑：cleansession的适用场景

由于桥接（把桥接当成一般的客户端来看的话）没有取消订阅主题一说，对于你的使用场景。

* 场景1：每次桥接要订阅的主题都是变化的。这个时候需要设置cleansession=true，否则下次连上来的时候由于上次断开没有取消订阅，将会得到上次订阅的消息。
* 场景2：每次桥接要订阅的主题都是固定的。可以无需设置cleansession=true，即使重复订阅也无伤大雅。

---

做默认cleansession（默认false）的测试：

首先128主机的mosquitto的配置如下，监听所有topic：
```shell
# vim /etc/mosquitto/mosquitto.conf

...

connection bridge129
address 192.168.193.129:1883
topic # both 0

connection bridge130
address 192.168.193.130:1883
topic # both 0

connection bridge131
address 192.168.193.131:1883
topic # both 0

...
```

128，129，130，131订阅所有话题

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/14.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/15.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/16.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/17.png)

128中发送一条到本地：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/11.png)

130发送一条到本地，一条到128：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/12.png)

131中发送一条到本地：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/13.png)

一切正常

现在我在128中不想要订阅所有话题了，我只想要订阅 `topic/#` ，即topic下的所有话题，改成如下配置：

```shell
# vim /etc/mosquitto/mosquitto.conf

...

connection bridge129
address 192.168.193.129:1883
#topic # both 0
topic topic/# both 0

connection bridge130
address 192.168.193.130:1883
#topic # both 0
topic topic/# both 0

connection bridge131
address 192.168.193.131:1883
#topic # both 0
topic topic/# both 0

...
```

注意，修改完128的配置文件后，我只重启了128的mosquitto。129，130，131没有重启。

在128主机上发送两条信息，一条给 topic/128，一条给private/128：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/21.png)

在130主机上发送两条， 一条给 topic/130，一条给private/130：
![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/22.png)

在131上发送一条给 private/131：
![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/23.png)


结果如下图：128主机收到了所有消息，不对劲：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/24.png)

129正常，因为我们期望就是只会收到话题 topic/# 的消息：
![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/25.png)

130正常，因为private/130就是发送到本地的：
![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/27.png)

131也是正常的：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/26.png)



可以发现发送  topic/128， topic/131，4台主机都能收到，这是我们预期的结果

在130中发送到主题 private/130，主机130收到（正常），为什么主机128也收到了？

在131中发送到主题 private/131 ，主机131收到（正常），为什么主机128也收到了？


根据我的理解画了个图：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/mosquitto2.png)


有两个解决方法：
* 1、重启每个mosquitto代理，可行，但你不觉得这样太麻烦了吗？（差点忘了你可以写个脚本来一键重启。）
* 2、就和cleansession这个配置项有关了，设置cleansession=true即可。


##### 第二个坑：每个桥接都需要配置自己的cleansession

修改129主机mosquitto配置文件，设置cleansession=true。然后重启，没有重启其它三台主机。但是还是不行，疑问：为什么我设置了128的mosquitto.conf的cleansession=true，还会出现这种问题？然后尝试设置130主机的cleansession true，但是因为130没有设置桥接，单独设置cleansession是不行的，启动失败。

原来cleansession不是单独设置的，是需要和桥接一起配置，如下配置3个cleansession才行（之前我就配置了一个cleansession）Orz。。。

```shell
# vim /etc/mosquitto/mosquitto.conf

...

connection bridge129
address 192.168.193.129:1883
cleansession true
topic topic/# both 0

connection bridge130
address 192.168.193.130:1883
cleansession true
topic topic/# both 0

connection bridge131
address 192.168.193.131:1883
cleansession true
topic topic/# both 0

...

```

这样设置完，重启128就可以了，就不截图了。

但是要注意cleansession的使用场景，如果你的应用对消息的质量QoS要求比较高，要求数据保证发送，需要保持session（网络原因暂时断开连接，立刻再连上），那就不能轻易cleansession掉。详见mqtt协议 cleansession介绍。**对了，后面包括 notifications notification_topic 这些配置项都是每个 connection配置对应配置一个才行。**


### 多个桥接中心尝试

128开启了桥接，尝试把130也配置桥接（配置桥接128，129，131），然后发送了一条消息，结果死循环了，屏幕无限刷消息。

```
128 -> 130
130 -> 128
128 -> 130
...
无限循环~
...
```

如果要配置多个桥接中心点，也是可以的，就是要控制好消息 in out 方向，数据单向流动就没问题。

### 使用桥接中心的两个问题

1、桥接中心崩溃则桥接失效。一种方法是启动一个监控程序监控着桥接中心，一旦桥接中心崩了，就重启桥接中心。

2、**无法使用 kill -s SIGHUP 重载配置，需要重启mosquitto以重新加载桥接配置 **，所以每次修改mosquitto桥接中心桥接相关配置时，需要重启服务。那是相当的麻烦。

> Bridges cannot currently be reloaded on reload signal.  [mosquitto config](https://mosquitto.org/man/mosquitto-conf-5.html#idm885) 



## 参考

* [参考](https://blog.csdn.net/hui6075/article/details/79092318)
