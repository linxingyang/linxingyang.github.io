---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab4d2aqw
title: 2016-03-23-jsp-连接mySql数据库
categories: [编程]
tags: [java,jsp,mysql,tomcat]
excerpt: java-tomcat连接mySql数据库
description: java-tomcat连接mySql数据库
gitalk-id: 8b072ff2a1da49c2be51643cab4d2aqw
toc: true
---

关于java-tomcat连接mySql数据库
关于在java中和在tomcat做.jsp过程中要使用到 mySql数据库。
刚开始的时候老郁闷了。老是提示

```java
ClassNoFound...
String driver = "com.mysql.jdbc.Driver";
Class.forName(driver);   
```

解决方法

对于java.,复制如下路径到环境变量中的classpath。（ps复制完后，要重新启动你的cmd才行，还有，如果你之前配置java的环境变量的时候，没有配置claspath的时候，那么必须也要配置一下java的classpath不然不行。。）

```
C:\Program Files\MySQL\Connector J 5.1.25\mysql-connector-java-5.1.25-bin.jar
```

```java
import java.util.*;
import java.sql.*;

public class Tsql
{
    public static void main(String args[]) throws Exception
    {
        Class.forName("com.mysql.jdbc.Driver");//驱动
        String url="jdbc:mysql://localhost/lxy?user=root&password=123456";//链接的数据库，用户名，密码
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

对于tomcat 是复制  如上路径下的文件
`mysql-connector-java-5.1.25-bin.jar`
到`C:\Program Files\Apache Software Foundation\Tomcat 7.0\lib`

jsp测试代码

```html
<!--
链接MYSQL数据库，
-->
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
