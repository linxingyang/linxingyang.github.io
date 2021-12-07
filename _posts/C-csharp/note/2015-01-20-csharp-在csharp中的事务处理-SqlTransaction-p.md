---
layout: post
permalink: /:year/5b849418e8ce4e3785cb179f21b11114/index
title: csharp-在csharp中的事务处理-SqlTransaction
categories: [csharp]
tags: [post, csharp]
date: 2015-01-20 20:29:53 +8
place: 福建工程学院
editdate: 2021-12-02 20:29:53 +8
eidtplace: 福州软件园
excerpt: csharp,事务处理,SqlTransaction
description: csharp-在csharp中的事务处理-SqlTransaction
catalog: true
author: 林兴洋
---

# csharp中的事务处理

## 函数

主要使用到SqlTransaction类的几个的函数
```csharp
Save()      // 保存点
Commit()    // 提交
Rollback()  // 回滚
```

* 开启事务之后，必须要提交，否则数据库数据不会被更新
* 开启事务后，若过程中sql执行失败，虽然不用Roolback()也会自动回滚，但最好还是写上。

## 模板

基本模板，使用using来自动释放资源。
```csharp
using (SqlConnection con = new SqlConnectin(conStr))
{
    using(SqlCommand cmd = new SqlCommand())
    {
        con.Open();
        cmd.Connection=con;
        SqlTransaction tran  = con.BeginTransaction(); 	// 创建事务
        cmd.Transaction = tran;

        cmd.CommandText = "要执行的SQL语句";
        try    
         {
            cmd.ExecuteNonQuery();
            Console.WriteLine("执行成功！");   
            tran.Commit();								// 成功则提交事务
        }
        catch(SqlException sqlEx)
        {
            Console.WriteLine("执行失败：{0}",sqlEx.Message);
            tran.Rollback();							// 失败则回滚
        }
    }
}
```

## 示例

执行成功并且用Commit()方法提交。

```csharp
using System;
using System.Data.SqlClient;

public class H7
{
    public static void Main(string[] args)
    {
        string conStr = "server=LXY;database=StudySql;integrated security=true;";
        string sql1 = "update Contacts set contactPhone='666' where contactId=1";
        string sql2 = "update Contacts set contactPhone='666' where contactId=2";
        string sql3 = "update Contacts set contactPhone='666' where contactId=3";
        string sql4 = "update Contacts set contactPhone='666' where contactId=4";
        using (SqlConnection con = new SqlConnection(conStr))
        {
            using(SqlCommand cmd = new SqlCommand(sql1,con))
            {
                con.Open();
                SqlTransaction tran = con.BeginTransaction();
                cmd.Transaction = tran;
                try     
                {
                    cmd.ExecuteNonQuery();
                    cmd.CommandText = sql2;
                    cmd.ExecuteNonQuery();
                    cmd.CommandText = sql3;
                    cmd.ExecuteNonQuery();
                    cmd.CommandText = sql4;
                    cmd.ExecuteNonQuery();
                    tran.Commit();
                    Console.WriteLine("执行成功了，也提交了");
                }
                catch(SqlException sqlEX)
                {
                    Console.WriteLine("执行失败了用 tran.Rollback 回滚"); 
                    Console.WriteLine("执行失败:{0}",sqlEX.Message);
                    tran.Rollback();
                } 
            }
        }
    }
}
```

