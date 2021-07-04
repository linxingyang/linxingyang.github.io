---
layout: post
permalink: /:year/60baaf14d2bb4ec89e1a3684d7819b01/index
title: 2018-11-09-mqtt-mosquitto-mosquitto_passwd
categories: [mqtt]
tags: [c,c++,mqtt,mosquitto,mosquitto系列]
relative-tags: [mosquitto系列]
excerpt:  mosquitto,passwd
description: mosquitto,passwod
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

## mosquitto_passwd 用户密码管理

```
mosquitto_passwd [-c | -D] passwordfile username
-c 增加用户
-D 删除用户
passwordfile 文件名
```

### -c 创建用户

```
root@ubuntu:/etc/mosquitto# mosquitto_passwd -c pwfile.test lxy
Password: 
Reenter password: 
root@ubuntu:/etc/mosquitto# vim pwfile.test         
lxy:$6$OD/jrLb1juS6ww9P$q5wj/3tIN0btT6hgDb+y0TKKq2hm8XsLJ8une9/b+V0UTpHzUZj09lHnXfa1Te+xG5kT2n0Ml
zbrW+4iwTRJTw==
```

###  -b  直接创建带密码用户/更新用户密码

直接创建带密码的用户，因为密码会显示在控制台，所以不推荐

```
mosquitto_passwd -b passwordfile username password 
例
mosquitto_passwd -b /etc/mosquitto/pwfile.example lxy abc
```

更新密码也可用这个
```
mosquitto_passwd -b /etc/mosquitto/pwfile.example username password 
```


### -D 删除用户

```
mosquitto_passwd -D /etc/mosquitto/pwfile.example username
```

### -U 更新明文文件为密码加密文件

使用-U可以让原来明码的密码变成hash密码。

注意：它不会检测一份密码文件是否已经加密，所以如果对一份已经hash加密的密码文件再次加密，会使得这份密码文件不能再用。

```
root@ubuntu:/etc/mosquitto# vim pwfile.test 
lxy:123
lts:456
dwp:123
root@ubuntu:/etc/mosquitto# mosquitto_passwd -U pwfile.test 
root@ubuntu:/etc/mosquitto# vim pwfile.test 
lxy:$6$SPFacwqt9GCeQgIc$j8QVIonW3QPlcWwkbEBnTt7pDyyD6bPG2Vc0Qw9lx8rQenou0wrqQ+o9EiEZhZx3OhEuyaWzq
D4hBU3Mgme3EA==
lts:$6$nqS7QQ4C8dEh0K0r$MhXYSGsFlO2FKAKiOVGDz5OEVdAC414rXS9IiyAQwRvIEjxmwJbiw5AbhjSpnD2lJK2S9ETJ6
4RU7LKZZbuy4g==
dwp:$6$eJBwDrMMKCy+onuA$tzH1J1z6Jhd7qSHxkNXOIAfk4oG4YYIQOj05NGBlJyXQ1ssE+feidK0auDvgxm8OJvIBg6rA3
729r87mUQSWQQ==
~               
```


