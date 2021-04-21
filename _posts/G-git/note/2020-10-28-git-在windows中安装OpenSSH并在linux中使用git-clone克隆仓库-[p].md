---
layout: post
permalink: /:year/6c2dd6e6e2a64309add9d19e6fd66639/index
title: 2020-10-28-git-在windows中安装OpenSSH并在linux中使用git-clone克隆仓库
categories: [git]
tags: [git,windows,OpenSSH]
excerpt: git,windows,OpenSSH,linux
description: git-在windows中安装OpenSSH并在linux中使用git-clone克隆仓库
catalog: true
---


[TOC]


# 在Win10中安装OpenSSH并在linux中clone仓库


今天突发奇想，其实也不算啦，就是有这么个想法，想要在linux中clone一下我在windows上建的git仓库，搞了一下记录之。

下面操作需要在win10中PowerShell进行，非win10劝退（win8有PowerShell？搜了一下，还真有，那使用WIN8的童鞋也可以试试）。

## 安装

获取OpenSSH的信息

```
PS C:\Windows\system32> Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'

# 输出如下，目前是有一个客户端和一个服务端版本
Name  : OpenSSH.Client~~~~0.0.1.0
State : NotPresent
Name  : OpenSSH.Server~~~~0.0.1.0
State : NotPresent
```



安装客户端以及服务端及其对应的输出

```
PS C:\Windows\system32> Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

Path          :
Online        : True
RestartNeeded : False


PS C:\Windows\system32> Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

Path          :
Online        : True
RestartNeeded : False
```


## 配置

启动ssh服务，并设置自启动
```
PS C:\Windows\system32> Start-Service sshd 
PS C:\Windows\system32> Set-Service -Name sshd -StartupType 'Automatic' 
```

确认防火墙规则已经配置，默认在安装的时候是会自动创建的。
```
PS C:\Windows\system32> Get-NetFirewallRule -Name *ssh*

Name                  : OpenSSH-Server-In-TCP
DisplayName           : OpenSSH SSH Server (sshd)
Description           : Inbound rule for OpenSSH SSH Server (sshd)
DisplayGroup          : OpenSSH Server
Group                 : OpenSSH Server
Enabled               : True
Profile               : Any
Platform              : {}
Direction             : Inbound
Action                : Allow
EdgeTraversalPolicy   : Block
LooseSourceMapping    : False
LocalOnlyMapping      : False
Owner                 :
PrimaryStatus         : OK
Status                : 已从存储区成功分析规则。 (65536)
EnforcementStatus     : NotApplicable
PolicyStoreSource     : PersistentStore
PolicyStoreSourceType : Local
```

如果没有如上有一条Name为"OpenSSH-Server-In-TCP"的，那么就创建一条。创建语句：

```
PS C:\Windows\system32> New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```


## 登录ssh

就和linux中一样
```
ssh user@server
```

如图在linux上登录了windows上的ssh，如下PP是我windows的用户名，linxy_dkpc是我windows的主机名

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/G-git/image/2020-10-28/01.png)


## 克隆仓库

就跟平常clone ssh仓库一样了，从`/d/linxy/xxx`开始就是仓库的路径了
```
# git clone ssh://PP@linxy_dkpc/d/linxy/home/local-respository/2020-10-28-server-39-15-applications
Cloning into '2020-10-28-server-39-15-applications'...
PP@linxy_dkpc's password: 
warning: You appear to have cloned an empty repository.
Checking connectivity... done.
```


## 移除

```
# 移除客户端
Remove-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# 移除服务端
Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```


## 问题

### 克隆时提示 git-update-pack

[2020-10-28-git-在linux中克隆windows的git仓库时报错-git-upload-pack](http://linxingyang.net/2020/89671ce9dfcd4acdbf8f8ac450c0b500)


## 参考

* [在windows中安装OpenSSH](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)
* [在windows中使用git clone克隆一个ssh协议的git仓库](https://stackoverflow.com/questions/53834304/how-do-i-git-clone-from-a-windows-machine-over-ssh)
* [windows中给OpenSSH配置默认的shell](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_server_configuration#configuring-the-default-shell-for-openssh-in-windows)
