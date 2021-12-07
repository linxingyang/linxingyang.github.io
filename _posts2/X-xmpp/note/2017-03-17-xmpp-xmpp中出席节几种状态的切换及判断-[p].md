---
layout: post
permalink: /:year/0abe3e91393643c389b8a6a65xmpp273/index
title: 2017-03-17-xmpp-xmpp中出席节几种状态的切换及判断
categories: [xmpp]
tags: [xmpp,出席节]
excerpt: xmpp,出席节,状态
description: xmpp中出席节几种状态的切换及判断
catalog: true
---

[TOC]

# 几种各种状态切换


## 1，在线

切换到在线。通过priority=1并且没有show则判断为在线

发送在线
```xml
<presence id='presOnline_342d2e245376' xmlns='jabber:client'>
    <status>在线</status>
    <priority>1</priority>
</presence>
```

服务器会广播“我”的在线信息，“我”自己也能收到。后面几种状态也是同样的
```xml
<presence xmlns="jabber:client" id="presOnline_342d2e245376" from="lxy@user-20160421db/3n1yyjs701" to="lxy@user-20160421db/3n1yyjs701">
    <status>在线</status>
    <priority>1</priority>
</presence>
```

## 2，空闲

切换到空闲，通过show=chat判断为空闲

“我”发布自己为空闲
```xml
<presence id='presChat_342d310b01889' xmlns='jabber:client'>
    <status>空闲</status>
    <show>chat</show>
    <priority>1</priority>
</presence>
```

服务器广播的
```xml
<presence xmlns="jabber:client" id="presChat_342d310b01889" from="lxy@user-20160421db/3n1yyjs701" to="lxy@user-20160421db/3n1yyjs701">
    <status>空闲</status>
    <show>chat</show>
    <priority>1</priority>
</presence>
```


## 3，忙碌

切换到忙碌。通过show=dnd（do not disturb）判断为忙碌

```xml
<presence id='presDnd_342d31c702391' xmlns='jabber:client'>
    <status>正忙</status>
    <show>dnd</show>
    <priority>0</priority>
</presence>
```


```xml
<presence xmlns="jabber:client" id="presDnd_342d31c702391" from="lxy@user-20160421db/3n1yyjs701" to="lxy@user-20160421db/3n1yyjs701">
    <status>正忙</status>
    <show>dnd</show>
    <priority>0</priority>
</presence>
```


## 4，离开

切换到离开，通过show=away判断为离开

```xml
<presence id='presAway_342d322f55629' xmlns='jabber:client'>
    <status>离开</status>
    <show>away</show>
    <priority>0</priority>
</presence>
```


```xml
<presence xmlns="jabber:client" id="presAway_342d322f55629" from="lxy@user-20160421db/3n1yyjs701" to="lxy@user-20160421db/3n1yyjs701">
    <status>离开</status>
    <show>away</show>
    <priority>0</priority>
</presence>
```

## 5，隐身

切换到隐身，通过type=unavailable判断为隐身/离线

```xml
<presence id='presOffline_342d32a09a44' type='unavailable' xmlns='jabber:client'>
    <status>Offline</status>
    <priority>0</priority>
</presence>
```

```xml
<presence xmlns="jabber:client" id="presOffline_342d32a09a44" type="unavailable" from="lxy@user-20160421db/3n1yyjs701" to="lxy@user-20160421db/3n1yyjs701">
    <status>Offline</status>
    <priority>0</priority>
</presence>
```
