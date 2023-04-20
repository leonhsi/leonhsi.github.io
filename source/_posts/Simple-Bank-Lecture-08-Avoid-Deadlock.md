---
title: 'Simple Bank - Lecture 08: Avoid Deadlock'
date: 2023-03-20 20:33:09
tags:
- simple-bank
- backend
categories:
- tech
---

[course list link](https://www.youtube.com/playlist?list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE)

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
