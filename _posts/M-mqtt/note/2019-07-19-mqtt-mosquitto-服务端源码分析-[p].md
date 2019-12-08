---
layout: post
permalink: /:year/bc5a8c01c1664643be595e8c828c3bd8
title: 2019-07-19-mqtt-mosquitto-服务端源码分析
categories: [mqtt]
tags: [c,c++,mqtt,mosquitto,mosquitto系列]
relative-tags: [mosquitto系列]
excerpt: mosquitto-服务端源码分析
description: mosquitto-服务端源码分析
catalog: true
author: 林兴洋
---

* content
{:toc}

最近看了一下mosquitt源码，整体感觉就是有很多过长的代码块不利于维护阅读吧。而且代码有点乱，src目录中的代码调用lib目录中的代码，lib中代码反过来也有调用到src目录中的代码。


从外面看，MQTT代理/服务端(broker)既可以和普通的客户端通信，也可以和其它MQTT代理通信。

![MQTT订阅发布模式](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/01.png)



从消息上来看

![MQTT交互简图](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/02.png)



内部主流程的简略类图。主要三条线，第一条处理链接，第二条处理各种收到的消息，第三条处理发送消息。

![简单类图](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/34.png)



下面就是详细流程的过程。

# 1 main()主流程

![简单主流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/05.png)

- 1，main()使用命令 mosquiitto -c /etc/mosquiito/mosquitto.conf 启动mosquitto服务。
- 2，config\_\_init() 初始化配置config（struct mosquitto_config<sup>注1</sup>）。
- 3，config\_\_parse_args() 从配置文件中读取配置并检查配置

-c配置文件， -d后台运行等参数也是在这个地方解析的

```
mosquitto -c /etc/mosquiito/mosquitto.conf -d
```

其中有个config\_\_read_file_core()方法，有1425行，里面是解析配置文件/etc/mosquitto/mosquitto.conf中的每一项，并将配置保存在struct mosquitto中。

* 4，db_open()，对db（struct mosquitto_db<sup>注3</sup>）进行初始化，在这里面添加了$SYS主题等操作。

```
// 添加一个空主题，作为普通订阅的父节点
subhier = sub__add_hier_entry(NULL, &db->subs, "", strlen(""));
// 添加$SYS主题，作为系统订阅的父节点
subhier = sub__add_hier_entry(NULL, &db->subs, "$SYS", strlen("$SYS"));
```

* 5，net\_\_socket_listen() 绑定端口监听。

这就是跟我们在配置文件中配置的多少个listener有关，默认的是监听1883(Default Listener)。同时，监听1883可能有IPV4和IPV6，所以虽然只监听了1883，但是有两个socks，一个是监听1883的IPV4,一个是IPV6。


在mosquitto_main_loop()之前还有做了其他一些事情，比如绑定signal信号等等。

```
signal(SIGINT, handle_sigint);
signal(SIGTERM, handle_sigint);
signal(SIGHUP, handle_sighup);
signal(SIGUSR1, handle_sigusr1);
signal(SIGUSR2, handle_sigusr2);
```

* 6，mosquitto_main_loop() 这里进入循环。当该函数返回的时候，就表示mosquitto服务器停止了。

该方法返回时，进行一些善后清理操作：客户端遗言处理，客户端下线处理，客户端清理，停止监听端口等等操作。

* 7，context\_\_send_will()处理所有客户端的遗嘱。
* 8，will_delay\_\_send_all() 需要延迟发送的遗嘱处理（延迟遗嘱<sup>注a</sup>）。
* 9，session_expiry\_\_remove_all()将所有客户端移除（会话过期<sup>注b</sup>）。
* 10，db\_\_close()关闭db，清除保留消息db->msg_store，清除订阅树结构db->subs。
* 11，config\_\_cleanup() 清除config。
* 12，net\_\_broker_cleanup()停止监听端口。


## 1.1 mosquitto_main_loop()

![简单主流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/06.png)

主要关注三个方法：db\_\_message_write()发送数据，net\_\_socket_accept()接受新客户端连接， loop\_\_handel_reads_write()处理接收的数据包。

* 1， mosquitto_main_loop()。


使用epoll的话，就绑定epoll回调事件，监听可读事件。然后进入循环，循环标志是run。

```
while(run){
}
```

通过发送SIGINT和SIGTERM给mosquitto对应的进程，就可以优雅的停止mosquitto了。

```
// in src/signals.c
/* Signal handler for SIGINT and SIGTERM - just stop gracefully. */
void handle_sigint(int signal)
{
	UNUSED(signal);

	run = 0;
}
```

```
kill -s SIGTERM [mosquitto PID]
kill -s SIGINT  [mosquitto PID]
```

* 2，db__message_write()。

遍历每一个已连接的客户端，检查是否有数据需要处理（发送待发送的数据，回复已接收待回复的数据），在其中调用了db__message_write()进行处理，该方法另外介绍。

```
HASH_ITER(hh_sock, db->contexts_by_sock, context, ctxt_tmp){
  db__message_write(db, context)
}
```

* 3，epoll_wait()阻塞100ms，此处举例的是epoll_wait，也有可能是其它的阻塞等待，如在不支持epoll的情况下使用poll等。

```
fdcount = epoll_wait(db->epollfd, events, MAX_EVENTS, 100);
```

* 4&5，net__socket_accept(), loop_handle_reads_writes()阻塞之后，遍历所有的监听端口句柄，当端口有新数据到来时，有两种情况：1，新连接到来，2，已有连接的数据到来。

```
for(i=0; i<fdcount; i++){
  for(j=0; j<listensock_count; j++){
  	// 新连接到来
  	net__socket_accept(db, listensock[j])
  }
  // 已有连接的数据到来
  loop_handle_reads_writes(db, events[i].data.fd, events[i].events);
}
```

对于新连接来到，在net\_\_socket_accept()对该新连接赋予一个新句柄，并调用context__init()为其创建初始化一个客户端上下文context（struct mosquitto<sup>注4</sup>）。

对于已有连接的数据到来，net__socket_accept()就是处理客户端发送来的事件，比如connect，publish，disconnected等等。 另外介绍。

接下来就是做一些其它事。

* 6， session_expiry__check(db, now)会话过期检测。

* 7，will_delay__check(db, now)遗嘱延迟检测。

* 8，config__read()重载配置。

```
/* Signal handler for SIGHUP - flag a config reload. */
void handle_sighup(int signal)
{
	UNUSED(signal);

	flag_reload = true;
}
```

发送SIGHUB来重载配置。

```
kill -s SIGHUP [mosquitto PID]
```

* 9，sub__tree_print()打印订阅树结构。

```
/* Signal handler for SIGUSR2 - print subscription / retained tree. */
void handle_sigusr2(int signal)
{
	UNUSED(signal);

	flag_tree_print = true;
}
```

发送SIGUSR2来打印当前订阅树结构。

```
kill -s SIGUSR2	[mosquitto PID]
```

### 1.1.1 loop_handle_reads_writes()

虽然db\_\_message_write()先于loop_handle_reads_writes()被调用，但是loop_handle_reads_writes()是处理收到的消息，db\_\_message_write()是处理发送的消息，所以先介绍loop_handle_reads_writes()。

![简单主流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/07.png)

* 1，loop_handle_reads_writes()。

* 2，packet\_\_read()调用net\_\_read()读取到来的数据，封装成mqtt消息包(struct mosquitto__packet<sup>注5</sup>)放到当前客户端的上下文context（struct mosquitto）的in_packet中。

* 3，net__read()读取数据。（认为与net_mosq.c中的方法打交道就是直接从端口读或写）。

* 4，handle__packet()处理读入的包，根据struct mosquitto\_\_packet中消息类型的不同，做不同的处理。下面列举了不同的类型(command)的消息。

```
#define CMD_CONNECT 0x10 // 连接
#define CMD_CONNACK 0x20 // 连接确认
#define CMD_PUBLISH 0x30 // 发布消息
#define CMD_PUBACK 0x40 // QoS1的回复
#define CMD_PUBREC 0x50 // QoS2第二步receive
#define CMD_PUBREL 0x60 // QoS2第三步release
#define CMD_PUBCOMP 0x70 // QoS3第四步complete
#define CMD_SUBSCRIBE 0x80 // 订阅
#define CMD_SUBACK 0x90 // 订阅确定
#define CMD_UNSUBSCRIBE 0xA0 // 取消订阅
#define CMD_UNSUBACK 0xB0 // 取消订阅确认
#define CMD_PINGREQ 0xC0 // 心跳ping
#define CMD_PINGRESP 0xD0 // 心跳pong
#define CMD_DISCONNECT 0xE0 // 断开连接
#define CMD_AUTH 0xF0 // 认证
```

下面列举了一些处理对应包的方法。

#### 1.1.1.1 handle__connect() 处理连接

前面mosquitto_main_loop()中的net__socket_accept()那个是接受客户端，创建fd句柄并为其初始化一个context。这里是真正处理连接的一些东西，认证，用户名密码等等。

![主流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/08.png)

* 1，handle__connect()，在这里做多客户端登录处理，协议判断，处理连接协议版本，内容，用户名，密码，遗嘱，生成客户端ID，CA认证等等协议中定义的东西。

* 2&3&4&5，send\_\_connack(), 各种情况下失败（协议格式错误，用户认证失败等等）发送带有特定连接失败码的connack给客户端。到net__write()就是从端口发出去了。

* 6， will__read()如果有遗嘱，那么读取遗嘱并保存在 context->will 中。

* 7，connect\_\_on_authorised()，该客户端是否有访问权限，多客户端处理（将较早的客户端下线），掉线重连处理。

* 8，该客户端是否有访问服务器权限。

* 9，从发送和接收队列中清空当前客户端已不再有访问权限的消息，（重连情况下可能有断线前的消息）。

* 10，设置状态为已连接。

* 11&12&13&14， send\_\_connack()组装conack成功包，发送连接成功。


#### 1.1.1.2 handle__disconnect() 处理断开连接

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/09.png)

* 1, handle__disconnect()。

* 2&3&4&5，send__disconnect()，当协议格式错误（MOSQ_ERR_PROTOCOL）的时候，直接发送断开连接断开。

* 6，do_disconnect()。

* 7，context__disconnect()。

* 8，net__socket_close() 关闭与该客户端的连接，关闭fd句柄。

* 9&10，context__send_will() 遗嘱处理。

如果是异常断开，那么就需要发送遗嘱，把遗嘱入队列。此处由于是正常断开，所以不会把遗嘱消息入队列。

* 11，will__clear()清除遗嘱。

* 12|13，根据session_expiry_interval过期时间是否为0，来确定调用哪个方法。

为0调用context\_\_add_to_disused()，直接弃用。
不为0调用session_expiry__add()，加入会话超时队列，超时结束后弃用。

* 14，设置成已断开disconnected状态。


#### 1.1.1.3 handle__subscribe() 处理订阅

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/30.png)

主要做两件事：1，将订阅加入订阅层次中(mosquitto\_\_subhier<sup>注6</sup> )(db->subs)； 2，将所有订阅同一个主题的客户端放入一个链表中(mosquitto\_\_subleaf<sup>注7</sup>)（db->subs->subs）。

* 1，handle\_\_subscribe()。从in_packet中读取订阅信息。

* 2，mosquitto_acl_check() 这里对订阅的主题进行验证。包括此用户是否有权限订阅此主题，此主题格式是否正确等。

* 3，sub__add() 添加订阅。

* 4，sub\_\_topic_tokenise() 根据 `/` 分割主题放入（struct sub\_\_token<sup>注8</sup>）。

* 5，sub__add_hier_entry()  先查找（HASH_FIND）是否已经存在订阅的第一层。如果不存在就新建并把第一层加入订阅层次中(db->subs)。因为第一层是不一样的，可能是\$SYS系统信息，\$share共享信息，还有其它的普通主题。

* 6，sub__add_context()。

* 7，sub__add_hier_entry()  和处理第一层是一样的，先调用（HASH_FIND）查找是否存在，不存在就创建。在此处再遍历从第二层到末尾的所有层，如果不存在该层就加入(db->subs)。

如果是共享主题<sup>注c</sup>，就调用sub\_\_add_shared()，如果是其它主题，就调sub\_\_add_normal()。我们平常订阅一般都是normal。

* 8，sub__add_shared()。

* 9，sub__add_leaf()。

* 10，sub\_\_add_normal()， 将订阅的主题的mosquitto__subhier保存到当前连接的上下文（context->subs）中。

* 11，sub__add_leaf()，将所有对同一主题进行订阅的客户端保存在同一个链表（db->subs->subs）中。

* 12，sub__topic_tokens_free()，释放第4步分割出来的临时主题

* 13&14&15&16，send_suback()，订阅成功，进行回复


##### 订阅构建

当运行mosquitto服务端之后，在1 main() 主流程中的第4步db_opne()会构建$SYS主题，以及空字符串主题。

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/17.png)


在本例中的第4步，对于\$share,\$sys,订阅主题的处理

假设客户端A订阅普通主题`a/b/c/d`，在这里会被分割成五个部分，分别是

```
 ""  第一部分空字符串是就是1中第4步创建的空字符串主题。
 "a" 
 "b" 
 "c" 
 "d"
```

订阅\$share主题 `$share/groupid/sharemessage1`，分割成如下

```
"$share"
"group1"
"sharemessage1"
```

订阅\$SYS主题 "$SYS/broker/load/bytes/received/15min" 会被分割成如下

```
"$SYS"
"broker" 
"load"
"bytes"
"received"
"15min"
```

发送信号量给mosquitto进程让其打印订阅结构，可以看到如下图

```
kill -s SIGUSR2 [mosquitto PID]
```

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/18.png)


在本例的第7步，遍历创建主题部分。对于订阅主题 `a/b/c/d`来说

```
 ""  这部分已经有了 ""
 "a" 这部分没有，创建之 ""->"a"
 "b" 这部分没有，创建之 ""->"a"->"b"
 "c" 这部分没有，创建之 ""->"a"->"b"->"c"
 "d" 这部分没有，创建之 ""->"a"->"b"->"c"->"d"
```

在本例的第10步中，sub\_\_add_normal()将 "d"，保存到context->subs链表中（clientA保存了d主题的引用）

在本例的第11步中，sub__add_leaf()将该客户端context引用保存到"d"(db->subs->subs)这个部分中 （d主题保存了ClientA客户端的引用）

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/21.png)


#### 1.1.1.4 handle__unsubscribe() 处理取消订阅


![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/11.png)

* 1， handle__unsubscribe()。

* 2，mosquitto_sub_topic_check()检查主题格式。

* 3，sub__remove()。

* 4，sub__topic_tokenise()，和订阅一样，对主题进行分割。

* 5，sub__remove_recurse()对每个分割部分进行处理，如果没有被订阅（该部分没有链接任何主题），那么将会被移除。

* 6|7，和handle\_\_subscribe类似。如果是共享主题就调用sub\_\_remove_shared()如果不是就调用sub\_\_remove_normal()。

* 8，sub__remove_recurse()迭代调用，直到遍历完主题的每一层。

* 9&10&11&12，send__unsuback()发送取消订阅确认。


##### 取消订阅

还是以ClientA订阅了 `a/b/c/d`为例，此时要取消该订阅。

第4步sub\_\_topic_tokenise将主题分成了

```
""
"a"
"b"
"c"
"d"
```

第5步sub__remove_recurse开始遍历这些部分。

第7步（因为是普通主题，所以调用sub__remove_normal），判断当前客户端在不在该主题的链表中(db->subs->subs)，如果在就移除该客户端，并且也将该客户端中保存的(context->subs)的当前主题移除。

情况1：只有ClientA订阅了`a/b/c/d`的情况。

```
"" 该主题中不包含客户端，所以移动到下一个
"a" 该主题中不包含客户端，所以移动到下一个
"b" 该主题中不包含客户端，所以移动到下一个
"c" 该主题中不包含客户端，所以移动到下一个
"d" 该主题中包含客户端，将该客户端在主题d的subs中移除，并且将该客户端中subs保存的主题d移除
```

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/24.png)

由于当前只有一个客户端订阅了`a/b/c/d`然后退出迭代调用的时候。

```
"d" 发现这个主题没有子主题，并且没有订阅的客户端，移除
"c" 发现这个主题没有子主题，并且没有订阅的客户端，移除
"b" 发现这个主题没有子主题，并且没有订阅的客户端，移除
"a" 发现这个主题没有子主题，并且没有订阅的客户端，移除
""  该主题不移除
```

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/28.png)


情况2：ClientA订阅了 `a/b/c/d`，ClientB订阅了 `a/b`。

前面部分处理ClientA的是一样的，但是在删除主题的时候不一样。

```
"d" 发现这个主题没有子主题，也没有订阅的客户端，移除
"c" 发现这个主题没有子主题，也没有订阅的客户端，移除
"b" 发现这个主题没有子主题，但有订阅的客户端，不移除
"a" 发现这个主题有子主题(b)，虽然没有订阅的客户端，不移除
""  该主题不移除
```

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/29.png)

#### 1.1.1.5 handle__publish() 处理发布

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/12.png)

* 1，handle__publish()，一些基本的东西获取，比如qos，retain，dup等等。

如果客户端没有启动使用别名，那跳过2,3。

* 2，alias__add()如果有带主题及其别名，那么添加这个主题别名。

* 3，alias__find()如果只带别名，那么从别名数组中查找该别名，如果没找到就断开连接（MQTT_RC_TOPIC_ALIAS_INVALID）。

* 4，mosquitto_pub_topic_check()，检查主题是否有效，无效的话直接释放该消息不做处理。

* 5，mosquitto_acl_check()，检查该客户端是否可以访问该主题。

* 6，db\_\_message_store_find() 调用db\_\_message_store_find()查找是否已经保存过当前消息。如果没有找到就调用db\_\_message_store()保存，如果已经保存过，就释放当前消息，取得保存的消息进行下一步。

* 7&8，db\_\_message_store() 保存该消息，用来判断消息是否是重复，db\_\_msg_store_add()将消息进行保存，如果是保留信息，就不会删除，同时如果之前已经有保留消息，那么那条保留消息会被删除。如果不是保留消息，有两种情况，一种是有客户端订阅该主题，那么将会在发送完所有订阅的客户端之后将该消息删除，另一种是没有客户端订阅该主题，那么将在第21步删除该消息。

如果QOS大于0，那么可能正处于发送队列中，qos1的话可能处于puback，qos2的话可能处于pubrec,pubrel,pubcomp； 也可能处于等待队列中。用来判断消息是否重复。

9~21 QoS0消息的处理

* 9，sub__messages_queue(mosq_md_out)，注意这里传入的是mosq_md_out，所以该消息最后会被存在  context->msgs_out中。

* 10，sub__topic_tokenise()分割主题。

* 11，db__msg_store_ref_inc()。

* 12&13&14&15，如果是保留消息要保证订阅主题是存在的，调用sub\_\_add_context() 构建订阅树。构建过程和订阅过程构建是一样的。

* 16&17&18， 通过sub__search()**迭代**分割后的主题。找到符合订阅该主题的客户端，对其调用subs_process()（后面用例子来解释遍历过程）。

* 19，db\_\_message_insert() 根据当前的情况，该消息进入context->msgs_out->queued队列或者进入context->msgs_out->inflight发送中队列。例如根据context->msgs_out->inflight消息数量的最大值（inflight_maximum）等等进行判断该放入哪个队列中。自此，该消息副本已经放到所有符合订阅该主题的客户端的当前发送/待发送消息队列中。

context->msgs_out->queued是等待队列，context->msgs_out->inflight是当前发送队列。每次当从inflight队列中发送一条数据之后，都会从queued队列中移动一条数据的inflight队列中。

* 20，sub__topic_tokens_free()释放切割后的主题。

* 21，db__msg_store_ref_dec()减少引用，并且删除该消息。

22~27 QoS1消息的处理。

* 22，sub__messages_queue()和QoS0处理一样。

* 23~27，puback() 因为QoS1需要反馈，注意此处响应的是CMD_PUBACK。

28~32 QoS2消息处理。

* 28，QoS0/QoS1调用sub\_\_messages_queue(mosq_md_out)，而QoS2调用db\_\_message_insert(mosq_md_in)。

注意这里有两个不同，第一个调用的方法不同，第二个是将消息放入的队列不同(mosq_md_out表示将消息放入context->msg_out， mosq_md_in表示将消息放入context->msg_in)。

这么做的原因是因为对于QoS0和QoS1来说，收到消息就算收到了，可以将消息直接分发给每个符合订阅条件的客户端。而对于QoS2来说要保证消息必须发送而且只能发送一次，要经历4步，publish->receive->release->complete。当收到publish，需要响应一个receive，等等收到release之后，才能说明是“收到了”该条消息（所以在handle_pubrel里面会调用到sub\_\_messages_queue对消息进行处理）。所以在这里QoS2消息是直接调用db\_\_message_insert()保存消息。而且消息保存在context->msg_in 说明这是待回复的收到的消息，稍后要发送receive。

* 29~33，send__pubrec() 回复receive包


##### 发布消息

有如下订阅发布关系

```
ClientA1 订阅 a/b/c
ClientA2 订阅 a/b/c/d
ClientA3 订阅 a/b/c/x
ClientA4 订阅 a/b/c/d/e

ClientB1 订阅 a/b/+
ClientB2 订阅 a/b/+/d
ClientB3 订阅 a/b/c/+
ClientB4 订阅 a/b/c/+/e
clientB5 订阅 a/b/c/d/+
clientB6 订阅 a/b/c/d/+/f

ClientC1 订阅 a/b/#
ClientC2 订阅 a/b/c/#
ClientC3 订阅 a/b/c/d/#
ClientC4 订阅 a/b/c/d/e/#

ClientD1 发送一条消息到主题 none/exists/topic
ClientD2 发送一条消息到主题 a/b/c/d
```

此时订阅树如下

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/31.png)


ClientD1发送的消息到主题`none/exists/topic`在第10步会被分解成

```
""
"none"
"exists"
"topic"
```

在第16&17&18步迭代遍历的时候，使用分解出来的主题topic（此处就是 ""，"none"，"exists"，"tpioc"），在订阅树db->subs（就是上面那棵树）上去寻找对应的主题，可以简单理解为search(topic->next)，直到topic->next为null。

此处用search-01代表第一层迭代，search-02代表第二层迭代，以此类推

```
search-01 "" 存在
search-02 "none" 不存在
search-02 + 通配符不存在
serach-02 # 通配符不存在
迭代回退
search-01 + 通配符不存在
serach-01 # 通配符不存在
迭代回退
退出
```

至此由于没找到任何可以发送的订阅者，该消息到这里就结束了。

ClientD2发送消息到主题`a/b/c/d`，在第10步会被分解成

```
""
"a"
"b"
"c"
"d"
```

第16&17&18步迭代遍历过程

```
search-01 传入""， 发现订阅树上存在 ""，调用search(topic->next，即a)
  search-02 传入"a" 发现订阅树上存在 "a"，调用search(topic->next，即b)
    search-03 传入"b" 发现订阅树上存在 "b"，调用search(topic->next，即c)
      search-04 传入"c" 发现订阅树上存在 "c"，调用search(topic->next，即d)
        search-05 传入"d" 发现订阅树上存在 "d"，调用search(topic->next，即null)
          search-06 发现主题为null，不继续调用search
          search-06 "+" （a/b/c/d/+）存在，但是+号必须要匹配一层，所以跳过
          search-06 "#" （a/b/c/d/#）存在，#号可以通配任意层，发现ClientC3符合条件
          迭代回退
        search-05 (a/b/c/d)存在，发现ClientA2符合条件
        search-05 "+" (a/b/c/+)存在，发现ClientB3符合条件
        	search-07 (a/b/c/+/e)存在，Client4不符合条件
        	search-07 "+" (a/b/c/+/+)不存在，如果存在也不符合条件
        	search-07 "#" 不存在，如果存在(a/b/c/+/#)，那就符合条件
        	迭代回退
        search-05 "#" (a/b/c/#)存在，发现ClientC2符合条件
        迭代回退
      search-04 (a/b/c) 存在，ClientA1不符合条件
      search-04 "+" (a/b/+)存在，ClientB1不符合条件
        search-08 (a/b/+/d)存在，发现ClientB2符合条件
        search-08 "+" (a/b/+/+)不存在，如果存在就符合条件
        search-08 "#" (a/b/+/#)不存在，如果存在就符合条件
      search-04 "#" (a/b/#)存在，clientC1符合条件
      迭代回退
    search-03 (a/b)不存在
    search-03 "+" (a/+)不存在
    search-03 "#" (a/#)不存在
    迭代回退
  search-02 (a)不存在
  search-02 "+" (+)不存在
  search-02 "#" (#)不存在
  迭代回退
search-01 由于订阅的时候必须带主题，空字符串主题走个过场而已
迭代回退
退出
```

总共有6个客户端会收到消息

```
ClientA2 订阅 a/b/c/d

ClientB2 订阅 a/b/+/d
ClientB3 订阅 a/b/c/+

ClientC1 订阅 a/b/#
ClientC2 订阅 a/b/c/#
ClientC3 订阅 a/b/c/d/#
```

按顺序标号如下：

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/32.png)



#### 1.1.1.6 handle__pubrec() 处理收到receive

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/13.png)

这个是服务端向其它客户端/代理发送(publish)QoS2的消息的时候会收到的回复(receive)，修改消息的状态并发送release包。

* 1，handle__pubrec()。

* 2，db__message_update_outgoing()， 从context->msgs_out.inflight找到该消息，设置其消息状态为mosq_ms_wait_for_pubcomp，等待qos2第四步的complete包。

* 3~7，send__pubrel() 发送release包。


#### 1.1.1.7 handle__pubrel() 处理收到release

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/14.png)

这是其他服务端/客户端向本服务器发送(publish)QoS2消息时，本服务器响应receive之后，对方又发送过来release，在这一步对于QoS2的消息来说，就已经是算是“收到”了该消息，所以可以进行处理了。

* 1，handle__pubrel()。

* 2，db__message_release_incoming()。

* 3，sub\_\_messages_queue()，此刻才说明该条qos2消息“接收”完成，这里做的是和handle\_\_publish里面qos0和qos1调用的sub\_\_messages_queue()是一样的。分割主题，将该消息副本放到每个符合订阅条件的客户端的context->msg_out中。

* 4，db__message_remove()， 从context->msgs_in.inflight中将该条消息移除

* 5，db__message_dequeue_first()，遍历context->msgs_in.queued队列，在确定infight队列未满（因为第4步从context->msgs_in.inflight移除了一条消息）的情况下处理context->msgs_in.queued队列中的第一条消息，发送receive，并将该消息移动到inflight队列中。

* 6~10，回复complete包


#### 1.1.1.8 handle__pubackcomp()处理complete

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/15.png)

服务器发送QoS2 release之后，收到对方回复complete。

* 1，handle__pubackcomp()。

* 2，db__message_delete_outgoing(PUBCOMP)。

* 3，db__message_remove()该消息已经发送完成，进行移除。

* 4，遍历context->msgs_out.inflight找到该发送完成的消息，从该队列中移除，然后从context->msgs_out.queued等待队列中把第一个消息移动到context->msgs_out.inflight进入准备发送状态。


### 1.1.2 db__message_write()

![流程](http://image.linxingyang.net/image/M-mqtt/image/2019-07-19/16.png)

处理发送消息。

* 1， db__message_write() ，服务端发送给客户端的消息是在此处进行处理的。

遍历处理context->msgs_in.inflight， 根据不同情况选择2~4其中一个进行处理。context->msgs_in.inflight中存放的是已接收（QoS2的消息）待回复的数据。

* 2，db__message_remove()，消息超时进行移除。

* 3，send__pubrec()，如果是收到的publish消息，那就回复receive 。

* 4，send__pubcomp()，如果是收到的release消息，那就回复complete。

遍历context->msgs_out.inflight，对需要发送的数据进行处理，也是根据不同情况选择进行处理

* 5，db__message_remove()超时删除。

* 6~11，发送QoS0消息，发送完毕从该客户端发送队列删除该消息。

* 12，发送QoS1消息。

* 13，发送QoS2消息。

* 14，发送release数据。

遍历context->msgs_in.queued，如果可以移入context->msg_in.inflight队列中，那么作如下处理。

* 15，db__message_dequeue_first()，把一个消息从queued队列中移动到inflight队列中。

* 16，send__pubrec() 发送receive。（queued中保存的是收到的QoS2消息，所以需要回复receive）。

遍历context->msgs_out.queued，如果可以移动到context->msgs_out.inflight队列中，那么作如下处理。

* 17，db__message_dequeue_first()，把一个消息从queued队列中移动到inflight队列中。


# 备注

## 注1 struct mqtt3_config/struct mosquitto__config

1.6.3版本定义为struct mosquitto__config

结构体struct mqtt3_config用于保存mosquitto的所有配置信息，mosquitto程序在启动时将初始化该结构体并从配置文件中读取配置信息保存于该结构体变量内。

struct mosquitto__config中定义的属性基本上和配置文件中的配置项是对应的

```
struct mosquitto__config {
	struct mosquitto__listener default_listener; // 默认监听器
	struct mosquitto__listener *listeners; // 可能有多个监听器
	...
}
```

## 注2 struct mosquitto__listener

每个监听器都是对应监听一个端口的配置

```
struct mosquitto__listener {
	int fd; 
	uint16_t port;
	char *host;
	char *bind_interface;
	int max_connections;
	char *mount_point;
	mosq_sock_t *socks;
	int sock_count;
	int client_count;
	enum mosquitto_protocol protocol;
	int socket_domain;
	bool use_username_as_clientid;
	uint8_t maximum_qos;
	uint16_t max_topic_alias;
	...
}
```


## 注3 struct mosquitto_db

结构体struct mosquitto_db是mosquitto对所有内部数据的统一管理结构，可以认为是其内部的一个内存数据库。它保存了所有的客户端，所有客户端的订阅关系等等，其定义形式为：

```
struct mosquitto_db{
   dbid_tlast_db_id;
   // 保存了订阅树的总树根,mosquitto中对所有的topic都在该订阅树中维护
   // 客户端的订阅关系也在该订阅树中维护
   struct _mosquitto_subhier subs; 
   // 可理解为一个用于存放所有客户端变量（类型为struct mosquitto）地址的数组，
   // mosquitto程序中，所有的客户端都在此数组中保存；
   struct mosquitto**contexts; 
   // 用于保存一个hash表，该hash表可通过客户端的ID快速找到该客户端在数组contexts中的索引；
   struct_clientid_index_hash *clientid_index_hash; 
   // 用于保存数组contexts的大小，该值也是当前mosquitto程序中维持的所有客户端的数目；
   int context_count; 
   struct mosquitto_msg_store *msg_store;
   int msg_store_count;
   // 用于保存mosquitto的所有配置信息；
   struct mqtt3_config *config; 
   int subscription_count;
	 ...
};
```

## 注4 struct mosquito

结构体struct mosquito主要用于保存一个客户端连接的所有信息，例如用户名、密码、用户ID、向该客户端发送的消息等，其定义为：

```
struct mosquitto {
  int sock; // sock表示mosquitto服务器程序与该客户端连接通信所用的socket描述符
  char *address; // address表示该客户端的IP地址
  char *id; // id是该客户端登陆mosquitto程序时所提供的ID值，该值与其他的客户端不能重复
  char *username; // 成员username和password用于记录客户端登陆时所提供的用户名和密码
  char *password;
  uint16_tkeepalive; // keepalive是该客户端需在此时间内向mosquitto服务器程序发送一条ping/pong消息
  time_t last_msg_in; // 参数last_msg_in和last_msg_out用于记录上次收发消息的时间
  time_t last_msg_out;
  time_t next_msg_out; // 下一条消息发送的预期时间
  time_t ping_t; // 为0的时候表示没有等待pingresp，否则就是在等待一个pingreq的响应pingresp
  struct mosquitto_client_msg *msgs; // 用于暂时存储发往该context的消息
  struct mosquitto_message_all *will; // 遗嘱
	uint32_t will_delay_interval;  // 遗嘱超时时间
	time_t will_delay_time; // 遗嘱过期时间 = 当前时间（指的应该是连接断开时间） + 遗嘱超时时间
  struct mosquitto__alias *aliases; // 主题别名是针对每个客户端的
  int alias_count; // 别名数量
  // context->msgs_out->inflight是当前发送队列。
  // context->msgs_out->queued是等待队列，
  // 每次当从inflight队列中发送一条数据之后，都会从queued队列中移动一条数据的inflight队列中
  // msgs_in也是同样的
  struct mosquitto_msg_data msgs_in; 
  struct mosquitto_msg_data msgs_out;
  struct mosquitto__packet in_packet; // 从端口读取的数据放到这里  
  // clean_session拆分成clean_start和session_expiry_interval
	bool clean_start;
	uint32_t session_expiry_interval;
	time_t session_expiry_time;
}
```

## 注5 struct mosquitto__packet

用来存储mosquitto 包格式数据

```
struct mosquitto__packet{
	uint8_t *payload; // 负载
	struct mosquitto__packet *next;
	uint32_t remaining_mult;
	uint32_t remaining_length;
	uint32_t packet_length; // 长度
	uint32_t to_process; // 读取数据时辅助之用
	uint32_t pos; // 位置position
	uint16_t mid; // 消息ID
	uint8_t command; // 该mqtt包的消息类型，参考mqtt协议
	int8_t remaining_count;
};
```

## 注6 struct_mosquitto_subhier

数据结构struct _mosquitto_subhier是用于保存订阅树的节点（包括叶子节点和中间节点），mosquitto中对订阅树采用孩子-兄弟链表法的方式进行存储，该存储方式主要借助与数据结构struct _mosquitto_subhier来完成，该数据结构的定义为：

```
struct _mosquitto_subhier {
   struct_mosquitto_subhier *children; // 该成员指针指向同结构的第一个孩子节点； 
   struct_mosquitto_subhier *next; // 该成员指针指向该节点的下一个兄弟节点；
   struct_mosquitto_subleaf *subs; // 该成员指向订阅列表，该主题的所有订阅客户端
   char* topic; // 该节点对应的topic片段；
   struct mosquitto_msg_store *retained;
};
```

### 订阅树机制的优缺点分析

>  Mosquito程序采用订阅树形式维护客户端之间的订阅与发布消息，这种方式优点是逻辑清晰，便于开发和维护。缺点是其遍历过程效率较低。同时，程序中存在很多对订阅树的遍历过程：订阅、发布消息、取消订阅等，在客户端数量增加时，该功能对效率的影响将更为明显。

>  因此，在mosquitto的实际应用中很难支持5万以上的客户端，尤其在客户端网络状态不好时，其断开重练操作将非常频繁，这样也造成大量对订阅树的遍历操作，从而严重影响mosquitto的效率。
>
> ---- [来自逍遥子博客](https://blog.csdn.net/shine1995/article/details/53303950)



## 注7 struct _mosquitto_subleaf

在mosquitto程序中，对某一topic的所有订阅者被组织成一个订阅列表，该订阅列表是一个双向链表，链表的每个节点都保存有一个订阅者，该链表的节点即是：struct _mosquitto_subleaf，定义形式为：

```
struct _mosquitto_subleaf {
   struct_mosquitto_subleaf *prev;
   struct_mosquitto_subleaf *next;
   structmosquitto *context;
   int qos;
};
```

## 注8 struct sub__token

这个是用来存储分割之后的主题的每个部分

```
struct sub__token {
	struct sub__token *next; // 连接下一个部分指针
	char *topic; // 本部分的名称
	uint16_t topic_len; //长度
};
```

## 注a 延迟遗嘱

MQTT5新特性。在MQTT3，只有一个遗嘱标志位，在MQTT5，新增了遗嘱超时时间。是为了避免在有些场景下出现客户端异常断线但又马上重连的情况下将遗嘱发出去。在MQTT3中只要异常断线会把遗嘱消息发送出去，而在MQTT5，只要在超时时间之内重连上，就不会发送遗嘱。

## 注b 会话过期

MQTT5新特性。把`清理会话标志`拆分成`新开始标志(指示会话应该在不使用现有会话的情况下开始)`和`会话过期间隔标志(指示连接断开之后会话保留的时间)`.`会话过期间隔时间`可以在断开时修改. 把`新开始标志`设置为1且`会话过期间隔标志`设置为0, 等同于在MQTT v3.1.1中把`清理会话(CleanSession)`设置为1.

## 注c 共享主题

共享主题是mqtt5的新特性，它是为了提供系统的可伸缩性。使用场景：一组共享客户端订阅了一组共享主题。对于每一个共享主题，如果有一个消息到达该共享主题，那么它只会将该消息发给一组共享客户端中的其中一个，它通过循环的方式选择共享客户端。
和以往每个主题会把消息的副本发送给每个订阅的客户相比，共享主题只要求一个共享客户端收到消息即可，这可以满足一些特定的场景需求
共享主题格式： \$share/group/topic    
\$share固定前缀
group指定组
topic和平常的topic一样，可以指定通配符等等
eg: \$share/group1/cts/#


## 注d 主题别名

MQTT5新特性，为了不用重复发送较长的订阅主题，给主题起个别名

通过将`主题名`缩写为`小整数`来减小MQTT报文的开销大小. 客户端和服务端分别指定它们允许的主题别名的数量.


## 注e 保留位 retain

保留位会保存某个主题的最后一次消息


通常，如果发布者向主题发布消息，并且没有人订阅该主题，则该消息将被代理放弃。但是，发布者可以通过设置保留的消息标志来告诉代理保留该主题的最后一条消息。这可能非常有用，例如，如果您的传感器仅在更改时发布其状态，例如门传感器。如果新订户订阅此状态会怎样？如果没有保留的消息，订户将不得不在收到消息之前等待状态改变。然而，对于保留的消息，订户将看到传感器的当前状态。

**重要的是要理解每个主题只保留一条消息。**

在该主题上发布的下一条保留消息将替换该主题的最后一条保留消息。





## 类 src/database.c

类database.c主要包含处理struct mosquitto_db结构的方法。

```
db__open() 初始化struct mosquitto_db，新增$SYS和空字符主题
db__close() 关闭db

检查队列中是否可以放入数据
db__ready_for_flight() 
db__ready_for_queue() 


这个就是用来保存消息的，对于所有消息到来的时候，都会调用db__msg_store_add()添加保存。
遍历完订阅主题，如果没有客户端订阅该消息，那么将会调用db__msg_store_remove()移除。
如果有客户端订阅该消息，那么将在把该消息发给所有客户端之后，再将该消息移除。
如果该消息的保留位设置为1，那么将会一直保存。
db__msg_store_add() 添加保存消息
db__msg_store_remove() 移除保存消息
db__msg_store_clean() 清楚所有保存信息
保存消息是否可以删除用引用来判断，db__msg_store_ref_inc()增加一个引用，db__msg_store_ref_dec()减少一个引用。当引用为0的时候，就将消息移除。
db__msg_store_ref_inc() 增加保存消息引用
db__msg_store_ref_dec() 减少保存消息引用
遍历所有保存消息，如果引用为0就将其删除。
db__msg_store_compact() 压缩保存消息


db__message_dequeue_first() 从 queued队列移动一个元素到inflight队列
db__message_insert() 保存消息
db__message_remove() 移除消息
db__message_store() 保存消息
db__message_store_find() 遍历context的inflight和queued队列，查找该消息是否已经发送过了。

db__message_update_outgoing() 更新消息状态
db__messages_delete() db__messages_delete_list() 用于删除队列中的所有数据（inflight,queued），在服务端停止的时候调用的。

```




# 参考

[MQTT5中文版](https://www.zybuluo.com/khan-lau/note/1325300)

[各种MQTT服务端/代理](https://github.com/mqtt/mqtt.github.io/wiki/servers)

[各种MQTT服务端/代理的对比](https://github.com/mqtt/mqtt.github.io/wiki/server-support)

[共享主题 MQTT Client Load Balancing With Shared Subscriptions](https://www.hivemq.com/blog/mqtt-client-load-balancing-with-shared-subscriptions/))

[逍遥子的博文](http://write.blog.csdn.net/postedit/21462005) 

我看的mosquitto版本是1.6.3，和逍遥子看的源码是有点区别的。

* mosquitto1.6.3在Linux上是支持epoll的，逍遥子博文中分析用的是poll
* 部分数据结构是不同
* 部分流程不同

