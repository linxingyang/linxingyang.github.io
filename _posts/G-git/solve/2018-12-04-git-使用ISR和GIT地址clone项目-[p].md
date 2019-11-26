---
layout: post
permalink: /:year/89671ce9dfcd4acdbf8f8ac450c0b500
title: 2018-12-04-git-使用ISR和GIT地址clone项目
categories: [工具]
tags: [git]
excerpt:  git,使用ISR和GIT地址,clone项目
description: git-使用ISR和GIT地址clone项目
gitalk-id: 89671ce9dfcd4acdbf8f8ac450c0b500
toc: true
---


今天经理给了我一个ISR文件和一个Git地址(git@192.168.11.120:Whatever/test.git)，让我去clone项目。


想想我玩Github，都是用github账号加邮箱方式来clone项目的。这种方式还真没用过。

直接克隆要密码，没让输入用户名，怪了。

![图](http://image.linxingyang.net/image/G-git/image/2018-12-04/02.png)


百度了一下，发现说确实有两种方式，一种是通过账号密码， 一种是设置SSH key公钥私钥。这么一百度， 想起来，我好像用过 Github for windows，这个当时好像就是用的公钥私钥。。。几百年没配都忘了。。


两种方式。

## 一种是用 git bash 来做。 

windows中，要安装 [git for bash](https://gitforwindows.org/) ,

![图](http://image.linxingyang.net/image/G-git/image/2018-12-04/01.png)




安装好后，到 .ssh文件夹中，把公司给你的ISR丢到这里（如图我的就是id_rsa.linxingyang），然后创建一个config文件，填入如下内容，

![图](http://image.linxingyang.net/image/G-git/image/2018-12-04/03.png)


config文件中内容：

```
host 192.168.11.120
HostName 192.168.11.120
IdentityFile ~/.ssh/id_rsa.linxingyang
User linxingyang
```

host和hostname用git地址中的(git@192.168.11.120:Whatever/test.git)

IdentityFile和config在同一个目录

最后因为我的账号用户名是linxingyang，所以我就写了。测试过，如果不写，也是可以的。

然后直接clone，就可以了

参考[https://superuser.com/questions/232373/how-to-tell-git-which-private-key-to-use](https://superuser.com/questions/232373/how-to-tell-git-which-private-key-to-use)


## 第二种

同事教了另一种，用 tortoiseGit。  （这只小乌龟，想当初用SVN的时候就用的tortoiseSVN，所以一看到倍感亲切啊。哈哈）

也是安装一个tortoiseGit。由于使用的是SSH的key。所以这里需要转换一下。

![图](http://image.linxingyang.net/image/G-git/image/2018-12-04/04.png)


打开这个，点击Load Private Key，加载那个ISR文件，然后点击save private key，生成一个后缀名为ppk的文件

![图](http://image.linxingyang.net/image/G-git/image/2018-12-04/05.png)


然后再加载生成的ppk文件

![图](http://image.linxingyang.net/image/G-git/image/2018-12-04/06.png)


最后在你想要导出项目的文件夹中右键 git clone

![图](http://image.linxingyang.net/image/G-git/image/2018-12-04/07.png)

如图导出即可。

![图](http://image.linxingyang.net/image/G-git/image/2018-12-04/08.png)
