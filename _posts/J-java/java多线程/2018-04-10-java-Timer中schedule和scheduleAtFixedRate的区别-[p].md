---
layout: post
permalink: /:year/4cxx9xxxx0274vsc8622d47e6587bdsd
title: 2018-04-10-java-Timer中schedule和scheduleAtFixedRate的区别
categories: [java]
tags: [java,timer,schedule,scheduleAtFixedRate]
excerpt:  java,Timer,schedule,scheduleAtFixedRate,区别
description: Timer中schedule和scheduleAtFixedRate的区别
catalog: true
author: 林兴洋
---

schedule属于固定延迟的，scheduleAtFixedRate属于固定速率的

一个T代表执行Task中1秒，一个W表示空闲1秒

`TTWWWTTWWWTTWWW`  

好看一点： `TTWWW` `TTWWW` `TTWWW`

那么这一段就代表，一个任务会执行2秒，它的period是5秒（因为从开始执行到下个任务开始执行，有两个T，3个W，5秒一轮回）。

如果其中出现了GC，使用G表示GC回收执行了1秒。

# schedule

> In fixed-delay execution, each execution is scheduled relative to the actual execution time of the previous execution. If an execution is delayed for any reason (such as garbage collection or other background activity), subsequent executions will be delayed as well.

那么在schedule中，因为固定延迟，任务二因为GC被推迟了2秒开始执行，那么任务三是参考的是任务二开始的时间+5秒的延迟。它会是这样的

`TTWWWGGTTWWWTTWWW`

好看一点 ： `TTWWW` `GG` `TTWWW` `TTWWW`

# scheduleAtFixedRate

> In fixed-rate execution, each execution is scheduled relative to the scheduled execution time of the initial execution. If an execution is delayed for any reason (such as garbage collection or other background activity), two or more executions will occur in rapid succession to "catch up."

在scheduleAtFixRate中，因为固定速率，他的速率是参照第一个，所以当其中一个任务因为任何原因被延迟了，后续的任务会进行追赶。它是这样的

`TTWWWGGTTWTTWWW`

好看一点 ： `TTWWW` `GG` `TTW` `TTWWW`


上面情况都是在任务的period周期 > 任务所需要执行的时间。 （任务周期为5S，运行需要1S）

如果任务的周期 < 任务所需要执行的时间（任务周期为5S，运行需要10S）

周期本来是2秒，但是任务运行却需要3秒，这个时候schedule和scheduleAtFixedRate的表现都是一样的，都是上个任务执行完马上执行下个任务（下个任务因为上个任务运行过长已经被延迟了），因为根本没多余的时间来赶。

`TTT` `TTT` `TTT` 

还有由于scheduleAtFixedRate具有追赶性，如果一个任务的firstTime（第一次执行时间）在程序运行时间之前，那么它也会开始追赶

如下：任务执行需要1秒，周期为5秒，并把任务开始时间设置在程序运行的1分钟之前。

```java
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;

public class TimerTest2 {

	final private static SimpleDateFormat sdf = new SimpleDateFormat("HH时mm分ss秒");
	public static void main(String[] args) {
		
		Calendar calendar = Calendar.getInstance();
		System.out.println("程序启动时间:" + sdf.format(calendar.getTime()));
		
		Timer timer = new Timer();
		List<TimerTask> tts = new ArrayList<TimerTask>();
		
		final int taskNumber = 1;
		for (int i = 0; i < taskNumber; i++) {
			final int finalI = i;
			tts.add(new TimerTask() {
				@Override
				public void run() {
					System.out.println(Thread.currentThread().getName() + ":任务" + finalI + "开始时间:" + sdf.format(new Date()));
						try {
							Thread.sleep(1 * 1000);
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
						System.out.println(Thread.currentThread().getName() + ":任务" + finalI + "结束时间:" + sdf.format(new Date()));
				}
			});
		}
        for (int i = 0; i < taskNumber; i++) {
             calendar.add(Calendar.MINUTE, -1);
			timer.scheduleAtFixedRate(tts.get(i), calendar.getTime(), 5 * 1000);
        }
    }
}
```

如下运行结果及注释：

```java
程序启动时间:20时01分43秒
Timer-0:任务0开始时间:20时01分43秒 // 1S正常
Timer-0:任务0结束时间:20时01分44秒 
Timer-0:任务0开始时间:20时01分44秒 // 空闲追赶1
Timer-0:任务0结束时间:20时01分45秒 
Timer-0:任务0开始时间:20时01分45秒 // 空闲追赶2
Timer-0:任务0结束时间:20时01分46秒 
Timer-0:任务0开始时间:20时01分46秒 // 空闲追赶3
Timer-0:任务0结束时间:20时01分47秒 
Timer-0:任务0开始时间:20时01分47秒 // 空闲追赶4
Timer-0:任务0结束时间:20时01分48秒 
Timer-0:任务0开始时间:20时01分48秒 // 1S正常
Timer-0:任务0结束时间:20时01分49秒
Timer-0:任务0开始时间:20时01分49秒 // 空闲追赶5
Timer-0:任务0结束时间:20时01分50秒
Timer-0:任务0开始时间:20时01分50秒 // 空闲追赶6
Timer-0:任务0结束时间:20时01分51秒
Timer-0:任务0开始时间:20时01分51秒 // 空闲追赶7
Timer-0:任务0结束时间:20时01分52秒
Timer-0:任务0开始时间:20时01分52秒 // 空闲追赶8
Timer-0:任务0结束时间:20时01分53秒
Timer-0:任务0开始时间:20时01分53秒 // 1S正常
Timer-0:任务0结束时间:20时01分54秒
Timer-0:任务0开始时间:20时01分54秒 // 空闲追赶9
Timer-0:任务0结束时间:20时01分55秒
Timer-0:任务0开始时间:20时01分55秒 // 空闲追赶10
Timer-0:任务0结束时间:20时01分56秒
Timer-0:任务0开始时间:20时01分56秒 // 空闲追赶11
Timer-0:任务0结束时间:20时01分57秒
Timer-0:任务0开始时间:20时01分57秒 // 空闲追赶12
Timer-0:任务0结束时间:20时01分58秒
Timer-0:任务0开始时间:20时01分58秒 // 追赶完毕，此时开始正常执行
Timer-0:任务0结束时间:20时01分59秒
Timer-0:任务0开始时间:20时02分03秒
Timer-0:任务0结束时间:20时02分04秒
Timer-0:任务0开始时间:20时02分08秒
Timer-0:任务0结束时间:20时02分09秒
Timer-0:任务0开始时间:20时02分13秒
Timer-0:任务0结束时间:20时02分14秒
...

    
```

scheduleAtFixedRate，为了追赶中间这1分钟的差距,它会在上个任务执行完马上执行下个任务。

原来周期为5S，那么差了1分钟，为了追上，要多执行12次（60S / 5S = 12）


程序从20时01分43秒启动，周期为5S，实际任务中只运行1S（因为线程只sleep 1秒），那么剩余的4S（周期5S-运行1S）可以用来追赶前面1分钟的那12次，那12次任务，每个需要1S。

1S正常任务 + 4S追赶（可以追赶4个）

1S正常任务 + 4S追赶（可以追赶4个）

1S正常任务 + 4S追赶（可以追赶4个）

当15秒执行完毕时时，发现已经能追赶上了（12个全部追赶完毕），所以第16秒开始就正常执行，不追赶了。


这里如果我们使用schedule而不是scheduleAtFixedRate，那么是不会去追赶前面少掉的次数的。使用schedule的结果

```java
程序启动时间:20时23分03秒
Timer-0:任务0开始时间:20时23分03秒
Timer-0:任务0结束时间:20时23分04秒
Timer-0:任务0开始时间:20时23分08秒
Timer-0:任务0结束时间:20时23分09秒
Timer-0:任务0开始时间:20时23分13秒
Timer-0:任务0结束时间:20时23分14秒
Timer-0:任务0开始时间:20时23分18秒
Timer-0:任务0结束时间:20时23分19秒
Timer-0:任务0开始时间:20时23分23秒
```


个人理解：

* 在不需要追赶的情况下，schedule和scheduleAtFixedRate的表现一样。
* 在需要追赶的情况下，如果任务执行的时间超过period，二者的表现也是一样的，因为scheduleAtFixedRated没有多余的时间去追赶。

参考：[What is the difference between schedule and scheduleAtFixedRate?
](https://stackoverflow.com/questions/22486997/what-is-the-difference-between-schedule-and-scheduleatfixedrate)