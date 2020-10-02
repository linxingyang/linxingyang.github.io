---
layout: post
permalink: /:year/8b072ff2a1da49c2be516443334d2aee
title: 2016-06-30-webosocket-websocket协议
categories: [websocket]
tags: [websocket,协议]
excerpt: 协议,websocket
description: 关于websocket协议
catalog: true
author: 林兴洋
---

# 关于websocket协议

## 是什么：

一个双向通信协议，建立在TCP之上，实现了浏览器服务器全双工通信且不需要依赖打开多个HTTP连接，一开始握手需要借助HTTP请求完成。

## 解决的问题：

http只能通过请求/响应的方式交互数据，实时性不强，通过轮询等又增大了流量（报文头比较大），不能主动推送消息给客户端。

BOSH提供了一个HTTP轮询的替代来进行从web页面到远程服务端的双向通信，轮询服务器压力大。

而Websocket（即时消息，游戏应用，股票行情等）报头流量小,服务器和客户端都能主动向对方发送或接收数据。

在 WebSocket API，浏览器和服务器只需要做一个握手的动作，然后，浏览器和服务器之间就形成了一条快速通道。两者之间就直接可以数据互相传送。在此WebSocket协议中，为我们实现即时服务带来了两大好处：

* 1. Header 互相沟通的Header是很小的-大概只有 2 Bytes
* 2. Server Push，服务器的推送，服务器不再被动的接收到浏览器的request之后才返回数据，而是在有新数据时就主动推送给浏览器。


## ajax和websocket的区别

两个用的地方是不同的。

* ajax主要做的事页面局部刷新，它可以做即时通讯，但是要以轮询方式
* websocket重心在信息交互，即时通讯，保持长连接。

## WebsocketHandShake和TCPHandShake的顺序

这是访问一个页面的HTTP请求，可以看到整个过程：建立TCP连接，然后HTTP请求响应，中间红色报文是要求Keep-Alive，但是经过一段时间后，还是断开TCP连接


![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/W-websocket/image/2016-06-30/01.png)

WebSocket连接服务器报文如下，整个过程：
TCP建立连接，然后WebSocket通过HTTP进行握手。（TCP连接并没有断开）

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/W-websocket/image/2016-06-30/02.png)

在调用WebSocket对象的onclose()方法与服务器断开连接的时候，TCP断开连接

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/W-websocket/image/2016-06-30/03.png)

根据上面的报文，TCP连接成功，WebSocket通过HTTP握手成功后，这个TCP就作为WebSocket的通信通道了，WebSocket没有开启一个新的TCP连接。

 TCPhandshake在前， websocket的handshake在后。

## 浏览器中的websocket

如何编程的：握手建立连接--发送信息--关闭连接

客户端  JS代码中：

WebSocket 对象一共支持四个消息 onopen, onmessage, onclose 和 onerror。所有的操作都是采用异步回调的方式触发，这样不会阻塞 UI，可以获得更快的响应时间，更好的用户体验。

* 当 Browser 和 WebSocketServer 连接成功后，会触发 onopen 消息；
* 当 连接失败，发送、接收数据失败或者处理数据出现错误，browser 会触发 onerror 消息；
* 当 Browser 接收到 WebSocketServer 发送过来的数据时，就会触发 onmessage 消息，参数 evt 中包含 Server 传输过来的数据；
* 当 Browser 接收到 WebSocketServer 端发送的关闭连接请求时，就会触发 onclose 消息。
* Browser用函数 send() 向服务端发送数据。
* 用属性 readyState 用以检查连接状态，

##  URI模式语法：

在java中做的时候，
```
@ServerEndpoint(value="/ws")
```
则访问路径
```
ws://localhost:8080/projectname/ws 
```

而用C#做的时候, 
```
WebSocketServer ws = new WebSocketServer();//实例化WebSocketServer
ws.Setup(10.10.123.120,  2014）;  // ip和端口
```
访问路径 ws://localhost:2014 

```
"ws:""//" authority path-abempty["?" query]  使用WebSocket协议打开一个连接
"wss:""//" authority path-abempty["?" query]  使用WebSocket协议打开一个使用TLS的连接
path-abempty , query 由服务器来确定，所以对于c#和java是有区别的
```

## Java中使用webscoket例子

使用websocket要求tomcat 1.7或以上。

wireshark的版本也要比较高，不然抓不到websocket的包，还有本机如果开启了防火墙，可能也会因为这个访问不到。

eclipse中新建一个web项目 TestWS（这个名称要作为访问的一部分）

### 服务器端代码 

新建一个类WebSocketTest，作为服务器端的WS类。

```java
package ws;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

@ServerEndpoint("/ws")
public class WebSocketTest {
	
	@OnOpen
	public void onOpen(Session session) {
		System.out.println(session.getId() + "打开了连接");
	}

	@OnClose
	public void onClose() {
		System.out.println("关闭了连接");
	}

	@OnMessage
	public void onMessage(String msg, Session session) throws Exception {
		System.out.println("客户端发来了消息" + msg);
		// 给客户端发送消息
		session.getBasicRemote().sendText("我是服务器，我收到了:" + msg);
	}

	@OnError
	public void onError(Session session, Throwable error) {
		System.out.println("发生了错误");
		error.printStackTrace();
	}
}
```

### 客户端代码

客户端访问服务器ws的路径：ws://localhost:8080/TestWS/ws 这个链接由ws开头，TestWS就是web项目的名称，ws就是@ServerEndpoint("/ws")注解的中的ws

```jsp
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
    <head>
        <base href="<%=basePath%>">
        <title>WS测试</title>
    </head>
    <body>
        <div>
		       访问路径：
		       <input type="text" value="ws://localhost:8080/TestWS/ws" id="addrid"/>
		       <input type="button" value="打开连接" onclick="openCon()" />
		       <input type="button" value="关闭连接" onclick="closeCon()" /><br>
		       <input type="text" id="msgid" />
		       <input type="button" value="发送消息" onclick="sendMsg()" />
		   </div>
		   <div id="msg"></div>
    <script type="text/javascript">
        var ws = null;
        function closeCon() {
            ws.close();
        }
        function openCon() {
            // 初始化
            var addr = document.getElementById("addrid").value; 
            
            if('WebSocket' in window) {
            	log("尝试连接服务器：" + addr);
                ws = new WebSocket(addr);
            } else {
                alert("该浏览器不支持WebSocket对象");
                return;
            }
            // 绑定事件
            ws.onopen = function(evt) {
                log("连接服务器成功！");
            };
            ws.onerror = function(evt) {
            	log("连接服务器失败！");
            };
            ws.onmessage = function(evt) {
            	log("从服务器收到：" + evt.data);
            };
            ws.onclose = function(evt) {
            	log("关闭了与服务器的连接！");
            };
        }
        function log(msg) {
        	document.getElementById("msg").innerHTML += msg + "<br>";
        } 
        function sendMsg() {
            var msg = document.getElementById("msgid").value;
            log("客户端发送：" + msg);
            ws.send(msg);
        }
    </script>
    </body>
</html>
```

### 结果

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/W-websocket/image/2016-06-30/04.png)

## C#中使用Websocket

环境是VS2012

要添加SuperWebSocket，（服务器用的）。右键项目

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/W-websocket/image/2016-06-30/05.png)

安装第二个，第一次安装过程比较久，后面要用就比较方便了。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/W-websocket/image/2016-06-30/06.png)

### 服务器

```C#
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SuperWebSocket;

namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {

            ChatWebSocket wsServer = new ChatWebSocket();
            wsServer.Start();
            Console.ReadKey();
            wsServer.Stop();
            Console.WriteLine("服务已经关闭");
            Console.ReadKey();

        }
    }
}
```

```c#
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SuperWebSocket;

namespace ConsoleApplication1
{
    class ChatWebSocket
    {
        //private const string ip = "127.0.0.1";
        private const string ip = "10.10.123.120";
        private const int port = 2014;
        private WebSocketServer ws = null; // SuperWebSocket中的WebSocketServer对象
        private int num = 1;
        private Dictionary<String, String> visits = new Dictionary<string, string>();

        public ChatWebSocket()
        {
            ws = new WebSocketServer();// 实例化WebSocketServer

            // 添加事件侦听
            ws.NewSessionConnected += ws_NewSessionConnected; // 有新会话握手并连接成功
            ws.SessionClosed += ws_SessionClosed; // 有会话被关闭 可能是服务端关闭 也可能是客户端关闭
            ws.NewMessageReceived += ws_NewMessageReceived; // 有客户端发送新的消息
        }


        // 新的游客连接进聊天室
        void ws_NewSessionConnected(WebSocketSession session)
        {
            visits.Add(session.SessionID, "游客" + num++);
            Console.WriteLine("{0:HH:MM:ss}  {1}创建新会话", DateTime.Now, visits[session.SessionID]);
            // Console.WriteLine(session.SessionID);
            var msg = string.Format("{0:HH:MM:ss} {1} 进入聊天室", DateTime.Now, visits[session.SessionID]);
            SendToAll(session, msg);
            AllVisit(session);
        }

        // 退出聊天室
        void ws_SessionClosed(WebSocketSession session, SuperSocket.SocketBase.CloseReason value)
        {
            Console.WriteLine("{0:HH:MM:ss}  与客户端:{1}的会话被关闭 原因：{2}", DateTime.Now, visits[session.SessionID], value);
            var msg = string.Format("{0:HH:MM:ss} {1} 离开聊天室", DateTime.Now, visits[session.SessionID]);
            SendToAll(session, msg);
        }

        // 发送消息
        void ws_NewMessageReceived(WebSocketSession session, string value)
        {
            var msg = string.Format("{0:HH:MM:ss} {1}说: {2}", DateTime.Now, visits[session.SessionID], value);
            SendToAll(session, msg);
            
        }
        /// <summary>
        /// 启动服务
        /// </summary>
        /// <returns></returns>
        public void Start()
        {
            if (!ws.Setup(ip, port))
            {
                Console.WriteLine("ChatWebSocket 设置WebSocket服务侦听地址失败");
                return;
            }
            if (!ws.Start())
            {
                Console.WriteLine("ChatWebSocket 启动WebSocket服务侦听失败");
                return;
            }
            Console.WriteLine("ChatWebSocket 启动服务成功");
        }

        /// <summary>
        /// 停止侦听服务
        /// </summary>
        public void Stop()
        {
            if (ws != null)
            {
                ws.Stop();
            }
        }

        private string GetSessionName(WebSocketSession session)
        {
            
            // 这里用Path来取Name 不太科学…… 
            // return HttpUtility.UrlDecode(session.Path.TrimStart('/'));
            return "";
        }

        // 广播消息
        private void SendToAll(WebSocketSession session, string msg)
        {
            foreach (var sendSession in session.AppServer.GetAllSessions())
            {
                
                sendSession.Send(msg);
            }
        }

        private void AllVisit(WebSocketSession session)
        {
            Console.WriteLine("当前游客目录如下：");
            foreach (var sendSession in session.AppServer.GetAllSessions())
            {
                Console.WriteLine("{0}", visits[sendSession.SessionID]);
            }
        }
    }
}
```

### 客户端

```html
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
</head>
<body>
    ip地址：<input type="text" value="10.10.123.120" id="ipid"/>
    端口：<input type="text" value="2014" id="socketid"/>
    <input type="button" value="连接服务器" onclick="connect()"/> &nbsp;&nbsp;
    <input type="button" value="断开服务器" onclick="disconnect()"/> <br />
    <input type="text" name="txt" id="txtid" />
    <input type="button" value="发送" onclick="sendMsg()"/>

    <div id="divmsg" ></div>
    <script type="text/javascript">
        
        var ws;

        // 连接服务器
        function connect() {
            var ip = document.getElementById("ipid").value;
            var socket = document.getElementById("socketid").value;
            // alert("ws://" + ip + ":" + socket);
            var addr = "ws://" + ip + ":" + socket;

            try {
                ws = new WebSocket(addr); // 连接服务器

                // 绑定事件
                ws.onopen = function (event) { // 打开
                    alert("连接服务器成功,状态：" + this.readyState);
                }
                ws.onclose = function (event) { // 关闭
                    alert("与服务器断开连接");
                }
                ws.onerror = function (event) { // 出错
                    alert("出错了");
                }
                ws.onmessage = function (event) { // 接收到消息
                    document.getElementById("divmsg").innerHTML += event.data+"<br>";
                }
                
            } catch (ex) {
                alert(ex.message);
            }
        }
        
        // 断开连接
        function disconnect() {
            try {
                ws.close(1000, "下线回家了");
            } catch (ex) {
                alert(ex.message);
            }
        }

        // 发送信息
        function sendMsg() {
            try {
                var msg = document.getElementById("txtid").value;
                ws.send(msg);
            } catch (ex) {
                alert(ex.message);
            }
        }
    </script>
</body>
</html>
```

### 部署

部署到IIS服务器

如果本地访问，直接debug就行，如果要局域网内另一台机子访问用来抓包，那么就要部署一下
部署参考：[http://blog.sina.com.cn/s/blog_acb983ba0101c5um.html](http://blog.sina.com.cn/s/blog_acb983ba0101c5um.html)

### 结果

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/W-websocket/image/2016-06-30/07.png)
