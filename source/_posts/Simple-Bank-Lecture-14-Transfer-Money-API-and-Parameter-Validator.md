---
title: 'Simple Bank - Lecture 14: Transfer Money API and Parameter Validator'
date: 2023-04-24 22:06:16
tags:
- simple-bank
- backend
categories:
- tech
---

[course list link](https://www.youtube.com/playlist?list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE)

## CreateTransfer API

實做`createTransfer` API的方式跟`createAccount`的方法差不多

會需要定義一個`transferRequest`的struct, 然後把GIN的context bind到這個struct的物件上

在`ctx.ShouldBindJSON(&req)`這行就會去檢查ctx中每一個json欄位的要求是否有符合`transferRequest`的定義, 像是`Amount`必須要大於0或是`FromAccountId`最小為1

```go=
type transferRequest struct {
	FromAccountId int64  `json:"from_account_id" binding:"required,min=1"`
	ToAccountId   int64  `json:"to_account_id" binding:"required,min=1"`
	Amount        int64  `json:"amount" binding:"required,gt=0"`
	Currency      string `json:"currency" binding:"required,checkCurrency"`
}
```

接下來在`createTransfer`中還要去檢查`currency`是否合法

合法的意思是transfer request中指定的currency跟帳戶中的currency是不是同一種, 轉入跟轉出帳戶都要檢查

寫一個`validAccount`, 從database中拿到account的資料, 檢查request使用的currency跟account使用的currency是否相同, 若不同則會回應`BadRequest`

接下來就可以測試看看, 先跑`make server`, 然後開啟postman來傳送API看看

在request的body中設定傳輸的資料

![](https://i.imgur.com/4aNy65I.jpg)

因為account id 2使用的currency是USD, 所以會回覆`400 Bad Request`

![](https://i.imgur.com/ilJG4cK.jpg)

如果改成USD的話，就可以成功產生trasfer transaction

![](https://i.imgur.com/VgLvxYD.jpg)

可以再利用tablePlus去看account id 2 跟 id 1的amount確實有減少100跟增加100

## Custom Validator

validator是一個條件判斷式，可以用來註冊到GIN上面, 在bind GIN context的時候就會被檢查到

在`transferRequest`跟`createAccountRequest`中, Currency的binding條件都是去hard coded有哪些貨幣，但這樣對於擴充或是修改都很麻煩, 所以寫一個validator去判斷有哪幾種貨幣

```go=
type createAccountRequest struct {
	...
	Currency string `json:"currency" binding:"required,oneof=USD,EUR"`
}

type transferRequest struct {
	...
	Currency string `json:"currency" binding:"required,oneof=USD,EUR"`
}
```

在`util/currency.go`中定義貨幣種類的const, 並寫一個`IsSupportedCurrencty`來判斷input currency是不是定義的constant之一

在`api/validator.go`中建立一個bool function變數`validCurrency`, 會回傳`util.IsSupportedCurrency`

接著在server剛開始的時候把`validCurrency`註冊到GIN上面, 取名為`checkCurrency`

```go=
v.RegisterValidation("checkCurrency", validCurrency)
```

最後就可以把`createAccountRequest`和`createTransferRequest`的binding改成`checkCurrency`, 等同於是呼叫`util.IsSupportedCurrency`來檢查，未來要新增或是修改貨幣種類就可以統一在`util/currency.go`中做修改

```go=
type transferRequest struct {
	...
	Currency string `json:"currency" binding:"required,checkCurrency"`
}

type createAccountRequest struct {
	...
	Currency string `json:"currency" binding:"required,checkCurrency"`
}
```