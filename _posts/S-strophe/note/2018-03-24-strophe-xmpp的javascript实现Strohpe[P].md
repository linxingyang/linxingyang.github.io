---
layout: post
permalink: /:year/4cxx9988502743b68622d47e6587b2d0
title: 2018-03-24-strophe-xmpp的javascript实现Strohpe
categories: [strophe]
tags: [javascript,strophe,xmpp,协议]
excerpt:  xmpp,strophe,api
description: strophe,api
catalog: true
authro: 林兴洋
---

# Strohpe1.2.7.API的介绍

顶层有个Strhope对象 ，这个对象中有这些东西。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/S-strophe/image/2018-03-24/01.png)

* Builder
* Handler
* TimeHandler
* Connection
* SASLMechanism
* SASLPlain
* SASLSHA1
* SASLMD5
* SASLOAuthBearer
* Request
* Bosh
* WebSocket

或者可以通过代码来查看，最后暴露了些什么到全局中。

```
var o = factory(root.SHA1, root.Base64, root.MD5, root.stropheUtils);
window.Strophe =        o.Strophe;
window.$build =         o.$build;
window.$iq =            o.$iq;
window.$msg =           o.$msg;
window.$pres =          o.$pres;
window.SHA1 =           o.SHA1;
window.Base64 =         o.Base64;
window.MD5 =            o.MD5;
window.b64_hmac_sha1 =  o.SHA1.b64_hmac_sha1;
window.b64_sha1 =       o.SHA1.b64_sha1;
window.str_hmac_sha1 =  o.SHA1.str_hmac_sha1;
window.str_sha1 =       o.SHA1.str_sha1;
```

* Strophe
* Builder 用来构建节，已经提供了三种基本的构建方式
    * iq 请求响应节
    * msg 消息节
    * pre 出席节
* Handler和TimeHandler
* Connection
    * 通讯通道一:Bosh
        * Request  Bosh通道不是真正意义上的长连接，通过不断发起请求来模拟长连接
    * 通讯通道二:WebSocket，真正意义上的长连接。
    * 登录加密：作为Connection登录时加密所用。
        * SASLMechanism
        * SASLPlain
        * SASLSHA1
        * SASLMD5
        * SASLOAuthBearer 

## Strophe对象中

### 命名空间

对应协议中定义的命名空间。NS对象指定了一些Strophe中使用到的命名空间

```
NS: {
        HTTPBIND: "http://jabber.org/protocol/httpbind",
        BOSH: "urn:xmpp:xbosh",
        CLIENT: "jabber:client",
        AUTH: "jabber:iq:auth",
        ROSTER: "jabber:iq:roster",
        PROFILE: "jabber:iq:profile",
        DISCO_INFO: "http://jabber.org/protocol/disco#info",
        DISCO_ITEMS: "http://jabber.org/protocol/disco#items",
        MUC: "http://jabber.org/protocol/muc",
        SASL: "urn:ietf:params:xml:ns:xmpp-sasl",
        STREAM: "http://etherx.jabber.org/streams",
        FRAMING: "urn:ietf:params:xml:ns:xmpp-framing",
        BIND: "urn:ietf:params:xml:ns:xmpp-bind",
        SESSION: "urn:ietf:params:xml:ns:xmpp-session",
        VERSION: "jabber:iq:version",
        STANZAS: "urn:ietf:params:xml:ns:xmpp-stanzas",
        XHTML_IM: "http://jabber.org/protocol/xhtml-im",
        XHTML: "http://www.w3.org/1999/xhtml"
    },
```

同时，如果我们需要扩展命名空间，可以使用addNamespace方法。

```
    addNamespace: function (name, value) {
      Strophe.NS[name] = value;
    },
```

### 连接状态

登录结果各种状态。

```
    Status: {
        ERROR: 0, // 错误
        CONNECTING: 1, // 连接中
        CONNFAIL: 2, // 连接失败
        AUTHENTICATING: 3, // 认证中
        AUTHFAIL: 4, // 认证失败
        CONNECTED: 5, // 已连接
        DISCONNECTED: 6, // 已断开连接
        DISCONNECTING: 7, // 断开连接中
        ATTACHED: 8, // 附加
        REDIRECT: 9, // 重定向
        CONNTIMEOUT: 10 // 连接超时
    },
```

### 日志

Strophe还提供了一个Log实现，当然，只是一个小实现。

我们要通过重写Strophe.log方法来

```
    LogLevel: {
        DEBUG: 0,
        INFO: 1,
        WARN: 2,
        ERROR: 3,
        FATAL: 4
    },

    /**
     * 
     * 函数：log
		用户重写打日志函数
		
		默认的实现没有做任何事情
		如果客户端代码想要去处理日志消息，应该重写这个函数：
		Strophe.log = function(level, msg) {
			// user code here
		};
		以下是不同的等级和它们所代表的意义
	参数：
		数值型 level - 日志等级，
		字符串 msg - 日志内容
     */
    log: function (level, msg) {
        return;
    },
    
    debug: function(msg){
        this.log(this.LogLevel.DEBUG, msg);
    },
    
    info: function (msg) {
        this.log(this.LogLevel.INFO, msg);
    },
    
    warn: function (msg) {
        this.log(this.LogLevel.WARN, msg);
    },
    
    error: function (msg) {
        this.log(this.LogLevel.ERROR, msg);
    },

    fatal: function (msg) {
        this.log(this.LogLevel.FATAL, msg);
    },
    
```
### addConnectionPlugin 添加插件

Strophe的一些其它插件通过该方法加入Strophe中。

```
    /**
     * 扩展Strophe.Connection使之能够接受给定的插件
     * 参数
     * 		name - 插件的名称
     * 		ptype  - 插件的标准|原型
     */
    addConnectionPlugin: function (name, ptype) {
        Strophe._connectionPlugins[name] = ptype;
    }
```

### forEachChild

```
	/**
     *
     * elem 传入的元素
     * eleName 子元素标签名过滤器，注意这个是区分大小写的。如果elemName是空的，所有子元素都会被通过这个函数的执
     * 否则只有那些标签名称能够匹配eleName的才会被执行
     * func 找到符合的每个子元素都会调用一次该函数，该函数参数为一个符合要求的DOM类型的元素
     */
    forEachChild: function (elem, elemName, func) {
        var i, childNode;

        for (i = 0; i < elem.childNodes.length; i++) {
            childNode = elem.childNodes[i];
            if (childNode.nodeType == Strophe.ElementType.NORMAL &&
                (!elemName || this.isTagEqual(childNode, elemName))) {
                func(childNode);
            }
        }
    },
    
```

#### 示例，解析Vcard节

* 可以这么做，但是如果用JQuery来做更方便。

```

    /**
     * 将Vcard节转为Vcard对象。
     */
    parseVcardStanzaToVcard : function(stanza) {
        // 前面这几行可以忽略，主要是展示后面使用forEachChild方法。
    	var $stanza = $(stanza);
    	var vcardTemp = new XoW.Vcard();
		var jid = $stanza.attr('from');
		vcardTemp.jid = jid; 
		var $vcard = $stanza.find('vCard');
		
		// stanza就是服务器返回的未经处理的Vcard节，
		Strophe.forEachChild(stanza, "vCard", function(vcard) {
            // 解析出该DOM元素中标签为vCard的DOM元素，即<vCard>...</vCard>		
			Strophe.forEachChild(vcard, "N", function(N) {
			    // 从Vcard元素中标签为N的元素，即<N>...</N>
				Strophe.forEachChild(N, "FAMILY", function(FAMILY) {
				    // 解析出N标签中的<FAMILY></FAMILY>元素。
					vcardTemp.N.FAMILY = FAMILY.textContent;
				});
				Strophe.forEachChild(N, "GIVEN", function(GIVEN) {
				    // 解析出N标签中的<GIVEN></GIVEN>元素。
					vcardTemp.N.GIVEN = GIVEN.textContent;
				});
				Strophe.forEachChild(N, "MIDDLE", function(MIDDLE) {
				// 解析出N标签中的<MIDDLE></MIDDLE>元素。
					vcardTemp.N.MIDDLE = MIDDLE.textContent;
				});
			});
			Strophe.forEachChild(vcard, "ORG", function(ORG) {
				Strophe.forEachChild(ORG, "ORGNAME", function(ORGNAME) {
					vcardTemp.ORG.ORGNAME = ORGNAME.textContent;
				});
				Strophe.forEachChild(ORG, "ORGUNIT", function(ORGUNIT) {
					vcardTemp.ORG.ORGUNIT = ORGUNIT.textContent;
				});
			});
			
			// ... 省略其他代码
		});

    	return vcardTemp;
    },
```

### isTagEqual


```
    /**
     * 判断某个元素的标签名
     * e1 一个dom元素
     * name 元素的名字
     */
    isTagEqual: function (el, name) {
        return el.tagName == name;
    },
```

### xmlescape,xmlunescape，serialize

* xmlescape,xmlunescape 用于转义标签
* serialize用于转义整个DOM，使之可以打印在HTML中，一般我们要打印DOM的时候可以用这个。

```
    xmlescape: function(text)
    {
        text = text.replace(/\&/g, "&amp;");
        text = text.replace(/</g,  "&lt;");
        text = text.replace(/>/g,  "&gt;");
        text = text.replace(/'/g,  "&apos;");
        text = text.replace(/"/g,  "&quot;");
        return text;
    },
        xmlunescape: function(text)
    {
        text = text.replace(/\&amp;/g, "&");
        text = text.replace(/&lt;/g,  "<");
        text = text.replace(/&gt;/g,  ">");
        text = text.replace(/&apos;/g,  "'");
        text = text.replace(/&quot;/g,  "\"");
        return text;
    },
    
    serialize: function (elem) {
        var result;

        // 省略...

        return result;
    },
```

### escapeNode，unescapeNode

JID因为它的格式，其中包含/和@符号，在有些地方可能不能直接使用。使用这个方法可以转义它。


```
/**
     * 对jid的node部分进行换码，node@domain/resource
     * 
     * 参数
     * 		node - 一个node
     * 返回值
     * 		换码后的node
     */
    escapeNode: function (node) {
        if (typeof node !== "string") { return node; }
        return node.replace(/^\s+|\s+$/g, '')
            .replace(/\\/g,  "\\5c")
            .replace(/ /g,   "\\20")
            .replace(/\"/g,  "\\22")
            .replace(/\&/g,  "\\26")
            .replace(/\'/g,  "\\27")
            .replace(/\//g,  "\\2f")
            .replace(/:/g,   "\\3a")
            .replace(/</g,   "\\3c")
            .replace(/>/g,   "\\3e")
            .replace(/@/g,   "\\40");
    },
    
    unescapeNode: function (node) {
        if (typeof node !== "string") { return node; }
        return node.replace(/\\20/g, " ")
            .replace(/\\22/g, '"')
            .replace(/\\26/g, "&")
            .replace(/\\27/g, "'")
            .replace(/\\2f/g, "/")
            .replace(/\\3a/g, ":")
            .replace(/\\3c/g, "<")
            .replace(/\\3e/g, ">")
            .replace(/\\40/g, "@")
            .replace(/\\5c/g, "\\");
    },
```

### 与JID相关的几个方法 getNodeFromJid,getDomainFromJid,getResourceFromJid,getBareJidFromJid

```
    /**
     * 从JID中获得node部分。node@domain/resource
     * 参数
     * 		jid
     * 返回值
     * 		node
     */
    getNodeFromJid: function (jid) {
        if (jid.indexOf("@") < 0) { return null; }
        return jid.split("@")[0];
    },
    
    /**
     * 从JID中得到domain
     * 参数
     * 		jid
     * 返回值
     * 		node
     */
    getDomainFromJid: function (jid) {
        var bare = Strophe.getBareJidFromJid(jid);
        if (bare.indexOf("@") < 0) {
            return bare;
        } else {
            var parts = bare.split("@");
            parts.splice(0, 1);
            return parts.join('@');
        }
    },
    /**
     * 从JID中得到resource部分
     * 
     */
    getResourceFromJid: function (jid) {
        var s = jid.split("/");
        if (s.length < 2) { return null; }
        s.splice(0, 1);
        return s.join('/');
    },
	/**
	 * 得到纯JID
	 */
    getBareJidFromJid: function (jid) {
        return jid ? jid.split("/")[0] : null;
    },
    
```

## Strophe.Builder

 这个对象提供了一个和JQuery很像的接口，但是构建DOM元素更容易和快速，
 所有的函数返回值都是对象类型的，除了 toString()和tree()，
 所以可以链式调用，这里是一个使用$iq()构建者的例子
 
方法

* Builder(name, attrs)  构造函数，两个参数：该节名称，节的属性
* tree() 返回当前节的DOM对象。返回的对象可以使用Strophe.Connection.send()方法直接发送给服务端
* up()返回上一级
* toString() 返回当前节的字符串形式
* attrs() 添加或者修改当前元素的属性
* c(name, attrs, text) 添加节点。参数分别是：节点名称，节点属性，节点文本内容。
* cnode(elem) 这个函数和c()函数以一样，除了它不是使用 name 和 attrs 去创建
* t(text) 添加一个文本子元素
* h(html) 用HTML替换当前的元素内容

已经默认提供了三种基本的节：

* 消息节 function $msg(attrs) { return new Strophe.Builder("message", attrs); }
* iq节 function $iq(attrs) { return new Strophe.Builder("iq", attrs); }
* 出席节 function $pres(attrs) { return new Strophe.Builder("presence", attrs); }

### 示例

```
$iq({to: 'you', from: 'me', type: 'get', id: '1'})
    .c('query', {xmlns: 'strophe:example'})
    .c('example')
    .toString();
```

以上的代码会生成如下的XML片段

```
<iq to='you' from='me' type='get' id='1'>
    <query xmlns='strophe:example'>
        <example/>
    </query>
</iq>
```

## Strophe.Handler和trophe.TimeHandler

这两个是Strophe内部使用的。

如下是Handler构造函数，我们不直接使用这两个对象。

```
参数：
    函数 handler - 触发式执行的函数
    字符串 ns - 需要匹配的命名空间
    字符串 name - 需要匹配的name
    字符串 type - 同上
    字符串 id - 同上
    字符串 from - 同上
    字符串 options - 处理器选项
Handler (handler, ns, name, type, id, from, options)
```

但是当我们监听Strophe中是否接收到节的时候，使用Strophe.Connection.addHandler()和Strophe.Connection.deleteHandler()间接使用。TimeHandler也是一样的。

```
    addHandler: function (handler, ns, name, type, id, from, options) {
        var hand = new Strophe.Handler(handler, ns, name, type, id, from, options);
        this.addHandlers.push(hand);
        return hand;
    },
```

## SASL

### Strophe.SASLMechanism 验证机制

优先级，所以如果没有设置，默认验证就是用SCRAM-SHA1。

```
 *  SCRAM-SHA1 - 40
 *  DIGEST-MD5 - 30
 *  Plain - 20
```

## Strophe.Connection

我们的程序主要使用Connection类，用它来建立连接，发送节等操作。

通道有两种，WebSocket和Bosh。他们对Connection提供了相同的接口。所以在使用Connection时，它会根据你在创建Connection对象时传进来的参数，判断需要使用的通道类型。

构造方法中，有这么一段。其中service就是服务器的地址，如果传进来的服务器地址以ws:或者wss:开头，那么就会使用Websocket作为通道，否则使用Bosh。

```
Connection (service, options) {
    // ....省略其他代码
    if (service.indexOf("ws:") === 0 || service.indexOf("wss:") === 0 ||
            proto.indexOf("ws") === 0) {
        this._proto = new Strophe.Websocket(this); // proto - WS对象
    } else {
        this._proto = new Strophe.Bosh(this);
    }
    // ....省略其他代码
}
```

### connect， disconnect断开连接。

```
// jid，密码，登录结果回调。
connect(jid, pass, callback, wait, hold, route, authcid) {
```

下面我写的一段代码，我的connect方法中，在新建了new Strophe.Connection(serviceURL);后，使用connect与服务器建立连接

```
	connect : function(serviceURL, jid, pass) {
		XoW.logger.ms(this.classInfo + "connect()");
		
		// 新建一个Strophe.Connection对象，此时并未开始连接服务器
		this._stropheConn = new Strophe.Connection(serviceURL);
		// 重写Stroope的rowInput/Ouput方法用于打印报文。
		this._rawInputOutput();
		// 连接服务器
		this._stropheConn.connect(jid, pass, this._connectCb.bind(this));
		
		XoW.logger.me(this.classInfo + "connect()");
	},
```

### send(elem) 发送节， sendIQ(elem, callback, errback, timeout) 发送IQ节

* send，发送消息节和出席节的时候使用这个。
* sendIQ，建议在发送IQ节的时候使用这个。因为iq节一定有一个返回的节。用一个回调去接受响应的节。

示例：发送在线出席节

```
    var p1 = $pres({
        id : XoW.utils.getUniqueId("presOnline")// 获得唯一的id
    }).c("status")
    .t("在线")
    .up()
    .c("priority")
    .t('1');
    
    this._gblMgr.getConnMgr().send(p1);
```

示例：发送请求vcard节。

```
    getVcard : function(jid, successCb, errorCb, timeout) {

		if(!jid) {
			jid = null;
		}
		// 没有带from属性，服务器也能知道是“我”发送的，服务器中有做处理。
		vcard = $iq({
			id : XoW.utils.getUniqueId("getVcard"), 
			type : "get", 
			to : jid
		}).c("vCard", {
			xmlns : XoW.NS.VCARD
		});

		this._gblMgr.getConnMgr().sendIQ(vcard, function(stanza) {
			// 成功获取vcard处理
		}.bind(this), function(errorStanza) {
			// 错误处理
		}, timeout);
	},
```

### addHandler,deleteHandler,addTimedHandler,deleteTimedHandler

addHandler监听节。我们通过这个方法，监听从服务器发送来的节。

```
    /**
     * 添加监听器
     * 		ns - 要匹配的命名空间
     * 		name - 同上
     * 		type - 匹配节的类型
     * 		id	- 匹配节的id
     * 		from - 匹配节的from
     * 		options 处理器的可选项
     */
    addHandler: function (handler, ns, name, type, id, from, options) {
        var hand = new Strophe.Handler(handler, ns, name, type, id, from, options);
        this.addHandlers.push(hand);
        return hand;
    },

    deleteHandler: function (handRef) {
        // this must be done in the Idle loop so that we don't change
        // the handlers during iteration
        this.removeHandlers.push(handRef);
        // If a handler is being deleted while it is being added,
        // prevent it from getting added
        var i = this.addHandlers.indexOf(handRef);
        if (i >= 0) {
            this.addHandlers.splice(i, 1);
        }
    },
    
    addTimedHandler: function (period, handler) {
        var thand = new Strophe.TimedHandler(period, handler);
        this.addTimeds.push(thand);
        return thand;
    },
    
    deleteTimedHandler: function (handRef) {
        // this must be done in the Idle loop so that we don't change
        // the handlers during iteration
        this.removeTimeds.push(handRef);
    },
```

比如

```
     // 若不指定具体参数，只给定回调函数，那么监听所有从服务器发送来的节
    this._gblMgr.getConnMgr().addHandler(this._needDealCb.bind(this));
    
    // 监听presence节，第一个参数是我的回调函数。
	this._gblMgr.getConnMgr().addHandler(this._presenceCb.bind(this), null, "presence");
```

### xmlInput，xmlOutput，rawInput，rawOutput

这四个方法，是发送接收节过程中必定会调用到了，它们都是空实现，这个的作用是让我们实现他们，来做一些自己想做的事，比如打印每次发送接收的节到控制台，方便调试。


这下面这段是我自定义的一个方法，里面重写了rawInput和rawOutput这两个方法，然后调用自己的日志类，打印他们。

```
	_rawInputOutput : function() {
		XoW.logger.ms(this.classInfo + "_rawInputOutput()");
		
		this._stropheConn.rawInput = function(data) {
			XoW.logger.receivePackage(data);
		}.bind(this);
		this._stropheConn.rawOutput = function(data) {
			XoW.logger.sendPackage(data);
		}.bind(this);
		XoW.logger.me(this.classInfo + "_rawInputOutput()");
	},
```

## Strohpe.Websocket，Strophe.Bosh 和 Strophe.Request

Bosh和Websocket类作为底层连接类，提供一些连接方法的处理。我们的关注点主要是在Connection类。

使用插件时并不会调用到这边的方法。
