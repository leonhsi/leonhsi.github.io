---
title: Simple Bank - Backend Project Notes
date: 2023-04-18 19:24:51
tags: 
- simple-bank
- bankend
categories:
- tech 
---

[course list link](https://www.youtube.com/playlist?list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE)

## Lecture 07: DB Trasnaction Lock
```sql
-- name: GetAccount :one
SELECT * FROM accounts
WHERE id = $1 LIMIT 1;
```

加上

- **FOR UPDATE**
    - 因為同時會有很多transaction去更新(select) account
    - 若一個account被select, 但不block其他select account, 則account可能會無法被正確更新
    - 加上FOR UPDATE: block其他query
        - 這個query select的東西會被update, 所以sql會先block它

- FOR **NO KEY** UPDATE
    - 因為primary key不會update
    - 告訴db說不要因為primary key被使用就block其他query

```sql
-- name: GetAccountForUpdate :one
SELECT * FROM accounts
WHERE id = $1 LIMIT 1
FOR NO KEY UPDATE;
```

## Lecture 08: Avoid Deadlock
avoid:

- transaction 1:
    - update id 1
    - update id 2
- transaction 2:
    - update id 2
    - update id 1

**deadlock**!!

change to:

- transaction 1:
    - update id 1
    - update id 2
- transaction 2:
    - update id 1
    - update id 2

依照固定的order來更新id (小的先更新

## Lecture 09: Isolation Level

A database transaction should follow the **ACID** property:

- Atomicity
    - 要馬所有operation都要成功完成, 不然transaction fail且db保持不變
- Isolation
    - Concurrent transactions必不會互相影響
- Consistency
    - 在transaction完成之後, db state必須要是valid的
- Durability
    - data written by a successful transaction must be recorded in persistent storage

其中, 有一些 **Read Phenomena** 會影響到 Isolation property:

- Dirty Read
    - 一個transaction會讀到其他transaction uncommitted的data
- Non-repeatable Read
    - 一個transaction重複讀了兩次data卻發現data被修改過(by another **committed** transaction)
- Phantom(幻象) Read
    - 一個transaction重複搜尋了兩次相同的條件卻得到不同的rows (due to another recently **committed** transaction)
- serialization anomaly
    - 若將所有的transaction sequentially run, 不可能會得到正確的結果

4 Standard **Isolation Levels** are defined by ANSI:

- Read uncommitted
    - 可以看到尚未被commit的data
- Read Committed
    - 只能看到被commit過後的data (avoid dirty read)
- Repeatable read
    - 一樣的select query會回傳同樣結果 (avoid non-repeatable & phantom read)
- serializable
    - 保證serially的按照某種順序去跑transaction, 結果會跟concurrently跑的結果一樣

(MySQL)

| Isolation Level | Dirty Read | Non-repeatable Read | Phantom Read | Serialization Anomaly |
| --- | --- | --- | --- | --- |
| Read Uncommitted | Yes | Yes | Yes | Yes |
| Read Committed | No | Yes | Yes | Yes |
| Repeatable Read | No | No | No | Yes |
| Serializable | No | No | No | No |

(PostgreSQL)

| Isolation Level | Dirty Read | Non-repeatable Read | Phantom Read | Serialization Anomaly |
| --- | --- | --- | --- | --- |
| Read Uncommitted | No | Yes | Yes | Yes |
| Read Committed | No | Yes | Yes | Yes |
| Repeatable Read | No | No | No | Yes |
| Serializable | No | No | No | No |

MySQL v.s. PostgreSQL

- MySQL可以設置所有的transaction的isolation level, PostgreSQL只能設定一個transaction的isolation level
- MySQL
    - 在serializable, mysql預設會把 SELECT 變成 SELECT FOR SHARE
        - 若transaction 1去 SELECT * from accounts where id = 1, 則transaction 2要去update account id 1就會被block
        
        ```sql
        T1:
        	select * from accounts where id = 1;
        T2:
        
        ---
        T1:
        
        T2:
        	update account set balance = balance - 10 where id = 1; 
        ---
        
        Transaction 2 would be blocked
        ```
        
        ```sql
        T1:
        	select * from accounts where id = 1;
        T2:
        
        ---
        T1:
        
        T2:
        	update account set balance = balance - 10 where id = 1;
        ---
        T1:
        	update account set balance = balance - 10 where id = 1;
        T2:
        
        ---
        
        Dead lock would occur, since T2 is waiting T1 to release the lock, 
        while T1 is also waiting to T2
        ```
        
- PostgreSQL
    - read uncommitted 跟 read committed 一樣
        - read uncommitted 也不允許 dirty read
    - repeatable read 可以防止 phantom read
- 在serializable level 對付serialization anomaly 的方法
    - PostgreSQL: dependency check, 若相同的query被其他transaction用過, 會發出error
        
        ```sql
        T1:
        	select sum(balance) from accounts; 
        T2:
        
        ---
        
        T1:
        	insert into accounts(owner, balance, currency) values ('sum', 810, 'USD')
        T2:
        
        ---
        
        T1:
        
        T2:
        	insert into accounts(owner, balance, currency) values ('sum', 810, 'USD')
        ---
        
        T1:
        	commit; #success
        T2:
        
        ---
        
        T1:
        
        T2:
        	commit; #fail
        ---
        
        T2 would fail to commit. 
        Since the same insert query has been queried by T2.
        ```
        
    - MySQL: locking mechanism,  用share lock來避免兩個transaction會看到不同的data

Retry Mechanism

- There might be errors, timeout or deadlocks

[https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-isolation-levels.html](https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-isolation-levels.html)

[https://www.postgresql.org/docs/current/transaction-iso.html](https://www.postgresql.org/docs/current/transaction-iso.html)

## Lecture 11: RESTful API with GIN

RESTful API:

- 代表符合REST規範的API
- HTTP為REST的實做
- Client-Server
- Stateless
- Cache
- Uniform Interface
- Layered System
- Code-On-Demand

HTTP Request Method

- GET：從指定的資源中獲取信息（一個或多個子資源), 不會更動到內部資源
    - Read
- POST：向指定的資源提交要被處理的數據。
    - Create
- PUT：將指定的資源用請求中的數據替換(更新)
    - Update
- DELETE：刪除指定的資源。
    - Delete

main.go

- 連線至postgreSQL, 並在8080這個port上面聽取request

server.go

- 將接收到的request透過GIN的router去呼叫對應的handler

account.go

- 實作request的handler (跟account有關的, 像是POST ⇒ createAccount, GET ⇒ getAccount / listAccount)
- 會呼叫account.sql.go裡的function來把data實際寫入到database裡面

## Lecture 12: Load Config by Viper


app.env:

- specify the environment variable
- no need to hard coded in go files

config.go

- use viper to load config files in a given path
- read the .env files

change main.go and main_test.go to read config through app.env


