---
layout: post
permalink: /:year/67756e86d8834aac97b1530cf4bbdfb1
title: 2018-11-11-mosquitto-配置基于CA的SSL-TLS登录
categories: [mqtt]
tags: [c,c++,mqtt,mosquitto,mosquitto系列]
relative-tags: [mosquitto系列]
excerpt:  mosquitto,CA,SSL-TLS,登录
description: mosquitto,CA,SSL-TLS,登录
catalog: true
author: 林兴洋
---

# mosquitto


[这个老兄写的不错](https://segmentfault.com/a/1190000014250065)

[steves-moquitt中使用tls](http://www.steves-internet-guide.com/mosquitto-tls/)

[steves-桥接中用tls](http://www.steves-internet-guide.com/mosquitto-bridge-encryption/)



在Mosquitto中配置基于certificate的TLS/SSL

## 证书

首先要搞个证书，官方文档有，非常好，照敲。

[http://mosquitto.org/man/mosquitto-tls-7.html](http://mosquitto.org/man/mosquitto-tls-7.html)

先把官方的过程列下来，后面我的过程也有

创建 ca.key ca.crt

```
openssl req -new -x509 -days <duration> -extensions v3_ca -keyout ca.key -out ca.crt

#<duration>指的是日期
```

服务端

```
# 创建一个服务端Key
openssl genrsa -des3 -out server.key 2048

# 创建csr,key
openssl req -out server.csr -key server.key -new

# 注意，当要求输入CN（common name）的时候，请输入你服务器的域名或者IP

# 发送CSR给CA或者用自己的CA key签名，哈哈，拙劣的翻译~
# Send the CSR to the CA, or sign it with your CA key:
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days <duration>

```


客户端

```
# 创建一个客户端key
openssl genrsa -des3 -out client.key 2048

# 创建csr
openssl req -out client.csr -key client.key -new

# 发送CSR给CA或者用自己的CA key签名
# Send the CSR to the CA, or sign it with your CA key:
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days <duration>
```



### 过程

#### 生成CA认证中心的ca.key和ca.crt

首先创建ca.key和ca.crt，注意这里有个坑，倒2行的Common Name，等等服务端和客户端设置过程中也有这个，ca的Common Name 的值不能和客户端和服务端的Common Name值一样，否则无效

-days 我就设置365了，毕竟是测试用。

```
root@ubuntu:/etc/mosquitto# mkdir ca
root@ubuntu:/etc/mosquitto# cd ca
root@ubuntu:/etc/mosquitto/ca# openssl req -new -x509 -days 365 -extensions v3_ca -keyout ca.key -out ca.crt
Generating a 2048 bit RSA private key
............+++
...............................................................+++
writing new private key to 'ca.key'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:cn
State or Province Name (full name) [Some-State]:fj
Locality Name (eg, city) []:fz
Organization Name (eg, company) [Internet Widgits Pty Ltd]:wecon      
Organizational Unit Name (eg, section) []:r3
# 就是这个，和后面的不能一样
Common Name (e.g. server FQDN or YOUR name) []:linxingyang
Email Address []:.

```

这步走完生成了两个文件

```
root@ubuntu:/etc/mosquitto/ca# ll
total 16
drwxr-xr-x 2 root root 4096 Nov 11 17:27 ./
drwxr-xr-x 3 root root 4096 Nov 11 17:26 ../
-rw-r--r-- 1 root root 1285 Nov 11 17:27 ca.crt
-rw-r--r-- 1 root root 1834 Nov 11 17:27 ca.key
```

#### 生成服务端使用的证书

##### 生成server.key

```
root@ubuntu:/etc/mosquitto/ca# openssl genrsa -des3 -out server.key 2048         
Generating RSA private key, 2048 bit long modulus
.........+++
...................+++
e is 65537 (0x10001)
# 注意，这里设置的就是服务端的密码，启动mosquitto服务要用到
Enter pass phrase for server.key: 
Verifying - Enter pass phrase for server.key:
```

##### 生成server.csr

```
root@ubuntu:/etc/mosquitto/ca# openssl req -out server.csr -key server.key -new
Enter pass phrase for server.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:cn
State or Province Name (full name) [Some-State]:fj
Locality Name (eg, city) []:fz
Organization Name (eg, company) [Internet Widgits Pty Ltd]:wecon
Organizational Unit Name (eg, section) []:r3
# 这里设置成主机的ip了，没试过别的行不行
Common Name (e.g. server FQDN or YOUR name) []:192.168.193.128
Email Address []:.

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:lxy128server
An optional company name []:.
```

##### 生成server.crt

```
root@ubuntu:/etc/mosquitto/ca# openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365
Signature ok
subject=/C=cn/ST=fj/L=fz/O=wecon/OU=r3/CN=192.168.193.128
Getting CA Private Key
Enter pass phrase for ca.key:
```

这步走完ca目录下有这些文件

```

root@ubuntu:/etc/mosquitto/ca# ll
total 32
drwxr-xr-x 2 root root 4096 Nov  9 23:13 ./
drwxr-xr-x 4 root root 4096 Nov  9 23:06 ../
-rw-r--r-- 1 root root 1285 Nov  9 23:09 ca.crt
-rw-r--r-- 1 root root 1834 Nov  9 23:09 ca.key
-rw-r--r-- 1 root root   17 Nov  9 23:13 ca.srl
-rw-r--r-- 1 root root 1172 Nov  9 23:13 server.crt
-rw-r--r-- 1 root root 1029 Nov  9 23:12 server.csr
-rw-r--r-- 1 root root 1743 Nov  9 23:11 server.key

```

#### 生成客户端使用的证书

##### 生成key

```
root@ubuntu:/etc/mosquitto/ca# openssl genrsa -des3 -out client.key 2048
Generating RSA private key, 2048 bit long modulus
......+++
......+++
e is 65537 (0x10001)
# 注意，这里设置的是客户端sub/pub的时候需要的密码
Enter pass phrase for client.key:
Verifying - Enter pass phrase for client.key:
```

##### 生成client.csr

```
root@ubuntu:/etc/mosquitto/ca# openssl req -out client.csr -key client.key -new
Enter pass phrase for client.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:cn
State or Province Name (full name) [Some-State]:fj
Locality Name (eg, city) []:fz
Organization Name (eg, company) [Internet Widgits Pty Ltd]:wecon
Organizational Unit Name (eg, section) []:r3
Common Name (e.g. server FQDN or YOUR name) []:192.168.193.128
Email Address []:.

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:lxy128client
An optional company name []:.
```

##### 生成client.crt

```
root@ubuntu:/etc/mosquitto/ca# openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 365
Signature ok
subject=/C=cn/ST=fj/L=fz/O=wecon/OU=r3/CN=192.168.193.128
Getting CA Private Key
Enter pass phrase for ca.key:

```



打完这一套，就有下面这些个文件

```
root@ubuntu:/etc/mosquitto/ca# ll
total 44
drwxr-xr-x 2 root root 4096 Nov  9 23:15 ./
drwxr-xr-x 4 root root 4096 Nov  9 23:06 ../
-rw-r--r-- 1 root root 1285 Nov  9 23:09 ca.crt
-rw-r--r-- 1 root root 1834 Nov  9 23:09 ca.key
-rw-r--r-- 1 root root   17 Nov  9 23:15 ca.srl
-rw-r--r-- 1 root root 1172 Nov  9 23:15 client.crt
-rw-r--r-- 1 root root 1029 Nov  9 23:14 client.csr
-rw-r--r-- 1 root root 1743 Nov  9 23:13 client.key
-rw-r--r-- 1 root root 1172 Nov  9 23:13 server.crt
-rw-r--r-- 1 root root 1029 Nov  9 23:12 server.csr
-rw-r--r-- 1 root root 1743 Nov  9 23:11 server.key

```



## 双向认证配置

到mosquitto.conf中进行配置，注意我这里直接修改默认的listener，然后修改端口为8883


```

# =================================================================
# Default listener
# =================================================================

port 8883
cafile /etc/mosquitto/ca/ca.crt
keyfile /etc/mosquitto/ca/server.key
certfile /etc/mosquitto/ca/server.crt
tls_version tlsv1
# 将要求双向认证设置为为true
require_certificate true
# 因为我后面有配置密码文件，所以需要用账号密码登录
# password_file /etc/mosquitto/pwfile.conf
use_identity_as_username false
```


配置完准备重启，这里踩了一个坑~，该坑如下，极其熟练的加了参数 -d，后台运行

```
mosquitto -c /etc/mosquitto/mosquitto.conf -d
```

然后日志中报了一个错

```
1541833572: mosquitto version 1.5.3 starting
1541833572: Config loaded from /etc/mosquitto/mosquitto.conf.
1541833572: Opening ipv4 listen socket on port 8883.
1541833572: Opening ipv6 listen socket on port 8883.
1541833572: Error: Unable to load server key file "/etc/mosquitto/ca/server.key". Check keyfile.
1541833572: Error: Invalid argument
```

首先以为是路径错了，确认确认再确认，没问题




找了几篇文章：

[https://answers.launchpad.net/mosquitto/+question/260828](https://answers.launchpad.net/mosquitto/+question/260828)
[https://bugs.eclipse.org/bugs/show_bug.cgi?id=452914](https://bugs.eclipse.org/bugs/show_bug.cgi?id=452914)
[https://answers.launchpad.net/mosquitto/+question/252120](https://answers.launchpad.net/mosquitto/+question/252120)


mosquitto作者Roger Light说该bug mosquitto1.4分支已修复。

有人说说是文件权限问题，要把ca证书所在的路径权限赋给 mosquitto.conf中配置的user（默认是mosquitto），但是我早就改成root了，这个应该没问题。

还有人说文件要放在 `/etc/mosquitto/certs/` 下才行。试了，也不行。


挠头中...


忽然想起来，好像哪里说过不能后台启动，把 -d 去了，提示输入密码，输入前面设置的服务端的密码

```
root@ubuntu:/etc/mosquitto/ca# mosquitto -c /etc/mosquitto/mosquitto.conf
Enter PEM pass phrase:
```

看到日志没有报错，成功了。 

```
1541842331: mosquitto version 1.5.3 starting
1541842331: Config loaded from /etc/mosquitto/mosquitto.conf.
1541842331: Opening ipv4 listen socket on port 8883.
1541842331: Opening ipv6 listen socket on port 8883.
1541842337: Warning: Mosquitto should not be run as root/administrator.
```

只因为多加了一个 -d ，绕地球一圈找解决方案~



## 双向认证测试

启动成功，来，测测订阅

```
root@ubuntu:/etc/mosquitto/certs# mosquitto_sub -h 192.168.193.128 -p 8883 -t "ssl/topic/#" --tls-version tlsv1 --cafile /etc/mosquitto/ca/ca.crt --cert /etc/mosquitto/ca/client.crt --key /etc/mosquitto/ca/client.key -u lxy128 -P lxy128
Enter PEM pass phrase:
```

没想到要打这么长一段，回车后输入的是前面设置的证书客户端的密码

```
-h 主机
-p 端口
-t 话题，订阅 ssl/topic/下的所有话题
--tls-version 因为mosquitto.conf中配置了tlsv1，这里也要配tlsv1
--cafile 指定ca.crt
--cert 客户端的client.crt
--key 客户端的client.key

因为我后台使用password_file，所以还要带上用户名密码，如果
这项 use_identity_as_username设为 true，那就不用了
-u lxy128 账号
-P lxy128 密码
```

后台日志显示客户端连接成功：

```
1541842539: New connection from 192.168.193.128 on port 8883.
1541842543: New client connected from 192.168.193.128 as mosqsub|19778-ubuntu (c1, k60, u'lxy128').
```



发布，也是老长了，配置项基本和订阅一样，也是需要密码

```
root@ubuntu:/etc/mosquitto/db# mosquitto_pub -h 192.168.193.128 -p 8883 -t "ssl/topic/128" --tls-version tlsv1 --cafile /etc/mosquitto/ca/ca.crt --cert /etc/mosquitto/ca/client.crt --key /etc/mosquitto/ca/client.key -m "i'm 128, msg to 128, port 8883" -u lxy128 -P lxy128
Enter PEM pass phrase:
```

监听端收到消息了

```
root@ubuntu:/etc/mosquitto/certs# mosquitto_sub -h 192.168.193.128 -p 8883 -t "ssl/topic/#" --tls-version tlsv1 --cafile /etc/mosquitto/ca/ca.crt --cert /etc/mosquitto/ca/client.crt --key /etc/mosquitto/ca/client.key -u lxy128 -P lxy128
Enter PEM pass phrase:
i'm 128, msg to 128, port 8883
```

截个图，看看加密后的效果

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/M-mqtt/image/2018-11-09/31.png)


下一步准备桥接的TLS玩一下



## 单向认证配置

我自己测试的时候都是用的双向认证，后面发现公司用的版本是单向认证，所以又搞了一下。



双向认证，发布和订阅都需要带上客户端自己的crt,key还有ca.crt，因为服务端和客户端需要互相认证。

单向认证只需要客户端认证服务端即可，所以客户端发布订阅的时候只要有ca.crt就可以了。



单向认证的服务端配置，好像没差0.0

```
listener 9883
protocol mqtt
cafile /etc/mosquitto/ca.crt
certfile /etc/mosquitto/server.crt
keyfile /etc/mosquitto/server.key
# 将双向认证设置为false
require_certificate false
```



## 单向认证测试

只需要指定`--cafile`，ca证书即可。

订阅

```
[root@localhost ~]# mosquitto_sub -h 192.168.45.190 -p 9883 -t "test" --cafile ca.crt --insecure  -u test -P test
```

发布

```
[root@localhost mosquitto-cmd]# mosquitto_pub -h 192.168.45.190  -p 9883 -t "test" -m "wtf" --cafile ca.crt --insecure -u test -P test
```



不指定`--insecure`会出现 A TLS 错误：

```
[root@localhost mosquitto-cmd]# mosquitto_pub -h 192.168.45.190  -p 9883 -t "test" -m "wtf" --cafile /usr/local/mosquitto-1.6/mosquitto-1.6.3/mosquitto-cmd/test-conf/ssl/ca.crt -u admin -P password 
Error: A TLS error occurred.
```

看一下insecure选项说的，不要检查服务器证书主机名是否与远程主机名匹配。使用此选项意味着您不能确定远程主机是您希望连接到的服务器，因此是不安全的。不要在生产环境中使用此选项（懒得翻译，来自有道翻译）。证书主机名我在创建ca.crt的时候都没有设置，当然会不同。

```
 --insecure : do not check that the server certificate hostname matches the remote
              hostname. Using this option means that you cannot be sure that the
              remote host is the server you wish to connect to and so is insecure.
              Do not use this option in a production environment.
```