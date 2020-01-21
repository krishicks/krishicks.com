---
title: "Random git tips"
date: "2012-07-03"
slug: quick-tips
categories:
  - development
tags:
  - git
---

The following are things I found very helpful, which you also may find make your day-to-day usage of Git more enjoyable.

<!--more-->

## Go HEADless

In many (and perhaps all) cases HEAD is implied when no ref is given, such as the following equivalent statements:

    $ git log origin/master..HEAD
    $ git log origin/master..

## Upstream reference

Before you start referring to the upstream, you'll want to do a `git fetch` to update your refs/heads:

    $ git fetch

You only need to do this once in a while, or whenever you know the upstream to have changed.

You can refer to the upstream of any branchname or otherwise symbolic-ref by appending `@{u}` to the ref, such as:

    $ git log master@{u}

If you just want the upstream of the current branch, whatever it may be, you can replace master from above with HEAD:

    $ git log HEAD@{u}

## Upstream difference

Often, I'll want to see what commits are on upstream that I don't have. I usually will do this via:

    $ git log @{u}..

Which, when on master, is equivalent to:

    $ git log origin/master..HEAD

You can see the reverse difference, or the commits are on the remote that you don't have, by reversing the range:

    $ git log ..@{u}

Which, again on master, is equivalent to:

    $ git log HEAD..origin/master

*To see the full list of formats recognizable, see `git revisions --help`*

If you want to see both of the above at the same time, you can use `git log` with the --left-right parameter. I've also included --format='' and --oneline (which must be passed in that order), which may be optional depending on your format configuration, but for me are not:

    $ git log HEAD@{u}...HEAD --left-right --format='' --oneline

Which can be shortened to:

    $ git log @{u}... --left-right --format='' --oneline

*Note: The above example uses three dots, not two, to show only the commits which are reachable as ancestors of one branch but not the other.*

You can replace HEAD in the above with any symbolic-ref or branchname to use as a reference instead. The output (with the format given previously) will look like:

    < e86bd83 D
    < 6ea2155 C
    > eb2de55 B
    > 74829bd A

Commits beginning with "<" are only on the left side of the triple-dot (in this case, the upstream), commits beginning with ">" are only on the right side (in this case, the current branch). A..D are the commit messages.

## Is it merged?

To find out if a particular branch has been merged into origin/master, you could dig through the log on master and search for it:

    $ git log origin/master

Or, if you knew who would have merged it, you could limit the above with that:

    $ git log origin/master --author Kris

I wanted a better way, and I found it. I wanted to see if a particular branch had been merged to master without changing branches or having to dig through a log looking for the merge of the branch.

The situation that prompted this was that I had a topic branch, topicB, which depended on another topic branch, topicA. I wanted to see if topicA had been merged into master to find out if I could rebase onto master to get up to date, or if I should continue rebasing on top of the branch.

    $ git fetch
    $ git branch --contains topicB@{u} -r

This gives you a list of all the remote branches that can reach (as an ancestor) the ref given. origin/master will be right at the top if the branch has been merged into it.

Many thanks to [John Wiegley](http://newartisans.com/2008/04/git-from-the-bottom-up/ "John Wiegley"), [Scott Chacon](http://www.git-scm.com/book "Scott Chacon") and [Mark Longair](http://serverfault.com/a/384862 "Mark Longair") for the sources of the tips.
