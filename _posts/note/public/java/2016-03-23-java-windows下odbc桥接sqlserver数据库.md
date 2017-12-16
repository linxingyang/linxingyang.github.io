---
layout: post
permalink: /:year/8b072ff2a1da49c2be51643cab4d2aee
title: 2016-03-23-java-windows下odbc桥接sqlserver数据库
categories: [问题解决,windows,sqlserver,java]
tags: [java,windows,odbc,sqlserver,桥接,问题解决]
excerpt: java,windows,odbc,sqlserver,桥接,问题解决
description: windows下java通过odbc数据源桥接sqlserver数据库

---

[TOC "z-index:10000;right:0px;position:fixed;overflow-y: scroll;height: 500px;top: 0px; width: 400px"]


windows系统下， jdbc odbc桥接

# 步骤 #

## 找到“数据源” ##

如果你是64位系统，你需要在如下路径找到  odbcad32.exe

![http://image.linxingyang.net/image/note/2016-03-23-java/01.png](http://image.linxingyang.net/image/note/2016-03-23-java/01.png)


如果你是32位系统，就在如下路径找

![http://image.linxingyang.net/image/note/2016-03-23-java/02.png](http://image.linxingyang.net/image/note/2016-03-23-java/02.png)

## 选择“系统 DSN” ##

![http://image.linxingyang.net/image/note/2016-03-23-java/03.png](http://image.linxingyang.net/image/note/2016-03-23-java/03.png)


## 点击    “添加”，后选择 “SQL Server” ##

![http://image.linxingyang.net/image/note/2016-03-23-java/04.png](http://image.linxingyang.net/image/note/2016-03-23-java/04.png)


如下：名称（这里只是一个别名而已，但在jsp中，需要用这个别名访问真实的数据库）
描述（这个可以不填）
服务器（选择你的Sqlserver服务器）

![http://image.linxingyang.net/image/note/2016-03-23-java/06.png](http://image.linxingyang.net/image/note/2016-03-23-java/06.png)


## 第一种是windows身份验证登录。##

我是使用第二种方式，使用用户名密码登录，并且输入“登录ID”和“密码”

![http://image.linxingyang.net/image/note/2016-03-23-java/07.png](http://image.linxingyang.net/image/note/2016-03-23-java/07.png)

## 勾选“更改默认的数据库为”，选择你要连接的数据库。 ##

![http://image.linxingyang.net/image/note/2016-03-23-java/08.png](http://image.linxingyang.net/image/note/2016-03-23-java/08.png)

## 这里默认设置 ##

![http://image.linxingyang.net/image/note/2016-03-23-java/09.png](http://image.linxingyang.net/image/note/2016-03-23-java/09.png)

## 配置完成，点击“测试数据源”，结果为“测试成功”即可 ##

![http://image.linxingyang.net/image/note/2016-03-23-java/10.png](http://image.linxingyang.net/image/note/2016-03-23-java/10.png)


## 如下，Tmssql 已经添加到了列表上 ##

![http://image.linxingyang.net/image/note/2016-03-23-java/11.png](http://image.linxingyang.net/image/note/2016-03-23-java/11.png)

## 附 ##

JSP中访问代码如下。

```java

<%@page contentType="text/html;charset=GB2312"%>
<%@page import="java.sql.*"%>
<html>
 <head>
  <title></title>
 </head>
 <body>
  <%
  
   Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
   //Class.forName("com.microsoft.jdbc.sqlserver.SQLServerDriver");    
   //String url="jdbc:;databaseName=StudySql;user=sa;password=123456";
   String url1 = "jdbc:odbc:Tmssql";
   String user = "sa";
   String pwd = "123456";
   Connection con = DriverManager.getConnection(url1,user,pwd);  
 
   String sql="select * from Contacts";
   Statement stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_READ_ONLY);
   
   //PreparedStatement pstmt = con.prepareStatement(sql);
   ResultSet rs = stmt.executeQuery(sql);                                     
   rs.last();
   int rowNumber = rs.getRow();
   out.print("共有："+rowNumber+" 条记录<br/>");
  rs.beforeFirst();
  
   while(rs.next())
   {
   %>
   <%=rs.getString(3)%><br />
    <%
    }
    %>
  <%
  rs.close();
  stmt.close();
  con.close();
 
  %>
 </body>
<html>

```

测试访问结果如下：

![http://image.linxingyang.net/image/note/2016-03-23-java/12.png](http://image.linxingyang.net/image/note/2016-03-23-java/12.png)

