---
title: 'Simple Bank - Lecture 09: Isolation Level'
date: 2023-03-20 23:32:14
tags:
- simple-bank
- backend
categories:
- tech
---

[course list link](https://www.youtube.com/playlist?list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE)

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