---
layout: post
permalink: /:year/b3e6ea73558241f99cb7e65d864eed1d
title: 2017-08-31-java-StringTokenizer和String.split的区别
categories: [java]
tags: [问题解决,java,equals,StringTokenizer,String.split]
excerpt:  java问题,StringTokenizer,String.split
description: java问题StringTokenizer和String.split

---

```java

package test;

import java.util.Arrays;
import java.util.StringTokenizer;
import java.util.UUID;

public class StringAndStringTokenizer {

	public static void main(String[] args) {
		String uuid = UUID.randomUUID().toString();
		StringTokenizer st = new StringTokenizer(uuid, "-");

		System.out.println(uuid);

		String stUUID = "";
		while (st.hasMoreTokens()) {
			stUUID += st.nextToken();
		}

		String[] splitUUID = uuid.split("-");

		System.out.println(stUUID);
		System.out.println(Arrays.toString(splitUUID));
	}
}

```

从javadoc上看到：StringTokenizer的是一个被保留，是因为兼容性的原因，不鼓励使用在新的代码中。建议任何人都寻求这种功能使用split或java.util.regex包。

转载：String.split和StringTokenizer的区别，String.Split（）使用正则表达式，而StringTokenizer的只是使用逐字分裂的字符。所以，如果我想更复杂的逻辑比单个字符（如\ r \ n分割）来标记一个字符串，可以不使用StringTokenizer，而用String.Split（） 。


