---
layout: post
permalink: /:year/4cxx9xxxx02743b68622d47eees7b2d0/index
title: 2016-10-18-spring-spring中的bean何时被实例化
categories: [spring]
tags: [spring,bean,初始化]
excerpt:  spring,bean,被实例化
description: spring中的bean何时被实例化
catalog: false
author: 林兴洋
---


spring中bean默认是singleton的，延迟加载为false。即<bean  scope="singleton”lazy-init="false">

如果想要一个类延迟实例化，那么将其的lazy-init="true"或改变其 scope（类的管理方式）。



**spring在服务器启动时就将所有的singleton的bean提前实例化**，这个是在web.xml中配置的ContextLoaderListener做的。

![图](https://img-blog.csdnimg.cn/img_convert/aeff144baff5ecd217e35955983b0dd8.png)


在ssh框架下，新建了3个类，UserDaoImpl,UserServiceImpl,UserAction，他们的空参构造方法中都写了一句话表示本类被初始化了。
测试如下，启动服务器，三句话都被打印出来了，说明这三个bean在服务器启动的时候都被初始化了。

![图](https://img-blog.csdnimg.cn/img_convert/ab6bb64635dbc7cdc2b79651ae87f3da.png)


如果使用单例singleton来管理action的话，如下图，两次调用的是同一个UserAction实例的save()方法
![图](https://img-blog.csdnimg.cn/img_convert/a6ceca1c775e92d3b4106e310c372fd7.png)


但是因为struts2的action是不是单例的，线程安全的，效率比较低。修改UserAction的scope为prototype原型，启动服务器，发现UserAction是没有被初始化的。
![图](https://img-blog.csdnimg.cn/img_convert/b898b00018fd459fa944e1046a1458df.png)

再次两次访问save方法。发现使用了prototype之后，生成两个UserAction实例
![图](https://img-blog.csdnimg.cn/img_convert/55bb10fc698da0226cf8f6285cb2c8b8.png)

继续修改代码，将UserService的lazy-init设置为ture。如下图，可以发现，现在只有UserDaoImpl被初始化了
![图](https://img-blog.csdnimg.cn/img_convert/1b1b4d23ebceeb777fe1fdd129327e87.png)

修改了一下UserAction，在其中调用了UserService的save方法。此时访问save()方法，可以发现UserServiceImpl被初始化了。
spring文档：需要说明的是，如果一个bean被设置为延迟初始化，而另一个非延迟初始化的singleton bean依赖于它，那么当ApplicationContext提前实例化singleton bean时，它必须也确保所有上述singleton 依赖bean也被预先初始化，当然也包括设置为延迟实例化的bean。因此，如果Ioc容器在启动的时候创建了那些设置为延迟实例化的bean的实例，你也不要觉得奇怪，因为那些延迟初始化的bean可能在配置的某个地方被注入到了一个非延迟初始化singleton bean里面。
![图](https://img-blog.csdnimg.cn/img_convert/3748a377f7afdf32a836a0863406c6f2.png)


总结
* spring管理的bean在默认情况下是会在服务器启动的时候初始化的。
* bean设置了scope为prototype（原型）之后，会每次使用时生产一个
* bean设置了lazy-init="true"后，启动服务器不会马上实例化，而是在用到的时候被实例化。
* 一个延迟实例化类被注射到一个非延迟实例化类中，也会在服务器其实时进行初始化

