---
layout: post
permalink: /:year/cb7c9049036a4fa7a973b2052f96e231
title: 2018-10-02-mysql-2002错误Can't connect to local MySQL server through socket
categories: [mysql]
tags: [mysql,错误2002]
excerpt:  mysql,错误2002
description: mysql-2002错误Can't connect to local MySQL server through socket
header-img: "img/post/bg-cup.jpg"
---




今天玩阿里云上的mysql，遇到了这个问题，其实挺早就看到这个问题，但是只是本机无法登陆，远程还是可以访问，所以之前没解决。

```
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock'
```

想了想，先把这行注释掉试试，打开自己的mysql配置文件，

```
// 这是我的配置文件路径，你的要看自己的路径
# vim /etc/mysql/mysql.conf.d/mysqld.cnf 
```

把[mysql_safe]下面的socket注释掉，如下

```
[mysqld_safe]
#socket         = /var/run/mysqld/mysqld.sock
```


然后再次启动mysql，还是没启动起来

查看一下mysql的错误日志，日志的路径就看你的mysql配置文件中的log_error一项

```
log_error = /var/log/mysql/error.log
```

打开后，发现其中有几行ERROR，发现说的是mysql在`/var/run/mysqld/`文件夹下不能创建mysqld.sock.lock文件。那就猜是mysql对于那个文件夹(mysqld)没有权限

```

2018-10-02T15:36:57.072472Z 0 [Note]   - '0.0.0.0' resolves to '0.0.0.0';
2018-10-02T15:36:57.072649Z 0 [Note] Server socket created on IP: '0.0.0.0'.
2018-10-02T15:36:57.072822Z 0 [ERROR] Could not create unix socket lock file /var/run/mysqld/mysqld.sock.lock.
2018-10-02T15:36:57.072966Z 0 [ERROR] Unable to setup unix socket lock file.
2018-10-02T15:36:57.073107Z 0 [ERROR] Aborting

2018-10-02T15:36:57.073246Z 0 [Note] Binlog end
2018-10-02T15:36:57.073426Z 0 [Note] Shutting down plugin 'ngram'

```

那就给权限吧，执行如下命令

给予mysql组权限，还是起不来，
```
# chgrp mysql /var/run/mysqld/
```

直接把文件的拥有者改成mysql

```
# chown mysql /var/run/mysqld/
```

现在这个文件夹的拥有者和所有组都是mysql了。
```
root@iZbp1ccq9xttkzab5d3fc9Z:/var/run# ll
drwxr-xr-x  2 mysql mysql  100 Oct  2 23:48 mysqld/
```

再启动，就成功了


回过头来想想，又到配置文件中把刚刚注释掉哪行去掉，重启了一下，还是成功了~~~那说明这个问题原来也是文件没有权限的原因。

```
[mysqld_safe]
socket          = /var/run/mysqld/mysqld.sock
```


另：过程中主要用这两个命令来观察mysql是否启动

```
观察3306端口是否启动
# netstat -tunlp | grep 3306  

观察mysql程序是否启动
# ps -ef | grep mysql

```