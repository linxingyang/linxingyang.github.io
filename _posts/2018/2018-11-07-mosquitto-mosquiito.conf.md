---
layout: post
permalink: /:year/be282d30a8dd4b28aa0104a20bf32b3d
title: 2018-11-07-mosquitto-mosquiito.conf
categories: [编程,mosquitto系列]
tags: [c&c++,mqtt,mosquitto]
excerpt:  mosquitto,mosquitto.conf
description: mosquitto,mosquitto.conf
gitalk-id: be282d30a8dd4b28aa0104a20bf32b3d
toc: true
---

# mosquitto

## mosquitto.conf 配置文件

### 文件格式

符号#代表注释

键值是以空格分割。 如 :

```
key value
```

### 身份认证

最简单的选择是根本不进行身份验证。如果没有给出其他选项，则这是默认值。使用基于证书的SSL / TLS选项cafile / capath，certfile和keyfile提供未经身份验证的加密支持。



MQTT提供用户名/密码身份验证作为协议的一部分。使用password_file选项定义有效的用户名和密码。如果您使用此选项，请务必使用网络加密，否则用户名和密码将容易被拦截。使用它 `per_listener_settings`来控制是全局还是基于每个侦听器需要密码。



使用基于证书的加密时，有三个选项会影响身份验证。第一个是require_certificate，可以设置为true或false。如果为false，则客户端的SSL / TLS组件将验证服务器，但不要求客户端为服务器提供任何内容：身份验证仅限于内置用户名/密码的MQTT。如果require_certificate为true，则客户端必须提供有效证书才能成功连接。在这种情况下，第二个和第三个选项use_identity_as_username和use_subject_as_username变得相关。如果设置为true，则use_identity_as_user将使用来自客户端证书的公共名称（CN）而不是MQTT用户名来进行访问控制。不替换密码，因为假定只有经过身份验证的客户端具有有效证书。如果use_identity_as_username为false，则客户端必须通过MQTT选项正常进行身份验证（如果password_file需要）。同样的原则适用于use_subject_as_username选项，但整个证书主题用作用户名而不仅仅是CN。



通过psk_hint和psk_file选项使用基于预共享密钥的加密时，客户端必须提供有效的标识和密钥才能在进行任何MQTT通信之前连接到代理。如果use_identity_as_username为true，则使用PSK标识而不是MQTT用户名进行访问控制。如果use_identity_as_username为false，则使用password_file选项时，客户端仍可使用MQTT用户名/密码进行身份验证。


基于证书和基于PSK的加密都是基于每个侦听器配置的。


可以创建身份验证插件以使用例如基于SQL的查找来扩充password_file，acl_file和psk_file选项。


可以一次支持多种身份验证方案。可以创建一个配置，该配置具有上述所有不同加密选项的监听器，因此具有大量的身份验证方式。



### 通用配置

#### 安全
##### acl_file 访问控制文件 

acl_file file path 设置访问控制列表文件的路径。如果已定义，则文件的内容用于控制客户端对代理上主题的访问。

如果定义了这个配置项，那么只有在这个文件中列出的话题才能够被访问，文件中话题的格式：

```
topic [read|write|readwrite] <topic>

read|write|readwrite是可选的，除非要配置<topic>。 默认是readwrite

<topic>可以包含 + 或者 # 号通配符

```


第一组话题是给匿名客户端访问的，这里假设allow_anonymous=true，可以在指定用户行后指定该用户访问的话题

```

user <username>
topic [read|write|readwrite] <topic>

```

这里的username就是password_file中定义的username
，不是 clientid


也可以使用正则的方法，例如

```

pattern [read|write|readwrite] <topic>

```

可用的替代符有

* %c 用来匹配client id
* %u 用来匹配username

和 + # 两个通配符一样，%c %u 也必须独占一层

例子

```
pattern write sensor /%u/data

```


##### allow_anonymous 匿名登录

`allow_anonymous`  [true | false]

布尔值，用于确定是否允许连接而不提供用户名的客户端进行连接。如果设置为*false*，则应创建另一种连接方式以控制经过身份验证的客户端访问。

如果没有配置任何安全权证选项，那么默认为true，如果有配置，那么默认为false


##### allow_duplicate_messages 允许重复消息

`allow_duplicate_messages` [ true | false ]

如果一个用户订阅了多个带有重复的主题，如：  foo/# 和 foo/+/baz 


那么如果 foo/bar/baz来了一个消息，那么该用户是应该收到一个消息还是两个消息呢（foo/#和foo/+/baz都可以通配foo/bar/baz）


如果你知道你的客户端将不会重复订阅话题，那么你可以放心的设置allow_duplicate_message为true


默认为true

可用信号量重载

##### auth_opt_* 认证选项

这个根据具体的认证方式而定

##### auth_plugin file path 认证插件的文件 

指定外部的认证和访问控制模块

不支持信号量重载


##### auth_plugin_deny_special_chars [true|false]



##### clientid_prefixes prefix 客户端前缀

客户端前缀，如果设置为  "secure-" 那么客户端 "secure-client"可以连接上，而 客户端 "mqtt"无法连接。


可用信号量重载，注意当前已经连接成功的客户端不会受到影响


##### password_file 密码文件







#### 日志相关 

##### connection_messages

如果设为true，那么log将会包含客户端的连接和断开信息，如果设为false，那么就不包含

可用信号量重载


##### log_dest destinations

日志打印到指定的地点，可选的有：stdout stderr syslog topic

stdout和stderr 日志输出到对应名称的控制台

syslog使用用户日志设备，通常像是/var/log/message


##### log_facility local facitity  日志设备

如果使用syslog来打日志

##### log_timestamp[true|false] 时间戳

##### log_type types 日志类型

可选值有 debug,error,warning,notice,information,subscribe,unsubscribe,websocket,none,all


默认 error,warning,notice和information，该参数可能被指定多次。

注意debug（用来解码 收到/发出 的网络报文）不会被打印到topic中








#### 持久化相关

##### retained_persistence 

这个和下面的persistence是同义词

##### persistence [true|false] 持久化

##### persistence_file 
文件名，默认mosquitto.db

可以用 kill -s SIGHUP 重新加载

##### autosave_on_change 改变后自动保存

如果为true，Mosquitto将会计算 订阅的改变量，保存收到的消息，队列中的消息。如果这些数量超过 autosave_interval的值，那么将会从内存写入磁盘。

如果为false，那么mosquitto就会把autosave_interval当做时间（秒）来对待。

##### autosave_interval seconds 自动备份间隔

前提：persistence true  开启了持久化


将内存中的数据保存到磁盘中，如果设置为0，那么只有当手动发送SIGUSR信号格mosquitto，才会进行备份。默认30分钟

可用信号量重载



##### persistence_location

持久化文件保存路径

##### persistent_client_expiration

过期时间。这是一个非MQTT标准选项

对于MQTT协议来说，所有设置cleansession=false的客户端的需要保存的东西将会被永远保存。

但是有一些设计的比较差的客户端，会把cleansession=false，同时每次连接的时候都重新生成一个随机的client id，这就导致对于服务端来说，这些客户端永远不会再重连（因为每次client id都不同），这个配置项就是为了解决这个问题而产生的


我们可以设置过期时间 h d w m y 对应 hour, day , week , month ,year。

如
* persistenct_client_expiration 2m    : 2个月
* persistenct_client_expiration 14d   : 14天
* persistenct_client_expiration 1y    : 1年


这是一个非标准的配置，如果不设置，那么默认客户端的东西会被永久保存

可以使用 kill -s SIGHUB 重新加载


#### 消息相关

##### max_inflight_bytes 

允许QoS 1 和 QoS 2的消息处于in flight状态的字节数量

默认是0，就是无限制

##### max_inflight_messages count

处于QoS1或2的消息的数量，

默认20，设为0表示无限制。如果设为1，那么将会保证有序的传递消息


##### max_queued_bytes count

最大排队字节数量

当前正在QoS1 和 2的数量（每个客户端），直到超过限制

默认0，表示无限制。

如果max_queued_bytes和max_queued_messages都设置了，那么先到达哪个限制点就按照那个限制点来

可用信号量重载

##### max_queued_messages count

最大排队消息数量


Qos1和2的消息当前处于排队的数量（每个客户端）

默认1000，，设为0 表示无限制


可用信号量重载


##### message_size_limit limit

消息的最大大小，

默认值是0，但是根据报文头中，最多用4个字节表示长度，每个字节只有7个有效位，第8位是标志位，所以长度是 268435455bytes约等于 256M

##### queue_qos0_message [true|false]

如果设为true，当一个持久化客户端断开连接了，那么将会把QoS 0的消息放到队列中。消息的最大数量收到max_queued_messages限制

默认为false

注意MQTT3.1.1指定QoS 1 和 QoS2的消息才应该在这种情况下被保存，所以这是一个非标准的选项

##### store_clean_interval seconds


清除不再被引用的数据的时间间隔，默认10秒


值越低，那么需要更少的储存空间但是更多的处理时间

值越大则相反

##### upgrade_outgoing_qos [true|false]

一个消息被传递给订阅者，它的QoS不会被升级到订阅者所需要的QoS等级

启动这个配置项就可以改变这个行为，如果设为true，那么消息发送给订阅者，就会符合该订阅者需要的QoS等级，这是一个非标准的选项

可用信号量重载


#### 其他配置

##### per_listener_settings [true|false]

如果设为true，那么每个listener就需要单独配置自己的一些参数：

password_file,acl_file,psk_file,allow_anonymous,allow_zero_length_clientid,auth_plugin,auth_opt_*,auto_id_prefix


默认是false


可用信号量重载


##### pid_file file path

可以指定pid

##### psk_file file

##### include_dir

额外的配置文件，可以通过 include_dir选项被包含进来，该选项定义了一个文件夹，所以以 '.conf'结尾的文件将会被认为是一个配置文件而加载。



最好在主配置文件的末尾配置该选项，同时该选项只会在主配置文件中被处理。该选项所指向的配置文件夹中不能包含该主配置文件


##### set_tcp_nodely [true|false]

如果设为true，将会禁用nagle's算法，nagles's的算法够减少潜在的需要发送的tcp包


nagles's的算法就是等待足够多的数据才发送，从而减少发送的数据包数量，缺点就是，最开始发送的数据要等待，等到攒够了足够多的数据，才能被发送，这造成了一定延迟。

所以我们可以禁用该算法来减少延迟

默认是false


可用信号量重载


##### sys_interval

订阅$SYS层次的更新时间，默认10秒


设为0，表示禁用$SYS层次


### Listeners 监听器

#### 基本配置

##### bind_adddress 监听地址

不可用信号量重载

##### http_dir 

当一个连接使用websocket协议，那么也可以提供http 数据，将想要提供的http服务对应的文件放到 http_dir目录下。

不可用信号量重载

##### port 监听端口

##### max_connections count

最大连接数， -1表示无限制

不可用信号量重载

##### mount_point

##### use_username_as_clientid [true|false]

使用username作为client id。 这使得认证与客户端绑定， 意味着可以防止因为B客户端使用了和A客户端一样的clientid 而导致 A客户端断开连接


默认false


不要和clientid_prefixes一起使用

不可用信号量重载


##### websocket_log_level

这是一个全局配置项，不能单独配给每个客户端。


它的值是一个整数值，查看libwebsockets文档了解更多内容

要使用这个选项， log_type要指定为 websocket，

默认为0


#### 基于CA证书的SSL/TLS

后面单独一篇

cafile

capath

certifile

ciphers

crlfile

keyfile

require_certificate

tls_version

use_identity_as_username

user_subject_as_username


#### 基于PSK的SSL/TLS


### 桥接

后面单独一篇












