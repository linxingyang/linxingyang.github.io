---
layout: post
permalink: /:year/bc31285213a44799bf9772ff27af7a42
title: 2019-03-18-shadowsocks-代理设置
categories: [工具]
tags: [shadowsocks]
excerpt: shadowsocks,代理设置
description: shadowsocks代理设置
gitalk-id: bc31285213a44799bf9772ff27af7a42
toc: true
---

> ss是一种基于Socks5代理方式的加密传输协议，也可以指实现这个协议的各种开发包。
> -- wiki

# ss安装与自己所处网络状况下的实践

## 安装ss服务端过程

### 下载

debian/ubuntu
```
apt-get install python-pip
pip install git+https://github.com/shadowsocks/shadowsocks.git@master
```

centos
```
yum install python-setuptools && easy_install pip
pip install git+https://github.com/shadowsocks/shadowsocks.git@master
```

如果是CentOS7,可能需要AEAD加密，需要安装libsodium
```
dnf install libsodium python34-pip
pip3 install  git+https://github.com/shadowsocks/shadowsocks.git@master
```

### 安装

```
snap install shadowsocks
```

### 启动

ss有两种启动的方式，ssserver和sslocal。ssserver是将该ss作为服务端，向外部提供服务，sslocal是将该ss作为客户端，需要连接一个ss服务器，可以向外提供socks5服务。

二者的配置文件是有差别的。

#### ssserver与配置文件

shadowsocks.json的配置文件位于`/etc/shadowsocks.json`，对于ssserver的配置文件
```
# vi /etc/shadowsocks.json
{
    "server":"0.0.0.0",
    "server_port":监听端口号, # 外界使用ss客户端连接时使用的端口
    "local_address": "127.0.0.1", # 本地IP
    "local_port":1080, # 本地端口
    "password":"密码", 
    "timeout":300,
    "method":"加密方式 (chacha20-ietf-poly1305 / aes-256-cfb)",
    "fast_open": false
}
```

对于服务器来说，
* server：表示可访问的客户端IP，"0.0.0.0"表示接受所有IP的连接，
* server_port：其监听的端口，可以设置值
* local_address：本机可接收的IP
* local_port：本地端口

ssserver表示监听server_port，等待IP符合server条件的客户端的连接。本地监听local_port（通常是1080）端口，等待IP符合local_address（此处尝试设置为"0.0.0.0"是不行的，只能127.0.0.1，故而只向本机内部开放，这是我当前的理解，没有详细验证，可能有误）条件的客户端的连接。

服务器启动方式
```
/usr/local/bin/ssserver -c /etc/shadowsocks.json -d start
```

一般情况下我们只用到ssserver，用来向内网/墙内的客户端提供服务。

#### sslocal与配置文件

对于sslocal的配置文件
```
# vi /etc/shadowsocks.json
{
    "server":"服务器端IP",
    "server_port":服务端端口号,
    "local_address": "0.0.0.0", 
    "local_port":1080, #
    "password":"密码", 
    "timeout":300,
    "method":"加密方式 (chacha20-ietf-poly1305 / aes-256-cfb)",
    "fast_open": false
}
```

对于客户端来说
* server：表示服务端的IP
* server_port：表示服务端监听的端口号
* local_address：表示本机可接受的IP，可以设置成"0.0.0.0"表示接受所有客户端连接
* local_port：表示本机代理的端口，通常是1080

sslocal表示连接到server:server_port服务器，并且自己也监听local_port(通常是1080)，等待IP符合local_address（和ssserver不同的是，此处可以设置为"0.0.0.0"，这也是为什么我后面的那个例子能够成功的原因）的客户端的连接。

说这个就是要注意一下ssserver和sslocal的区别。


Python 版客户端命令是 sslocal ， Shadowsocks-libev 客户端命令为 ss-local
```
/usr/local/bin/sslocal -c /etc/shadowsocks.json -d start
```

### 停止

如果需要停止，找到对应的PID，杀之即可

```
ps -ef|grep shadowsocks 
kill [对应的PID]
```

## 我的情况

我的情况是这样的
* 国外服务器，可科学上网
* 国内服务器，可百度
* 公司内网，内网被禁，但是可以访问国内服务器，不可访问国外服务器。

我想要即可访问国内百度，又可科学上网。

先通过上面的方式，在国外服务器和国内服务器安装上ss。

### 只使用国内服务器

国内服务器，启动ssserver
```
# cat /etc/shadowsocks.json 
{
    "server":"0.0.0.0",
    "server_port":15481,
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"your password one",
    "timeout":300,
    "method":"aes-256-gcm",
    "fast_open":false
}
# nohup /usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json &
```

此时，国内服务器监听15481（server_port）端口，可接受所有客户端的连接（server为"0.0.0.0"）。


那么我想要用上这个ss服务器，

第一种方式只需要在我内网的电脑上装一个ss客户端即可，配置上该服务器的IP，密码，端口，加密等方式就可以连上了。

![图](http://image.linxingyang.net/image/note/2019/2019-03-18-shadowsocks/04.png)


第二种方式，利用了sslocal可以设置local_address为"0.0.0.0"从而接受所有客户端的socks5连接，我在国内服务器上启动一个sslocal
```
# cat /etc/shadowsocks-inside.json
{
    "server":"国内服务器公网IP", # 
    "server_port":15481, # 国内服务器监听端口
    "local_address":"0.0.0.0", # 注意此处，配置成0.0.0.0代表所有客户端可以访问这个服务器的1082端口（local_port配置），因为1080已经被前面启动的ssserver占用了
    "local_port":1082, # 此处配置可访问的端口
    "password":"your password one",
    "timeout":300,
    "method":"aes-256-gcm",
    "fast_open":false
}
# nohup /usr/bin/python /usr/local/bin/sslocal -c /etc/shadowsocks-inside.json &
```

这个时候，我就能在支持socks5代理的微信上配置网络代理，地址填的是国内服务器的IP，端口填的是1082。（另外说一下，如果我们使用了第一种方法shadowsocks，那我们也可以在这里填写地址127.0.0.1以及端口1080，因为第一种的本质也是启动一个shadowsocks的客户端，并且它默认127.0.0.1的1080端口，你看上面的第一种配置方式，里面有个代理端口1080）

![图](http://image.linxingyang.net/image/note/2019/2019-03-18-shadowsocks/05.png)

当然，第二种方法，如果别人知道你的服务器IP以及你开放的端口，就可以来蹭你流量了。

这两种方法选一种就好了，本质是一样的，就是一个在本地装一个ss客户端，一个在服务器装一个ss客户端。

我暂时喜欢第二种，第二种只要服务器端弄好了，本地就不用再下一个shadowsocks的客户端了，至于端口号，可以改的拗一点，别人不好猜，基本上不用担心别人蹭流量。

但是这样，如果要用的方便，比如设置浏览器socks5代理（说实话我也没手动配过），我是用后面介绍的一款谷歌插件来切换的。等等说这个软件，先说说要访问国外服务器怎么做。

### 如果想要访问国外服务器

如果我想使用国外的服务器

相同的，国外服务器启动ssserver
```
# cat /etc/shadowsocks.json 
{
    "server":"0.0.0.0",
    "server_port":15481,
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"your password two",
    "timeout":300,
    "method":"aes-256-gcm",
    "fast_open":false
}
# nohup /usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json &
```

因为国内服务器能访问到国外服务器，所以在国内服务器启动一个sslocal（我暂时没有测试能否多个sslocal串联）。
```
# cat /etc/shadowsocks-outside.json 
{
    "server":"国外服务器IP",
    "server_port":15481, # 国外服务器监听的端口
    "local_address":"0.0.0.0",
    "local_port":1081,
    "password":"your password two",
    "timeout":300,
    "method":"aes-256-gcm",
    "fast_open":false
}
# nohup /usr/bin/python /usr/local/bin/sslocal -c /etc/shadowsocks-outside.json &
```

此处国内服务器暴露1081端口，那么我在内网中连接到国内服务器的1081端口，就可以科学上网了。

do you see the brilliant here?

访问国内网络，国内服务器启动ssserver和sslocal。

访问国外网络，国外服务器启动ssserver，国内服务器启动sslocal。

## 浏览器插件switchy sharp

在内网中，为了方便，下了一个谷歌浏览器的插件SwitchySharp工具，来配置国内服务器的socks5的IP，统一配置socks5。

这个插件百度一下就有了，如果用谷歌加载插件的时候提示不能用，那就把插件后缀名改成rar后进行解压，谷歌再加载未压缩的插件即可。

配置内网和外网的socks5代理

![图](http://image.linxingyang.net/image/note/2019/2019-03-18-shadowsocks/01.png)

![图](http://image.linxingyang.net/image/note/2019/2019-03-18-shadowsocks/02.png)

在谷歌浏览器的右上角进行切换，直接连接默认是内网，国内用来访问百度，国外的用来科学上网。

![图](http://image.linxingyang.net/image/note/2019/2019-03-18-shadowsocks/03.png)

## proxychains

另外想说一下的是proxychain。在windows中，我们主要是看应用本身支不支持socks5，如果支持那就很好办了，直接配上ss服务器的IP和地址。但是在linux中，一般访问网络的程序没有这种可以配置socks5的，这个时候就可以使用proxychains。

### 下载安装

Debian / Ubuntu
```
sudo apt-get install proxychains
```

### 配置文件

编辑 `/etc/proxychains.conf`，修改最后一行。此处的IP和端口根据需要，可配置成访问国内，访问国外的。
```
# 国内
#socks5 [服务端IP] 1082

# 国外
#socks5 [服务端IP] 1081
```

### 使用

接着我们就可以直接 用 proxychains + 命令的方式使用代理，例如
```
proxychains curl xxxx
proxychains wget xxxx

sudo proxychains apt-get xxxx
```

## 手机连接科学上网的笔记本wifi进行科学上网

有的时候，我们在笔记本上科学上网，然后笔记本开启热点分享给手机，但我们在手机却不能科学上网，这里还是那句话，ss是socks5代理，只有通过我们设置的代理端口（通常就是那个1080），才会通过ss进行代理。

在手机中选择当前连接的笔记本的wifi，进行设置，如下配置即可

![图](http://image.linxingyang.net/image/note/2019/2019-03-18-shadowsocks/06.png)

## 参考 

* [ss安装指导](https://github.com/Shadowsocks-Wiki/shadowsocks/blob/master/6-linux-setup-guide-cn.md#5%E5%85%B6%E4%BB%96%E7%A8%8B%E5%BA%8F%E4%BD%BF%E7%94%A8)

