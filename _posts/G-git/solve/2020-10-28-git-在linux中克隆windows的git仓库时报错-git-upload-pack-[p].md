---
layout: post
permalink: /:year/89671ce9dfcd4acdbf8f8ac450c0b500/index
title: 2020-10-28-git-在linux中克隆windows的git仓库时报错-git-upload-pack
categories: [git]
tags: [git,git-update-pack]
excerpt:  git,linux,windows,git-upload-pack
description: git-在linux中克隆windows的git仓库时报错-git-upload-pack
catalog: false
author: 林兴洋
---



如何在windows中安装OpenSSH可以看[2020-10-28-git-在windows中安装OpenSSH并在linux中使用git-clone克隆仓库](https://blog.csdn.net/JKL852qaz/article/details/109347886)



从linux命令行通过OpenSSH clone windows中的仓库失败，报错 

```
# git clone PP@linxy_dkpc:/d/linxy/home/local-respository/2020-10-28-server-39-15-applications

'git-upload-pack' Ҳ

fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```



最简单的方式：默认OpenSSH使用的shell是powershell.exe，将其改为git for windows的bash.exe即可解决这个问题。

```
# 注意bash.exe的路径使用你自己的
PS C:\Windows\system32> New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\linxy\software\git\Git\bin\bash.exe" -PropertyType String -Force

DefaultShell : C:\linxy\software\git\Git\bin\bash.exe
PSPath       : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\OpenSSH
PSParentPath : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE
PSChildName  : OpenSSH
PSDrive      : HKLM
PSProvider   : Microsoft.PowerShell.Core\Registry
```

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/G-git/image/2020-10-28/02.png)



若要恢复回powershell.exe，如下

```
# 注意powershell.exe使用你自己的
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
```



## 参考

* [在windows中安装OpenSSH](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)
* [在windows中使用git clone克隆一个ssh协议的git仓库](https://stackoverflow.com/questions/53834304/how-do-i-git-clone-from-a-windows-machine-over-ssh)

* [windows中给OpenSSH配置默认的shell](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_server_configuration#configuring-the-default-shell-for-openssh-in-windows)

