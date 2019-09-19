---
layout: post
permalink: /:year/4c58xxvv202743b68622d47e6587b2d0
title: 2018-01-20-ssm-mysql-socket_time_out
categories: [编程]
tags: [java,mysql,ssm]
excerpt:  问题解决,mysql,ssm,socket_time_out
description: web项目中mysql报错socket_time_out
gitalk-id: 4c58xxvv202743b68622d47e6587b2d0
toc: true
---


在使用连接池的时候，发现当长时间不访问应用后再去访问，会产生 socket time out 这个错误。

在数据库连接配置中加入这一条每60测试连接一下数据库，这样就不会导致长时间不连接而发生那个错误。

```
<!-- 每60秒检查所有连接池中的空闲连接.Default:0 -->  
<property name="idleConnectionTestPeriod" value="${jdbc.idleConnectionTestPeriod}"/> 
```

数据库配置

```
JDBC.DriverName=com.mysql.jdbc.Driver
JDBC.URL=jdbc\:mysql\://localhost\:3306/websale
JDBC.User=root
JDBC.Password=123456

POOL.MaxSize=150
POOL.MinSize=10
POOL.initPoolSize=20
POOL.acquireIncrement=6
POOL.idleConnectionTestPeriod=60
```

spring配置文件中加载该配置

```
    <!-- 数据源配置 -->
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <property name="driverClass" value="${JDBC.DriverName}"/>
        <property name="jdbcUrl" value="${JDBC.URL}"/>  
        <property name="user" value="${JDBC.User}"/>
        <property name="password" value="${JDBC.Password}"/>
        <property name="maxPoolSize" value="${POOL.MaxSize}"/>
        <property name="minPoolSize" value="${POOL.MinSize}"/>
        <property name="idleConnectionTestPeriod" value="${POOL.idleConnectionTestPeriod}"></property>
    </bean>
```
