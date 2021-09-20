---
layout: post
permalink: /:year/9f841b1490fc46aa8285db2576b1b7e0/index
title: 2018-11-05-mqtt-mosquitto系列01之安装启动
categories: [mqtt]
tags: [post, mqtt, mosquitto, mosquitto系列]
date: 2018-11-05 11:35:24 +8
editdate: 2021-08-19 11:35:24 +8
eidtplace: 福州软件园
excerpt:  mosquitto,安装启动
description: mosquitto安装启动
catalog: true
author: 林兴洋
---

# mosquitto

## 是啥

mosquitto是基于MQTT协议的开源消息服务端，同时也提供简易使用的客户端以及客户端库，使用C/C++编写（主要部分使用C编写，提供C++封装的客户端库）。mosquitto作为一个MQTT服务端（文档中称为broker，翻译为经理人、代理人，我习惯称为服务端），实现了MQTT3.1、MQTT3.1.1、MQTT5版本。截止目前为止最新版本是2.0.11，相较于mosquitto1.6.X，mosquitto2.X性能有较大提升。

## 安装

### 编译安装

到[github](https://github.com/eclipse/mosquitto/tags)上下载需要的版本，然后编译安装。

编译安装2.0.11：

```shell
# apt install -y wget tar gcc g++ cmake libssl-dev
# wget https://github.com/eclipse/mosquitto/archive/refs/tags/v2.0.11.tar.gz
# tar -zxvf v2.0.11.tar.gz 
# cd mosquitto-2.0.11/
# mkdir ____build
# cd ____build/
# vi ../CMakeLists.txt

// 修改这行，不编译文档
option(DOCUMENTATION "Build documentation?" OFF)

// 先安装到当前目录的__install_x86目录下，如果需要安装到系统，用 cmake .. 即可
# cmake -DCMAKE_INSTALL_PREFIX=${PWD}/__install_x86 .. 
# make -j8
# make install
# cd __install_x86
# vi etc/mosquitto/mosquitto.conf

// 监听端口
listener 1883 0.0.0.0
// 允许匿名登录
allow_anonymous true

# ./sbin/mosquitto -c etc/mosquitto/mosquitto.conf
```

编译安装1.5.3：

```shell
// 安装必要的依赖
# apt install -y wget tar gcc g++ cmake libssl-dev
# wget https://mosquitto.org/files/source/mosquitto-1.5.3.tar.gz
# tar -zxvf mosquitto-1.5.3.tar.gz
# cd mosquitto-1.5.3
# mkdir build
# cd build
# cmake ..
# make && make install
```



如果编译遇到问题可以参考最后的问题列表。



编译完目录结构大致如下：

```
├── bin
│   ├── mosquitto_passwd	// 生成、加密密码文件命令
│   ├── mosquitto_pub		// mqtt发布客户端
│   ├── mosquitto_rr		// ?
│   └── mosquitto_sub		// mqtt订阅客户端
├── etc
│   └── mosquitto 	// 配置文件
│       ├── aclfile.example // 控制访问示例列表
│       ├── mosquitto.conf  // mosquitto配置文件
│       ├── pskfile.example // psk示例文件
│       ├── pwfile.conf     // 密码示例文件
│       └── pwfile.example  // 密码示例文件
├── include 		// 头文件
│   ├── mosquitto_broker.h
│   ├── mosquitto.h
│   ├── mosquitto_plugin.h
│   └── mosquittopp.h
├── lib 			// 依赖库，我把依赖了openssl库也放在这里了
│   ├── libcrypto.so.1.0.0
│   ├── libmosquitto.so -> libmosquitto.so.1
│   ├── libmosquitto.so.1 -> libmosquitto.so.1.6.3
│   ├── libmosquitto.so.1.6.3
│   └── libssl.so.1.0.0
├── sbin
│   ├── mosquitto // mosquitto服务端
```



### 命令安装

因为我使用的是ubuntu系统，为了简单，也可以直接使用命令安装，这里根据ubuntu系统版本会安装对应版本的mosquitto，并且不用考虑依赖问题。不过，命令行安装我看只有1.4.X版本。

```shell
# apt install mosquitto
```

## 启动服务端

### 启动命令

```shell
mosquitto [-c config file] [ -d | --daemon ] [-p port number] [-v]

-c 配置文件路径
-p 指定端口，默认1883，监听端口最好配置在配置文件中
-d 后台启动
-v 打印全部日志，等于配置文件中的 log_type=all
```

启动服务端（关于启动的配置文件参数，参考另一篇关于配置文件mosquitto.conf的文档。）


```shell
# mosquitto -c /etc/mosquitto/mosquitto.conf
```

## 测试

### 订阅

订阅主题为mqtt的消息

```shell
# mosquitto_sub -t "mqtt"
```

### 发布

（再起一个终端）发布内容为 "hello world"到主题mqtt，切到监听端的终端就能看到收到消息了

```shell
# mosquitto_pub -t "mqtt" -m "hello world"
```


### 连接test.mosquitto.org

前面我们使用mosquitto来创建服务，如果有公用的服务器（如test.mosquitto.org），那么只需要使用mosquitto_sub和mosquitto_pub来发布订阅即可。

订阅端

```shell
// 恰逢IG夺冠，来，订阅一波IG
# root@ubuntu:~# mosquitto_sub -h test.mosquitto.org -t "IG"
b
c
```

发布端

```shell
root@ubuntu:~# mosquitto_pub -h test.mosquitto.org -t "ig" -m "a"    
root@ubuntu:~# mosquitto_pub -h test.mosquitto.org -t "IG" -m "b"  
root@ubuntu:~# mosquitto_pub -h test.mosquitto.org -t "IG" -m "c"      
root@ubuntu:~# 
```

可以发现，发布端使用 -t "ig" -m "a" 并没有被收到，-t "IG" -m "b"才能收到， 说明 -t（topic话题）大小写敏感

## 问题列表

### 编译安装可能遇到的问题

使用make && make install 失败，出现了下面几个问题，

####  make[1]: cc command not found

安装gcc

```shell
# apt install gcc
```

#### 编译找不到openssl/ssl.h

使用apt-get install openssl-xxxx  

```shell
# apt install libssl-dev
```

#### 缺少g++

```shell
# apt-get install g++
```

#### 需要uuid。 uuid/uuid.h: No such file or directory错误

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


#### libwebsockets.h missing from the src directory

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
# apt-install install cmake
```


我就出现了这几个错误，然后使用make && make isntall，可以了。

### 启动问题


#### libwebsockets.so.12: cannot open shared object file: No such file or directory

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

### 发布问题

发布内容为 "hello world"到主题mqtt，

```shell
# mosquitto_pub -t "mqtt" -m "hello world"
```

#### 发布时报错 mosquitto_pub: error while loading shared libraries: libmosquitto.so.1: cannot open shared object file: No such file or directory

mosquitto_pub: error while loading shared libraries: libmosquitto.so.1: cannot open shared object file: No such file or directory

运行下面的命令即可

```shell
# sudo /sbin/ldconfig
```

再次运行

```shell
# mosquitto_pub -t "mqtt" -m "hello world"
```

#### 又报错 Error: The connection was lost.

Error: The connection was lost.

注意此时需要修改配置文件中的一些配置项，就是下面这一个

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

```shell
# mosquitto_pub -t "mqtt" -m "hello world"
```

OK， 这次成功了，切到监听端的终端就能看到收到消息了



## 参考

* [编译中webosocket问题解决参考](https://github.com/eclipse/mosquitto/issues/583)
* [libwebsockets.so.12: cannot open shared object file: No such file or directory](https://blog.csdn.net/houjixin/article/details/79789448)
* [mosquitto官网](http://mosquitto.org/)
* [mosquitto源码](https://github.com/eclipse/mosquitto)
* [MQTT协议组织官网](https://mqtt.org/)

