---
layout: post
permalink: /:year/8b072ff2a1da49c2be51444cab4d2aqw
title: 2017-01-04-maven-eclipse中控制台中文乱码
categories: [maven]
tags: [问题解决,中文乱码,eclipse,maven]
excerpt: 问题解决,中文乱码,eclipse,maven
description: 解决maven test命令时console出现中文乱码乱码

---

eclipse中maven在console输出中文乱码，在build中加入如下代码

```xml

<build>
    <plugins>  
        <!-- 解决maven test命令时console出现中文乱码乱码 -->  
        <plugin>  
            <groupId>org.apache.maven.plugins</groupId>  
            <artifactId>maven-surefire-plugin</artifactId>  
            <version>2.7.2</version>  
            <configuration>  
                <forkMode>once</forkMode>  
                <argLine>-Dfile.encoding=UTF-8</argLine>   
            </configuration>  
        </plugin>  
    </plugins>  
</build>
  
```