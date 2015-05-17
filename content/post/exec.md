---
title: "git exec"
date: "2012-04-06"
categories:
  - git
---

(Update #1 below)

Say you're going to do an interactive rebase where you're going to be squashing commits or reordering them. During this process you may want Git to execute a command after applying certain items of the todo list. An example of this would be when you want to run `rake` or similar to ensure a newly-squashed commit is still green.

<!--more-->

You can do this by adding a task to the todo list, `exec`, followed by the command you'd like Git to run at that point in the rebase. If the command you specify should return a non-zero exit code, Git will pause the rebase and allow you to sort it out, in the same way that it pauses when a conflict arises while applying the todo list during any other rebase.

Here's an example of the above situation, where two commits are going to be squashed, and I want Git to run `rake` after it does the squash.

Pre-edits, this would look like:

    pick dad8d12 Commit #1
    pick f613ac1 Commit #2
    pick 58822ee Commit #3

Post-edits, this would look like:

    pick dad8d12 Commit #1
    f f613ac1 Commit #2
    x rake
    pick 58822ee Commit #3

What happens here is Git will fixup Commit #2 into Commit #1, creating a new commit, then run `rake`. If `rake` returns a zero exit code, Git applies Commit #3 and completes the rebase. If `rake` had returned a non-zero exit code, Git would have paused the rebase operation at that point, allowing any necessary changes to be made to the HEAD commit, which is the squashed #1/#2.

I typically do this separate from doing an initial rebase, where I rebased and made a change to Commit #1 and had to resolve conflicts throughout the rest of the commits. This way I can keep my head straight while doing the rebase, then fix anything I missed as a second operation.

Update #1: As of Git 1.7.12 you can pass `-x <cmd>` to `git rebase -i` to have Git run the exec command after every commit in the resulting history: `git rebase -i <treeish> -x <cmd>`.
