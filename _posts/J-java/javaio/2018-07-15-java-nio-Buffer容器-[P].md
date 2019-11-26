---
layout: post
permalink: /:year/04d162bb5639481589d50400087ee7ea
title: 2018-07-15-java-nio-Buffer容器
categories: [编程]
tags: [java]
excerpt: java,nio,Buffer
description: java-nio-Buffer容器
gitalk-id: 04d162bb5639481589d50400087ee7ea
toc: true
---


# Buffer 容器

想要玩好NIO，必须懂的Buffer，连容器都不会玩，那是玩不好NIO滴~

记得自己刚看的时候，对Buffer的印象：Buffer是个卡车，Channel是一个隧道。卡车可以把东西从隧道中运出来，也可以把东西运到隧道中~

## 为什么使用Buffer? 

《Java NIO》

> 操作系统与Java基于流的I/O模型有些不匹配。操作系统要移动的是大块数据（缓冲区），这往往是在硬件直接存储器存取（DMA）的协助下完成。而JVM的I/O类喜欢操作小块数据--单个字节、几行文本。结果，操作系统送来整缓冲区的数据，java io的流数据在花大量时间把它们拆成小块，往往拷贝一个小块就要往返于几层对象。
>
> 操作系统喜欢整卡车的运来数据，Java io则喜欢一铲子一铲子的加工数据。
>
> 这并不是说使用传统的IO模型无法移动大量数据，当然可以：只要坚持使用基于数组的read()和write()方法，这些方法与底层操作系统调用相当接近，尽管必须保留一份缓存区拷贝

![图](http://image.linxingyang.net/image/J-java/image/2018/2018-07-15/02.png)


下面进行一个测试，读取文件（该文件 c.txt 大约2M）


### FileInputStream读取 

一个字节一个字节的读

```java
public static void main(String[] args) throws IOException {
	File f = new File("d:/temp/c.txt");
	InputStream is = new FileInputStream(f);
	long startMinillis = Calendar.getInstance().getTimeInMillis();
	while (-1 != is.read()) {
	}
	System.out.println("读取完成时间(毫秒):" + (Calendar.getInstance().getTimeInMillis() - startMinillis));
}
```

结果

```
读取完成时间(毫秒):7230
```


使用byte[10]

```java
public static void main(String[] args) throws IOException {
	File f = new File("d:/temp/c.txt");
	InputStream is = new FileInputStream(f);
	long startMinillis = Calendar.getInstance().getTimeInMillis();
	byte[] bs = new byte[10];
	while (-1 != is.read(bs)) {
	}
	System.out.println("读取完成时间(毫秒):" + (Calendar.getInstance().getTimeInMillis() - startMinillis));
}
```

结果

```
读取完成时间(毫秒):1237
```


省略一些代码，直接上结果： 随着byte的容量的扩大，读取完成时间变小的多了。到了一定程度byte的容量继续扩大，但时间变化也不大了。

| 文件大小    | 使用FileInputStream读取完成时间 |
| ----------- | ------------------------------- |
| 1字节       | 7230ms                          |
| byte[10]    | 1237ms                          |
| byte[100]   | 84ms                            |
| byte[1000]  | 30ms                            |
| byte[10000] | 6ms                             |

### BufferedInputStream包装FileInputStream读取

一个一个字节的读

```java
public static void main(String[] args) throws IOException {
	File f = new File("d:/temp/c.txt");
	BufferedInputStream is = new BufferedInputStream(
		new FileInputStream(f));
	long startMinillis = Calendar.getInstance().getTimeInMillis();
	while (-1 != is.read()) {
	}
	System.out.println("读取完成时间(毫秒):" + (Calendar.getInstance().getTimeInMillis() - startMinillis));
}
```

结果

```
读取完成时间(毫秒):126
```

byte[10]

```java
public static void main(String[] args) throws IOException {
		File f = new File("d:/temp/c.txt");
		BufferedInputStream is = new BufferedInputStream(
			new FileInputStream(f));
		long startMinillis = Calendar.getInstance().getTimeInMillis();
		byte[] bs = new byte[10];
		while (-1 != is.read(bs)) {
		}
		System.out.println("读取完成时间(毫秒):" + (Calendar.getInstance().getTimeInMillis() - startMinillis));
	}
```

结果

```
读取完成时间(毫秒):28
```

也省略一些代码，结果如下表格。

和使用FileInputStream一样，随着byte的容量的扩大，读取完成时间变小的多了。到了一定程度byte的容量继续扩大，但时间基本稳定了。

但是可以看到使用BufferedInputStream包装了FileInputStream后，BufferedInputStream效率比FileInputStream高了不少。

| 文件大小    | 使用FileInputStream读取完成时间 | 使用BufferedInpuStream读取完成时间 |
| ----------- | ------------------------------- | ---------------------------------- |
| 1字节       | 7230ms                          | 126ms                              |
| byte[10]    | 1237ms                          | 28ms                               |
| byte[100]   | 84ms                            | 18ms                               |
| byte[1000]  | 30ms                            | 12ms                               |
| byte[10000] | 6ms                             | -                                  |


### BufferedInputStream为什么效率比较高？

FileInputStream如果用read()方法读取一个文件，每读取一个字节就要访问一次硬盘，这种读取的方式效率是很低的。即便使用read(byte b[])方法一次读取多个字节，当读取的文件较大时，也会频繁的对磁盘操作。为了提高字节输入流的工作效率，Java提供了BufferedInputStream类。

首先解释一下BufferedInputStream的基本原理：在创建 BufferedInputStream时，会创建一个内部缓冲区数组。在读取流中的字节时，可根据需要从包含的输入流再次填充该内部缓冲区，一次填充多个字节。

也就是说，Buffered类初始化时会创建一个较大的byte数组，一次性从底层输入流中读取多个字节来填充byte数组，当程序读取一个或多个字节时，可直接从byte数组中获取，当内存中的byte读取完后，会再次用底层输入流填充缓冲区数组。

这种从直接内存中读取数据的方式要比每次都访问磁盘的效率高很多。

## 什么是Buffer

缓冲区(Buffer)就是在内存中预留指定大小的存储空间用来对输入/输出(I/O)的数据作临时存储，这部分预留的内存空间就叫做缓冲区

### 好处

使用缓冲区有这么两个好处：

1、减少实际的物理读写次数

2、缓冲区在创建时就被分配内存，这块内存区域一直被重用，可以减少动态分配和回收内存的次数


举个简单的例子，比如A地有1w块砖要搬到B地

由于没有工具（缓冲区），我们一次只能搬一块，那么就要搬1w次（实际读写次数），就像FileInputStream，每次需要读取的时候都要访问一次硬盘。

但是要是此时我们有辆大卡车（缓冲区），一次可运5000块，那么2次就够了，就像BufferedInputStream，它其中创建了一个byte[]数组，一次读取多个字节来填充该byte[]数组，即使我们一次只从这辆大卡车上取下一块砖，但是我们省下从A搬到B的痛苦了，现在就是从车上搬1W次砖，AB之间只要跑两次就好了

相比之前，性能肯定是大大提高了。而且一般在实际过程中，我们一般是先将文件读入内存，再从内存写出到别的地方，这样在输入输出过程中我们都可以用缓存来提升IO性能。

所以，buffer在IO中很重要。在旧I/O类库中（相对java.nio包）中的BufferedInputStream、BufferedOutputStream、BufferedReader和BufferedWriter在其实现中都运用了缓冲区。java.nio包公开了Buffer API，使得Java程序可以直接控制和运用缓冲区。


在Java NIO中，缓冲区的作用也是用来临时存储数据，可以理解为是I/O操作中数据的中转站。缓冲区直接为通道(Channel)服务，写入数据到通道或从通道读取数据，这样的操利用缓冲区数据来传递就可以达到对数据高效处理的目的。


### 几个疑问

下面属于自问自答，如有错误欢迎指出~有更好的想法和解答也欢迎留言

#### 疑问1：既然有BufferedInputStream等几个java.io包下的Buffered类了，为什么还要有java.nio.ByteBuffer这一系列类呢？

答1，是因为要和nio的Channel合作使用啊？
那为什么不使用BufferedInputStream和Channel合作使用，即当初那群设计者为什么要设计出Buffer来和Channel合用，而不考虑使用BufferedInputStream这些旧类来合用呢？

考虑：BufferedInputStream等Buffered类是通过包装其他流来操作，而NIO中使用的是Channel，他们两个的思想架构不同

答2，BufferedInputStream不能设置缓冲区大小？
构造函数BufferedInputStream(InputStream in, int size);的第二个参数提供初始缓冲区大小

答3，不能很好的操作缓冲区？
就像上面说的 java.nio包公开了Buffer API，使得Java程序可以直接控制和运用缓冲区。BufferedInputStream等几个Buffered类不能操作缓冲区。这可以算个原因，也是我第三个疑问。


#### 又有疑问2：如果要操作缓存区，那么直接在程序中创建byte[]数组用来做缓存区这样不是也能操作缓冲区，为什么要创建Buffer这一系列的类？


根据《Java NIO》一书的说法

> 新的Buffer类是常规Java类和通道之间的纽带。通道既可以提取存放在缓冲区中的数据（写），也可以向缓冲区中存入数据供读取（读）

也就是说，常规Java类不会和通道直接打交道，而是和Buffer类打交道，而通道是“了解”Buffer类的，比直接使用byte[]数组这一类的方式好。


#### 疑问3：为什么要直接控制和运用缓冲区呢？

这java.io包下的几个Buffered类没有向外暴露他们的缓冲区，所以我们无法操作缓冲区。但使用BufferedInputStream不也好好的么，也能够获取数据啊，使用BufferedOutputStream能够写入数据啊。


考虑：思路变了


原先我们使用BufferedInputStream和BufferedOutputStream调用read()和write()方法进行操作，

如下，读取文件内容

```java
File f = new File("d:/temp/c.txt");
BufferedInputStream is = new BufferedInputStream(
	new FileInputStream(f));
byte[] bs = new byte[1000];
while (-1 != is.read(bs)) {}
```

而现在使用Channel，如下，读取通道中的内容

```java
SocketChannel sc = SocketChannel.open();
// ...省略
sc.read(ByteBuffer src); // 通道中内容读到ByteBuffer中
```

对比二者，可以发现，BufferedInputStream中的byte[]数组（不是指byte[] bs = new byte[1000];，指的是BufferedInputStream初始化时内部创建的那个byte[]数组），我们没必要控制，因为我们读的数据都能读到byte[] bs = new byte[1000];中，我们处理的是bs这个byte[]数组的数据即可。

而在SocketChannel这边，SocketChannel将获取的数据保存到ByteBuffer中，我们要直接操作ByteBuffer来处理读取到的数据。这也因为NIO的设计思想，所以要有Buffer这一系列类出现的原因吧~


## 有很多Buffer

![图片](http://image.linxingyang.net/image/J-java/image/2018/2018-07-15/03.png)


CharBuffer、IntBuffer...可以根据数据不同类型使用不同的Buffer，常用的就是ByteBuffer~下面就用常用的ByteBuffer为例子看一下


MappedByteBuffer这个没有涉及，后面再加入吧~


### 几个构造方法

ByteBuffer提供几个创建实例的方法

```java
public static ByteBuffer allocate(int capacity)  // 通过指定缓存区大小创建非直接缓冲区
public static ByteBuffer allocateDirect(int capacity)  // 通过指定缓冲区大小创建直接缓冲区
    
// 注意使用wrap构造的，其position=0
public static ByteBuffer wrap(byte[] array) // 给定字节数组，创建非直接缓冲区
public static ByteBuffer wrap(byte[] array, int offset, int length) // 给定字节数组，并指定下标和长度，创建非直接缓冲区

```

#### 非直接缓冲区allocate(int capacity)  和  直接缓冲区allocateDirect(int capacity)  

为什么要提供两种方式呢？这与Java的内存使用机制有关。第一种分配方式产生的内存开销是在JVM中的，而另外一种的分配方式产生的开销在JVM之外，也就是系统级的内存分配。当Java程序接收到外部传来的数据时，首先是被系统内存所获取，然后在由系统内存复制复制到JVM内存中供Java程序使用。所以在另外一种分配方式中，能够省去复制这一步操作，效率上会有所提高。可是系统级内存的分配比起JVM内存的分配要耗时得多，所以并非不论什么时候allocateDirect的操作效率都是最高的。以下是一个不同容量情况下两种分配方式的操作时间对照： 


![图片](http://image.linxingyang.net/image/J-java/image/2018/2018-07-15/01.png)

由图能够看出，当操作数据量非常小时，两种分配方式操作使用时间基本是同样的，第一种方式有时可能会更快，可是当数据量非常大时，另外一种方式会远远大于第一种的分配方式。


另外两个warp()方法，都是使用非直接缓冲区，也就是allocate()方式


### 接着就是下面四个变量

在BufferedInputStream中的byte[]缓冲，当byte[]中没有东西时，从磁盘中读一次，然后read()方法每次都从这个byte[]中取数据，直到该byte[]没有数据时，才会再去磁盘中读取一次。

从磁盘中读取数据写入byte[]中不由程序员控制，程序员只管调用read()方法取出数据

同样在BufferedOutputStream中，程序员只管调用write()写就行了


但在Buffer中，读写都可以由程序员控制，这下开心了~
写东西到Buffer中，你要关注从哪个下标开始写，啥时候写满了，从Buffer中读东西的时候，你要关注从哪个下标开始读，啥时候读完了，什么时候处于写状态，什么时候处于读状态


Buffer开发者提供了很好的解决方法，提供了几个变量和一些方法，很妙啊~ 虽然我刚看接口的时候觉得似乎是在找茬~哈哈，不过如果自己要想设计一个类似的容器~也是酸爽


不多说了~

ByteBuffer中提供了下面几个基本变量

* position：当前光标的位置
* limit：从limit开始，其后的位置不是存储位置
* capacity：容器的容量
* mark：标记，调用mark()来设定使得mark=postion，调用reset()来设定position=mark


它们之间的关系：mark <= postion <= limit <= capacity


每次写的时候，都是从position开始写，写到limit为止就说明缓存满了
每次读的时候，都是从position开始读的，读到limit为止就说明缓存内数据读完了

注意这里，读写都是从position开始，到limit为止（而不是到capacity为止）


### 几个关于基本变量值的方法

#### capacity()

```java
// 获取capacity值
public final int capacity();
```

#### position()和position(int newPosition)

```java
// 获得position值
public final int position();

// 设置position值
// 1, newPosition的范围 0 <= newPosition <= limit
// 2， 如果mark > position， 那么mark = -1
public final Buffer position(int newPosition);
```

#### limit()和limit(int newLimit)

```java
// 获取limit值
public final int limit();

// 我们也可手动设置limit的值，但是也要注意
// 1，newLimit的范围 0 <= newLimit <= capacity
// 2，如果position > newLimit，那么position = newLimit
// 3，如果mark > newLimit，那么mark = -1
// 这里引用那句通用的话：只有当你确切知道你自己在做什么，你再调用该方法
public final Buffer limit(int newLimit);
```

#### remaining()和hasRemaining()

```java
// 剩余的可用空间，值为limit - position
public final int remaining()；

// 是否有可用空间，值为position < limit的结果值
public final boolean hasRemaining();
```

#### mark()

```java
// 调用mark()方法之后 mark = position;
// 这个是配合reset()方法使用
public final Buffer mark()；
```

### 存取方法-基本操作

既然是一个缓存，那么就能够存取数据，基本操作~

#### put()

```java
// 在position位置放入一个字节
public abstract ByteBuffer put(byte b); 

// 在position位置放入一个byte[]数组，并可以指定范围
public final ByteBuffer put(byte[] src);
public ByteBuffer put(byte[] src, int offset, int length);

// 从position开始放入 传入的ByteBuffer中的从position开始到limit的数据
public ByteBuffer put(ByteBuffer src);

// 对指定下标的字节进行替换
public abstract ByteBuffer put(int index, byte b); 

// 还有一系列的putXxx方法，如
public abstract ByteBuffer putChar(char value);
public abstract ByteBuffer putChar(int index, char value);
// ...省略其他
```

##### 测试

```java
public static void main(String[] args) throws IOException {
    File f = new File("d:/temp/e.txt");
    System.setOut(new PrintStream(f));
    
    ByteBuffer byteBuffer = ByteBuffer.allocate(50);
    byte[] byteArray = byteBuffer.array();

    System.out.println("初始化:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("put(byte b):");
    byteBuffer.put("a".getBytes()[0]);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("put(byte[] src):");
    byteBuffer.put("bcde".getBytes());
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("put(ByteBuffer src):");
    ByteBuffer src = ByteBuffer.allocate(20);
    src.put("hijklmn".getBytes());
    src.flip();
    byteBuffer.put(src);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("put(int index, byte b):");
    byteBuffer.put(5, "t".getBytes()[0]);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putChar(char c):");
    byteBuffer.putChar('t');
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putFloat(float f):");
    byteBuffer.putFloat(1F);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putDouble(double f):");
    byteBuffer.putDouble(2D);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putShort(short s):");
    byteBuffer.putShort((short) 25);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putInt(int i):");
    byteBuffer.putInt(5);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putLong(long l):");
    byteBuffer.putLong(10L);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
}
```

##### 结果

```
初始化:
position :0
remaining:50
limit    :50
capacity :50
内容              :                                                  
---------------------
put(byte b):
position :1
remaining:49
limit    :50
capacity :50
内容              :a                                                 
---------------------
put(byte[] src):
position :5
remaining:45
limit    :50
capacity :50
内容              :abcde                                             
---------------------
put(ByteBuffer src):
position :12
remaining:38
limit    :50
capacity :50
内容              :abcdehijklmn                                      
---------------------
put(int index, byte b):
position :12
remaining:38
limit    :50
capacity :50
内容              :abcdetijklmn                                      
---------------------
putChar(char c):
position :14
remaining:36
limit    :50
capacity :50
内容              :abcdetijklmn t                                    
---------------------
putFloat(float f):
position :18
remaining:32
limit    :50
capacity :50
内容              :abcdetijklmn t?�                                  
---------------------
putDouble(double f):
position :26
remaining:24
limit    :50
capacity :50
内容              :abcdetijklmn t?�  @                               
---------------------
putShort(short s):
position :28
remaining:22
limit    :50
capacity :50
内容              :abcdetijklmn t?�  @                              
---------------------
putInt(int i):
position :32
remaining:18
limit    :50
capacity :50
内容              :abcdetijklmn t?�  @                             
---------------------
putLong(long l):
position :40
remaining:10
limit    :50
capacity :50
内容              :abcdetijklmn t?�  @                  
          
---------------------
```

#### get()

取，和存是相对的

```java
// 获取当前position的值，并且position加1
public abstract byte get(); 

// 获取指定byte[]数组大小的数据，并且可以指定范围，byte[]数组的大小如果大于可取数据的范围，会报错
public ByteBuffer get(byte[] dst);
public ByteBuffer get(byte[] dst, int offset, int length);

// 获取指定下标的值，不会影响到position
public abstract byte get(int index); 

// 还有一系列的getXxx方法，如
public abstract char getChar();
public abstract char getChar(int index);
// ...省略其他
```

##### 测试

```java
public static void main(String[] args) throws IOException {
    ByteBuffer byteBuffer = ByteBuffer.allocate(50);
    byte[] byteArray = byteBuffer.array();
    
    System.out.println("初始化:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("put(byte b):");
    byteBuffer.put("a".getBytes()[0]);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("put(byte[] src):");
    byteBuffer.put("bcde".getBytes());
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("put(ByteBuffer src):");
    ByteBuffer src = ByteBuffer.allocate(20);
    src.put("hijklmn".getBytes());
    src.flip();
    byteBuffer.put(src);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("put(int index, byte b):");
    byteBuffer.put(5, "t".getBytes()[0]);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putChar(char c):");
    byteBuffer.putChar('t');
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putFloat(float f):");
    byteBuffer.putFloat(1F);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putDouble(double f):");
    byteBuffer.putDouble(2D);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putShort(short s):");
    byteBuffer.putShort((short) 3);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putInt(int i):");
    byteBuffer.putInt(4);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("putLong(long l):");
    byteBuffer.putLong(5L);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    // 后面看flip()方法的时候再说什么用
    byteBuffer.flip();
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("get(byte b):");
    System.out.println("获取结果    :" + new String(new byte[]{byteBuffer.get()}));
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("get(byte[] src):");
    byte[] getBytes = new byte[11];
    byteBuffer.get(getBytes);
    System.out.println("获取结果    :" + new String(getBytes));
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");


    System.out.println("get(int index):");
    System.out.println("获取结果    :" + new String(new byte[]{byteBuffer.get(5)}));
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");


    System.out.println("getChar():");
    System.out.println("获取结果    :" + byteBuffer.getChar());
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("getFloat():");
    System.out.println("获取结果    :" + byteBuffer.getFloat());
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("getDouble():");
    System.out.println("获取结果    :" + byteBuffer.getDouble());
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("getShort():");
    System.out.println("获取结果    :" + byteBuffer.getShort());
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("getInt():");
    System.out.println("获取结果    :" + byteBuffer.getInt());
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    System.out.println("getLong():");
    System.out.println("获取结果    :" + byteBuffer.getLong());
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
}
```

##### 结果

```
初始化:
position :0
remaining:50
limit    :50
capacity :50
内容              :                                                  
---------------------
put(byte b):
position :1
remaining:49
limit    :50
capacity :50
内容              :a                                                 
---------------------
put(byte[] src):
position :5
remaining:45
limit    :50
capacity :50
内容              :abcde                                             
---------------------
put(ByteBuffer src):
position :12
remaining:38
limit    :50
capacity :50
内容              :abcdehijklmn                                      
---------------------
put(int index, byte b):
position :12
remaining:38
limit    :50
capacity :50
内容              :abcdetijklmn                                      
---------------------
putChar(char c):
position :14
remaining:36
limit    :50
capacity :50
内容              :abcdetijklmn t                                    
---------------------
putFloat(float f):
position :18
remaining:32
limit    :50
capacity :50
内容              :abcdetijklmn t?�                                  
---------------------
putDouble(double f):
position :26
remaining:24
limit    :50
capacity :50
内容              :abcdetijklmn t?�  @                               
---------------------
putShort(short s):
position :28
remaining:22
limit    :50
capacity :50
内容              :abcdetijklmn t?�  @                              
---------------------
putInt(int i):
position :32
remaining:18
limit    :50
capacity :50
内容              :abcdetijklmn t?�  @                             
---------------------
putLong(long l):
position :40
remaining:10
limit    :50
capacity :50
内容              :abcdetijklmn t?�  @                            
---------------------
position :0
remaining:40
limit    :40
capacity :50
内容              :abcdetijklmn t?�  @                            
---------------------
get(byte b):
获取结果    :a
position :1
remaining:39
limit    :40
capacity :50
内容              :abcdetijklmn t?�  @                            
---------------------
get(byte[] src):
获取结果    :bcdetijklmn
position :12
remaining:28
limit    :40
capacity :50
内容              :abcdetijklmn t?�  @                            
---------------------
get(int index):
获取结果    :t
position :12
remaining:28
limit    :40
capacity :50
内容              :abcdetijklmn t?�  @                            
---------------------
getChar():
获取结果    :t
position :14
remaining:26
limit    :40
capacity :50
内容              :abcdetijklmn t?�  @                            
---------------------
getFloat():
获取结果    :1.0
position :18
remaining:22
limit    :40
capacity :50
内容              :abcdetijklmn t?�  @                            
---------------------
getDouble():
获取结果    :2.0
position :26
remaining:14
limit    :40
capacity :50
内容              :abcdetijklmn t?�  @                            
---------------------
getShort():
获取结果    :3
position :28
remaining:12
limit    :40
capacity :50
内容              :abcdetijklmn t?�  @                            
---------------------
getInt():
获取结果    :4
position :32
remaining:8
limit    :40
capacity :50
内容              :abcdetijklmn t?�  @                            
---------------------
getLong():
获取结果    :5
position :40
remaining:0
limit    :40
capacity :50
内容              :abcdetijklmn t?�  @                            
---------------------
```

### 重要方法-骚操作

看似简单，不过想出这些方法，真是骚操作~

#### 预备读flip()

我们创建完ByteBuffer，使用put()方法往里面放东西，然后我们想要把东西取出来，此时不能直接调用get()方法取，如下：

```
如申请容器容量为10，初始化后
mark = -1;position = 0;capacity = 10;limit = 10; (初始化时limit的值为capacity的值)

0 1 2 3 4 5 6 7 8 9 
- - - - - - - - - -

然后放入ab，如下
mark = -1;position = 2;capacity = 10;limit = 10; 

0 1 2 3 4 5 6 7 8 9 
a b - - - - - - - -

再放入cd，如下
mark = -1;position = 4;capacity = 10;limit = 10; 

0 1 2 3 4 5 6 7 8 9 
a b c d - - - - - -

每次写的时候，都是从position写到limit，读的时候也是从position读到limit
所以初始化完了的时候，我们可以从0(position=0)写到10(limit=10)

写入了ab和cd，此时position=4,limit=10，然后我们想要读了，那么我们肯定不能直接调用get()方法，如果直接调用，(此时position=4,limit=10),不就意味着从4读到10了么？

所以骚操作就在这里，提供了一个flip()方法，将limit=position, position=0，那么我们就可以从0读到4了，这正是我们想要的范围。

也就是调用了flip()方法，进入了读状态，我们才可以调用get()方法读取数据
```

prepare for writing，告诉卡车司机，准备卸货，卡车准备卸东西，要从卡车中里取出东西

```java
limit=position
position=0
```

要准备从卡车中卸东西，会把limit=position,position=0。这样我们从position开始卸东西，卸到limit的位置就知道卸完了。（因为容器可能没有装满，把limit=position就是为了不读取Limit后面的东西，从而不会出现null）


##### 测试

```java
public static void main(String[] args) throws IOException {
    ByteBuffer byteBuffer = ByteBuffer.allocate(50);
    byte[] byteArray = byteBuffer.array();
    System.out.println("初始化:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    byteBuffer.put("hello world".getBytes());
    System.out.println("写入hello world后:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    // 调用flip()，进入读状态
    byteBuffer.flip();
    System.out.println("进入读状态:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    byte[] bytes = new byte[100];
    int remaing = byteBuffer.remaining();
    byteBuffer.get(bytes, 0, remaing);
    System.out.println("读取内容：" + new String(bytes, 0, remaing));
    System.out.println("读取完毕后:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
}
```

##### 结果

初始化后各个参数如下

```
初始化:
position :0
remaining:50
limit    :50
capacity :50
内容              :                                                  
---------------------
```

写入hello world后，position移动了, 可写空间remaining(limit - position)也变化了

```java
写入hello world后:
position :11
remaining:39
limit    :50
capacity :50
内容              :hello world                                       
---------------------
```


调用flip()后进入读状态，可以看到，limit=postion，position=0，remaining就是当前可读的字节数共11个字节~

```java
进入读状态:
position :0
remaining:11
limit    :11
capacity :50
内容              :hello world                                       
---------------------

```

读取所有remaining的字节后，发现position=limit，就代表读完了。

```java
读取内容：hello world
读取完毕后:
position :11
remaining:0
limit    :11
capacity :50
内容              :hello world                                       
---------------------
```


#### 重读rewind()

有时候我们读取ByteBuffer中的内容，从position读到limit之后就算是读完了，如果我们想要重复读取内容，此时将position=0，然后再次从position读到limit就可以了。ByteBuffer类提供了一个方法，就是rewind()

```java
position=0
```

rewind和flip()相似，但是它不影响上界属性limit。它只是将position=0。

场景：在使用了flip()后，调用rewind()来将position=0，再次从头开始读取。


##### 测试

还是使用flip()的代码就是后面加了一个rewind的使用

```java
public static void main(String[] args) throws IOException {
    ByteBuffer byteBuffer = ByteBuffer.allocate(50);
    byte[] byteArray = byteBuffer.array();
    System.out.println("初始化:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    byteBuffer.put("hello world".getBytes());
    System.out.println("写入hello world后:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    // 调用flip()，进入读状态
    byteBuffer.flip();
    System.out.println("进入读状态:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    byte[] bytes = new byte[100];
    int remaing = byteBuffer.remaining();
    byteBuffer.get(bytes, 0, remaing);
    System.out.println("读取内容：" + new String(bytes, 0, remaing));
    System.out.println("读取完毕后:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    // 使用rewind()重置position，再次读取
    byteBuffer.rewind();
    System.out.println("rewind()之后:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
    
    bytes = new byte[100];
    final int readLength = 5;
    byteBuffer.get(bytes, 0, readLength);
    System.out.println("读取内容：" + new String(bytes, 0, readLength));
    System.out.println("读取完毕后:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
}
```

##### 结果

前面的结果一样

```java
初始化:
position :0
remaining:50
limit    :50
capacity :50
内容              :                                                  
---------------------
写入hello world后:
position :11
remaining:39
limit    :50
capacity :50
内容              :hello world                                       
---------------------
进入读状态:
position :0
remaining:11
limit    :11
capacity :50
内容              :hello world                                       
---------------------
读取内容：hello world
读取完毕后:
position :11
remaining:0
limit    :11
capacity :50
内容              :hello world                                       
---------------------
```

可以发现使用rewind()的之后，position变为0

```java
rewind()之后:
position :0
remaining:11
limit    :11
capacity :50
内容              :hello world                                       
---------------------
```

读取5个字节后，position相应的变化了~

```	java
读取内容：hello
读取完毕后:
position :5
remaining:6
limit    :11
capacity :50
内容              :hello world                                       
---------------------
```

#### 预备写clear()

循环使用缓存嘛，写完了读，读完了再写，写完了再读~。当我们读完了缓存内的东西，需要再写时，调用clear()进入写状态。


和filp()方法相对，prepare for reading，告诉卡车司机，准备装货，要把东西装到卡车中。

```java
limit=capacity
position=0
```

##### 测试

前面部分还是一样的

```java
public static void main(String[] args) throws IOException {
    ByteBuffer byteBuffer = ByteBuffer.allocate(50);
    byte[] byteArray = byteBuffer.array();
    System.out.println("初始化:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    byteBuffer.put("hello world".getBytes());
    System.out.println("写入hello world后:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    // 调用flip()，进入读状态
    byteBuffer.flip();
    System.out.println("进入读状态:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    byte[] bytes = new byte[100];
    int remaing = byteBuffer.remaining();
    byteBuffer.get(bytes, 0, remaing);
    System.out.println("读取内容：" + new String(bytes, 0, remaing));
    System.out.println("读取完毕后:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    // 读完后再次进入写状态
    byteBuffer.clear();
    System.out.println("clear()之后:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    byteBuffer.put("Java NIO".getBytes());
    System.out.println("写入Java NIO后:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
}
```



##### 结果

前面结果相同

```java
初始化:
position :0
remaining:50
limit    :50
capacity :50
内容              :                                                  
---------------------
写入hello world后:
position :11
remaining:39
limit    :50
capacity :50
内容              :hello world                                       
---------------------
进入读状态:
position :0
remaining:11
limit    :11
capacity :50
内容              :hello world                                       
---------------------
读取内容：hello world
读取完毕后:
position :11
remaining:0
limit    :11
capacity :50
内容              :hello world                                       
---------------------
```

调用clear()进度写状态之后，可以看到内容`hello world`还在，说明clear()没有清空缓存，只是更改了position和limit的值。

```java
clear()之后:
position :0
remaining:50
limit    :50
capacity :50
内容              :hello world                                       
---------------------
```

重新写入内容

```java
写入Java NIO后:
position :8
remaining:42
limit    :50
capacity :50
内容              :Java NIOrld                                       
---------------------
```

#### 移到标记处reset()和mark()

* reset()方法是和mark()方法合用的。
* reset()返回到先前mark()的那个位置，即将position=mark，如果没有设置mark值调用reset()将抛出异常InvalidMarkException。
* 调用rewind(),clear(),flip()会清空标记。


测试

```java
public static void main(String[] args) throws IOException {
    ByteBuffer byteBuffer = ByteBuffer.allocate(50);
    byte[] byteArray = byteBuffer.array();
    System.out.println("初始化:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    byteBuffer.put("hello world".getBytes());
    System.out.println("写入hello world后:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    // mark之后
    byteBuffer.position(2).mark().position(7);
    System.out.println("mark 之后");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");


    byte[] bytes = new byte[2];
    byteBuffer.get(bytes);
    System.out.println("未调用reset()之前读取两个字节:" + new String(bytes));
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    byteBuffer.reset();
    System.out.println("调用reset()状态:");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");

    byte[] bytesAfterReset = new byte[2];
    byteBuffer.get(bytesAfterReset);
    System.out.println("读取两个字节后:" + new String(bytesAfterReset));
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
}
```

结果

```java
初始化:
position :0
remaining:50
limit    :50
capacity :50
内容              :                                                  
---------------------
写入hello world后:
position :11
remaining:39
limit    :50
capacity :50
内容              :hello world                                       
---------------------
```

调用`byteBuffer.position(2).mark().position(7);`将position设为了7

```java
mark 之后
position :7
remaining:43
limit    :50
capacity :50
内容              :hello world                                       
---------------------
```

`hello world` position为7读取两个字节后，得到`or`，并且position为9

```java
未调用reset()之前读取两个字节:or
position :9
remaining:41
limit    :50
capacity :50
内容              :hello world                                       
---------------------
```

调用reset()之后position被重新设置了~，因为在`position(2).mark()`，所以回到了position=2

```java
调用reset()状态:
position :2
remaining:48
limit    :50
capacity :50
内容              :hello world                                       
---------------------
```

此时读取两个字节，为`ll`

```java
读取两个字节后:ll
position :4
remaining:46
limit    :50
capacity :50
内容              :hello world                                       
---------------------
```

### 其他方法

#### array()方法

```java
// 只有当前ByteBuffer
// 1，不是直接缓存（使用allocateDirect()构建的）
// 2，不是只读
// 返回ByteBuffer中的缓存数组。注意，返回的是一个引用
// 所以返回的byte[]就是那个缓存数组
public final byte[] array();
```

验证一下：如下是代码片段，调用byteBuffer.array();，然后打印byteArray的内容，然后往byteBuffer中加入内容，再次打印byteArray的内容，可以发现结果不同了。

```java
byte[] byteArray = byteBuffer.array();
System.out.println("__>" + new String(byteArray));
byteBuffer.put("hijklmn".getBytes());
System.out.println("__>" + new String(byteArray));

```

结果：说明返回的不是副本，就是缓存的引用

```
__>abcdeobqrst
__>abcdeobqrsthijklmn
```

#### asXxxBuffer()

获取ByteBuffer的视图，视图和原始的ByteBuffer的position,limit,mark这几个变量都没有关系了~


```
public abstract CharBuffer asCharBuffer();
public abstract FloatBuffer asFloatBuffer();
// ...省略
```

#### duplicate()方法

```java
// 复制当前的ByteBuffer并返回
// 注意：二者共享缓存，但是二者的capacity, limit, position, mark 这些变量值是独立的
// 新ByteBuffer和当前的ByteBuffer的类型将会是一致的，如：当前ByteBuffer是直接缓存的，那么新ByteBuffer也是直接缓存的。当前ByteBuffer是只读的，那么新ByteBuffer也是只读的。
public abstract ByteBuffer duplicate();
```

#### compareTo()方法


```java
// 和另外一个ByteBuffer进行比较
// 比较的是剩下的字符(即position到limit之间的字符)是否相同
public int compareTo(ByteBuffer that) {
```

##### 测试

```java
	public static void main(String[] args) throws IOException {
		ByteBuffer byteBuffer1 = ByteBuffer.allocate(20);
		ByteBuffer byteBuffer2 = ByteBuffer.allocate(20);
		ByteBuffer byteBuffer3 = ByteBuffer.allocate(40);
		ByteBuffer byteBuffer4 = ByteBuffer.allocate(50);
		
		byte[] bytes = "hello world".getBytes();
		byteBuffer1.put(bytes);
		byteBuffer2.put(bytes);
		byteBuffer3.put(bytes);
		byteBuffer4.put(bytes);
		
		System.out.println(byteBuffer1.compareTo(byteBuffer2));
		System.out.println(byteBuffer1.compareTo(byteBuffer3));
		System.out.println(byteBuffer1.compareTo(byteBuffer4));
		System.out.println("第一次结果:");
		byteBuffer1.flip();
		byteBuffer2.flip();
		byteBuffer3.flip();
		byteBuffer4.flip();
		System.out.println("第二次结果:");
		System.out.println(byteBuffer1.compareTo(byteBuffer2));
		System.out.println(byteBuffer1.compareTo(byteBuffer3));
		System.out.println(byteBuffer1.compareTo(byteBuffer4));
	}
```

结果

```java
第一次结果:
0
-20
-30
第二次结果:
0
0
0
```

为什么byteBuffer1、byteBuffer3、byteBuffer4放入了相同的数据而不等？

为什么byteBuffer1和byteBuffer3、4第一次不等，而flip()之后就相等了呢？


因为 compareTo()方法对比的是剩下的字符(即position到limit之间的字符)是否相同

```java
byteBuffer1  position=11 limit=20
byteBuffer2  position=11 limit=20
byteBuffer3  position=11 limit=40
byteBuffer4  position=11 limit=50

byteBuffer1和byteBuffer2的remaining的长度和字符都相同，所以这两个相等
而byteBuffer1和byteBuffer3，byteBuffer4剩余的remaining长度不相同，虽然内容都是null，所以他们之间不相等

filp()之后,byteBuffer1、2、3、4中的剩余（remaning）内容都是 hello world ，所以他们四个都相等
```

#### isDirect()

判断是否是直接缓存

#### isReadOnly()

判断是否只读

```java
public abstract class Buffer {
    public abstract boolean isReadOnly()
}
```

#### compact压缩

ByteBuffer的一个方法。

调用该方法后，丢弃已经释放的数据，保留未释放的数据，并使缓冲区进入 预备写状态

##### 测试

```java
public static void main(String[] args) throws IOException {
    ByteBuffer byteBuffer = ByteBuffer.allocate(30);
    byte[] byteArray = byteBuffer.array();
    
    byte[] bytes = "hello world".getBytes();
    byteBuffer.put(bytes);
    
    System.out.println("写入hello world后");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
        
    System.out.println("调用flip(),进入读状态");
    byteBuffer.flip();
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
    
    System.out.println("读取三个字节后");
    byteBuffer.get();
    byteBuffer.get();
    byteBuffer.get();
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
    
    byteBuffer.compact();
    System.out.println("compact()之后");
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
    
    // 压缩之后进入写状态
    byteBuffer.put(bytes);
    System.out.println("position :" + byteBuffer.position());
    System.out.println("remaining:" + byteBuffer.remaining());
    System.out.println("limit    :" + byteBuffer.limit());;
    System.out.println("capacity :" + byteBuffer.capacity());
    System.out.println("内容              :" + new String(byteArray));
    System.out.println("---------------------");
}
```

##### 结果

```java
写入hello world后
position :11
remaining:19
limit    :30
capacity :30
内容              :hello world                   
---------------------
调用flip(),进入读状态
position :0
remaining:11
limit    :11
capacity :30
内容              :hello world                   
---------------------
读取三个字节后
position :3
remaining:8
limit    :11
capacity :30
内容              :hello world                   
---------------------
```

使用compact()之后，因为前面的`hel`已经被读取了，所以被“压缩”掉了，后面的数据依次左移，最后留下了
`rld`，不会进行删除置空

此时该byteBuffer默认进入了写状态，可以往里面写东西


```java
compact()之后
position :8
remaining:22
limit    :30
capacity :30
内容              :lo worldrld                   
---------------------

```

往里面写东西，可以发现最后的那个`rld`被覆盖了

```java

position :19
remaining:11
limit    :30
capacity :30
内容              :lo worldhello world           
---------------------
```


参考书籍、博客。部分图片来自于这些博客

* 《Java NIO》Ron Hitchens著
* [深入理解BufferedInputStream实现原理](https://blog.csdn.net/zhangping871/article/details/54016604)
* [ByteBuffer常用方法详解](https://blog.csdn.net/z69183787/article/details/77102198)
* [ByteBuffer的allocate和allocateDirect](https://www.cnblogs.com/mengfanrong/p/3984841.html)
