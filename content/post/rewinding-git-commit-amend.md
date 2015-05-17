---
layout: post
title: "rewinding git commit --amend"
date: "2012-06-25"
comments: true
categories: 
  - git
---

It may come to pass that you will `git commit --amend` by mistake.

<!--more-->

When this happens, you'll want to rewind that operation you just did, and apply it to the correct commit. With simple changes you may find [git reset -p](/blog/2012/05/16/git-reset-p/ "git reset -p") handy. For times when the changes are far too large and intertwined to the commit, you will want to refer to `git reflog` for help.

The reflog records when the tip of a branch is updated. The tip is updated any time you create a new commit, amend a commit, reset a commit, switch branches, etc. Basically, any time HEAD changes, you will get a reflog entry. The reflog therefore is a great tool for understanding how the repository came to be in a particular state.

`git reflog -2` will give you the last two operations that Git performed. In this case, it will look something like:

    8751261 HEAD@{0}: commit (amend): Something something something commit message
    9d3a192 HEAD@{1}: reset: moving to HEAD~1

`git commit --amend` is kind of shorthand for (given changes have been made, and are either in the index or in the working directory):

    git stash
    git reset HEAD~1
    git stash pop
    git add .
    git commit

Or, in English:

* Save the changes that you want to apply to the HEAD commit off in the stash
* Remove the HEAD commit and put its contents in the index
* Apply the stashed changes to the working directory, adding them to the changes from the commit that was reset
* Make a new commit.

Thus, the last two operations in the reflog are **reset** and **commit**.

So, what can we do with this? Well, 9d3a192 was HEAD before the amend (specifically, before the reset) happened. 8751261 was the commit that resulted at the end of the amend process. `git diff 8751261..9d3a192` will show you what changes were applied as part of the amend.

From here, you can use `git apply` to apply the difference from before the amend to after the amend to your working tree via `git diff`:

    git diff 8751261..9d3a192 | git apply -

* Note: The hyphen in `git apply -` causes `git apply` to take stdin as input.
* Extra Note: The arguments here are given in reverse order, with the later commit happening first to show the reverse of the amend. It's the same as doing `git diff 9d3a192..8751261 -R`, which reverses the diff output. Additionally, the -R argument may be applied to `git apply` instead of `git diff` to achieve the same effect.

Now we can do another amend to put the commit back to where it was before we did the previous amend:

    git commit -a --amend -CHEAD

And then, by reversing the order of the SHAs to `git diff`, get the changes we want to apply to the correct commit back:

    git diff 9d3a192..8751261 | git apply -

And commit as necessary, this time using --fixup to indicate the correct commit (in this example, 1234567):

    git commit -a --fixup 1234567

Then you can rebase at a later time (or now) to do the 'amend' you had originally intended:

    git rebase --i --autosquash 1234567~1

So don't fret when you do an accidental amend. It's just a couple commands away from being unwound and applied to the correct commit.
