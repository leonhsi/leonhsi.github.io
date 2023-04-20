---
title: 'Simple Bank - Lecture 12: Load Config by Viper'
date: 2023-03-31 23:29:12
tags:
- simple-bank
- backend
categories:
- tech
---

[course list link](https://www.youtube.com/playlist?list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE)

app.env:

- specify the environment variable
- no need to hard coded in go files

config.go

- use viper to load config files in a given path
- read the .env files

change main.go and main_test.go to read config through app.env