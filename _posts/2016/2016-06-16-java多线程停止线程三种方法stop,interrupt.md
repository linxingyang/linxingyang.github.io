---
layout: post
permalink: /:year/8b072ff2a1da49c2be516443214d2aee
title: 2016-03-23-java-多线程停止三种方法stop_interrupt
categories: [java]
tags: [java,多线程,停止方法]
excerpt: java,多线程,停止方法
description: java多线程停止三种方法stop_interrupt

---


# 停止线程的3种方法 #

## 1，标记法：在run方法中使用标记，完成后退出 ## 

```java


private boolean flag = true;
public void run() {
    while (flag) {
        // 继续运行
    }    
}
public void setFlag(boolean flag) {
    this.flag = flag;
}


```

怎么控制线程的结束呢？

任务中都会有循环结构，只要控制住循环，就可以结束任务。
（为什么线程中都会有循环结构？如果没有循环结构，为什么
要单开一个线程来执行？直接在主线程执行不就完了？,当然现在想想也非必然，比如进行一些复杂的计算等等）



### 例子：标记法从运行中结束 ###


```java

package lxy.Test4;

/**
 * 停止线程，设置一个标记
 * 
 * @author lxy
 * 
 */
public class T01 {

	public static void main(String[] args) {
		StopThread st = new StopThread();
		Thread t1 = new Thread(st);
		Thread t2 = new Thread(st);
		t1.start();
		t2.start();

		for (int i = 0; i < 50; i++) {
			if (i == 49) {
				st.stopThread();
			}
			System.out.println("mainThread..." + i);
		}
	}
}

class StopThread implements Runnable {
	private boolean flag = true;

	@Override
	public void run() {
		while (flag) {
			System.out.println(Thread.currentThread().getName());
		}
	}

	public void stopThread() {
		flag = false;
	}
}

```





### 例子：标记法+interrupt()从阻塞中结束 ###



如果线程处于阻塞状态，实际上是没有运行的，无法执行到读取标记代码，那又该如何结束呢？

可以用interrupt()方法将线程从阻塞状态中强制恢复到运行状态中，让线程具备cpu的执行资格，但是强制动作会产生InterruptedException 记得要处理



interrupt();   方法

```java

package lxy.Test4;

/**
 * 停止线程，使用interrupte()
 * 
 * @author lxy
 * 
 */
public class T01 {

	public static void main(String[] args) {
		StopThread st = new StopThread();
		Thread t1 = new Thread(st);
		Thread t2 = new Thread(st);
		t1.start();
		t2.start();

		for (int i = 0; i < 50; i++) {
			if (i == 49) {
				// 这里要使用interrupte()方法。
				// 来唤醒在wait的线程1和线程2
				// st.stopThread();
				t1.interrupt();
				t2.interrupt();
			}
			System.out.println("mainThread..." + i);
		}
	}
}

class StopThread implements Runnable {
	private boolean flag = true;

	@Override
	public synchronized void run() {
		while (flag) {

			try {
				wait();
			} catch (InterruptedException e) {
				// 线程被强制唤醒（改变状态）之后，会产生InterruptedException
				System.out.println(Thread.currentThread().getName() + "....."
						+ e);
				// 要在这里将flag设为false，不然一直会执行。
				flag = false;
			}
			System.out.println(Thread.currentThread().getName() + " ....+++=");
		}
	}

	public void stopThread() {
		flag = false;
	}
}

```



## 2，使用stop方法强行终止线程（不推荐，已废弃） ##

不推荐使用这个方法，因为stop和suspend以及resume与，都是作废过期的方法，使用它们可能产生不可意料的结果（不使用）


### 停止线程--暴力法 使用stop ###

```java

package thread;

public class App4 {
	public static void main(String[] args) throws InterruptedException {
		MyT4 m1 = new MyT4();
		m1.start();
		Thread.currentThread().sleep(3000);
		m1.stop();
	}
}

class MyT4 extends Thread {

	@Override
	public void run() {
		try {
			for (int i = 0; i < 100000; i++) {
				Thread.sleep(1000);
				System.out.println("i = " + i);
			}
		} catch (InterruptedException e) {
			System.out.println("进入了异常. this.isInterrupted()=" + this.isInterrupted());
		}
	}
}
输出：
i = 0
i = 1
i = 2

结果分析
使用stop直接干掉了线程。。

```

使用 stop()方法会抛出异常java.lang.ThreadDeath异常，但在通常情况下不需要显示的捕捉。

方法stop已被作废，因为如果强制停止线程，可能使得一些请理性的工作得不到完成。另外一个情况就是对锁定对象进行了“解锁”，导致数据得不到同步处理，出现数据不一致。

不建议使用stop


## 3，使用 interrupt方法中断线程 ##



### interrupt()方法 测试 ###



#### 测试一 ####

```java
class MyThread4 extends Thread {
	@Override
	public void run() {
		final int loop =  50 * 1000;
		for (int i = 0; i < loop; i++) {
			System.out.println(i);
		}
		System.out.println("线程运行完毕");
	}
}
public class ThreadStopTest {

	public static void main(String[] args) throws InterruptedException {
	
		MyThread4 myThread4 = new MyThread4();
		myThread4.start();
		myThread4.interrupt();
		System.out.println("主线程运行完毕");
	}
}
```

结果

```java
...
49992
49993
49994
49995
49996
49997
49998
49999
线程运行完毕
    
```

分析

```java
可以看到线程一直运行到最后，调用interrupt()没有真正的让线程停止

```



#### 测试二：对sleep中的线程调用其intterupt()方法 ####

```java

class MyThread7 extends Thread {
	@Override
	public void run() {
		try {
			System.out.println("睡3秒...");
			Thread.sleep(3 * 1000);
			System.out.println("线程运行完毕");
		} catch (InterruptedException e) {
			System.out.println("出错了");
			e.printStackTrace();
		}
		System.out.println("会继续执行的代码");
	}
}

public class ThreadStopTest {

	public static void main(String[] args) throws InterruptedException {
	
		MyThread7 myThread7 = new MyThread7();
		myThread7.start();
		Thread.sleep(1000);
		myThread7.interrupt();
	}
}
```



结果

```java
睡3秒...
java.lang.InterruptedException: sleep interrupted
	at java.lang.Thread.sleep(Native Method)
	at thx.MyThread7.run(ThreadStopTest.java:36)
出错了
会继续执行的代码

```

分析

```java
在线程sleep中，调用其interrupt()会导致其抛出InterruptedException
```







单独调用 thread.interrupt无法停止线程，要结合下面两个方法来做。

```java

public static boolean interrupted() // 测试当前线程是否已经中断,执行后具有将状态标识清除为false的功能
    
public boolean isInterrupted() // 测试线程是否已经中断，但不清除状态标志。如果线程已死，那么此方法返回false。

```

### public static boolean interrupted()  方法测试 ###

```java

package com.thread;

class MyThread4 extends Thread {
	@Override
	public void run() {
		for (int i = 0; i < 50000; i++) {
		}
	}
}

```

#### 测试一 ####



```java

public class App5 {

	public static void main(String[] args) throws InterruptedException {
		MyThread4 t = new MyThread4();
		t.start();
		Thread.sleep(1000);
		t.interrupt(); // 注意调用的是线程t的interrupt()
        // 这里Thread.interrupted()调用的是当前线程，即main的interrupted()。
		System.out.println("是否停止1 ？" + Thread.interrupted());  // false
		System.out.println("是否停止2？" + Thread.interrupted()); // false

	}
}

```

测试结果

```

是否停止1 ？false
是否停止2？false

```

分析

```
此时当前线程为  main，main从未停止过，所以两个都是false 

```



#### 测试二 ####



```java

public class App5 {

	public static void main(String[] args) throws InterruptedException {
		MyThread4 t = new MyThread4();
		t.start();
		Thread.sleep(1000);
		// t.interrupt();
		Thread.currentThread().interrupt(); // 调用线程main的interrupt()
        // 调用线程main的interrupted()
		System.out.println("是否停止1 ？" + Thread.interrupted()); // true
		System.out.println("是否停止2？" + Thread.interrupted()); // false
	}
}

```

测试结果：

```

是否停止1 ？true
是否停止2？false

```

分析：

```
首先调用了Thread.currentThread().interrupt()希望让main线程停止，但是可以发现后面语句继续执行了

因为单独调用 thread.interrupt无法停止线程，它只是打了一个停止的标记，并不是真正的停止线程。

下面这个输出true在意料之中 
System.out.println("是否停止1 ？" + Thread.interrupted()); // true

那么第二个为什么是false呢？
System.out.println("是否停止2？" + Thread.interrupted()); // false
因为 interrupted()方法执行后具有将状态标识清除为false的功能，所以第二次打印的时候为false。


```

### public boolean isInterrupted()方法测试 ###



```java
class MyThread6 extends Thread {
	@Override
	public void run() {
		for (int i = 0; i < Integer.MAX_VALUE; i++) {
			
		}
		System.out.println("线程运行完毕");
	}
}

```



#### 测试一 ####



```java
public class ThreadStopTest {

	public static void main(String[] args) throws InterruptedException {

		MyThread6 myThread6 = new MyThread6();
		myThread6.start();
		myThread6.interrupt();
		System.out.println("是否活着1 ---" + myThread6.isAlive()); // true
		System.out.println("是否停止1 ？" + myThread6.isInterrupted()); // true
		System.out.println("是否活着2 ---" + myThread6.isAlive()); // true
		System.out.println("是否停止2 ？" + myThread6.isInterrupted()); // true
		System.out.println("是否活着3 ---" + myThread6.isAlive()); // true
		
	}
}
```

结果 

```java

是否活着1 ---true
是否停止1 ？true
是否活着2 ---true
是否停止2 ？true
是否活着3 ---true
线程运行完毕

```



分析：

```java
调用了一次interrupte()，其isInterrupted()返回的都是true，说明isInterrupted不会清除状态

```



#### 测试二  ###



```java

public class ThreadStopTest {

	public static void main(String[] args) throws InterruptedException {
		// interruptTest1();
		// interrupteTest2();
	
		MyThread6 myThread6 = new MyThread6();
		myThread6.start();
		// 为了让myThread6线程执行完毕，主线程睡3秒
		Thread.sleep(3 * 1000);
		myThread6.interrupt();
		System.out.println("是否活着1 ---" + myThread6.isAlive()); // false
		System.out.println("是否停止1 ？" + myThread6.isInterrupted()); // false
		System.out.println("是否活着2 ---" + myThread6.isAlive()); // false
		System.out.println("是否停止2 ？" + myThread6.isInterrupted()); // false
		System.out.println("是否活着3 ---" + myThread6.isAlive()); // false
		
	}
}
```

结果

```java
线程运行完毕
是否活着1 ---false
是否停止1 ？false
是否活着2 ---false
是否停止2 ？false
是否活着3 ---false

```



分析

```java
可以在线程死亡之后调用interrupt();方法
但是在线程运行之后调用isInterrupted()返回false。

```

#### 测试三 ###

```java

public class ThreadStopTest {

	public static void main(String[] args) throws InterruptedException {
		// interruptTest1();
		// interrupteTest2();
		// interrupteTest3();
		// interrupteTest4();
		
		MyThread6 myThread6 = new MyThread6();
		myThread6.start();
		myThread6.interrupt();
		System.out.println("是否活着1 ---" + myThread6.isAlive()); // true
		System.out.println("是否停止1 ？" + myThread6.isInterrupted()); // true
		// 为了让myThread6线程执行完毕，主线程睡3秒
		Thread.sleep(3 * 1000);
		System.out.println("是否活着2 ---" + myThread6.isAlive()); // false
		System.out.println("是否停止2 ？" + myThread6.isInterrupted()); // false
		System.out.println("是否活着3 ---" + myThread6.isAlive()); // false
	}
}
```



结果

```java
是否活着1 ---true
是否停止1 ？true
线程运行完毕
是否活着2 ---false
是否停止2 ？false
是否活着3 ---false

```

分析

```java
调用intterupte()后，线程未死亡之前调用isInterrupted()为true，死亡之后调用isInterrupted()为false 

```




### 使用interrupt停止线程--异常法 ###



#### 异常法测试一 ####

异常法测试一与前面的设置标志法很像。

```
package thread;

public class App1 {
	public static void main(String[] args) throws InterruptedException {
		MyT1 m1 = new MyT1();
		m1.start();
		Thread.currentThread().sleep(100);
		m1.interrupt();
	}
}

class MyT1 extends Thread {

	@Override
	public void run() {
		for (int i = 0; i < 50000; i++) {
			if (this.isInterrupted()) {
				System.out.println("现在已经是停止状态了，我要退出了");
				break;
			}
			System.out.println("i =" + i);
		}
		System.out.println("程序结束了，这句还被执行了。");
	}

}


```



结果



```java

...
i =4555
i =4556
i =4557
i =4558
i =4559
i =4560
i =4561
i =4562
i =4563
i =4564
i =4565
i =4566
i =4567
i =4568
i =4569
现在已经是停止状态了，我要退出了
程序结束了，这句还被执行了。

```

分析

```java
使用这种方法与使用标志法很像，但是其不用再额外设置变量了，利用线程本身的东西来结束。
但同样的问题就是如果for后面还有语句，还会继续执行那个语句，因为本质上不是真正停止线程，而是跳出那个线程
```



#### 异常法测试二，对上面的代码进行改造 ####

测试二就是抛出异常了。

```
package thread;

public class App1 {
	public static void main(String[] args) throws InterruptedException {
		MyT1 m1 = new MyT1();
		m1.start();
		Thread.currentThread().sleep(100);
		m1.interrupt();
	}
}

class MyT1 extends Thread {

	@Override
	public void run() {
		try {
			for (int i = 0; i < 50000; i++) {
				if (this.isInterrupted()) {
					System.out.println("现在已经是停止状态了，我要退出了");
					throw new InterruptedException();
				}
				System.out.println("i =" + i);
			}
			System.out.println("程序结束了，这句还被执行了。");

		} catch (InterruptedException e) {
			System.out.println("使用异常法停止了线程");
		} catch (Exception e) {
			System.out.println("发生其他异常，线程结束");
			throw new RuntimeException(e.getMessage());
		}
	}
}


```



结果

```java
...
i =3894
i =3895
i =3896
i =3897
i =3898
i =3899
i =3900
现在已经是停止状态了，我要退出了
使用异常法停止了线程

```



分析

```java
现在没有执行到for语句后面那句了，正式期待的结果
```



#### 如果在沉睡中调用interrupt停止会怎么样？ ####

前面介绍interrupt()的时候已经看到了会抛异常：sleep和interrupt犯冲，，两个同时出现就出错。



##### 先sleep 后interrupt

```
package thread;

public class App2 {
	public static void main(String[] args) throws InterruptedException {
		MyT2 m1 = new MyT2();
		m1.start();
		Thread.currentThread().sleep(100);
		m1.interrupt();
	}
}

class MyT2 extends Thread {

	@Override
	public void run() {
		try {
			System.out.println("run start");
			Thread.sleep(200000);
			System.out.println("run end");
		} catch (InterruptedException e) {
			System.out.println("使用异常法停止了线程. this.isInterrupted()=" + this.isInterrupted());
		}
	}
}

```

结果

```java

run start
使用异常法停止了线程. this.isInterrupted()=false

```

分析

```java
发现如果线程在沉睡中，被调用 interrup停止，那么产生InterrruptedException错误，
并且通过打印 . this.isInterrupted()=false 可知进入catch后，清除了停止状态值，使之变成false

```



##### 先interrupt后sleep

```
package thread;

public class App3 {
	public static void main(String[] args) throws InterruptedException {
		MyT3 m1 = new MyT3();
		m1.start();
		// Thread.currentThread().sleep(100);
		m1.interrupt();
		System.out.println("main end");
	}
}

class MyT3 extends Thread {

	@Override
	public void run() {
		try {
			for (int i = 0; i < 100000; i++) {
				System.out.println("i = " + i);
			}
			System.out.println("run start");
			Thread.sleep(200000);
			System.out.println("run end");
		} catch (InterruptedException e) {
			System.out.println("进入了异常. this.isInterrupted()=" + this.isInterrupted());
		}
	}
}


```



结果



```java

main end
i = 0
...
i = 99996
i = 99997
i = 99998
i = 99999
run start
进入了异常. this.isInterrupted()=false


```



分析

```java
先停止，后sleep。。。那么会在sleep之时发生错误。sleep之前正常执行。
```





### interrupt结合return 停止线程 ###

结合interrupt 和return。前面interrupte结合异常，使得停止了线程,fro后面的语句不会再执行。 结合return也是同样的道理，


不过还是建议使用interrupt + 异常来，因为异常可以向上抛，使得线程停止事件被传播。

```
package thread;

public class App5 {
	public static void main(String[] args) throws InterruptedException {
		MyT5 m1 = new MyT5();
		m1.start();
		Thread.currentThread().sleep(100);
		m1.interrupt();
	}
}

class MyT5 extends Thread {

	@Override
	public void run() {
		for (int i = 0; i < 50000; i++) {
			if (this.isInterrupted()) {
				System.out.println("现在已经是停止状态了，我要退出了");
				// throw new InterruptedException();
				// 改抛异常为return
				return;
			}
			System.out.println("i =" + i);
		}
		System.out.println("程序结束了，这句还被执行了。");
	}
}



```



结果

```java

...
i =3480
i =3481
i =3482
i =3483
现在已经是停止状态了，我要退出了


```

分析

```java
结合interrupt和return也能结束线程（线程中的任务。。）。
```






