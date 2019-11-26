---
layout: post
permalink: /:year/9f841b1490fc46aa8285db2576b1b7e0
title: 2018-11-05-mosquitto-安装启动
categories: [编程,mosquitto系列]
tags: [c&c++,mqtt,mosquitto]
excerpt:  mosquitto,安装启动
description: mosquitto,安装启动
gitalk-id: 9f841b1490fc46aa8285db2576b1b7e0
toc: true
---

# mosquitto

## 官网

[mosquitto](http://mosquitto.org/)

## 是什么

基于MQTT协议的开源消息**代理软件**

提供轻量级的，支持可发布/可订阅的消息推送模式，使设备间的短消息通信变得简单。

redis也支持发布订阅哦~


## 能做什么

MQTT能做什么？  一个开源的即时通讯协议，类似XMPP，但是相对XMPP更轻量，更简洁，常用于传送较短的消息，比如设备间的通信，物联网。XMPP常用于即时聊天。（为啥和XMPP比，~因为我学过XMPP啊[手动狗头-微博看多的下场]）


mosquitto能做什么？

它实现了MQTT协议，类似Openfire实现了XMPP协议（作为服务端），Spark（此spark非大数据的那个spark）实现了XMPP协议（作为PC客户端），Smack实现了XMPP（作为安卓端），而mosiqutto实现了MQTT协议，mosquitto作为服务端，mosquitto_sub,mosquitto_pub作为订阅/发布客户端


## 安装

我的linux版本是ubuntu。redhat系的，后面出现问题的时候，下载那些东西用的命令是不一样的。

到mosquitto官网 [http://mosquitto.org/download/](http://mosquitto.org/download/) ，复制下载链接

```
wget https://mosquitto.org/files/source/mosquitto-1.5.3.tar.gz
```

下载完成后解压缩

```
tar -zxvf mosquitto-1.5.3.tar.gz
```

解压后进入该文件夹

```
cd mosquitto-1.5.3
```

使用make && make install 失败，出现了下面几个问题，百度所得，原文链接没有保存

```
make && make install
```

###  问题：make[1]: cc command not found

安装gcc

```
apt-get install gcc
```

### 问题：编译找不到openssl/ssl.h

使用apt-get install openssl-xxxx  ，阿里云的那个下载失败

```
apt-get install libssl-dev
```

### 问题：缺少g++

```
apt-get install g++
```

### 问题：需要uuid。 uuid/uuid.h: No such file or directory错误

```
wget http://downloads.sourceforge.net/e2fsprogs/e2fsprogs-1.41.14.tar.gz
tar xvzf e2fsprogs-1.41.14.tar.gz
// 进入e2fsprogs-1.41.14目录后执行
cd e2fsprogs-1.41.14
./configure --enable-elf-shlibs
make && make install
cp -r lib/uuid/    /usr/include/  
cp -rf lib/libuuid.so* /usr/lib  
```


### 问题：libwebsockets.h missing from the src directory

这个问题是因为我要使用到websocket功能，所以在 

[来源github](https://github.com/eclipse/mosquitto/issues/583)，按照下面命令照撸就行了

```
git clone -b v2.4.1 https://github.com/warmcat/libwebsockets.git
cd libwebsockets
mkdir build
cd build
cmake .. -DLIB_SUFFIX=64
make
make install
```

如果没有安装cmake
```
apt-install install cmake
```




我就出现了这几个错误，然后使用make && make isntall，可以了。


## 启动 与 测试

终于要启动了

### 启动


#### 问题：libwebsockets.so.12: cannot open shared object file: No such file or directory


[参考文章](https://blog.csdn.net/houjixin/article/details/79789448)

```

mosquitto -c /etc/mosquitto/mosquitto.conf 
mosquitto: error while loading shared libraries: libwebsockets.so.12: cannot open shared object file: No such file or directory

```

为什么是lib64，因为我们前面cmake的时候安装`cmake .. -DLIB_SUFFIX=64`

```

[root@localhost lib]# cd /usr/local/lib64/
[root@localhost lib64]# ll
总用量 516
drwxr-xr-x. 3 root root     27 12月 20 09:49 cmake
-rw-r--r--. 1 root root 311854 12月 20 09:49 libwebsockets.a
lrwxrwxrwx. 1 root root     19 12月 20 09:49 libwebsockets.so -> libwebsockets.so.12
-rwxr-xr-x. 1 root root 211208 12月 20 09:49 libwebsockets.so.12
drwxr-xr-x. 2 root root     61 12月 20 09:49 pkgconfig
[root@localhost lib64]# ln -s /usr/local/lib64/libwebsockets.so.12 /usr/lib/libwebsockets.so.12
[root@localhost lib64]# ldconfig

```

再次启动就可以了


```
mosquitto -c /etc/mosquitto/mosquitto.conf
```

### 订阅

（另起一个终端）订阅主题为mqtt的消息

```
mosquitto_sub -t "mqtt"
```

### 发布

（再起一个终端）发布内容为 "hello world"到主题mqtt，

```
mosquitto_pub -t "mqtt" -m "hello world"
```

#### 问题：发布时报错 mosquitto_pub: error while loading shared libraries: libmosquitto.so.1: cannot open shared object file: No such file or directory

mosquitto_pub: error while loading shared libraries: libmosquitto.so.1: cannot open shared object file: No such file or directory

运行下面的命令即可

```
sudo /sbin/ldconfig
```

再次运行

```
mosquitto_pub -t "mqtt" -m "hello world"
```

#### 问题：又报错 Error: The connection was lost.

Error: The connection was lost.

注意此时需要修改配置文件中的一些配置项，应该就是下面这一个吧

```
allow_anonymous true
```

重启mosquitto

注意使用如下方式重启，有一些配置项是无法重新加载的

```
kill -s SIGHUP [mosquitto的pid] 
```

用这种方式重启：先停止mosquitto服务，然后再重新启动

```
serivce mosquitto restart

或者
service mosquitto stop
mosquitto -c /etc/mosquitto/mosquitto.conf

或者
ps -ef|grep mosquitto
kill -9 [pid]
mosquitto -c /etc/mosquitto/mosquitto.conf

```

再次运行

```
mosquitto_pub -t "mqtt" -m "hello world"
```

OK， 这次成功了，切到监听端的终端就能看到收到消息了


### 连接test.mosquitto.org

前面我们使用mosquitto来创建服务，如果有公用的服务器（如test.mosquitto.org），那么只需要使用mosquitto_sub和mosquitto_pub来发布订阅即可

订阅端

```
# 恰逢IG夺冠，来，订阅一波IG
root@ubuntu:~# mosquitto_sub -h test.mosquitto.org -t "IG"
b
c
```

发布端

```
root@ubuntu:~# mosquitto_pub -h test.mosquitto.org -t "ig" -m "a"    
root@ubuntu:~# mosquitto_pub -h test.mosquitto.org -t "IG" -m "b"  
root@ubuntu:~# mosquitto_pub -h test.mosquitto.org -t "IG" -m "c"      
root@ubuntu:~# 
```

可以发现，发布端使用 -t "ig" -m "a" 并没有被收到，-t "IG" -m "b"才能收到， 说明 -t（topic话题）大小写敏感




