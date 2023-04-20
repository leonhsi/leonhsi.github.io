---
title: 'Simple Bank - Lecture 07: DB Transaction Lock'
date: 2023-03-18 23:33:53
tags:
- simple-bank
- backend
categories:
- tech
---

[course list link](https://www.youtube.com/playlist?list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE)

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