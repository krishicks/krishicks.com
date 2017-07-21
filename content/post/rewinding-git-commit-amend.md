---
title: "rewinding git commit --amend"
date: "2012-06-25"
categories:
  - development
tags:
  - git
---

It may come to pass that you will run `git commit --amend` by mistake. When this happens, you'll want to unwind the operation you just did.

<!--more-->

In some cases the changes are simple enough that you can use [git reset -p](/blog/2012/05/16/git-reset-p/ "git reset -p") to remove those lines from the commit. However, sometimes `git reset -p` isn't up to the task, as in the case when the changeset is very large. Luckily, git has a ticker tape of the changes you make to each branch, which is called the reflog.

The reflog records when the tip of a branch is updated. The tip is updated any time you create a new commit, amend a commit, reset a commit, switch branches, etc. Basically, any time HEAD changes, you will get a reflog entry. The reflog therefore is a great tool for understanding how the repository came to be in a particular state.

`git reflog -2` will give you the last two operations that Git performed. In the case of an amend, it will look something like this:

    C HEAD@{0}: commit (amend): Something something something commit message
    B HEAD@{1}: reset: moving to HEAD~1

`git commit --amend` is kind of shorthand for the following, given changes have been made, and are either in the index or in the working directory:

    $ git stash
    $ git reset HEAD~1
    $ git stash pop
    $ git add .
    $ git commit

Or, in English:

* Save the changes that you want to apply to the HEAD commit off in the stash
* Remove the HEAD commit and put its contents in the index
* Apply the stashed changes to the working directory, adding them to the changes from the commit that was reset
* Make a new commit

Thus, the last two operations in the reflog are **reset** and **commit**.

So, what can we do with this? Well, B was HEAD before the amend happened. C is the amended commit. `git diff C..B` will show you what changes were applied as part of the amend:

    $ git diff C..B

From here you can use `git apply` to apply the reverse of what you amended earlier to your working tree:

    $ git diff C..B | git apply -

* Note: The hyphen in `git apply -` causes `git apply` to take stdin as input.
* Extra Note: The arguments to `git diff` are given in reverse order, with the later commit happening first to show the reverse of the amend. It's the same as doing `git diff B..C -R`, which reverses the diff output. Additionally, the -R argument may be applied to `git apply` instead of `git diff` to achieve the same effect.

Now we can do another amend to put the commit back to where it was before we did the previous amend:

    $ git commit -a --amend -CHEAD

And then, by reversing the order of the refs to `git diff`, get the changes we want to apply to the correct commit back:

    $ git diff B..C | git apply -

And commit as necessary, this time using --fixup to indicate the correct commit (in this example, A):

    $ git commit -a --fixup A

Then you can rebase either now or at a later time to do the 'amend' you had originally intended:

    $ git rebase --i --autosquash A~1

So don't fret when you do an accidental amend. It's just a couple commands away from being unwound and applied to the correct commit.
