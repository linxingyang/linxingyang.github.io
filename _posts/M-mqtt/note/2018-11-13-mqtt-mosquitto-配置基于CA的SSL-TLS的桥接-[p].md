---
layout: post
permalink: /:year/6efdf2685be94f6b9c4fce8d52233bab/index
title: 2018-11-13-mqtt-mosquitto-配置基于CA的SSL-TLS的桥接
categories: [mqtt]
tags: [c,c++,mqtt,mosquitto,mosquitto系列]
relative-tags: [mosquitto系列]
excerpt:  mosquitto,CA,桥接,SSL-TLS
description: -mosquitto-配置基于CA的SSL-TLS的桥接
catalog: true
author: 林兴洋
---

# mosquitto

还是4台机器，128，129，130，131。128是桥接中心，这次准备把129设置为需要证书才能连接的。


## 生成证书

129主机，生成CA证书相关文件，和前一篇一样，略（当年做作业最讨厌看到略了，今天写略有点爽怎么回事）。

启动129主机的mosquitto，也和前面一篇一样，略。


## 配置


我用winscp连接128和129，然后把129的ca证书，放到128的 `/etc/mosquitto/ca/ca129/`中

128桥接配置

```shell
# vi /etc/mosquitto/mosquitto.conf

...

#connection bridge129
#address 192.168.193.129:1883
#cleansession true
#topic # both 0
#notifications true
#notification_topic notifications129
#remote_username lxy129
#remote_password lxy129

# 129安全接口配置
connection bridge129SSL
address 192.168.193.129:8883
cleansession true
topic # both 0
notifications true
notification_topic notifications129SSL
remote_username lxy129
remote_password lxy129
bridge_cafile /etc/mosquitto/ca/ca129/ca.crt
bridge_keyfile /etc/mosquitto/ca/ca129/client.key
bridge_certfile /etc/mosquitto/ca/ca129/client.crt
bridge_tls_version tlsv1

# 130
connection bridge130
address 192.168.193.130:1883
cleansession true
topic # both 0
notifications true
notification_topic notifications130

# 131
connection bridge131
address 192.168.193.131:1883
cleansession true
topic # both 0
notifications true
notification_topic notifications131

...
```




## 启动

此时启动128的mosquitto，会要求输入两个 PEM pass。


```shell
root@ubuntu:/etc/mosquitto/ca# mosquitto -c /etc/mosquitto/mosquitto.conf
Enter PEM pass phrase:  # 因为128主机也是有配置证书访问的，输入128服务端的密码
Enter PEM pass phrase:  # 这个就是访问129客户端的证书密码
```



在129发送消息（这一长串真是累死个人）。

```shell
root@ubuntu:~# mosquitto_pub -h 192.168.193.129 -p 8883 -t "ssl/topic/129" --tls-version tlsv1 --cafile /etc/mosquitto/ca/ca.crt --cert /etc/mosquitto/ca/client.crt --key /etc/mosquitto/ca/client.key -m "i'm 129, msg to 129, port 8883" -u lxy129 -P lxy129
Enter PEM pass phrase:
root@ubuntu:~# 
```

128,129,130,131都监听话题 #，都能收到消息。

```sheel
# 128
root@ubuntu:/etc/mosquitto/certs# mosquitto_sub -t "#" -u lxy128 -P lxy128 -v
ssl/topic/129 i'm 129, msg to 129, port 8883

# 129
root@ubuntu:~# mosquitto_sub -t "#" -u lxy129 -P lxy129 -v
ssl/topic/129 i'm 129, msg to 129, port 8883

# 130
root@ubuntu:~# mosquitto_sub -t "#" -v
ssl/topic/129 i'm 129, msg to 129, port 8883

# 131
root@ubuntu:~# mosquitto_sub -t "#" -v
ssl/topic/129 i'm 129, msg to 129, port 8883
```



129发布的消息，发布到128（桥接中心）是通过SSL传输的，报文截下来是加密的，但是128发送到130和131都是明文发送。   

这点根据配置文件也可以看出来，对于130和131都是“裸奔”的消息。


```vi
# vi /etc/mosquitto/mosquitto.conf

...

# 129安全接口配置
connection bridge129SSL
address 192.168.193.129:8883
cleansession true
topic # both 0
notifications true
notification_topic notifications129SSL
remote_username lxy129
remote_password lxy129
bridge_cafile /etc/mosquitto/ca/ca129/ca.crt
bridge_keyfile /etc/mosquitto/ca/ca129/client.key
bridge_certfile /etc/mosquitto/ca/ca129/client.crt
bridge_tls_version tlsv1

# 130
connection bridge130
address 192.168.193.130:1883
cleansession true
topic # both 0
notifications true
notification_topic notifications130

# 131
connection bridge131
address 192.168.193.131:1883
cleansession true
topic # both 0
notifications true
notification_topic notifications131

...
```



## 消息死循环

另外，如果把下面这个bridge129的注释放开。即和129主机桥接了两个端口1883和8883，那么就会出现消息的无限发送，128，129，130，131的订阅都被消息无限刷屏


```vim
# vi /etc/mosquitto/mosquitto.conf

...

# 129 1883端口
connection bridge129
address 192.168.193.129:1883
cleansession true
topic # both 0
notifications true
notification_topic notifications129
remote_username lxy129
remote_password lxy129

# 129安全接口配置
connection bridge129SSL
address 192.168.193.129:8883
cleansession true
topic # both 0
notifications true
notification_topic notifications129SSL
remote_username lxy129
remote_password lxy129
bridge_cafile /etc/mosquitto/ca/ca129/ca.crt
bridge_keyfile /etc/mosquitto/ca/ca129/client.key
bridge_certfile /etc/mosquitto/ca/ca129/client.crt
bridge_tls_version tlsv1

...
```



我自己的推断与测试，当我只配置一个的时候，如下是开放1883端口，注释8883端口，注册的情况是这样的：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/42.png)

当我发送消息的时候，是这样的：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/43.png)

截取的报文也是符合这样的。

129发送一份给本地订阅者，然后发送一份给桥接中心（可以认为也是一个订阅者）。 

然后128作为桥接中心，向130，131这两个订阅者发送该消息

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/44.png)




当把两个注释都放开，就是和129主机的1883和8883端口都配置了桥接，那么现在注册的情况如下

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/45.png)

那么现在，情况是这样的:


由于128和129之间配置了两个桥接，分别是1883和8883端口，那么mosquitto把它们认为是两个不同的订阅，而1883和8883端口订阅的话题都是 # ，就是订阅所有话题


当我在129上发送一个消息给1883端口。

```
mosquitto_pub -t "topic/nossl/129" -m "xxxx"
```

此消息第一步如红色所示，会发送给本地的一个sub和128主机。
当128主机收到该消息时，它会向所有订阅该主题的订阅者发送该消息。
所以，130和131是能够收到消息的，但同时因为8883端口也是订阅所有话题的，（mosquitto知道给它发送消息的是1883端口，并且不会再向1883端口发送这个消息，这个我们从前面只配置1883端口的时候截取的报文也可以知道），但它会向8883端口发送该消息， 如下绿色那条msg。


![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/46.png)



接下来连锁反应就来了，129作为订阅者（128和129互为订阅者，因为配置中 topic # both 0），收到那个绿色的msg之后，它会向符合该消息和话题订阅者发送绿色的msg。

注意，此时129发送该绿色msg（我把颜色改成了蓝色，和原来发送红色消息路径一样）， 最后128又会有一条msg（紫色表示）发送给129。


![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/47.png)

然后就死循环了（欢乐吧~），解决方法：

* 1、对一台主机只配置一个桥接，这样妥妥的没问题。

* 2、小心合理配置要订阅的topic，如果订阅的话题不是 #， 对一台主机的两个桥接配置，不要让订阅的topic有交集（这样就等于堵死从128->129的8883端口的那条绿色的消息）


```shell
# vi /etc/mosquitto/mosquitto.conf

...

connection bridge129
address 192.168.193.129:1883
cleansession true
# 订阅 topic/nossl/#
topic topic/nossl/# both 0
notifications true
notification_topic notifications129
remote_username lxy129
remote_password lxy129


connection bridge129SSL
address 192.168.193.129:8883
cleansession true
# 订阅 topic/ssl/#
topic topic/ssl/# both 0
notifications false
notification_topic notifications129SSL
remote_username lxy129
remote_password lxy129
bridge_cafile /etc/mosquitto/ca/ca129/ca.crt
bridge_keyfile /etc/mosquitto/ca/ca129/client.key
bridge_certfile /etc/mosquitto/ca/ca129/client.crt
bridge_tls_version tlsv1

...
```




* 3、和解决方法二类似的道理，我们可以控制订阅的方向，同时订阅in，或者同时订阅out。这样数据只会从128->129或者只会从129->128，就不会出现循环消息。

```shell
# vi /etc/mosquitto/mosquitto.conf

...
connection bridge129
address 192.168.193.129:1883
cleansession true
# 订阅in
topic # in 0
notifications true
notification_topic notifications129
remote_username lxy129
remote_password lxy129


connection bridge129SSL
address 192.168.193.129:8883
cleansession true
# 订阅in
topic # in 0
notifications false
notification_topic notifications129SSL
remote_username lxy129
remote_password lxy129
bridge_cafile /etc/mosquitto/ca/ca129/ca.crt
bridge_keyfile /etc/mosquitto/ca/ca129/client.key
bridge_certfile /etc/mosquitto/ca/ca129/client.crt
bridge_tls_version tlsv1

...
```






## 消息死循环的另一种情况

还有另一种情况，就是配置了多个桥接中心，之前我还特别好奇的配置了两个桥接中心，结果也是消息死循环。

这是一幅草稿图。。。。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/49.png)

128中的桥接配置

```
address 192.168.139.129:1883
topic # both 0

address 192.168.139.130:1883
topic # both 0
```


129中的桥接配置

```
address 192.168.139.128:1883
topic # both 0

address 192.168.139.130:1883
topic # both 0
```


和前面出现的问题都是同一个原因

128发送一条消息msg，会发送到129和130


当129收到来自128的，又会将该消息发送给128和130


然后也出现了死循环


![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/48.png)

解决方法也是类似前面的咯。



