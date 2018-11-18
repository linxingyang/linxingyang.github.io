---
layout: post
permalink: /:year/60baaf14d2bb4ec89e1a3684d7819b01
title: 2018-11-09-mosquitto-passwd
categories: [mosquitto]
tags: [mosquitto,passwod]
excerpt:  mosquitto,passwd
description: mosquitto,passwod
header-img: "img/post/bg-cup.jpg"
---

[toc]
# mosquitto

## mosquitto_passwd 用户管理

### -c -b 增加，更新用户密码

```
mosquitto_passwd [-c | -D] passwordfile username
-c 增加用户
-D 删除用户
passwordfile 文件名
```

创建用户
```
root@ubuntu:/etc/mosquitto# mosquitto_passwd -c  pwfile.test lxy
Password: 
Reenter password: 
root@ubuntu:/etc/mosquitto# vim pwfile.test         
lxy:$6$OD/jrLb1juS6ww9P$q5wj/3tIN0btT6hgDb+y0TKKq2hm8XsLJ8une9/b+V0UTpHzUZj09lHnXfa1Te+xG5kT2n0Ml
zbrW+4iwTRJTw==
```

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
删除用户
mosquitto_passwd -D /etc/mosquitto/pwfile.example username
```

### -U

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


