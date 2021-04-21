---
layout: post
permalink: /:year/9f841b1490fc46aa8285db2576b1b7e0/index
title: 2018-11-05-mqtt-mosquitto-安装启动
categories: [mqtt]
tags: [c,c++,mqtt,mosquitto,mosquitto系列]
relative-tags: [mosquitto系列]
excerpt:  mosquitto,安装启动
description: mosquitto,安装启动
catalog: true
author: 林兴洋
---

* [2018-11-05-mqtt-mosquitto-安装启动](http://linxingyang.net/2018/9f841b1490fc46aa8285db2576b1b7e0)
* [2018-11-07-mqtt-mosquiito-配置文件](http://linxingyang.net/2018/be282d30a8dd4b28aa0104a20bf32b3d)
* [2018-11-08-mqtt-mosquitto-mosquitto_sub和mosquitto_pub](http://linxingyang.net/2018/3a7989b061fd44c7a9ff4cdd7be5f8c2)
* [2018-11-09-mqtt-mosquitto-mosquitto_passwd](http://linxingyang.net/2018/60baaf14d2bb4ec89e1a3684d7819b01)
* [2018-11-10-mqtt-mosquitto-配置用户名密码验证](http://linxingyang.net/2018/798abc8b2bff498a9d4c4933c0b1d91e)
* [2018-11-11-mqtt-mosquitto-配置基于CA的SSL-TLS登录](http://linxingyang.net/2018/67756e86d8834aac97b1530cf4bbdfb1)
* [2018-11-12-mqtt-mosquitto-配置桥接](http://linxingyang.net/2018/bf6b45256d9d48c3a0ae55e318d077f4)
* [2018-11-11-mqtt-mosquitto-配置基于CA的SSL-TLS登录](http://linxingyang.net/2018/6efdf2685be94f6b9c4fce8d52233bab)

---

# mosquitto

## 是啥 & 为了啥

了解mosquitto之前需要先了解MQTT协议：MQTT协议是一个开源的、轻量级的、支持发布/订阅模式的协议，追求通讯的简单高效、低成本，所以常用于设备间的通信、物联网。（相比XMPP来说更轻量，更简洁，XMPP常用于即时通讯）

mosquitto是基于MQTT协议的开源消息服务端，同时也提供简易使用的客户端以及客户端库，使用C/C++编写。mosquitto作为一个MQTT服务端（又称broker，不过我们习惯称呼服务端），实现了MQTT3.1、MQTT3.1.1、MQTT5版本，截止目前为止最新版本是2.0.6。

几个相关网站如下：

* [mosquitto官网](http://mosquitto.org/)

* [mosquitto源码](https://github.com/eclipse/mosquitto)

* [MQTT协议组织官网](https://mqtt.org/)



## 下载 & 编译 & 安装

我的linux版本是ubuntu。redhat系的，后面出现问题的时候，下载那些东西用的命令是不一样的。到mosquitto官网 [http://mosquitto.org/download/](http://mosquitto.org/download/) ，复制下载链接

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

使用apt-get install openssl-xxxx  

```
apt-get install libssl-dev
```

### 问题：缺少g++

```
apt-get install g++
```

### 问题：需要uuid。 uuid/uuid.h: No such file or directory错误

```shell
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

这个问题是因为我要使用到websocket功能，按照下面命令照撸就行了

```shell
git clone -b v2.4.1 https://github.com/warmcat/libwebsockets.git
cd libwebsockets
mkdir build
cd build
cmake .. -DLIB_SUFFIX=64
make
make install
```

如果没有安装cmake
```shell
apt-install install cmake
```


我就出现了这几个错误，然后使用make && make isntall，可以了。



## 启动 & 测试

### 启动命令

```
mosquitto [-c config file] [ -d | --daemon ] [-p port number] [-v]

-c 配置文件路径
-p 指定端口，默认1883，监听端口最好配置在配置文件中
-d 后台启动
-v 打印全部日志，等于配置文件中的 log_type=all
```

### 配置文件

关于启动的配置文件参数，参看配置文件mosquitto.conf

### 启动


#### 问题：libwebsockets.so.12: cannot open shared object file: No such file or directory

```shell
mosquitto -c /etc/mosquitto/mosquitto.conf 
mosquitto: error while loading shared libraries: libwebsockets.so.12: cannot open shared object file: No such file or directory
```

为什么是lib64，因为我们前面cmake的时候安装`cmake .. -DLIB_SUFFIX=64`

```shell
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


```shell
# mosquitto -c /etc/mosquitto/mosquitto.conf
```

### 订阅

订阅主题为mqtt的消息

```shell
# mosquitto_sub -t "mqtt"
```

### 发布

（再起一个终端）发布内容为 "hello world"到主题mqtt，

```
mosquitto_pub -t "mqtt" -m "hello world"
```

#### 问题：发布时报错 mosquitto_pub: error while loading shared libraries: libmosquitto.so.1: cannot open shared object file: No such file or directory

mosquitto_pub: error while loading shared libraries: libmosquitto.so.1: cannot open shared object file: No such file or directory

运行下面的命令即可

```shell
sudo /sbin/ldconfig
```

再次运行

```shell
mosquitto_pub -t "mqtt" -m "hello world"
```

#### 问题：又报错 Error: The connection was lost.

Error: The connection was lost.

注意此时需要修改配置文件中的一些配置项，应该就是下面这一个吧

```shell
# vi mosquitto.conf
allow_anonymous true
```

重启mosquitto，注意使用如下方式重启，有一些配置项是无法重新加载的

```shell
# kill -s SIGHUP [mosquitto的pid] 
```

用这种方式重启：先停止mosquitto服务，然后再重新启动

```shell
# serivce mosquitto restart

或者
# service mosquitto stop
# mosquitto -c /etc/mosquitto/mosquitto.conf

或者
# ps -ef|grep mosquitto
# kill -9 [pid]
# mosquitto -c /etc/mosquitto/mosquitto.conf
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



## 参考

* [编译中webosocket问题解决参考](https://github.com/eclipse/mosquitto/issues/583)

* [libwebsockets.so.12: cannot open shared object file: No such file or directory](https://blog.csdn.net/houjixin/article/details/79789448)