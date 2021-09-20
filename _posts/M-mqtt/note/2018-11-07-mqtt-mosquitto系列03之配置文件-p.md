---
layout: post
permalink: /:year/be282d30a8dd4b28aa0104a20bf32b3d/index
title: 2018-11-07-mqtt-mosquitto系列03之配置文件
categories: [mqtt]
tags: [post, mqtt, mosquitto, mosquitto系列]
date: 2018-11-07 11:39:09 +8
editdate: 2021-08-22 11:39:09 +8
eidtplace: 福州软件园
excerpt: mqtt, mosquitto, mosquitto.conf, 配置文件
description: mqtt-mosquiito-配置文件
catalog: true
author: 林兴洋
---



# mosquitto

## mosquitto使用的几个文件

```shell
/etc/mosquitto/mosquitto.conf 配置文件
/var/lib/mosquitto/mosquitto.db 持久化消息保存路径
/var/log/mosquitto.log 日志文件
/etc/hosts.allow 允许的主机
/etc/hosts.deny 拒绝的主机
```

## mosquitto1.6.12的配置文件mosquitto.conf

### 概览

mosquitto1.6.12大致分为如下几个段，具体内容有些机翻，有些自己用过的会加上一些自己的理解。

```shell
# 在mosquitto配置文件中，符号`#`代表注释
# This is a comment.

# 键值是以空格分割
key value

# General configuration
基础配置，对于MQTT协议选项进行支持

# Default listener
# Certificate based SSL/TLS support
# Pre-shared-key based SSL/TLS support
默认监听器，默认监听1883端口，默认开启
可以选择基于SSL/TLS加密证书的支持，默认监听8883端口，需手动开启
可以选择基于SSL/TLS预共享秘钥的支持，需手动开启

# Extra listeners
# Certificate based SSL/TLS support
# Pre-shared-key based SSL/TLS support
额外的监听器，和默认监听器类似，需手动开启
可以选择基于SSL/TLS加密证书的支持，默认监听8883端口，需手动开启
可以选择基于SSL/TLS预共享秘钥的支持，需手动开启
和默认监听器差不多，没有额外整理。
同时mosquitto2将`default listener`和`extra listener`合并了。
另外强烈推荐用mosquitto2，因为根据我的测试，连接数相比1.6.X翻一番，性能提高一倍。

# Persistence
持久化，由于mosquitto将数据保留在内存中，意外情况下可能导致数据丢失，所以加了一道持久化。

# Logging
日志相关

# Security
# Default authentication and topic access control
# External authentication and topic access plugin options
安全相关选项
默认认证和话题访问插件控制--mosquitto本身支持的认证和话题访问控制
额外的认证和话题访问插件配置--我们二次开发的认证和话题访问插件

# Bridges
# Certificate based SSL/TLS support
# PSK based SSL/TLS support
桥接
对基于SSL/TLS加密证书的桥接进行支持
对基于SSL/TLS预共享秘钥的桥接支持

# External config files
额外的配置文件，我们可以拆分上面的配置，放到指定目录中，mosquitto将会加载该目录中的所有配置文件。
```

### General configuration 基础配置

建议：这里的配置，有需要才去改，不懂别瞎改。

```
per_listener_settings 独立设置

默认为false，mosquitto会给listener做一些默认配置。
如果设为true，那么每个listener就需要单独配置自己的一些参数，包括：
password_file,acl_file,psk_file,allow_anonymous,allow_zero_length_clientid,auth_plugin,auth_opt_*,auto_id_prefix
可用信号量重载。
```

```
allow_duplicate_messages 允许重复消息

如果一个用户订阅了多个带有重复的主题，如： `foo/#` 和 `foo/+/baz`，如果`foo/bar/baz`来了一个消息，那么该用户是应该收到一个消息还是两个消息呢？（foo/#和foo/+/baz都可以通配foo/bar/baz）
如果你知道你的客户端将不会重复订阅话题，那么你可以放心的设置allow_duplicate_message为true。
默认为true，可用信号量重载
```

```
allow_zero_length_clientid 允许空的clientid

该选项控制是否允许客户端使用零长度的客户端id进行连接。此选项只影响使用MQTTv3.1.1及更高版本的客户机。如果设置为false，连接到零长度客户端id的客户端将断开连接。如果设置为true，代理将为客户端分配客户端id。这意味着它只对clean session设置为true的客户端有用。
```

```
auto_id_prefix 分配clientid的前缀

如果开启了`allow_zero_length_clientid true`，那么将会自动分配一个客户端ID，此处指定客户端ID前缀。
默认是 'auto-'
```

```
check_retain_source 

当客户端订阅具有保留消息的主题时，此选项将影响该场景。有可能将保留的消息发布到主题的客户机在发布时拥有访问权，但随后该访问权已被删除。如果check_retain_source设置为true，则在重新发布消息之前，将检查被保留消息的源以获得访问权限。当设置为false时，将不进行检查，并且始终发布保留的消息。
默认为true
```

```
max_inflight_bytes 

允许QoS 1 和 QoS 2的消息处于in flight状态的字节数量
默认是0，就是无限制
```

```
max_inflight_messages count

处于QoS1或2的消息的数量，
默认20，设为0表示无限制。如果设为1，那么将会保证有序的传递消息
```

```
max_keepalive 65535

对于MQTT v5客户机，可以让服务器发送一个“服务器keepalive”值，该值将覆盖客户机设置的keepalive值。这是用来作为一种机制来说明服务器将比预期更早地断开客户端连接，并且客户端应该使用新的keepalive值。max_keepalive选项允许您指定客户端只能使用小于或等于这个值的keepalive进行连接，否则将发送一个服务器keepalive通知它们使用max_keepalive。这只适用于MQTT v5客户机。允许的最大值是65535。不要设置在10以下。
```

```
max_packet_size 0

对于MQTT v5客户端，可以让服务器发送一个“最大数据包大小”值，该值将指示客户端不接受大于max_packet_size字节的MQTT数据包。这适用于完整的MQTT包，而不仅仅是有效负载。将此选项设置为正值将最大数据包大小设置为该字节数。如果客户端发送的数据包大于此值，则断开连接。这适用于所有客户端，不管他们使用的协议版本是什么，但是v3.1.1和更早的客户端当然不会收到最大数据包大小的信息。默认没有限制。设置小于20字节是被禁止的，因为它可能会干扰普通的客户端操作，即使是非常小的有效负载。
```

```
max_queued_bytes 0 最大排队字节数量

当前正在QoS1 和 2的数量（每个客户端），直到超过限制
默认0，表示无限制。
如果max_queued_bytes和max_queued_messages都设置了，那么先到达哪个限制点就按照那个限制点来
可用信号量重载
```

```
max_queued_messages count 最大排队消息数量

Qos1和2的消息当前处于排队的数量（每个客户端）
默认1000，设为0 表示无限制
可用信号量重载
```

```
memory_limit 0
该选项设置mosquitto将分配的堆内存字节的最大数量，从而设置代理使用内存的硬限制。超过这个值的内存请求将被拒绝。根据被否决的内容，其效果将有所不同。如果正在处理传入消息，则将删除该消息，并断开发布客户端。如果正在发送传出消息，则单个消息将被丢弃，接收客户端将断开连接。
默认没有限制。
```

```
message_size_limit 0 消息的最大大小

此选项设置代理将允许的最大发布负载大小。接收到的超过此大小的消息将不会被代理接受。
默认值是0，但是根据报文头中，最多用4个字节表示长度，每个字节只有7个有效位，第8位是标志位，所以长度是 268435455bytes约等于256M。
```

```
persistent_client_expiration

持久化过期时间。这是一个非MQTT标准选项，对于MQTT协议来说，所有设置cleansession=false的客户端的需要保存的东西将会被永远保存。但是有一些设计的比较差的客户端，会把cleansession=false，同时每次连接的时候都重新生成一个随机的client id，这就导致对于服务端来说，这些客户端永远不会再重连（因为每次client id都不同），这个配置项就是为了解决这个问题而产生的。

我们可以设置过期时间 h d w m y 对应 hour, day , week , month ,year。如
* persistenct_client_expiration 2m    : 2个月
* persistenct_client_expiration 14d   : 14天
* persistenct_client_expiration 1y    : 1年
这是一个非标准的配置，如果不设置，那么默认客户端的东西会被永久保存。
可以使用 kill -s SIGHUB 重新加载
```

```
pid_file file

指定PID文件，默认为空，表示不写入pid。
在mosquitto开机启动情况下应该设置为 /var/run/mosquitto.pid
```

```
queue_qos0_message [true|false]

如果设为true，当一个持久化客户端断开连接了，那么将会把QoS 0的消息放到队列中。消息的最大数量收到max_queued_messages限制
默认为false
注意MQTT3.1.1指定QoS 1 和 QoS2的消息才应该在这种情况下被保存，所以这是一个非标准的选项
```

```
retain_available

设置为false则禁用保留消息支持。这种情况下客户端发布的消息设置了保留位，则断开连接。
```

```
set_tcp_nodely [true|false]

如果设为true，将会禁用nagle's算法，nagles's的算法够减少潜在的需要发送的tcp包
nagles's的算法就是等待足够多的数据才发送，从而减少发送的数据包数量，缺点就是，最开始发送的数据要等待，等到攒够了足够多的数据，才能被发送，这造成了一定延迟。
所以我们可以禁用该算法来减少延迟
默认是false
可用信号量重载
```

```
sys_interval

订阅$SYS层次的更新时间，默认10秒
设为0，表示禁用$SYS层次
```

```
upgrade_outgoing_qos [true|false]

MQTT规范要求传递给订阅者的消息的QoS永远不会升级到与订阅的QoS匹配。启用此选项将改变此行为。如果upgrade_outgoing_qos设置为true，发送到订阅者的消息将始终与其订阅的QoS匹配。这是规范明确禁止的非标准选项。
一个消息被传递给订阅者，它的QoS不会被升级到订阅者所需要的QoS等级，启动这个配置项就可以改变这个行为，如果设为true，那么消息发送给订阅者，就会符合该订阅者需要的QoS等级，这是一个非标准的选项
可用信号量重载
默认false
```

```
user mosquitto 用户

默认mosquitto，如果以root身份运行mosquitto程序，会降级到该用户（即此处配置的mosquitto），如果不是以root身份运行的，则此配置无效。
```

### Listeners 监听器

建议：生产环境的mosquitto有条件上证书认证就上证书认证，没条件至少要用用户名密码认证，而且密码还不能太简单。一旦后期客户端达到一定数量再上安全方面的东西就相较费力。

#### 基本

```
bind_adddress 监听地址

可以用来控制访问，比如
bind 127.0.0.1 仅本机可访问
bind 0.0.0.0 所有主机可访问
不可用信号量重载
```

```
port 监听端口

默认1883
```

```
bind_interface 绑定的网络接口

绑定本地网卡，比如
bind_interface eth0
```

```
http_dir 

当一个连接使用websocket协议，那么也可以提供http 数据，将想要提供的http服务对应的文件放到 http_dir目录下。
不可用信号量重载
```

```
max_connections count

最大连接数， -1表示无限制
默认无限制
不可用信号量重载
```

```
protocol mqtt

目前支持mqtt以及websocket，在编译时默认禁用websocket。
```

```
use_username_as_clientid [true|false]

使用username作为client id。 这使得认证与客户端绑定， 意味着可以防止因为B客户端使用了和A客户端一样的clientid 而导致 A客户端断开连接
默认false
不要和clientid_prefixes一起使用
不可用信号量重载
```

#### 基于CA证书的SSL/TLS

```
cafile ca证书路径
capath ca证书目录
certfile 服务端证书
keyfile 服务端私钥
```

```
crlfile 访问控制列表

如果你将require_certificate设置为true，你可以创建一个证书撤销列表文件来撤销对特定客户端证书的访问。如果您已经这样做了，那么使用crlfile来指向PEM编码的撤销文件。
```

```
ciphers 加密算法

ciphers DEFAULT:!aNULL:!eNULL:!LOW:!EXPORT:!SSLv2:@STRENGTH
```

```
dhparamfile 指定dh文件
```

```
require_certificate 要求客户端提供证书（双向认证）

默认false
```

```
tls_version tls版本

可选的有tlsv1.3 tlsv1.2， tlsv1.1.
默认tlsv1.3 tlsv1.2， tlsv1.1都支持
```

```
use_identity_as_username 使用CN作为用户名

如果require_certificate设置为true，则可以设置这个选项，使用客户端证书的CN作为username，
同时password_file选项将对该listener无效。
这个优先级比user_subject_as_username高。
```

```
user_subject_as_username 使用主题名作为用户名

如果require_certificate为真，您可以将use_subject_as_username设置为真，以使用客户端证书的完整主题值作为用户名。
```

#### 基于PSK的SSL/TLS

这个实际中还没有用过。

```
psk_hint
ciphers
use_identity_as_username
```



### Persistence 持久化相关

建议：一般我们使用mosquitto都是主要用它的发布订阅、快速分发机制，而很少用它来缓存消息（retain），所以大部分情况下持久化没必要。如果涉及一些重要数据发送，可以开启持久化。

```
autosave_interval seconds 自动备份间隔

如果启用了持久性，每隔autosave_interval秒保存内存中的数据库到磁盘。如果设置为0，则只在mosquito退出时写入持久化数据库。也看到autosave_on_changes。注意，可以通过将mosquito发送到SIGUSR1信号强制写入持久化数据库。
```

```
autosave_on_change 改变后自动保存

如果为true，则会统计（订阅数的改变量，收到的保留消息数量，正在发送的消息数量）的总计，如果总数大于autosave_interval，则会保存到数据库。
如果为false，则以autosave_interval设置的时间间隔来保存。
```

```
persistence false

是否开启持久化，保存内存数据到硬盘中，包括所有订阅，当前正在发送的消息，以及保留消息。
retained_persistence和persistence是同义词
```

```
persistence_file 持久化文件名

文件名，默认mosquitto.db
可以用 kill -s SIGHUP 重新加载
```

```
persistence_location 持久化文件保存路径

默认保存在当前路径（启动程序的路径）
```



### Logging 日志相关 

建议：一般在开发、测试的时候日志可以开大一点，生产使用的时候日志开小一点（error，warning）。另外老问题了，防止日志把磁盘吃光，如果是直接使用命令安装`apt-get install mosquitto`（在ubuntu中），会帮你加一道系统自带的`logrotate`日志翻滚，不必担心日志大小问题，但如果是自行编译安装的，是不带这个的，建议也直接加个配置`logrotate`文件来翻滚日志，不要自己造轮子了。

```
log_dest destinations

日志打印到指定的地点，可选的有：stdout stderr syslog topic file
stdout、stderr 控制台输出
syslog 使用用户日志设备，通常像是/var/log/message
topic 主题
file 输出到文件中

可以使用多个log_dest来指定输出到多个地方，比如
log_dest stdout
log_dest file /var/log/mosquitto/mosquitto.log
就代表着输出到控制台，同时也输出到文件中。

对于topic，会发布到$SYS/broker/log/<severity>中，其中<severity>取值有：D, E, W, N, I, M
分别对应debug, error, warning, notice, information and message.

设置`log_dest none`用来取消日志
```

```
log_type types 日志类型

可选值有 debug,error,warning,notice,information,subscribe,unsubscribe,websocket,none,all
默认 error,warning,notice和information，该参数可能被指定多次。
注意debug（用来解码 收到/发出 的网络报文）不会被打印到topic中
```

```
connection_messages true

如果设为true，那么log将会包含客户端的连接和断开信息，如果设为false，那么就不包含
可用信号量重载
```

```
log_facility local facitity  日志设备

如果使用syslog来打日志，那么使用此选项来选择local0 到 local7
```

```
log_timestamp true

消息带时间戳
```

```
log_timestamp_format

时间戳格式，默认就是1970年开始的那个毫秒数
我们也可以手动设置。例如
log_timestamp_format %Y-%m-%dT%H:%M:%S
```

```
websocket_log_level

这是一个全局配置项，不能单独配给每个客户端。
它的值是一个整数值，查看libwebsockets文档了解更多内容
要使用这个选项， log_type websocket也要开启
默认为0
```



### Security 安全相关

MQTT提供

* 匿名登录，1.6.X版本默认允许匿名登录，2.X版本默认不允许匿名登录。
* 基于用户名/密码身份验证登录
  * 使用基础配置中的 `per_listener_settings`来控制是全局还是基于每个侦听器需要密码。
* 基于证书的SSL/TLS单向认证，可带用户名密码
  * 配置require_certificate=false即是单向认证，则客户端的SSL / TLS组件将验证服务器，但不要求客户端为服务器提供任何内容.
* 基于证书的SSL/TLS双向认证，可带用户名密码
  * 配置require_certificate=true即是双向认证，则客户端必须提供有效证书才能成功连接。在这种情况下，选项use_identity_as_username和use_subject_as_username变得相关。如果设置为true，则use_identity_as_username将使用来自客户端证书的公共名称（CN）而不是MQTT用户名来进行访问控制。同样的原则适用于use_subject_as_username选项，但整个证书主题用作用户名而不仅仅是CN。
* PSK（没用过）。
  * 通过psk_hint和psk_file选项使用基于预共享密钥的加密时，客户端必须提供有效的标识和密钥才能在进行任何MQTT通信之前连接到代理。如果use_identity_as_username为true，则使用PSK标识而不是MQTT用户名进行访问控制。如果use_identity_as_username为false，则使用password_file选项时，客户端仍可使用MQTT用户名/密码进行身份验证。



基于证书和基于PSK的加密都是基于每个侦听器配置的。


可以创建身份验证插件以使用例如基于SQL的查找来扩充password_file，acl_file和psk_file选项。


可以一次支持多种身份验证方案，新增一个配置，该配置具有上述所有不同加密选项的监听器，因此具有大量的身份验证方式。



```
clientid_prefixes prefix 客户端前缀

允许连接当前服务器的客户端前缀，如果设置为"secure-"，那么客户端"secure-client"可以连接上，而客户端"mqtt"无法连接上。
可用信号量重载，注意当前已经连接成功的客户端不会受到影响
```

```
allow_anonymous 匿名登录

布尔值，用于确定是否允许连接而不提供用户名的客户端进行连接。如果设置为false，则应创建另一种连接方式以控制经过身份验证的客户端访问。
如果没有配置任何安全权证选项，那么默认为true，如果有配置，那么默认为false
```

```
password_file 密码文件

密码文件所在路径，其中密码文件可以用mosquitto_passwd来生成。
如果mosquitto编译时开启带TLS，那么还支持使用加密后的密码文件（mosquitto_passwd加密，mosquitto能解开）。
```

```
psk_file 
```

```
acl_file 访问控制文件 

acl_file file path 设置访问控制列表文件的路径。如果已定义，则文件的内容用于控制客户端对代理上主题的访问。
如果定义了这个配置项，那么只有在这个文件中列出的话题才能够被访问，文件中话题的格式：
topic [read|write|readwrite] <topic>

read|write|readwrite是可选的，除非要配置<topic>。 默认是readwrite
<topic>可以包含 + 或者 # 号通配符

第一组话题是给匿名客户端访问的，这里假设allow_anonymous=true，可以在指定用户行后指定该用户访问的话题
user <username>
topic [read|write|readwrite] <topic>
这里的username就是password_file中定义的username，不是clientid也可以使用正则的方法，例如

pattern [read|write|readwrite] <topic>
可用的替代符有
* %c 用来匹配client id
* %u 用来匹配username

和 + # 两个通配符一样，%c %u 也必须独占一层，例子:
pattern write sensor /%u/data
```

```
auth_plugin file path 认证插件的文件 

指定外部的认证和访问控制模块
不支持信号量重载
```

```
auth_opt_* 认证选项

这个根据具体的认证方式而定
```



### Bridges 桥接

#### 基本

```
connection <name> 连接名

每个连接必须有一个唯一的名称。
```

```
address <host>[:<port>] [<host>[:<port>]] 地址

必须指定地址和至少一个要订阅的主题。
地址行可以指定多个主机地址和端口。
```

```
topic <topic> [[[out | in | both] qos-level] local-prefix remote-prefix] 主题

topic：订阅的话题。
方向：这个话题将被分享的方向，可指定的out, in, both。默认是out。
	针对client-broker来说（站在客户端角度来看），客户端订阅则方向是in，客户端发布则方向是out。

qos-level：默认为0，如果要指定qos-level，那么方向也必须要指定。
local-prefix remote-prefix： 本地和远程前缀选项允许主题在桥接到/从远程代理时被重新映射
一个连接可以指定多个topic，但要注意不要造成订阅的死循环（这点我在后面桥接里面有详细说）。
对于两个broker来说，cleansession也有起作用，默认是false，这会导致一种情况，如果你改变了订阅的主题，而远程borker可能仍然会给你发送旧主题的内容，因为远程broker仍然保留着你之前的订阅。如果你出现了这个问题，你可以将cleansession设置true，连接服务器后再断开，以清除之前的订阅，再将cleansession设置为true。
```

```
bridge_attempt_unsubscribe true

如果桥接器有具有“out”方向的主题，默认行为是向该主题的远程代理发送退订请求。这意味着将主题方向从“in”改为“out”将不会一直收到传入的消息。发送这些退订请求并不总是可取的，设置bridge_attempt_unsubscribe为false将禁止发送退订请求。
```

```
bridge_protocol_version mqttv311

桥接使用的MQTT协议版本，可指定mqttv311或者mqttv11，默认mqttv311
```

```
cleansession false

默认false
为这个网桥设置干净会话变量。当设置为true时，当桥接因任何原因断开连接时，远程代理上将清除所有消息和订阅。注意，如果将cleansession设置为true，当桥接器在失去连接后重新连接时，可能会发送大量保留的消息。当设置为false时，订阅和消息将保留在远程代理上，并在桥接重新连接时传递。
```

```
idle_timeout

设置使用延迟启动类型的桥在停止之前必须处于空闲状态的时间。默认为60秒。
```

```
keepalive_interval

保活时长，默认60秒
```

```
local_clientid

设置要在本地broker使用的客户端id。如果没有定义，则默认为'local.<clientid>'。如果要将broker代理连接到自己，local_clientd和clientd不能是一样的
```

```
notifications

如果设置为true，则向本地和远程代理发布通知消息，提供关于桥连接状态的信息。保留的消息被发布到主题$SYS/broker/connection/<clientid>/state，除非使用notification_topic选项。如果消息为1，那么连接是活动的，如果连接失败，则为0。这使用了最后的遗嘱和遗嘱功能。
```

```
notification_topic

发布通知消息的主题，默认$SYS/broker/connection/<clientid>/state
```

```
remote_clientid

设置在这个网桥连接的远端使用的客户端id。如果没有定义，默认为'name.host '。其中name是连接名，Hostname是这台计算机的主机名。这将取代旧的“clientid”选项以避免混淆。“clientd”暂时有效。
```

```
remote_password

设置连接到需要身份验证的代理时使用的密码。此选项仅在也设置了remote_username时使用。这将取代旧的“password”选项，以避免混淆。“密码”暂时有效。
```

```
remote_username

设置连接到需要身份验证的代理时使用的用户名。这将取代旧的“username”选项，以避免混淆。"username"暂时有效。
```

```
restart_timeout

设置使用自动启动类型的网桥在尝试重新连接之前等待的时间。这个选项可以配置为使用以秒为单位的常量延迟时间，或者使用基于“解除相关抖动”的后退机制，这将在重启发生时增加一定程度的随机性。

设置固定超时20秒:
restart_timeout 20

设置后退的基础(起始值)为10秒，上限(上限)为60秒:
restart_timeout 10 30

默认抖动的基数为5，上限为30
restart_timeout 5 30
```

```
round_robin

如果在address/addresses配置中给出的网桥有多个地址，则round_robin选项定义网桥连接失败时的行为。如果round_robin为false(默认值)，则第一个地址被视为主桥连接。如果连接失败，将依次尝试其他的辅助地址。当连接到次级桥接器时，桥接器将定期尝试重新连接到主桥接器，直到成功为止。如果round_robin为true，则所有地址都被同等对待。如果连接失败，将尝试下一个地址，如果成功，将保持连接直到它失败
```

```
start_type

设置网桥的起始类型。这控制了桥的启动方式，可以是三种类型之一:自动、惰性和一次性。请注意，RSMB提供了第四种启动类型的“手册”，目前还没有被mosquitoto支持。"automatic"是默认的启动类型，意味着当代理启动时桥接连接将自动启动，如果连接失败，也会在短时间延迟(30秒)后重新启动。使用“lazy”启动类型的桥将在队列中的消息数量超过“threshold”参数设置的数量时自动启动。在“idle_timeout”参数设置的时间后自动停止。如果您希望连接仅在需要时处于活动状态，请使用此启动类型。使用“once”启动类型的网桥将在代理启动时自动启动，但如果连接失败则不会重新启动。
```

```
threshold

设置重新启动带有延迟启动类型的桥接时需要排队的消息数量。默认为10条消息。必须小于max_queued_messages。
```

```
try_private

如果try_private设置为true，桥将尝试向远程代理表明它是桥而不是普通客户端。如果成功，这意味着循环检测将更有效，保留的消息将正确传播。并不是所有的代理都支持这个特性，所以如果网桥连接不正确，可能需要将try_private设置为false。
```

#### 基于CA证书的 SSL/TLS

```
bridge_cafile ca证书路径
bridge_capath ca证书目录
bridge_certfile 服务端证书
bridge_keyfile 服务端私钥
```

```
bridge_alpn

如果远程代理的端口上有多个可用协议，例如MQTT和WebSockets，那么使用bridge_alpn配置请求哪个协议。注意，WebSockets对桥的支持还不可用。
```

```
bridge_insecure

当使用基于证书的加密时，bridge_insecure禁用对服务器证书中的服务器主机名的验证。这在测试初始服务器配置时很有用，但也可能使恶意第三方通过DNS欺骗来模拟您的服务器。仅在测试中使用此选项。如果您需要在生产环境中使用此选项，那么您的设置有问题，使用加密是没有意义的。
```

#### 基于PSK的SSL/TLS

```
bridge_identity
bridge_psk

当使用基于证书的加密时，bridge_insecure禁用对服务器证书中的服务器主机名的验证。这在测试初始服务器配置时很有用，但也可能使恶意第三方通过DNS欺骗来模拟您的服务器。仅在测试中使用此选项。如果您需要在生产环境中使用此选项，那么您的设置有问题，使用加密是没有意义的。
```

### External config files 额外的配置文件

建议：如果需要经常修改配置，推荐用这种方式比较方便。类似我们常用的，`mosquitto.conf`中包含通用基本配置，然后使用`include_dir`引入多个目录`product`、`dev`、`test`、`linxy_conf`中的一个，根据需要修改包含的目录而不是修改配置文件内容。（在开发过程中我喜欢这六个字并将他们投入实践：约定优于配置）

```
include_dir

额外的配置文件，可以通过 include_dir选项被包含进来，该选项定义了一个文件夹，所有以 '.conf'结尾的文件将会被认为是一个配置文件而加载。
最好在主配置文件的末尾配置该选项，同时该选项只会在主配置文件中被处理。
该选项所指向的配置文件夹中不能包含该主配置文件。
```



### 1.6.13 和 2.0.7 配置文件对比

仅配置文件的对比

* D - delete
* A - add
* M - modify

|      | 配置                                                         | 1.6.13                                                       | 2.0.7                                                        | 备注                                                         |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| D    | allow_duplicate_messages false                               |                                                              | 去掉该配置                                                   | 未找到原因                                                   |
| A    | max_qos 2                                                    |                                                              | 添加该配置                                                   |                                                              |
| M    | 每个客户端QoS1和QoS2消息数量                                 | max_queued_messages 100                                      | max_queued_messages 1000                                     | 支持更多正在发送中的QoS1和QoS2消息数量                       |
| M    | PID文件默认路径修改                                          | /var/run/mosquitto.pid                                       | /var/run/mosquitto/mosquitto.pid                             | 对嘛，放在/var/run/mosquitto下面更香不是吗                   |
| M    | user mosquitto                                               | 以root身份启动mosquitto程序，最后mosquitto会降级到该用户（默认配置mosquitto用户）。 | 以root身份允许mosquitto程序，最后mosquitto会降级到该用户，如果该户用不存在，则降级到`nobody`用户 | 是啊，我们大多数时候没有创建mosquitto这个用户，所以降级到`nobody`是个不错的选择。 |
|      |                                                              |                                                              |                                                              |                                                              |
| M    | default listener和extra lisenter整合成一个，这导致配置有些许变化。 |                                                              |                                                              |                                                              |
|      |                                                              |                                                              |                                                              |                                                              |
| A    | 日志输出新增一个 dlt （Diagnostic Log and Trace 诊断日志和跟踪） |                                                              |                                                              | 编译时需要开启DLT支持。                                      |
|      |                                                              |                                                              |                                                              |                                                              |
| M    | 匿名登录                                                     | allow_anonymous true                                         | allow_anonymous false                                        | 最新的，默认不允许匿名登录。但如果没有配置lisenter，即使用默认listener（只允许本机登录）的情况下允许匿名登录。 |
| M    | 主题访问qr权限，`topic`                                      |                                                              | 新增一个deny选项。                                           | 一个主题，同时设置允许访问和禁止访问，那么禁止访问先起作用。 |
|      |                                                              |                                                              |                                                              |                                                              |
| A    | 桥接绑定本地IP地址                                           |                                                              | bridge_bind_address                                          |                                                              |
| A    | 桥接支持MQTT5                                                |                                                              |                                                              |                                                              |
|      |                                                              |                                                              |                                                              |                                                              |




