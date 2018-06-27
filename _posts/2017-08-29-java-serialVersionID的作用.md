---
layout: post
permalink: /:year/1aa51ec7327b4cbf87dff3086c9afc7d
title: 2017-08-29-java-serialVersionID的作用
categories: [java]
tags: [java,serialVersionID的作用]
excerpt:  java,问题解决,serialVersionID的作用
description: java中serialVersionID的作用

---


很多代码都有一句

```java

private static final long serialVersionUID = 1L

```

这句是什么作用呢？看网站上扯了一大堆。。。看多了反而不明白。


暂且理解为，在java序列化和反序列化的时候，需要判断这个对象能否被反序列化，这个serialVersionUID是作为判断的一部分存在吧。

## 一个例子 ##

上代码。定义一个worker，有id,name,age三个属性，当然如果需要序列化，需要实现Serializable接口，下面这个Worker认为是版本1。

```java

package test;

import java.io.Serializable;

public class Worker implements Serializable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private String name;
	private Integer age;

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Integer getAge() {
		return age;
	}

	public void setAge(Integer age) {
		this.age = age;
	}

	@Override
	public String toString() {
		return "Worker [id=" + id + ", name=" + name + ", age=" + age + "]";
	}
}

```


新建两个对象，并保存到文件中

```java

package test;

import java.io.File;
import java.io.FileOutputStream;
import java.io.ObjectOutputStream;

public class App {

	public static void main(String[] args) {
		Worker worker = new Worker();
		worker.setId(100);
		worker.setName("alien lin");
		worker.setAge(24);

		Worker worker2 = new Worker();
		worker2.setId(60);
		worker2.setName("jack ma ");
		worker2.setAge(66);
		try {
			File f = new File("d:/temp/a.txt");
			if (!f.exists()) {
				f.createNewFile();
			}
			ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(f));
			oos.writeObject(worker);
			oos.writeObject(worker2);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}

```


在从文件中读取出这两个对象

```java

package test;

import java.io.File;
import java.io.FileInputStream;
import java.io.ObjectInputStream;

public class App2 {

	public static void main(String[] args) {
		File f = new File("d:/temp/a.txt");
		Object o = null;
		try {
			FileInputStream fis = new FileInputStream(f);
			ObjectInputStream ois = new ObjectInputStream(fis);
			// 用fis来判断是否已经读到结尾了。
			while (0 != fis.available() && null != (o = ois.readObject())) {
				System.out.println(((Worker) o).toString());
			}
			ois.close();
			fis.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}

```

结果：

```

Worker [id=100, name=alien lin, age=24]
Worker [id=60, name=jack ma , age=66]

```



现在我们在不改动Worker其他属性的情况下，把Worker的serialVersionUID改成2L，认为是版本2。如下

```java

private static final long serialVersionUID = 2L;

```

然后再次运行上面的读取对象的代码，结果报了一个错

```java

java.io.InvalidClassException: test.Worker; local class incompatible: stream classdesc serialVersionUID = 1, local class serialVersionUID = 2
	at java.io.ObjectStreamClass.initNonProxy(ObjectStreamClass.java:617)
	at java.io.ObjectInputStream.readNonProxyDesc(ObjectInputStream.java:1622)
	at java.io.ObjectInputStream.readClassDesc(ObjectInputStream.java:1517)
	at java.io.ObjectInputStream.readOrdinaryObject(ObjectInputStream.java:1771)
	at java.io.ObjectInputStream.readObject0(ObjectInputStream.java:1350)
	at java.io.ObjectInputStream.readObject(ObjectInputStream.java:370)
	at test.App2.main(App2.java:16)

```

根据提示我们知道，这两个冲突了。因为serialVersionUID的不同导致了读出对象失败。可以认为它做的是一个版本是否兼容的功能。



java中，如果版本1和版本2兼容，即它们之间可以任意序列化反序列化，那么它们的serialVersionUID就应该相同。相反的，如果认为版本1和版本2之间不应该进行任意序列化反序列化，那么就不应该有相同的serialVersionUID。


比如版本2新增了一个属性，而这个属性从数据库/文件/网络中读取后要求必须有值，那么版本2就不能从保存版本1数据库/文件/网络中读取。此时两个版本的代码的serialVersionUID就要设置为不同才行。


如果版本2新增了一个属性，而这个属性不必一定有值。从而版本2的类能够从保存版本1的类的存储中读取版本1的对象，这样版本1和2就可以是兼容的。

下面新建一个版本3，新增了一个属性gender，去掉了一个属性age。但是serialVersionUID不变，说明版本3兼容版本1，它们之间可以任意序列化反序列化。但是由于属性的不对等，所以会造成数据的缺失。

```java

package test;

import java.io.Serializable;

public class Worker implements Serializable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private String name;
	// private Integer age;
	private String gender;

	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Override
	public String toString() {
		return "Worker [id=" + id + ", name=" + name + ", gender=" + gender + "]";
	}

	// public Integer getAge() {
	// return age;
	// }
	//
	// public void setAge(Integer age) {
	// this.age = age;
	// }
}

```

运行进行读取程序，结果如下。age缺失，genkder为空，

```java

Worker [id=100, name=alien lin, gender=null]
Worker [id=60, name=jack ma , gender=null]

```


## 那么如果我们不指定serialVersionUID的值，那将会如何？ ##

如果我们不显示指定serialVersionUID的值，那么JVM会根据属性的生成一个serialVersionUID，如果我们更改了属性，添加了非private方法，那么serialVersionUID就不同了，就不能序列化了。


定义一个Person，有id,name属性及其get/set方法。注意该对象我们没有设置serialVersionUID的值

```java

package test;

import java.io.Serializable;

public class Person implements Serializable {
	private Integer id;
	private String name;
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
}

```


使用Test1将两个Person对象存入文本中

```java

package test;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;

public class Test1 {

	public static void main(String[] args) {
		Person p = new Person();
		p.setId(1);
		p.setName("lxy");
		Person p1 = new Person();
		p1.setId(2);
		p1.setName("ddd");
		
		try {
			ObjectOutput oo = new ObjectOutputStream(
				new FileOutputStream("d:/logs/c.txt"));
			oo.writeObject(p);
			oo.writeObject(p1);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}

```

使用Test2读出该对象。

```java

package test;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.ObjectInput;
import java.io.ObjectInputStream;

public class Test2 {
	
	public static void main(String[] args) throws ClassNotFoundException, FileNotFoundException, IOException {
		FileInputStream fis = new FileInputStream("d:/logs/c.txt");
		ObjectInput oi = new ObjectInputStream(fis);
		Person p = null;
		while (0 != fis.available()) {
			p = (Person)oi.readObject();
			System.out.println(p.getId() + " " + p.getName());
		}
		
	}

}

```


现在我们给Person新增一个属性age及其get/set属性

```java

package test;

import java.io.Serializable;

public class Person implements Serializable {
	private Integer id;
	private String name;
	private Integer age;
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public Integer getAge() {
		return age;
	}
	public void setAge(Integer age) {
		this.age = age;
	}
	

}

```

再运行Test2.发现报错了。发现是的serialVersionUID不同导致的，从这里我们可以知道，如果我们没有指定serialVersionUID，那么将会根据属性得到一个serialVersionUID。

```

Exception in thread "main" java.io.InvalidClassException: test.Person; local class incompatible: stream classdesc serialVersionUID = -3988139021726296639, local class serialVersionUID = -2271613962938391343
	at java.io.ObjectStreamClass.initNonProxy(ObjectStreamClass.java:562)
	at java.io.ObjectInputStream.readNonProxyDesc(ObjectInputStream.java:1583)
	at java.io.ObjectInputStream.readClassDesc(ObjectInputStream.java:1496)
	at java.io.ObjectInputStream.readOrdinaryObject(ObjectInputStream.java:1732)
	at java.io.ObjectInputStream.readObject0(ObjectInputStream.java:1329)
	at java.io.ObjectInputStream.readObject(ObjectInputStream.java:351)
	at test.Test2.main(Test2.java:16)


```


如果给Person加上一个私有的方法private void whateverMethod(){}。结果是没有报错的，但是如果修饰符不是private就会报同样的错误。

```java

package test;

import java.io.Serializable;

public class Person implements Serializable {
	private Integer id;
	private String name;
	
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	private void whateverMethod() {
		
	}
}

```

