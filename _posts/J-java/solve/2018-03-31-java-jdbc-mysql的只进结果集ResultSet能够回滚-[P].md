---
layout: post
permalink: /:year/4cxx9xxxx0274vxv8622d47e6587bdsd
title: 2018-03-31-java-jdbc-mysql的只进结果集ResultSet能够回滚
categories: [编程]
tags: [java,mysql]
excerpt:  java,jdbc,mysql,ResultSet,能够回滚
description: java,jdbc,mysql,ResultSet,能够回滚
gitalk-id: 4cxx9xxxx0274vxv8622d47e6587bdsd
toc: true
---

使用mysql数据库的连接，使用只进结果集，在后面调用beforeFirst()方法，让指针回到第一条数据之前。

设想应该是报错，结果没有报错。

```
package test.use;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class JDBC1 {

	public static void main(String[] args) throws ClassNotFoundException, SQLException {
		test1();
	}


	private static final String DRIVER = "com.mysql.jdbc.Driver";
	private static final String URL = "jdbc:mysql://localhost:3306/test"; 
	private static final String USERNAME = "root"; 
	private static final String PASSWORD = "123456";
	
//	private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
//	private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=test1;"; 
//	private static final String USERNAME = "sa"; 
//	private static final String PASSWORD = "123456";
	
	private static void test1() throws ClassNotFoundException, SQLException {
		Class.forName(DRIVER);
		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement statement = connection.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);
		ResultSet resultSet = statement.executeQuery("select * from userr");
	    
		while (resultSet.next()) {
			System.out.println(resultSet.getString(1));
			System.out.println(resultSet.getString(2));
			System.out.println(resultSet.getString(1));
		}
		resultSet.beforeFirst();
		
		resultSet.close();
		statement.close();
		connection.close();
	}
}
```

同一段代码，使用sqlserver数据库，结果报错了。

```
package test.use;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class JDBC1 {

	public static void main(String[] args) throws ClassNotFoundException, SQLException {
		test1();
	}
	
//	private static final String DRIVER = "com.mysql.jdbc.Driver";
//	private static final String URL = "jdbc:mysql://localhost:3306/test"; 
//	private static final String USERNAME = "root"; 
//	private static final String PASSWORD = "123456";
	
	private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
	private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=test1;"; 
	private static final String USERNAME = "sa"; 
	private static final String PASSWORD = "123456";
	
	private static void test1() throws ClassNotFoundException, SQLException {
		Class.forName(DRIVER);
		Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
		Statement statement = connection.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);
		ResultSet resultSet = statement.executeQuery("select * from account");
	    
		while (resultSet.next()) {
			System.out.println(resultSet.getString(1));
			System.out.println(resultSet.getString(2));
			System.out.println(resultSet.getString(1));
		}
		resultSet.beforeFirst();
		
		resultSet.close();
		statement.close();
		connection.close();
	}
}
```

会抛出异常 

```

...
// 正常数据
...
Exception in thread "main" com.microsoft.sqlserver.jdbc.SQLServerException: 只进结果集不支持请求的操作。
	at com.microsoft.sqlserver.jdbc.SQLServerException.makeFromDriverError(SQLServerException.java:170)
	at com.microsoft.sqlserver.jdbc.SQLServerResultSet.throwNotScrollable(SQLServerResultSet.java:376)
	at com.microsoft.sqlserver.jdbc.SQLServerResultSet.verifyResultSetIsScrollable(SQLServerResultSet.java:399)
	at com.microsoft.sqlserver.jdbc.SQLServerResultSet.beforeFirst(SQLServerResultSet.java:1239)
	at test.use.JDBC1.test1(JDBC1.java:75)
	at test.use.JDBC1.main(JDBC1.java:15)
```

稍微看了下mysql-connector的源码，它没有完全按照java.sql.ResultSet中对于接口的规定来实现：当只进结果集调用prevous(),beforeFirst()等方法时应该抛出异常。而mysql-connector却没有。

```
    /**
     * Moves the cursor to the front of
     * this <code>ResultSet</code> object, just before the
     * first row. This method has no effect if the result set contains no rows.
     *
     * @exception SQLException if a database access error
     * occurs; this method is called on a closed result set or the
     * result set type is <code>TYPE_FORWARD_ONLY</code>
     * @exception SQLFeatureNotSupportedException if the JDBC driver does not support
     * this method
     * @since 1.2
     */
    void beforeFirst() throws SQLException;
```
