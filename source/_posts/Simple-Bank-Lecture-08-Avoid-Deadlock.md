---
title: Simple Bank, Lecture 08 - Avoid Deadlock
date: 2023-04-17 20:12:09
tags: simple-bank, backend
---
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
