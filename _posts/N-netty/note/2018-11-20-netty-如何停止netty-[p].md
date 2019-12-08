---
layout: post
permalink: /:year/4aa3fd336b664d13876e758915c1d776
title: 2018-11-20-netty-如何停止netty
categories: [netty]
tags: [java,netty]
excerpt:  停止netty
description: 停止netty
catalog: false
author: 林兴洋
---

这次任务是开发一个日志服务器，让所有项目的日志都发送这个日志服务器中。

久闻netty大名而不得见啊，这次做这个就决定用netty做底层通信框架。

接口啥的都挺友好的，做着做着，突然发现一个问题：怎么停止netty。

```
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.LineBasedFrameDecoder;
import io.netty.handler.codec.string.StringDecoder;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.core.Logger;
import org.apache.logging.log4j.core.LoggerContext;

import java.net.URISyntaxException;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.*;

public class Log4j2ServerBootStrap {
    
    
    private final EventLoopGroup group = new NioEventLoopGroup();
    private final EventLoopGroup worker = new NioEventLoopGroup();
    
    private Channel parentChannel;
    
    public void start() throws Exception {
        final StringDecoder stringDecoder = new StringDecoder(Charset.forName("UTF-8"));
        
        try {
            ServerBootstrap b = new ServerBootstrap();
            b.group(group, worker)
                // .channel(EpollSocketChannel.class)
                .channel(NioServerSocketChannel.class)
                .localAddress(ConfigurationFromLog4j2.getInstance().getPort())
                .childHandler(new ChannelInitializer<SocketChannel>() {
                    @Override
                    protected void initChannel(SocketChannel channel) throws Exception {
                        channel.pipeline()
                        .addLast(new LineBasedFrameDecoder(ConfigurationFromLog4j2.getInstance().getLineMaxLength()))
                        .addLast(stringDecoder);
                    }
                });
            ChannelFuture bindFuture = b.bind().sync();
            parentChannel = bindFuture.channel();
            bindFuture.addListener(new ChannelFutureListener() {
                @Override
                public void operationComplete(ChannelFuture channelFuture) throws Exception {
                    if (channelFuture.isSuccess()) {
                        LogUtils.getLogger().info("日志服务器监听成功," + channelFuture.channel().localAddress());
                    } else {
                        LogUtils.getErrorLogger().error("日志服务器监听失败!" + channelFuture.cause());
                    }
                }
            });
            ChannelFuture closeFuture = bindFuture.channel().closeFuture().sync();
            closeFuture.addListener(new ChannelFutureListener() {
                @Override
                public void operationComplete(ChannelFuture channelFuture) throws Exception {
                    if (channelFuture.isSuccess()) {
                        LogUtils.getLogger().info("日志服务器停止监听成功," + channelFuture.channel().localAddress());
                    } else {
                        LogUtils.getErrorLogger().error("日志服务器停止监听失败!" + channelFuture.cause());
                    }
                }
            });
        } catch (Exception e) {
            group.shutdownGracefully().sync();
            worker.shutdownGracefully().sync();
        }
    }
}
```

突然间的困惑,下面的代码会一直阻塞着直到channel()被关闭，那如何主动的去关闭？

```
bindFuture.channel().closeFuture().sync();
```

可以借鉴SocketChannel那个时候用的方法一样，一旦收到客户端发送的 exit或者quit字符，那就关闭channel。

那在netty中，也可以做这样的事，定义一个类继承ChannelInBoundHandlerAdapter，然后实现ChannelRead()方法，当读到 exit 或者 quit就关闭  

```
@Override
public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
    // 根据msg信息关闭channel
    ctx.channel().parent().close();
}
```

使得 bindFuture.channel().closeFuture().sync(); 
跳出阻塞继续往下运行。然后在finally中关闭资源。

```
group.shutdownGracefully().sync();
worker.shutdownGracefully().sync();
```

而项目的情况是

接收日志：接收的是JSON格式的日志，直接使用log4j2提供的SocketAppender，不想定制自己的客户端。这就导致了我没有办法给服务端发送类似 quit或者exit。（当然也可以变通的通过lo4j2发送exit）

所以就考虑通过启动停止流程来控制

启动停止流程：通过启动tomcat，让配置在web.xml中的Servlet被初始化， 然后调用该Servlet的init()方法(netty启动)。通过停止tomcat，触发Servlet的destory()方法(netty停止)


```
public class StartLog4j2Servlet extends HttpServlet {
   @Override
    public void init() throws ServletException {

        // 要重新启动一个线程
        // 如果不启动新线程，那么netty因为阻塞在下面这句代码，导致tomcat整个就卡在那里。
        // bindFuture.channel().closeFuture().sync();
        Thread startNettyThread = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    LogUtils.getLogger().info("启动日志服务器");
                    // Log4j2ServerBootStrap是一个单例
                    // 所以虽然启动和停止不是同一个线程
                    // 但使用的是同一个实例
                    Log4j2ServerBootStrap.getInstance().start();
                } catch (Exception e) {
                    LogUtils.getErrorLogger().error("启动日志服务器失败" + e.getMessage(), e);
                }
            }
        });
        startNettyThread.setDaemon(false);
        startNettyThread.start();
    }
    
    @Override
    public void destroy() {
        LogUtils.getLogger().info("停止日志服务器");
        Log4j2ServerBootStrap.getInstance().shutdown();
    }
}
```

当tomcat停止的时候调用Servlet的destory()方法，destory()去调用shutdown()方法去释放资源

```
public class Log4j2ServerBootStrap {
    public void shutdown() {
        try {
            LogUtils.getLogger().info("开始停止netty...");
            // 关闭当前所有的管道
            // stateMonitorHandler.closeAllChannel();
            parentChannel.close();
            // 释放资源
            group.shutdownGracefully().sync();
            worker.shutdownGracefully().sync();
            LogUtils.getLogger().info("释放netty资源完毕!");
        } catch (Exception e) {
            LogUtils.getErrorLogger().error("停止netty失败!" + e.getMessage(), e);
        }
    }
}
```

回过头来看，关闭也就这样，当时自己脑子是不是抽抽了。因为当时很疑惑，我要如何触发关闭？关闭时需要释放哪些资源？做了一遍就豁然开朗。


题外话

这次做的过程中，参考了李林峰的netty权威指南，还有何品 译 norman maurer的netty in action。   


李林峰的netty权威指南用的是全新的netty5，但是很遗憾啊，我到github上面一看netty5停止了，还是在维护netty4，所以选用netty4，主要参考的 netty in action 一书。 两本书都学到了一些东西。

