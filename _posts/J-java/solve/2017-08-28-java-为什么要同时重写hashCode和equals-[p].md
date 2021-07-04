---
layout: post
permalink: /:year/a90ab5dbfa254f4385f44268cd663768/index
title: 2017-08-28-java-为什么要同时重写hashCode和equals
categories: [java]
tags: [java,equals,hashCode]
excerpt:  java,equals,hashCode
description: 为什么要同时重写hashCode和equals
catalog: true
author: 林兴洋
---


[toc]
# 为什么要同时重写hashCode和equals？？？

之前也是有点郁闷，为什么javadoc建议二者最好一起重写(hashCode & equals)，通过看文档以及分析了解了一下，下面通过代码的方式来理解一下。

Worker类有id,name,age三个属性，如下

```java
public class Worker {
	private Integer id;
	private String name;
	private Integer age;
	
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id
	}
	// 省略get/set方法
}
```

平时我们比较两个对象是否相等，都是通过equals方法进行比较，比较的是它们在内存中的引用地址。如果两个对象指向同一个地址，那么这两个对象就是相等的。如下代码：

```java
public class Test {
	public static void main(String[] args) {
		Worker w1 = new Worker();
		Worker w2 = new Worker();
		Worker w3 = w1;
		w1.setId(100);
		w2.setId(100);
		
		System.out.println(w1.equals(w2)); // false 
		System.out.println(w1.equals(w3)); // true
	}
}
```



## 重写了equals方法

现在有个需求，如果员工的id相同就认为是同一个员工，那么上面的w1和w2的equals方法此时应该返回true，所以我们要对equals方法进行重写：利用员工id来进行比较是否equals

```java
public class Worker {
	// 属性, get/set方法省略
	
	@Override
	public boolean equals(Object obj) {
		if(!(obj instanceof Worker)) {
			return false;
		}
		if(this == obj) {									/* 引用相同 */
			return true;
		}
		Integer objId = ((Worker)obj).getId();
		if(null != objId && objId.equals(this.getId())) {	/* id相同 */
			return true;
		} else {
			return false;
		}
	}
}
```

重写了equals之后，则下面的测试结果都为true。

```java
public class Test {
	public static void main(String[] args) {
		Worker w1 = new Worker();
		Worker w2 = new Worker();
		Worker w3 = w1;
		w1.setId(100);
		w2.setId(100);
		
		System.out.println(w1.equals(w2)); // true 
		System.out.println(w1.equals(w3)); // true
	}
}
```



## 重写hashCode方法

现在又有了新的需求，需要把Worker对象保存在HashSet中。

啪啪啪打完代码，如下，但是此时却出现了我们不想看到的情况，worker.size()为2，应该是1的， 因为我们认为w1等于w2。

```java
public class Test {
	public static void main(Stirng[] args) {
		Worker w1 = new Worker();
		Worker w2 = new Worker();
		w1.setId(100);
		w2.setId(100);
		
		Set<Worker> workers = new HashSet<Worker>();
		workers.add(w1);
		workers.add(w2);
		
		System.out.println(workers.size()); // 2
	}
}
```



我们要把对象放到HashSet中就是调用add()方法把对象存进去，so easy。看看HashSet的add()方法，它其中有一个HashMap对象，他保存值是直接使用HashMap的put方法把保存的对象作为Key存到map中。（即HashSet直接使用HashMap实现它保存唯一对象的功能）。


```java
public boolean add(E e) {
    return map.put(e, PRESENT)==null;
}
```

以下是HashMap的put()和hash()方法。

从`int hash = hash(key.hashCode());`这一行我们看到通过获取key的哈希值，传给hash方法计算出一个值，作为两个key是否相同的依据。也就是，如果两个对象相等那么他们的hashCode就一定要相等（or 就会出现相同对象取到不同的hashCode这种不合理的情况）。

```java 
	// 放入方法，
	public V put(K key, V value) {
        if (key == null)
            return putForNullKey(value);
        int hash = hash(key.hashCode()); /* 就是这一行 */
        int i = indexFor(hash, table.length);
        for (Entry<K,V> e = table[i]; e != null; e = e.next) {
            Object k;
            if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
                V oldValue = e.value;
                e.value = value;
                e.recordAccess(this);
                return oldValue;
            }
        }

        modCount++;
        addEntry(hash, key, value, i);
        return null;
    }

	// 根据key的hashCode，用map自己的方法计算出一个hash值。
	static int hash(int h) {
        // This function ensures that hashCodes that differ only by
        // constant multiples at each bit position have a bounded
        // number of collisions (approximately 8 at default load factor).
        h ^= (h >>> 20) ^ (h >>> 12);
        return h ^ (h >>> 7) ^ (h >>> 4);
    }
```


很明显，虽然重写了equals方法让w1与w2相等，但是由于没有重写hashCode()方法，导致能够往HashSet中存入了两个相等的对象。在这种情况下，我们就要重写hashCode方法。

那我们怎么重写一个对象的hashCode()方法？

获取hash值有多种算法，根据你的需要（或者说项目的大小，更具体就是你存在这个Set中的对象的数量）选择重写的hashCode方法如下。这种算法就是简单线性处理：

```java
@Override
public int hashCode() {
    final int PRIME = 31;
    int result = 1;
    result = PRIME * result + getId();
    return result;
}
```

我们可以使用Apache-commons-lang包下（common包可以认为是Java第二大类库，自带的那些是第一大类库）提供的类来帮助重写equals方法和hashCode方法：

```java
import org.apache.commons.lang3.builder.EqualsBuilder;
import org.apache.commons.lang3.builder.HashCodeBuilder;

	@Override
	public boolean equals(Object obj) {
	    if(!(obj instanceof Worker)) {
			return false;
		}
        if(this == obj) {											/*  引用相同 */
			return true;
		}
		Integer id = ((Worker) obj).getId();
		return new EqualsBuilder().append(getId(), id).isEquals();	/* 使用类库根据ID去判断是否相等 */
	}

	@Override
	public int hashCode() {
		final int PRIME = 31;
		// initialNonZeroOddNumber, multiplierNonZeroOddNumber
        /* 使用类库根据id以及PRIME为31去计算hash值 */
		return new HashCodeBuilder(getId() % 2 == 0 ? getId() + 1 : getId(), PRIME).toHashCode();
	}
```



### 题外话：为什么要用到hashCode？

总的来说，Java中的集合（Collection）有两类，一类是List，再有一类是Set。你知道它们的区别吗？前者集合内的元素是有序的，元素可以重复；后者元素无序，但元素不可重复。那么这里就有一个比较严重的问题了：要想保证元素不重复，可两个元素是否重复应该依据什么来判断呢？这就是Object.equals方法了。但是，如果每增加一个元素就检查一次，那么当元素很多时，后添加到集合中的元素比较的次数就非常多了。也就是说，如果集合中现在已经有1000个元素，那么第1001个元素加入集合时，它就要调用1000次equals方法。这显然会大大降低效率。 

于是，Java采用了哈希表的原理。哈希（Hash）实际上是个人名，由于他提出一哈希算法的概念，所以就以他的名字命名了。哈希算法也称为散列算法，是将数据依特定算法直接指定到一个地址上。如果详细讲解哈希算法，那需要更多的文章篇幅，我在这里就不介绍了。初学者可以这样理解，hashCode方法实际上返回的就是对象存储的物理地址（实际可能并不是）。 

这样一来，当集合要添加新的元素时，先调用这个元素的hashCode方法，就一下子能定位到它应该放置的物理位置上。如果这个位置上没有元素，它就可以直接存储在这个位置上，不用再进行任何比较了；如果这个位置上已经有元素了，就调用它的equals方法与新元素进行比较，相同的话就不存了，不相同就散列其它的地址。所以这里存在一个冲突解决的问题。这样一来实际调用equals方法的次数就大大降低了，几乎只需要一两次。 

所以，Java对于eqauls方法和hashCode方法是这样规定的： 

* 1、如果两个对象相同，那么它们的hashCode值一定要相同； 
* 2、如果两个对象的hashCode相同，它们并不一定相同 
  

上面说的对象相同指的是用eqauls方法比较。 

你当然可以不按要求去做了，但你会发现，相同的对象可以出现在Set集合中。同时，增加新元素的效率会大大下降。



## 总结

* 尽量用同样的几个属性来生成hashCode和equals两个方法。
* 二者必须同时重写。
	* 两个equals()返回true的对象，hashCode也要相同。
	* 反之则不必，即hashCode相同不一定要equals()=true
* 在ORM中，要使用get/set方法来获取时属性，因为有时候变量会被延迟加载。
	* 例如上面的 使用id == id 可能就会出现这个问题，使用getId() == getId()就不会了

## 参考



* [https://www.oschina.net/question/82993_75533](https://www.oschina.net/question/82993_75533)

* [http://blog.csdn.net/fanfanjin/article/details/6881474](http://blog.csdn.net/fanfanjin/article/details/6881474)
