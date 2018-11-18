---
layout: post
permalink: /:year/4cxx9qvvv0sssssc8622d47e658vxdsd
title: 2018-05-10-openfire-eclipse中部署openfire源代码
categories: [openfire]
tags: [openfire,eclipse,部署,openfire源代码]
excerpt:  openfire,eclipse,部署,openfire源代码
description: openfire-eclipse中部署openfire源代码

---

# openfire-源代码部署 #

## 1、环境准备： ## 
* eclipse-kepler开普勒版本
* JDK1.7
* Openfire源码，版本4.0.4。于 [http://www.igniterealtime.org/index.jsp](http://www.igniterealtime.org/index.jsp) 下载


## 2、步骤 ##

### （1）下载源码后进行解压。 ### 
### （2）重命名 ### 

在windows系统中，点击win+R，输入cmd，回车，进入命令行控制台。然后进入解压后目录下，使用rename命令将其中 settings, classpath, project重命名为前面加个.（点）。

```

rename project .project

```

如图

![http://image.linxingyang.net/image/note/2018-05-10-webim/02.png](http://image.linxingyang.net/image/note/2018-05-10-webim/02.png)




### （3）将Openfire项目导入eclipse中。 ### 

导入后，发现报错提示有些
lib不见了，直接remove掉。

![http://image.linxingyang.net/image/note/2018-05-10-webim/03.png](http://image.linxingyang.net/image/note/2018-05-10-webim/03.png)


### （4）将项目中build/lib文件夹下及其子文件夹中所有的包都导入到项目中。   ###


![http://image.linxingyang.net/image/note/2018-05-10-webim/04.png](http://image.linxingyang.net/image/note/2018-05-10-webim/04.png)



### （5）添加路径 ###

.在Build Path配置中把  
/openfire_src/src/i18n、
/openfire_src/src/
resources/jar、
/openfire_src/build/lib/dist 
文件夹添加到 Source 中，
如图：

![http://image.linxingyang.net/image/note/2018-05-10-webim/05.png](http://image.linxingyang.net/image/note/2018-05-10-webim/05.png)


### （6）运行调试配置 ###

进行run/debug配置。
选中项目，`右键`->`Run As`-> `Run Configurations`。或者debug configuration也行

在打开的Run Configurations面板中，在左侧列表中找到`Java Application`，`右键`->`New`。
此时新建了一个配置。对该配置进行如下设置：（未提及的则默认配置）


```

在Main选项卡中
对于Project，点击Browse...选择项目Opnefire项目。

Main class中填入：org.jivesoftware.openfire.starter.ServerStarter

```

![http://image.linxingyang.net/image/note/2018-05-10-webim/08.png](http://image.linxingyang.net/image/note/2018-05-10-webim/08.png)







```

在Arguments选项卡中
对于VM arguments，填入：
-DopenfireHome="${workspace_loc:openfire_src}/target/openfire"

注意其中的 openfire_src，这个是openfire的项目名称，如果不一样要改。
```

![http://image.linxingyang.net/image/note/2018-05-10-webim/07.png](http://image.linxingyang.net/image/note/2018-05-10-webim/07.png)



在Common选项卡中勾选Debug和Run。然后点击Apply运用该配置，点击close关闭。


![http://image.linxingyang.net/image/note/2018-05-10-webim/09.png](http://image.linxingyang.net/image/note/2018-05-10-webim/09.png)



### （7）使用ant build ### 

配置完后，需要将工程用ant编译一遍。如图，展开项目的build目录->`右键build.xml`文件->`run as`->`ant build...` -> 在targets选项卡中如图勾选openfire->`点击apply`->`点击run`。
至此部署完成，最后控制台输出 Build Success说明部署成功。


![http://image.linxingyang.net/image/note/2018-05-10-webim/10.png](http://image.linxingyang.net/image/note/2018-05-10-webim/10.png)



### （8）部署成功后，运行该服务器。 ###


选中项目，`右键Run as`->`run configurations`->选中我们刚刚新建的那个配置，->点击`run`。

随后在eclipse的Console选项卡会输出一些内容。例如我的显示如下：

```

Openfire 4.0.4 [2017-6-16 20:57:32]
管理平台开始监听 http://lxy:9090

```


#### 如何停止Openfire服务器？ ####


在eclipse的Console中，将光标定位到最后，输入exit即可停止服务，并且控制台会打印相关信息。


不要点击Console选项卡上面的那个小红方块，那等于是强行关机/拔电源。那样openfire结束的流程没有执行完毕，可以会导致一些意外问题。比如一些定时保存的会议室聊天信息进行保存。


### （9） 控制台中访问进行配置 ###

复制http://lxy:9090，在浏览器中进行访问。进行Openfire服务器的配置。

* 语言选择：中文
* 服务器设置：域，即JID中domain部分，可以更改为想要的域。其它不变。
* 数据库设置：如果没有准备外部的数据库，则可以使用嵌入数据库。如果要使用外部数据库，则需要选择数据库类型，输入数据库URL等信息。
* 外形设置：使用默认。
* 管理员账户：登陆该Web控制台使用
* 账号密码，输入密码即可。账号为admin。


配置完成后，即可用admin账号和刚刚设置的密码登陆Web控制台。至此Openfire服务器运行配置完成。