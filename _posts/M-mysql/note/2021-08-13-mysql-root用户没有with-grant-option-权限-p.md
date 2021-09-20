---
layout: post
permalink: /:year/linxingyangwriteat20210919043707/index
title: 2021-08-13-mysql-root用户没有with-grant-option-权限
categories: [mysql]
tags: [post, mysql]
date: 2021-08-13 04:37:07 +8
editdate: 2021-08-13 04:37:07 +8
eidtplace: 福州软件园
excerpt: mysql,root用户,with-grant-option,权限
description: mysql-root用户没有with-grant-option-权限
catalog: true
author: 林兴洋
---


## root用户没有WITH-GRANT-OPTION导致赋权失败

赋权的时候发现root没有GRANT权限导致赋权失败。

```mysql
mysql> grant all on wvn.* to 'wvn'@'localhost' identified by '123456';
ERROR 1044 (42000): Access denied for user 'root'@'localhost' to database 'wvpn'
```


查看权限。

```mysql
mysql> show grants;
+--------------------------------------------------------------+
| Grants for root@localhost                                    |
+--------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost'            | <-- 没有 with grant option
| GRANT PROXY ON ''@'' TO 'root'@'localhost' WITH GRANT OPTION |
+--------------------------------------------------------------+

mysql> select user, host, Grant_priv from mysql.user;
+------------------+---------------+------------+
| user             | host          | Grant_priv |
+------------------+---------------+------------+
| root             | 192.168.1.137 | Y          |
| mysql.session    | localhost     | N          |
| mysql.sys        | localhost     | N          |
| debian-sys-maint | localhost     | Y          |
| root             | localhost     | N          | <-- 没有 with grant option
| root             | 192.168.1.224 | N          | <-- 没有 with grant option
| root             | 192.168.1.136 | N          | <-- 没有 with grant option
| wvn              | localhost     | N          |
+------------------+---------------+------------+
8 rows in set (0.00 sec)
```



那就来赋权，因为当前用户就是root用户，可以为所欲为。

```mysql
mysql> update mysql.user set Grant_priv='Y' where user='root';
Query OK, 3 rows affected (0.00 sec)
Rows matched: 4  Changed: 3  Warnings: 0
```

```mysql
mysql> select user, host, Grant_priv  from mysql.user;
+------------------+---------------+------------+
| user             | host          | Grant_priv |
+------------------+---------------+------------+
| root             | 192.168.1.137 | Y          |
| mysql.session    | localhost     | N          |
| mysql.sys        | localhost     | N          |
| debian-sys-maint | localhost     | Y          |
| root             | localhost     | Y          | <-- 有了
| root             | 192.168.1.224 | Y          | <-- 有了
| root             | 192.168.1.136 | Y          | <-- 有了
| wvn              | localhost     | N          |
+------------------+---------------+------------+
```


刷新权限，退出。

```mysql
mysql> flush privileges;
mysql> quit;
```

然后重新登录，即可成功赋权。
```mysql
mysql> grant all on wvn.* to 'wvn'@'localhost' identified by '123456';
Query OK, 0 rows affected, 1 warning (0.02 sec)
```


## 参考

* [mysql的root用户没有grant权限](https://blog.csdn.net/langkeziju/article/details/53099984)

