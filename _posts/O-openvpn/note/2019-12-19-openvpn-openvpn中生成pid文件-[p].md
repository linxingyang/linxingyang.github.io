---
layout: post
permalink: /:year/7e5af4deb40e4c168be245b140f378b0/index
title: 2019-12-19-openvpn-openvpn中生成pid文件
categories: [openvpn]
tags: [openvpn,pid]
relative-tags: [openvpn]
excerpt: openvpn,pid
description: openvpn中生成pid文件
catalog: false
---

要生成openvpn的pid文件，在openvpn的配置文件中新增一句（在windows和linux中都可以使用）
```
writepid /path/to/openvpn.pid
```
