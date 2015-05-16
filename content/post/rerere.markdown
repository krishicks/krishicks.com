---
layout: post
title: "rerere"
date: "2012-06-13"
comments: true
categories:
  - git
---
There have been times where I performed a rebase and had to resolve conflicts as part of the rebase, and then decided to abort the rebase for one reason or another.

<!--more-->

Without `rerere` the next time I went to perform the rebase I'd end up having to resolve at least some of the same conflicts I had previously, which is annoying.

This is where `rerere` comes in. It stands for **re**use **re**corded **re**solution.

What `rerere` does is save the resolution of a conflict so that it can be re-applied later if it sees the same conflict again. When Git sees the conflict which it already has a resolution recorded for, it will apply the resolution automatically for you, and give you the opportunity to accept the resolution as applied, or change it.

Turning it on can be done two ways: set it as a configuration parameter using `git config rerere.enabled true`, or use it only when you think you might need it with `git rerere` both before and after the resolution of a conflict.

*A more verbose explanation of `rerere` exists in Scott Chacon's **Pro Git***.
