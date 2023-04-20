---
title: 'Simple Bank - Lecture 11: RESTful API with GIN'
date: 2023-03-30 23:30:19
tags:
- simple-bank
- backend
categories:
- tech
---

[course list link](https://www.youtube.com/playlist?list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE)

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