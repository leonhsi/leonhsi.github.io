---
title: 'Simple Bank - Lecture 13: Mock DB for testing HTTP API'
date: 2023-04-20 23:27:12
tags:
- simple-bank
- backend
categories:
- tech
---

[course list link](https://www.youtube.com/playlist?list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE)

gomock:

- use gomock to mock db to return hard coded values
- 用來測試server HTTP API handling

in server.go, NewServer(store *db.Store) 都是接收一個db store object,

這個store object會連接到真正的database, 即是需要去mock這個object

為了產生mock的db, 把store object換成一個interface,

```
type Store interface {
	Querier
	TransferTX(....)
}

type Store struct {
	db *sql.DB
	*Queries
}
```

使用mockgen來產生被mock的store:
```bash
# mockgen -package <package_name> -destination /path/to/output <module_name>/path/to/interface <interface_name> 
mockgen -package mockdb -destination db/mock/store.go github.com/techschool/simplebank/db/sqlc Store
```
在`db/mock/`裡的`store.go`裡面的`MockStore`就是a mock of Store interface

### Test HTTP API
接著就可以在`api` package裡面新增一個檔案`account_test.go`來測試account handler

在account handler裡面用一個function `TestGetAccountAPI()`來測試`getAccount`

這個function主要負責:

1. 產生一個MockStore object `store`
2. 產生stubs: 即設定`store`裡的GetAccount function的參數, 呼叫次數和回傳值
3. 利用假的`store`產生新的`server` object, 開始傳送request
4. 傳送`/account/id` url來測試account handler裡面的`getAccount`是否正確
5. 檢查status code是否為200 OK, body的內容是否為假`store`所回傳的account

總之就是利用假的store物件來創立server, 寫死database(`store` object)要回傳的值, 來測試HTTP GET METHOD是否正確

接下來要擴充test case, 加入`NotFound`, `InternalError` 跟 `InvalidID`的測試, 來達到`getAccount` 的code coverage 100%

為了程式碼的整潔性, 使用golang的anonymous struct, 即不宣告struct而是直接建立
example:
```go
foo := struct {
    id int64,
    name string
} {
    id: 1,
    name: "trash",
}
```
可以利用到struct的好處, 將資料都集中在一起, 且只會被用到一次的話就不用特別再宣告命名它

```go
testCases := []struct {
    name          string
    accountID     int64
    buildStubs    func(store *mockdb.MockStore)
    checkResponse func(t *testing.T, recorder *httptest.ResponseRecorder)
}{
    {   // test case 1
        name:         "test OK",          
		accountID:    account.ID,
		buildStubs    func(store *mockdb.MockStore){
            // buildStubs implementation
        },
		checkResponse func(t *testing.T, recorder *httptest ResponseRecorder){
            // checkResponse implementation
        },
    },

    {   // test case 2
        name:         "test NotFound",          
		accountID:    account.ID,
		buildStubs    func(store *mockdb.MockStore){},
		checkResponse func(t *testing.T, recorder *httptest ResponseRecorder){},
    },

    {   // test case 3
        name:         "test InternalError",          
		accountID:    account.ID,
		buildStubs    func(store *mockdb.MockStore){},
		checkResponse func(t *testing.T, recorder *httptest ResponseRecorder){},
    },

    {   // test case 4
        name:         "test InvalidID",          
		accountID:    account.ID,
		buildStubs    func(store *mockdb.MockStore){},
		checkResponse func(t *testing.T, recorder *httptest ResponseRecorder){},
    },
}
```
`testCase`是一個array of anonymous struct, 這個anonymous struct包含:
* 測試的名字, 
* 要被抓取的accountID, 
* `buildStubs`設定假的`store`物件的`GetAccount` method的參數、呼叫次數跟回傳值等等, 
* `checkResponse`檢查http response的status跟body

因為`getAccount`總共可能會產生四種status:
* OK
* Bad Request: accountID不可能存在於datebase (i.e., 小於1)
* Not Found: accountID不存在於database
* Internal Error: 連不上database

所以就建立四種testCase, 有各自定義好的accountID, `buildStubs`, `checkResponse`等等

如此就包含了`getAccount`的所有status, 達到code coverage 100%

### Gin TestMode
在vscode上面run `api`的package test時, GIN會印出很多重複性log導致眼花撩亂, 這是因為GIN的預設模式是debug mode

解決方法是在`api` package裡面建立一個`main_test.go`, 並在`TestMain` function裡面設定GIN為TestMode就好了
