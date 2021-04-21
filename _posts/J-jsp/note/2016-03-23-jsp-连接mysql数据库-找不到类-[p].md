---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab4d2aqw/index
title: 2016-03-23-jsp-连接mysql数据库-找不到类
categories: [jsp]
tags: [java,jsp,mysql,tomcat]
excerpt: java,tomcat,mysql,jsp
description: jsp-连接mysql数据库
catalog: false
author: 林兴洋
---

在编写jsp过程中要连接到mysql数据库。刚开始的时候老是提示未找到类，老郁闷了：

```java
ClassNoFound...
String driver = "com.mysql.jdbc.Driver";
Class.forName(driver);
```

问题就是缺库，找到你的mysql版本对应的jdbc库即可，如下我的mysql安装路径下就有mysql对应Java的jdbc实现类的jar包。
```
C:\Program Files\MySQL\Connector J 5.1.25\mysql-connector-java-5.1.25-bin.jar
```

如果找不到对应的jar包，可以根据你的mysql的版本，到[mvn仓库中的mysql](https://mvnrepository.com/artifact/mysql/mysql-connector-java)下载一个即可。

---

java程序


对于java程序，编译运行命令如下，这里程序名为`MysqlConnectTest.java`，mysql驱动和程序在同个目录下，叫`mysql-connector-java-5.1.25-bin.jar`
```
javac -cp .\mysql-connector-java-5.1.25-bin.jar;. MysqlConnectTest.java
java -cp .\mysql-connector-java-5.1.25-bin.jar;. MysqlConnectTest
```

示例程序：

```java
import java.util.*;
import java.sql.*;

public class MysqlConnectTest
{
    public static void main(String args[]) throws Exception
    {
        Class.forName("com.mysql.jdbc.Driver"); // 驱动
        String url="jdbc:mysql://localhost/lxy?user=root&password=123456"; // 链接的数据库，用户名，密码
        Connection con  = DriverManager.getConnection(url);
        String sql = "select * from tbl_student";

        PreparedStatement pstmt = con.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();

        while(rs.next())
        {
                System.out.println("姓名："+rs.getString("sname"));
        }
        rs.close();
        pstmt.close();
        con.close();
    }
}
```

---

jsp程序

在jsp中，在项目上找找（囧，我现在手边没有eclipse），右键添加库，把刚刚找到的那个库添加进去即可。



示例程序：

```jsp
<!-- 链接MYSQL数据库 -->
<%@ page contentType="text/html;charset=GB2312"%>
<%@ page import="java.sql.*"%>

<html>
    <head>
        <title>JSP测试链接MYSQL</title>
    </head>
    <body>
<%
    Class.forName("com.mysql.jdbc.Driver");
    String url="jdbc:mysql://localhost:3306/lxy?user=root&password=123456";
    Connection con = DriverManager.getConnection(url);
    String sql = "select * from tbl_student";
    PreparedStatement pstmt =con.prepareStatement(sql);
    ResultSet rs = pstmt.executeQuery();
    while(rs.next()) {
        out.println("姓名："+rs.getString("sname")+",性别："+rs.getString("ssex")+"<br />");
    }

    rs.close();
    pstmt.close();
    con.close();
%>
    </body>
</html>
```
