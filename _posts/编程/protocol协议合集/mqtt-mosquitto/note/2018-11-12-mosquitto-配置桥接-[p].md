---
layout: post
permalink: /:year/bf6b45256d9d48c3a0ae55e318d077f4
title: 2018-11-12-mosquitto-配置桥接
categories: [编程,mosquitto系列]
tags: [c&c++,mqtt,mosquitto]
excerpt:  mosquitto,配置桥接
description: mosquitto,配置桥接
gitalk-id: bf6b45256d9d48c3a0ae55e318d077f4
toc: true
---

# mosquitto

## 桥接

可以[参考博客](https://blog.csdn.net/hui6075/article/details/79092318)


桥接配置（无法使用 kill -s SIGHUP 重载配置）


### 配置文件中关于桥接的配置项

#### 基本配置

##### address 地址

```

address address[:port] [address[:port]]
指定桥接地址，如果没有指定端口，默认1883

如果是ipv6地址，那么该端口是不可选的

```

##### cleansession [true | false]

默认false。

为桥接设置cleansession选项。设置为false(默认值)，意味着远程代理上的所有订阅都被保留，以防网络连接中断。

如果设置为true，那么如果连接中断，远程代理上的所有订阅和消息将被清除。注意，设置为true可能会导致每次桥接重新连接时发送大量保留的消息。

如果您使用的桥将cleansession设置为false(默认值)，那么如果您更改订阅的主题，可能会从传入的主题中获得意想不到的行为。这是因为远程代理保留旧主题的订阅。如果你有这个问题，设置该桥接的cleansession为true，然后再连接cleansession 设置为假。

##### connection name
 
为远程的borker起个名字



##### remote_clientid  

远程客户端ID


##### remote_username

远程broker用户名


##### remote_password

远程borker密码


##### notifications [true|false]

如果设置为true，则向本地和远程代理发布通知消息，提供有关桥接状态的信息。保留的消息被发布到主题$SYS/broker/connection/<remote_clientid>/state，除非另设置为notification_topics。如果消息是1，则连接是活动的，如果连接失败，则为0。默认值为true。

可以用来查看该桥接是否可用

##### notifications_local_only [true | false]

如果设置为true，则只向本地代理发布通知消息，提供有关桥接状态的信息。默认值为false。

##### notification_topic topic

给通知消息设置一个话题，如果没有设置，那么通知消息将会发送到 $SYS/broker/connection/<remote_clientid>/state.


##### topic pattern [[[out | in bot] qos-level] local-prefix remote-prefix]

out 出方向

in 入方向

qos-level 质量

local-prefix 

remote-prefix

##### try_private [true | false]

默认true，桥接会告诉远程broker这不是一个普通的客户端（是一个broker），如果成功了，那么将会提高 桥接环检测的效率 并且 消息也会更正确的被传播。

不是所有的支持该特性，所以如果你的桥接无法正常连接，可能需要设置try_private为false，

#### 其他

##### bridge_attemp_unsubsribe [ true| false ]

如果桥接有out（出）方向的topic（话题），默认的行为就是发送一个unsubscribe request（取消订阅）请求给远程的borker（代理）。这意味着将一个话题的方向从 in 改成 out 将不会收到后续的消息。 发送这些取消订阅的请求不总是期望的。 

设置birdge_attempt_unsubsribe 为false将会取消发送 unsubsribe 请求，默认为true。


##### bridge_protocol_version verison

MQTT协议，可以是 mqttv31或者mqttv311，默认mqttv31




##### keepalive_interval seconds  保活

多久时间发送一次ping ，默认60秒，最小5秒



##### local_clientid id

本地borker id

##### local_username

连接时需要的用户名

在Mosquitto中，我没有看到local_username和local_password配置项，这两个应该是访问本地的话题 需要的账号密码，但是现在看情况，桥接中好像是不用账号密码就可以直接访问本地的话题的（访问远程是需要的）

##### local_password

连接时需要的密码


##### round_robin [true|false]

是否循环，如果address配置了多个地址


默认false，那么第一个address被认为主 桥连接，如果与第一个address连接失败，那么会尝试和第二个addres进行连接知道成功为止。如果连上了第二个，也会周期性的尝试连接第一个address知道成功为止。

如果round_robin为true，那么所有的address都会被同等对待，如果一个地址失败了，那么下个地址将会被尝试连接，并且如果连接上了，会一直持续到该连接失败为止


#### 桥接启动相关

##### start_type [automatic | lazy | once]


桥接启动模式，有三个选项，automatic,lazy,once，

automatic是默认选项，桥接将会和borker一起启动，并且如果连接失败，那么它会在一段时间后（30秒）重启

lazy，只有当排队的消息超过 threshold选项，将会自动启动，当经过 idle_timeout后自动停止。  

once， 启动broker时启动一次，如果启动失败也不会在再次启动

##### restart_timeout value

当设置为 automatic start类型，设置多长时间尝试重新连接，默认30秒

##### idle_timeout seconds 

和桥接使用lazy start有关，经过多长时间的空闲就停止， 默认60秒，

##### threshold count

配合start_type的lazy选项， 默认10条消息后启动






#### 关于桥接安全部分-SSL

##### bridge_insecure [true | false]

只在测试环境开启，生产环境不能开启，不安全~


##### bridge_tls_version 


##### bridge_cafile 

##### bridge_capath 

##### bridge_certfile


##### bridge_identity

PSK

##### bridge_keyfile

##### bridge_psk



### 桥接测试

#### 配置

如图让128主机作为桥接中心

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/mosquitto.png)


在128主机上配置mosquitto.conf

```
vim /etc/mosquitto/mosquitto.conf
```

增加如下三个配置，分别是129，130，131的主机

* connection指定名字
* address指定了ip地址和端口号
* topic ： # 所有话题， both 消息方向为双向， 0 QoS

```
connection bridge129
address 192.168.193.129:1883
topic # both 0

connection bridge130
address 192.168.193.130:1883
topic # both 0

connection bridge131
address 192.168.193.131:1883
topic # both 0
```


#### 测试

现在在128和130各发送两条信息

128给自己和129各发送一条

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/05.png)

130给自己和128各发送一条

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/06.png)


各个主机收到消息的情况

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/01.png)

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/02.png)

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/03.png)

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/04.png)




桥接就是这样的


如果把128主机的mosquitto进程kill掉，桥接就停了，这个道理都懂吧？

如果把131主机的mosquitto进程kill掉，桥接仍然正常，这个也懂吧？


#### cleansession

这里有个坑，踩到了，记录一下。


首先128主机的mosquitto的配置如下，监听所有topic

```
connection bridge129
address 192.168.193.129:1883
topic # both 0

connection bridge130
address 192.168.193.130:1883
topic # both 0

connection bridge131
address 192.168.193.131:1883
topic # both 0

```

128，129，130，131订阅所有话题

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/14.png)

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/15.png)

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/16.png)

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/17.png)

128中发送一条到本地

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/11.png)

130发送一条到本地，一条到128

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/12.png)

131中发送一条到本地

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/13.png)


现在一切正常~


现在我在128中，不想要订阅所有话题了，我只想要订阅 topic/# ，即topic下的所有话题

改成如下配置

```
connection bridge129
address 192.168.193.129:1883
topic topic/# both 0

connection bridge130
address 192.168.193.130:1883
topic topic/# both 0

connection bridge131
address 192.168.193.131:1883
topic topic/# both 0
```

注意，修改完128的配置文件后，我只重启了128的mosquitto，129，130，131没有重启


在 128主机上发送两条信息，一条给 topic/128，一条给private/128

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/21.png)

在130主机上也和128主机上一样， 发送两条， 一条给 topic/130，一条给private/130
![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/22.png)

在131上发送一条给 private/131
![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/23.png)


结果如图

128主机收到了所有消息

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/24.png)

129正常，因为我们期望就是只会收到话题 topic/# 的消息
![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/25.png)

130正常，因为private/130就是发送到本地的
![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/27.png)

131也是正常的

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/26.png)



可以发现发送  topic/128， topic/131，4台主机都能收到，这是我们预期的结果


在130中发送到主题 private/130，主机130收到（正常），为什么主机128也收到了？

在131中发送到主题 private/131 ，主机131收到（正常），为什么主机128也收到了？


根据我的理解，自己画了个图

![图](http://image.linxingyang.net/image/note/2018-11-09-mosquitto/mosquitto2.png)


有两个解决方法，

解决方法一：重启每个Mosquitto代理，可行，但太麻烦了。。。


解决方法二：这个就是和cleansession这个配置项有关了。 


这里踩了一个坑，
（

修改129主机mosquitto配置文件，设置cleansession=true。然后重启，没有重启其它三台主机。但是还是不行，疑问：为什么我设置了128的mosquitto.conf的cleansession=true，还会出现这种问题？

然后尝试设置130主机的cleansession true，但是因为130没有设置桥接，单独设置cleansession是不行的，启动失败

）

后来发现，原来cleansession不是单独设置的，是需要和桥接一起配置，如下配置3个cleansession才行（之前我就配置了一个cleansession）

```

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

```

这样设置完，就可以了，重启128就可以了。 这里就不截图了

但是要注意cleansession的使用场景咯，如果你的应用对消息的质量QoS要求比较高，要求数据保证发送，需要保持session（网络原因暂时断开连接，立刻再连上），那就不能轻易cleansession掉。（详见mqtt协议 cleansession介绍）



后面包括 notifications notification_topic 这些配置项都是每个 connection配置对应配置一个才行




#### 多个桥接中心点


128开启了桥接，尝试把130也配置桥接（配置桥接128，129，131），然后发送了一条消息，结果死循环了，屏幕无限刷消息。


```
128 -> 130
130 -> 128
128 -> 130
....无限循环~

```

如果要配置多个桥接中心点，感觉也是可以的，就是要控制好 in out 方向，数据单向流动就没问题。后面桥接SSL中有说到 这个原因


#### 登录密码测试

##### 登录需要密码测试

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


##### 桥接设置密码 remote_username 和 remote_password


128还是作为桥接中心，

128的mosquitto.config

```

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

```

128的登录账号密码

```

mosquitto_passwd -b /etc/mosquitto/pwfile.conf lxy128 lxy128

```



129也设置了密码

129的mosquitto.config

```

# 关闭匿名模式
allow_anonymous false
# 指定密码文件
password_file /etc/mosquitto/pwfile.conf

```

129的登录账号密码

```

mosquitto_passwd -b /etc/mosquitto/pwfile.conf lxy129 lxy129

```

130和131的配置不变



开始测试，每个主机都启动mosquitto_sub监听。 在128主机中发送两条消息  

```

mosquitto_pub -t "topic/128" -m "i'm 128, msg to 128" -u lxy128 -P lxy128
mosquitto_pub -t "topic/128" -m "i'm 128, msg to 128" -u lxy128 -P lxy128

```

结果如下：

128。能收到消息。 同时可以看到，对于notifications，130，131都是1，只有129是0，说明129没连上，多个notifications129 0 说明有重复去连接129主机，

为什么连不上129，原因也很简单，因为在128的桥接配置中没有配置129的账号密码

```

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

在128中mosquitto.conf中配置129的账号密码

```

connection bridge129
address 192.168.193.129:1883
cleansession true
topic topic/# both 0
notifications true
notification_topic notifications129
# 配置密码
remote_username lxy129
remote_password lxy129

```


再次测试


128发送消息

```

root@ubuntu:~# mosquitto_pub -t "topic/128" -m "i'm 128, msg to 128" -u lxy128 -P lxy128

```

128监听。这里也可以看到notifications129 1， 说明129连接正常

```

root@ubuntu:/etc/mosquitto# mosquitto_sub -t "#" -v -u lxy128 -P lxy128
notifications129 1
notifications130 1
notifications131 1
topic/128 i'm 128, msg to 128

```

129监听。 设置了账号密码之后就可以了。

```

root@ubuntu:~# mosquitto_sub -t "#" -v -u lxy129 -P lxy129
notifications129 1
topic/128 i'm 128, msg to 128

```





















