---
layout: post
permalink: /:year/b3e6ea73558241f99cb7e65d864eed21/index
title: 2018-02-22-java-Integer等包装类型中的缓存
categories: [java]
tags: [java]
excerpt:  java,Integer,包装类型,缓存
description: java-Integer等包装类型中的缓存
catalog: false
author: 林兴洋
--- 

一个重要的知识点（其实就是面试官可能会问到的问题）：Integer等包装类型的缓存问题 --  会缓存一个字节范围的对象缓存 。



code.....

```
package thread.c13;

public class App {

	public static void main(String[] args) {
		Integer i1 = 12;
		Integer i2 = 12;
		Integer i3 = new Integer(12); 
		Integer i4 = Integer.valueOf(12);
		Integer i5 = Integer.valueOf("12");
		System.out.println(i1 == i2); // true; 
		System.out.println(i1 == i3); // false
		System.out.println(i1 == i4); // true
		System.out.println(i1 == i5); // false
		System.out.println(i3 == i5); // false
		// i1,i2,i4 同一个对象
		// i3 一个对象
		// i5 一个对象
		
		System.out.println("Integer-------");
		Integer ii1 = 188;
		Integer ii2 = 188;
		Integer ii3 = new Integer(188); 
		Integer ii4 = Integer.valueOf(188);
		Integer ii5 = Integer.valueOf("188");
		System.out.println(ii1 == ii2); // false; 
		System.out.println(ii1 == ii3); // false
		System.out.println(ii1 == ii4); // false
		System.out.println(ii1 == ii5); // false
		System.out.println(ii3 == ii5); // false
		
		System.out.println("Long-------");
		Long g1 = 12L;
		Long g2 = 12L;
		Long g3 = new Long(12);
		Long g4 = Long.valueOf(12L);
		Long g5 = Long.valueOf("12");
		System.out.println(g1 == g2); // true
		System.out.println(g1 == g3); // false
		System.out.println(g1 == g4); // true
		System.out.println(g1 == g5); // false 		
		System.out.println(g3 == g5); // false
			
		System.out.println("Byte-------");
		Byte b1 = 1;
		Byte b2 = 1;
		Byte b3 = new Byte((byte)1);
		Byte b4 = Byte.valueOf((byte)1);
		Byte b5 = Byte.valueOf("1");
		System.out.println(b1 == b2); // true
		System.out.println(b1 == b3); // false
		System.out.println(b1 == b4); // true
		System.out.println(b1 == b5); // false
		System.out.println(b3 == b5); // false
	
		System.out.println("Double-------");
		Double d1 = 1d;
		Double d2 = 1d;
		Double d3 = new Double((double)1);
		Double d4 = Double.valueOf((double)1); 
		Double d5 = Double.valueOf("1");
		System.out.println(d1 == d2); // false
		System.out.println(d1 == d3); // false
		System.out.println(d1 == d4); // false
		System.out.println(d1 == d5); // false
		System.out.println(d3 == d5); // false
	}
}
```





首先，i1为什么等于i2？在自动装箱过程，在java中会对一个字节内的数字进行缓存，可以参考后面valueOf(int i)中的代码，可以看到，一个字节 -128~127之间会进行缓存。所以这两个是相等的。

```java
Integer i1 = 12;
Integer i2 = 12;
```

但是因为范围只有一个字节，所以ii1和ii2是不相等的。

```java
Integer ii1 = 188;
Integer ii2 = 188;
```

而i3是直接new出来的对象，不经过缓存判断，故而

```java
System.out.println(i1 == i3); // false
```

i4相等，而i5又不相等。是为什么？

```java
System.out.println(i1 == i4); // true
System.out.println(i1 == i5); // false
```

看如下Integer源代码，可以发现valueOf方法，当传入一个int的时候，会去读取缓存。而传入一个String的时候，是不读取缓存的，直接返回一个新建的Integer对象。所以i1等于i4,而i1不等于i5.

```java
public static Integer valueOf(int i) {
    final int offset = 128;
    if (i >= -128 && i <= 127) { // must cache 
        return IntegerCache.cache[i + offset];
    }
    return new Integer(i);
}

public static Integer valueOf(String s) throws NumberFormatException
{
    return new Integer(parseInt(s, 10));
}
```



经过测试，**发现Byte,Short,Integer,Long都对值为-128-127，使用自动装箱方式创建或者valueOf(其对应基本类型)创建的对象进行保存。Double,Float没有。**



因为装箱会浪费时间，但是如果每次装箱的对象比较常在-128~127之间，那效率也不会低太多。

```java
package thread.c13;

import java.util.Date;

public class App {

	public static void main(String[] args) {
		int loopTimes = 100000000;
		Date dStart = new Date();
		for (int i = 0; i < loopTimes; i++) {
			Integer i1 = 12;
		}
		Date dEnd = new Date();
		System.out.println("Integer i1 = 12;  " + (dEnd.getTime() - dStart.getTime()));
		
		dStart = new Date();
		for (int i = 0; i < loopTimes; i++) {
			Integer i2 = 188;
		}
		dEnd = new Date();
		System.out.println("Integer i2 = 188; " + (dEnd.getTime() - dStart.getTime()));
		
		dStart = new Date();
		for (int i = 0; i < loopTimes; i++) {
			int i3 = 12;
		}
		dEnd = new Date();
		System.out.println("int i3 = 12;      " + (dEnd.getTime() - dStart.getTime()));
		
		dStart = new Date();
		for (int i = 0; i < loopTimes; i++) {
			int i4 = 188;
		}
		dEnd = new Date();
		System.out.println("int i4 = 188;     " + (dEnd.getTime() - dStart.getTime()));
	}
}
```

结果，可以发现利用自动装箱创建包装类缓存对象（-127~128），时间比创建基本类型仅多了一倍左右（如下i1和i3）当然我这里因为一直创建的是同一个对象，实际创建不同对象时间会多一些。而不在缓存中的包装类对象，时间就多了太多倍了（如下i2和i4）


```
Integer i1 = 12;  118
Integer i2 = 188; 855
int i3 = 12;      59
int i4 = 188;     58
```
