---
layout: post
permalink: /:year/a571xxxxx81f42d49a831f17e2fffd5d/index
title: csharp-MSMQ简介和简单例子
categories: [csharp]
tags: [post, csharp, promotion]
date: 2015-05-22 11:26:32 +8
place: 福建工程学院
editdate: 2021-12-03 11:26:32 +8
eidtplace: 福州软件园
excerpt: MSMQ,csharp,介绍,简单例子
description: MSMQ简介和简单例子
catalog: true
author: 林兴洋
---

# csharp

## 1、什么是MSMQ

微软消息队列 Mircosoft Message Queue，一台计算机先把消息放到队列中，其它机器可以将这个信息从队列中取出。图示如下：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/15.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/16.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/17.png)

## 2、使用CSharp操作消息队列前的设置 

### 添加MSMQ这个功能

`控制面板` ->`程序` -> `程序和功能`中的 `打开或关闭Windows功能`勾选MSMQ，点击确定，如图：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/01.png)

### 在新建winForm项目中引用 System.Messaging

新建一个winForm项目 ，如下图，选择添加引用：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/02.png)

选中 “System.Messageing” 点击确定：

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/03.png)

并且 “using System.Messaging”

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/04.png)


## 3、MSMQ如何创建队列（两种方式）

### 第一种：手动创建

右键“计算机” —> “管理” —》 “服务和应用程序” —》“消息队列” 

![](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/05.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/06.png)

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/07.png)

### 第二种：代码创建

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/08.png)

```csharp
private void btnSend_Click(object sender, EventArgs e)
{
    if (!MessageQueue.Exists(myQueuePath)) // 不存在就创建，存在就跳过
    {
        createQueue(); // 创建队列
    }
   
}

private void createQueue()
{
    myQueue = MessageQueue.Create(myQueuePath); 
    myQueue.Label = myQueuePath; // 获取或设置队列说明

}
```

## 4、事务性和权限

队列创建完是还不能直接用的，这边有两个东西要清楚一下

### 队列的事务性和非事务性

用第一种方法创建队列的时候，如下图，有一个事务性的勾选框

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/09.png)

这里的事务性和非事务性和数据库的事务处理是一个道理的，大致用在同时传多个消息到队列中的时候，有时必须保证必须全部传到消息队列（比如一个比较大的文件分段了，百度上说MSMQ队列单个消息最大4MB），要是有一个失败这几个的消息都不会入队列。但我做实验的时候都是用非事务性队列的。事务性的队列在用代码创建队列时与非事务性有区别，在发送接收消息时也有区别。

### 权限

用上面两种方法创建队列后，右键单击队列进入属性

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/10.png)

如图，默认有2个组（一个everyone,一个ANONYOUS LOGON(匿名)组），1个用户（本机）

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/11.png)

* 默认情况下，这两个组的权限的复选框只有几个勾选的，**但是没有接受消息的权限**。

* 本机的“允许”一列复选框都被勾选了，说明本机对这个队列有完全的控制能力。

如果是在本机上用MSMQ做发送和接受消息的测试时，是完全可以发送和收到消息的，但是如果同样的代码，本机为发送端，另一台机器为接收端，那么是收不到消息的。这也是我刚开始接触MSMQ的时候想要远程从队列中接收信息时为什么接收不到，困扰的比较久的问题。

两台设备的权限要设置好。在远程机器上获取本机器上队列的消息，因为没有通过验证，所以这里要设置ANONYOUS LOGON （匿名）的权限，使远程计算机能够获取本机上队列的消息。

#### 1、就是直接在上图所示勾选 ANONYOUS LOGON （匿名）的权限

#### 2、在代码中设置

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/12.png)

这里可以根据需要给远程的机器赋予权限，为了方便，我这里设置了.FullControl 即全部权限，这里权限很多，不一一列出，和使用方法1设置权限是对应的。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/13.png)

```csharp
private void createQueue()
{
    myQueue = MessageQueue.Create(myQueuePath, true); // 事务性队列
    myQueue.SetPermissions("ANONYMOUS LOGON", MessageQueueAccessRights.FullControl); // 使得匿名登录拥有所有权限
    myQueue.Label = myQueuePath; // 获取或设置队列说明
}
```

## 5、相关方法

要用MSMQ前先要知道一些概念和常用的关于MSMQ的方法

### 序列化（在网络上传输的二进制流）

发送端和接收段 要使用同一种系列化，在代码中选用 BinaryMessageFormatter

```csharp
IMessageFormatter myFormatter = new System.Messaging.BinaryMessageFormatter();//序列化
```

###  关于messageQueue的一些常用方法

* Create方法:创建使用指定路径的新消息队列。
* Delete方法：删除现有的消息队列。
* Existe方法：查看指定消息队列是否存在。
* GetAllMessages()方法:得到队列中的所有消息。
* Peek/BeginPeek方法：查看某个特定队列中的消息队列，但不从该队列中移出消息。
* Receive/BeginReceive方法：检索指定消息队列中最前面的消息并将其从该队列中移除。
* Send方法：发送消息到指定的消息队列。
* Purge方法：清空指定队列的消息。

MessageQueue 支持两种消息类型，同步和异步，

* 同步方法使用的是peek();receive();
* 异步使用的是：Beginpeek() and Beginreceive();


### 关于message 消息的载体

* Id 唯一标识信息，
* body 消息的内容
* 消息的优先级，如下图，其中 Highest > VeryHigh

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/14.png)

```
这里优先级的概念是：假设用 0 1 2 3 4 5 6 7 表示优先级从小到大

现在假设有消息M1,M2，M3,M4，他们的优先级如下
消息  优先级
M1   3
M2   0
M3   7 
M4   6

那么在队列中，不论以那种顺序插入这四个消息，队列中最终消息的排列会是
：（头） M3 M4 M1 M2 （尾） 

此时插入消息M5，M6
消息  优先级
M5    4
M6    6

那么消息的顺序如下：
：（头） M3 M4 M6 M5 M1 M2 （尾）
```

## 6、简单发送接收例子

### 发送端

```csharp
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Messaging;

namespace MSMQsend_5_18
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        static string myQueuePath = ".\\private$\\register";//本地的队列路径
        IMessageFormatter myFormatter = new System.Messaging.BinaryMessageFormatter();//序列化
        MessageQueue myQueue = new MessageQueue(myQueuePath);//消息队列

        #region 发送消息
        private void btnSendMessage_Click(object sender, EventArgs e)//发送消息
        {
            //点击发送消息到消息队列的时候要先判断一下该队列存不存在。
            if (!MessageQueue.Exists(myQueuePath))//不存在就创建，存在就跳过
            {
                createQueue();//创建队列
            }
            if (checkOtherThings())
            {
                try
                {
                    myQueue.Send(sendMessage());//发送消息
                    label1.Text = "发送成功！";
                }
                catch (MessageQueueException mqEx)
                {
                    label1.Text = "发送失败！";
                    MessageBox.Show("发生错误：" + mqEx.Message);
                }
            }   
        }

        private void createQueue()//在队列不存在的情况下创建队列
        {
            myQueue = MessageQueue.Create(myQueuePath);//创建一个队列
            //权限设置：队列的可使用者设置，这里是设置（匿名）所有人都有权限，
            myQueue.SetPermissions("ANONYMOUS LOGON", MessageQueueAccessRights.FullControl);
            myQueue.Label = myQueuePath;//获取或设置队列说明
        }

        private Boolean checkOtherThings()//检查其他项
        {
            if (rtbMessage.Text.Trim() == "")
            {//判断 富文本框 中要发送的消息是否为空
                MessageBox.Show("消息为空无效！");
                return false;
            }
            else
            {
                return true;
            }
        }

        private System.Messaging.Message sendMessage()//消息
        {
            System.Messaging.Message myMessage = new System.Messaging.Message();//发送和接收消息都要用到的“载体”
            myMessage.Body = rtbMessage.Text;//消息的内容
            myMessage.Formatter = myFormatter;//序列化
            return myMessage;
        }
       endregion

        private void rtbMessage_TextChanged(object sender, EventArgs e)
        {
            label1.Text = "";
        }

    }
}
```

#### 当发送一个消息后，刷新队列，会出现一个消息。

![图](https://gitee.com/linxingyang/at-2020-10-02-image/raw/master/image/C-csharp/image/2015-05-22/18.png)

### 接收端

```csharp
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Messaging;

namespace MSMQreceive_5_18
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }


        static string myQueuePath = "FormatName:Direct=TCP:192.168.92.100\\private$\\test";//远程队列的路径
        //static string myQueuePath = "FormatName:Direct=OS:N4N3QZ5JPZCKS8I\\private$\\test";
        MessageQueue myqueue = new MessageQueue(myQueuePath);//队列路径
        IMessageFormatter myFormatter = new System.Messaging.BinaryMessageFormatter();//序列化
        private void Form1_Load(object sender, EventArgs e)
        {
            
        }

        #region 接收消息
        private void btnReceive_Click(object sender, EventArgs e)
        {
            myqueue.Formatter = myFormatter;//序列化
            try
            {
                
                if(myqueue.GetAllMessages().Count() != 0)//判断是否存在信息
                {
                    System.Messaging.Message myMessage = myqueue.Receive();//接收并且删除信息
                    rtbMessage.Text = myMessage.Body.ToString();//显示信息
                }
                else
                {
                    rtbMessage.Text = "";
                }
            }
            catch (MessageQueueException mqEx)
            {
                MessageBox.Show("发生错误：" + mqEx.Message);
            }
        }
        

        private void btnReceiveNotDel_Click(object sender, EventArgs e)
        {
            myqueue.Formatter = myFormatter;//序列化
            try
            {

                if (myqueue.GetAllMessages().Count() != 0)//判断是否存在信息
                {
                    System.Messaging.Message myMessage = myqueue.Peek();//接收不删除信息
                    rtbMessage.Text = myMessage.Body.ToString();//显示信息
                }
                else
                {
                    rtbMessage.Text = "";
                }

            }
            catch (MessageQueueException mqEx)
            {
                MessageBox.Show("发生错误：" + mqEx.Message);
            }
        }
        #endregion

    }
}
```

#### 如何判断队列中存在消息？

这是我当初做的时候比较大的问题。刚开始学的时候，因为不知道如何判断队列中存在消息，所以老是因为队列中没有消息而客户端再次去读取的时候卡住。

* 1、判断队列中是否存在消息可以用 messageQueue的 GetAllMessages() 方法，该方法可以得到队列中所有的消息，然后用自带的 count（） 方法判断消息的个数。但是按照老师说的，这样做的缺点呢也比较明显，当队列中存在许多消息的时候，如果用这个去判断个数，等于将服务器的整个队列读下来，效率不高。（但是可以通过这个一次读取多个消息）
if (myqueue.GetAllMessages().Count() != 0)//判断是否存在信息
* 2、可以用一个线程去监听，这个就克服了上面的方法的缺点。但是，这个监听每次只能读取队列的第一个消息（线程是根据Message的ID来判断的，防止重复接收同一个信息），这就意味这 发送端上面应该要有Timer，每过一段时间将队列的第一个消息删除，以便客户端读到后面的消息。线程只能以messagebox.show（）的方式显示得到的消息，如果将消息放到label中就会因线程问题出错。
* 3、用一个timer每过一段时间检查是否有新消息，这个和 线程监听 达到的效果差不多。但是也要用到 messageQueue的 GetAllMessages() 方法。
* 4、哨兵，新建队列的时候就往里面填入一个默认的，优先级最低的消息，后面插入消息的时候不要用到这个最低的优先级。那么服务器端在删除过时的消息的时候，只要是这个默认的消息就不删除，那么在客户端每次可以读取消息不用判断队列中是否存在消息，当读到 优先级最低的一个消息的时候就知道这个消息不应该显示。

#### 在接收端如何得到 消息的优先级？

我在用第四个方法来接收信息的时候，想要得到接收到的信息的优先级，直接使用MessageBox.Show(myMessage.Priority.ToString())来查看优先级结果报错。 

参照[表](https://msdn.microsoft.com/zh-cn/library/system.messaging.messagequeue.messagereadpropertyfilter.aspx)，message的属性表，当Default value（默认值） 为 true时，表示接收一个消息时，也有接收该消息的这个属性，若为 false，则默认不接收这个属性。所以我前面直接用 MessageBox.Show(myMessage.Priority.ToString());去看一个消息的优先级的时候出错。 

这个时候要用  MessagePropertyFilter 来“过滤”想要的消息的属性。
例子：比如要得到  消息内容 和 优先级,这个时候就不会报错

```csharp
MessagePropertyFilter myFilter = new MessagePropertyFilter ();
myQueue.MessageReadPropertyFilter = myFilter;
myFilter.Body = true;
myFilter.Priority = true;
MessageBox.Show(myMessage.Priority.ToString())
```

