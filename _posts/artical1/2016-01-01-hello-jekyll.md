---
layout: post
title: hello jekyll
---
{{ page.excerpt | markdownify }}

## you know, i'm new here, {{ page.title }} ##

### code sample1 ###

{% highlight java linenos %}

public class A {
	public static void main(String[] args) {
		System.out.println("hello jekyll");
	}
}

{% endhighlight %}


### code sample2 ###

```java
public class B {
	public static void main(String[] args) {
		System.out.println("hello jekyll");
	}
}
```

[另一篇文章]({% post_url 2016-01-02-hello-github %})

* 当前时间：{{ site.time | date_to_xmlschema  }}
* 文章字数：{{ page.content | number_of_words }}

* 作者：{{ site.author }}
* 个人邮件： {{ site.personnal-email }}
* 公司邮件：{{ site.work-email }}
* 电话:{{ site.phone }}