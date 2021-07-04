---
layout: post
permalink: /:year/bd7886a8b31e4fae9b51795b33d12sxx/index
title: 2021-02-24-python-TypeError__init__-takes-1-positional-argument-but-5-were-given
categories: [python]
tags: [python,typeerror,take,positional,argument]
excerpt: python,TypeError,init,takes,positional,argument,but,were,given
description: python-TypeError__init__-takes-1-positional-argument-but-5-were-given
---



今天在部署一个Django网站后，在浏览器中访问控制台报了这个错误。
```
TypeError:__init__() takes 1 positional argument but 5 were given
```

根据提示找到那一行，这段代码在另外一台服务器上是没问题的，新部署了一台服务器就有问题。

```python
    def __init__(self):
        self.db = pymysql.connect("192.168.31.111", "root", "123456", "test");
```

查看了一下该方法对应参数说明：
```
pymysql.Connect()参数说明
host(str):      MySQL服务器地址
port(int):      MySQL服务器端口号
user(str):      用户名
passwd(str):    密码
db(str):        数据库名称
charset(str):   连接编码

connection对象支持的方法
cursor()        使用该连接创建并返回游标
commit()        提交当前事务
rollback()      回滚当前事务
close()         关闭连接

cursor对象支持的方法
execute(op)     执行一个数据库的查询命令
fetchone()      取得结果集的下一行
fetchmany(size) 获取结果集的下几行
fetchall()      获取结果集中的所有行
rowcount()      返回数据条数或影响行数
close()         关闭游标对象
```

通过如下修改就可以了，**猜测**是因为没有指定对应参数造成了混乱，可能新旧版本之间有不同。
```python
    def __init__(self):
        # 连接数据库
        self.db = pymysql.connect(
            host="192.168.31.111",
            user="root",
            password="123456",
            db="test"
        )
```



## 参考

* [pymysql.connect()参数说明](https://blog.csdn.net/xiaosongshupy/article/details/78462553)




