---
layout: post
permalink: /:year/4cxx9xxxx02743b68622d47e6587b2d0
title: 2018-03-30-spring-java配置方式
categories: [spring]
tags: [spring,java配置]
excerpt:  spring,java配置
description: spring,java配置

---


## spring的java配置方式 ##


java配置是spring4.x推荐的配置方式，可以完全支持替代xml配置


### xml替代和bean标签替代 @Configuration 和 @Bean ###

spring的java配置是通过@Configuration和@Bean两个注解实现的

* @Configuration作用在类上，相当于一个配置文件
* @Bean作用在方法上，相当于XML配置中的<bean>，默认是返回单例的。


#### 测试：新建maven项目 ####

#### 配置文件 ####

代码来自文档参考

```xml

<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>cn.itcast.springboot</groupId>
	<artifactId>itcast-springboot</artifactId>
	<version>1.0.0-SNAPSHOT</version>
	<packaging>war</packaging>

	<dependencies>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-webmvc</artifactId>
			<version>4.3.7.RELEASE</version>
		</dependency>
		<!-- 连接池 -->
		<dependency>
			<groupId>com.jolbox</groupId>
			<artifactId>bonecp-spring</artifactId>
			<version>0.8.0.RELEASE</version>
		</dependency>
	</dependencies>
	<build>
		<finalName>${project.artifactId}</finalName>
		<plugins>
			<!-- 资源文件拷贝插件 -->
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-resources-plugin</artifactId>
				<configuration>
					<encoding>UTF-8</encoding>
				</configuration>
			</plugin>
			<!-- java编译插件 -->
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-compiler-plugin</artifactId>
				<configuration>
					<source>1.7</source>
					<target>1.7</target>
					<encoding>UTF-8</encoding>
				</configuration>
			</plugin>
		</plugins>
		<pluginManagement>
			<plugins>
				<!-- 配置Tomcat插件 -->
				<plugin>
					<groupId>org.apache.tomcat.maven</groupId>
					<artifactId>tomcat7-maven-plugin</artifactId>
					<version>2.2</version>
				</plugin>
			</plugins>
		</pluginManagement>
	</build>
</project>

```

#### java配置 ####

```java

package com.shierlu.springboot.javaconfig;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

// 通过该注解来表明该类是一个Spring的配置，相当于一个xml文件
@Configuration
// 配置扫描包
@ComponentScan(basePackages = "com.shierlu.springboot.javaconfig")
public class SpringConfig {
	
	// 通过该注解来表明是一个Bean对象，相当于xml中的<bean>
	
	// @Bean
	// 没有任何配置，getBean方法中可以通过下面两种方法获取
	// context.getBean(UserDAO.class); // 通过类获取，要求只有一个类返回UserDAO类的实例
	// context.getBean("getUserDAO", UserDAO.class); // 通过名称获取

	// @Bean(name={"myDao", "whatDao"})
	// 如果配置了name
	// userDAO = context.getBean("getUserDAO", UserDAO.class); // 不能获取
	// context.getBean(UserDAO.class); // 要求只有一个类返回UserDAO
	// userDAO = context.getBean("myDao", UserDAO.class); // 可以获取
	// userDAO = context.getBean("whatDao", UserDAO.class); // 可以获取
    @Bean(name={"userDAO"})
    public UserDAO getUserDAO(){
        return new UserDAO();
    }
}

```

#### 测试 ####

```java

package com.shierlu.springboot.javaconfig;

import java.util.List;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class Main {
    
    public static void main(String[] args) {
        // 通过Java配置来实例化Spring容器
        AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(SpringConfig.class);
        
        // 在Spring容器中获取Bean对象
        UserService userService = context.getBean("userService", UserService.class);
        System.out.println(userService.getUserDAO()); // com.shierlu.springboot.javaconfig.UserDAO@15c960e
        
        userService = context.getBean("userService", UserService.class);
        System.out.println(userService.getUserDAO()); // com.shierlu.springboot.javaconfig.UserDAO@15c960e
        
        UserDAO userDAO = context.getBean("userDAO", UserDAO.class);
        System.out.println(userDAO); // com.shierlu.springboot.javaconfig.UserDAO@15c960e
        
        userDAO = context.getBean("userDAO", UserDAO.class);
        System.out.println(userDAO); // com.shierlu.springboot.javaconfig.UserDAO@15c960e
        
        
        // 调用对象中的方法
        List<User> list = userService.queryUserList();
        for (User user : list) {
            System.out.println(user.getUsername() + ", " + user.getPassword() + ", " + user.getPassword());
        }
        
        // 销毁该容器
        context.destroy();
    }
}

```

可以看到上面打印的userDao是同一个对象，和spring的xml配置方式相同，spring管理的bean是单例模式。


### 读取外部资源文件 @PropertySource ###


读取外部资源文件

```java

// 从外部读入两个文件
@PropertySource(value={"classpath:/config/db/db.properties", "classpath:/config/log.properties"})

// db文件中内容
db.a=11
db.b=helloworld

// log文件中内容
log.a=abc
log.b=666

```

使用方式一：

```java

	// 获取传入的配置文件方式一：
	@Value("${db.a}")
	private Integer dba;
	@Value("${db.b}")
	private String dbb;
	
	@Value("${log.a}")
	private String loga;
	@Value("${log.b}")
	private Integer logb;
    
    
    // 使用
	System.out.println(dba);
    System.out.println(dbb);
    System.out.println(loga);
    System.out.println(logb);

```

使用方式二：Environment类

```java

	// 获取方式二：
	// spring提供的，它会默认的把配置文件中的键值对放到Environment对象中。要用Autowired注解
	@Autowired
	Environment env;
    
    // 使用
    System.out.println(env.getProperty("db.a"));
    System.out.println(env.getProperty("db.b"));
    System.out.println(env.getProperty("log.a"));
    System.out.println(env.getProperty("log.b"));
    
```


* 配置文件不存在？

```java

使用 ignoreResourceNotFound=true 忽略
@PropertySource(
	value={"classpath:/config/db/db.properties", "classpath:/config/log.properties"},
	ignoreResourceNotFound=true)
    
```


#### 完整配置 ####


```java

package com.shierlu.springboot.javaconfig;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;

// 通过该注解来表明该类是一个Spring的配置，相当于一个xml文件
@Configuration 
// 配置扫描包
@ComponentScan(basePackages = "com.shierlu.springboot.javaconfig") 
@PropertySource(value={"classpath:/config/db/db.properties", "classpath:/config/log.properties"})
public class SpringConfig {
	
	// 获取传入的配置文件方式一：
	@Value("${db.a}")
	private Integer dba;
	@Value("${db.b}")
	private String dbb;
	
	@Value("${log.a}")
	private String loga;
	@Value("${log.b}")
	private Integer logb;
	
	// 获取方式二：
	// spring提供的，它会默认的把配置文件中的键值对放到Environment对象中。
	@Autowired
	Environment env;
	
    @Bean(name={"userDAO"})
    public UserDAO getUserDAO(){
    	
    	System.out.println(dba);
    	System.out.println(dbb);
    	System.out.println(loga);
    	System.out.println(logb);
    	
    	System.out.println(env.getProperty("db.a"));
    	System.out.println(env.getProperty("db.b"));
    	System.out.println(env.getProperty("log.a"));
    	System.out.println(env.getProperty("log.b"));
    	
    	// 直接new对象做演示
        return new UserDAO(); 
    }
 
}

```


### 懒加载 @Lazy ###

就是xml配置中bean中的Lazy


### 范围 @Scope ###

单例singleton，原型prototype

```java


package com.shierlu.springboot.javaconfig;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;

// 通过该注解来表明该类是一个Spring的配置，相当于一个xml文件
@Configuration
// 配置扫描包
@ComponentScan(basePackages = "com.shierlu.springboot.javaconfig") 
public class SpringConfig {

    
    // 默认设置
    // 多次获取userDao，只会调用一次该方法。
    
    // @Scope("prototype")
    // 如果设置了@Scope("prototype")，
    // 那么每次获取都会调用该方法
    @Bean(name={"userDAO"})
    public UserDAO getUserDAO(){
    	// 直接new对象做演示
        return new UserDAO(); 
    }
}

```

### 首选的 @Primary ###

当有多个候选者可用时，哪个候选者有@Primary标签，就用它。

代码来自文档参考

```java

@Component
 public class FooService {
     private FooRepository fooRepository;

     @Autowired
     public FooService(FooRepository fooRepository) {
         this.fooRepository = fooRepository;
     }
 }

 @Component
 public class JdbcFooRepository {
     public JdbcFooService(DataSource dataSource) {
         // ...
     }
 }

 @Primary
 @Component
 public class HibernateFooRepository {
     public HibernateFooService(SessionFactory sessionFactory) {
         // ...
     }
 }

```

因为HibernateFooRepository有@Primary标签，所以使用的是它。



### xml数据源配置改为java配置 ###

mysql.properties

```

JDBC.DriverName=com.mysql.jdbc.Driver
JDBC.URL=jdbc\:mysql\://localhost\:3306/websale
JDBC.User=root
JDBC.Password=123456

POOL.MaxSize=150
POOL.MinSize=10
POOL.initPoolSize=20
POOL.acquireIncrement=6
POOL.idleConnectionTestPeriod=60

```

原来xml的配置

```xml

    <!-- 数据源配置 -->
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <property name="driverClass" value="${JDBC.DriverName}"/>
        <property name="jdbcUrl" value="${JDBC.URL}"/>  
        <property name="user" value="${JDBC.User}"/>
        <property name="password" value="${JDBC.Password}"/>
        <property name="maxPoolSize" value="${POOL.MaxSize}"/>
        <property name="minPoolSize" value="${POOL.MinSize}"/>
        <property name="idleConnectionTestPeriod" value="${POOL.idleConnectionTestPeriod}"></property>
    </bean>

```

改为java配置

```java

package com.shierlu.springboot.javaconfig;

import java.beans.PropertyVetoException;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;

import com.mchange.v2.c3p0.ComboPooledDataSource;

@Configuration
@ComponentScan(basePackages = "com.shierlu.springboot.javaconfig") 
@PropertySource(
	value={"classpath:/config/db/mysql/mysql.properties"})
public class SpringConfig2 {
	
	@Autowired
	Environment env;
	
    @Bean(name={"userDAO"})
    public UserDAO getUserDAO(){
        return new UserDAO(); 
    }
    
    @Bean(name={"dataSource"})
    public DataSource dataSource() throws PropertyVetoException {
    	ComboPooledDataSource dataSource = new ComboPooledDataSource();
    	
    	dataSource.setDriverClass(env.getProperty("JDBC.DriverName"));
    	dataSource.setJdbcUrl(env.getProperty("JDBC.URL"));
    	dataSource.setUser(env.getProperty("JDBC.User"));
    	dataSource.setPassword(env.getProperty("JDBC.Password"));
    	dataSource.setMaxPoolSize(env.getProperty("POOL.MaxSize", Integer.class));
    	dataSource.setMinPoolSize(env.getProperty("POOL.MinSize", Integer.class));
    	dataSource.setIdleConnectionTestPeriod(env.getProperty("POOL.idleConnectionTestPeriod", Integer.class));
    	
    	return dataSource;
    }
}

```



