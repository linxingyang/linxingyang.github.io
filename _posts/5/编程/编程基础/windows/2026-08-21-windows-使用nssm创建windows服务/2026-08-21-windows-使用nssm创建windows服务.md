---
layout: post
published: true
toc: true
title: 使用nssm创建windows服务
description:
date: 2026-10-21T17:31:53.157Z
tags:
  - 编程/编程基础/windows
editor: markdown
dateCreated:
location:
---

# NSSM = Non-Sucking Service Manager

"不坑人的服务管理器"，它是 Windows 上的一个小工具，能把任何程序注册成 Windows 服务。

## 历史

为什么叫 "Non-Sucking"？因为Windows自带的srvany把程序注册成服务体验极差，作者 Iain Patterson 在 [nssm.cc](https://nssm.cc/) 首页的原话：

> nssm is a service helper which doesn't suck. srvany and other service helper programs suck because they **don't handle failure of the application** running as a service. If you use such a program you may see a service listed as started when in fact the application has died. nssm monitors the running service and will restart it if it dies. With nssm you know that if a service says it's running, it really is.

- 初始动机：应用的错误情况未处理，应用死了没人管也不会重启，服务还显示运行中。
- 后续版本：逐步加入日志捕获、优雅停止、环境变量、GUI。
- 对标对象：NSSM 真正替代的是 srvany（README 自述 "similar to srvany and cygrunsrv"），以及 cygrunsrv（要装整个 Cygwin）、FireDaemon（商业收费）这类同类工具。
- 为什么活到现在：微软从 2003 RK 之后就没再更新过 srvany，官方一直没补上这块空缺；NSSM 免费、单文件 300KB、无依赖，所以最后正式版停在 2014（2.24）仍被广泛使用。
## 特性

| 特性           | 说明                                                         |
| ------------ | ---------------------------------------------------------- |
| 支持任意可执行文件    | `.exe`、`.bat`、`.cmd`、Python 脚本、Java JAR、Node.js 应用等均可注册为服务 |
| 自动重启（守护进程）   | 程序崩溃后可自动重启，配置重启延迟，这是 `sc.exe` 和 `srvany` 所不具备的             |
| I/O 重定向与日志轮转 | 可将 stdout/stderr 重定向到文件，支持日志文件轮转（rotate），方便排查问题            |
| GUI + 命令行双模式 | 提供 `nssm install <服务名>` 的图形化配置界面，也支持纯命令行操作，适合自动化脚本         |
| 环境变量自定义      | 可为服务设置专属环境变量                                               |
| 无需安装         | 单文件 `nssm.exe`，绿色免安装，32/64 位均可使用                           |
| 开源免费         | 社区活跃，稳定可靠（最后稳定版本 2.24，历经多年验证）                              |

## 对比

| 特性     | NSSM        | sc.exe（系统自带） | srvany（Resource Kit） | WinSW  |
| ------ | ----------- | ------------ | -------------------- | ------ |
| 易用性    | ⭐⭐⭐⭐⭐       | ⭐⭐           | ⭐⭐                   | ⭐⭐⭐    |
| GUI 配置 | ✅           | ❌            | ❌                    | ❌      |
| 自动重启   | ✅           | ❌（需额外配置恢复策略） | ❌                    | ✅      |
| 日志重定向  | ✅ 内置轮转      | ❌            | ❌                    | ✅      |
| 任意程序支持 | ✅           | ⚠️（仅原生服务程序）  | ✅（但配置繁琐）             | ✅      |
| 配置方式   | 命令行/注册表/GUI | 命令行          | 注册表编辑（繁琐）            | XML 文件 |
| 开源     | ✅           | 系统内置         | ❌                    | ✅      |

- **vs `sc.exe`**：`sc.exe` 只能注册原生 Windows 服务程序，对于普通 EXE/脚本无能为力，且参数配置复杂、不支持日志重定向和自动重启。NSSM 完美弥补了这些不足。
- **vs `srvany`**：`srvany` 是老牌方案，但需要手动编辑注册表，配置繁琐且容易出错，不支持自动重启和日志管理。NSSM 是它的现代替代品。
- **vs `WinSW`**：WinSW 通过 XML 文件配置，适合需要版本控制的场景（如 CI/CD），但配置不如 NSSM 直观，且需要 .NET 运行时环境。NSSM 更轻量、更适合快速部署。

# 下载

官网：**[https://nssm.cc](https://nssm.cc/)**，就一个 300KB 的 exe，下载后放到 `C:\Windows\System32\` 或任意 PATH 目录

# 命令

|分类|命令|语法|中文注释|
|:--|:-:|:--|:--|
|安装服务（GUI）|install|`nssm install [<servicename>]`|打开服务安装图形界面，可选指定服务名称|
|安装服务（静默）|install|`nssm install <servicename> <app> [<args> ...]`|无需确认直接安装服务，指定服务名、应用程序路径及启动参数|
|编辑服务|edit|`nssm edit <servicename>`|打开服务编辑图形界面，修改已有服务的配置|
|参数管理|get|`nssm get <servicename> <parameter> [<subparameter>]`|查询（获取）服务的某个参数值，支持子参数|
||set|`nssm set <servicename> <parameter> [<subparameter>] <value>`|设置（修改）服务的某个参数值，支持子参数|
||reset|`nssm reset <servicename> <parameter> [<subparameter>]`|重置服务的某个参数为默认值，支持子参数|
|移除服务（GUI）|remove|`nssm remove [<servicename>]`|打开服务卸载图形界面，可选指定服务名称|
|移除服务（静默）|remove|`nssm remove <servicename> confirm`|无需确认直接卸载（移除）指定服务|
|服务管理|start|`nssm start <servicename>`|启动指定服务|
||stop|`nssm stop <servicename>`|停止指定服务|
||restart|`nssm restart <servicename>`|重启指定服务|
||status|`nssm status <servicename>`|查看指定服务的运行状态|
||rotate|`nssm rotate <servicename>`|轮转（切换）服务的日志文件，常用于日志滚动|

# 示例：把 Python 静态服务器注册成服务

## 1、准备目录和文件

### index.html

![](5/编程/编程基础/windows/2026-08-21-windows-使用nssm创建windows服务/assets/Pasted%20image%2020261022115615.png)


```
<h1> hello nssm </h1>
<p> website run as windows services. </p>
```

### log目录


创建两个空文件

![](5/编程/编程基础/windows/2026-08-21-windows-使用nssm创建windows服务/assets/Pasted%20image%2020261022115722.png)

## 2、安装服务

获取python的安装路径

```powershell
# 查看并记下 python.exe 的完整路径
PS C:\Users\linxingyang> (Get-Command python).Source
>>
C:\Python311\python.exe
```

### 命令行方式

```powershell
# 使用你的python路径
nssm install demo-http C:\Python313\python.exe "-m http.server 8899"

# 设置工作目录
nssm set demo-http AppDirectory D:\linxingyang\workspace\2026-10-21-nssm-example\webroot 
# 设置日志文件
nssm set demo-http AppStdout D:\linxingyang\workspace\2026-10-21-nssm-example\log\access.log  
nssm set demo-http AppStderr D:\linxingyang\workspace\2026-10-21-nssm-example\log\error.log
```

### GUI方式

1、启动GUI方式安装服务

```
nssm install demo-http
```

2、在Application标签页填入基本信息
- python.exe路径
- webroot
- 参数

3、在I/O标签页填入日志路径
- Output，正常日志
- Error，异常日志

4、点击Install service


![](5/编程/编程基础/windows/2026-08-21-windows-使用nssm创建windows服务/assets/Pasted%20image%2020261022115951.png)

![](5/编程/编程基础/windows/2026-08-21-windows-使用nssm创建windows服务/assets/Pasted%20image%2020261022114359.png)


## 3、启动服务

```
# 启动服务（需要管理员权限运行的cmd或者ps执行）
nssm start demo-http

# 查看服务状态
nssm status demo-http
```

![](5/编程/编程基础/windows/2026-08-21-windows-使用nssm创建windows服务/assets/Pasted%20image%2020261022142935.png)

## 4、浏览器访问


![](5/编程/编程基础/windows/2026-08-21-windows-使用nssm创建windows服务/assets/Pasted%20image%2020261022143053.png)


## 5、删除服务

```powershell
nssm stop demo-http
nssm remove demo-http confirm
```

