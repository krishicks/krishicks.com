---
title: "Rewinding git pull"
date: "2012-07-09"
categories:
  - development
tags:
  - git
---
If you're using a rebase strategy for the first time you may run `git pull` in a situation where Git practically tells you to do it, but you don't actually want to do it.

<!--more-->

The situation is described below, and the method to unwind it follows. I've added pictures of the branches between hashes to make it clear what the state of the world is at any given point prior to or after running a particular command, which I hope makes it easier to follow.

First, you update master, as it's out of date:

    #############################
    A--B--C--D origin/master
    A--B--C master
    #############################
    
    (master) $ git pull
    Updating C..D
    Fast-forward
    ...snip...
    
    #############################
    A--B--C--D origin/master
    A--B--C--D master
    #############################

You create and checkout a topic branch, topicA:

    (master) $ git checkout -b topicA
    Switched to a new branch 'topicA'
    
    #############################
    A--B--C--D origin/master
    A--B--C--D master
              \
               topicA
    #############################

You make some changes, commit, and push it to origin.

    (topicA) $ git commit -am "Changed README"
    
    #############################
    A--B--C--D origin/master
    A--B--C--D master
              \
               E topicA
    #############################
    
    (topicA) $ git push -u origin
    (topicA) Counting objects: 28, done.
    ...snip...
    (topicA)  * [new branch]      topicA -&gt; topicA
    (topicA) Branch topicA set up to track remote branch topicA from origin.
    
    #############################
    A--B--C--D origin/master
    A--B--C--D master
              \
               E topicA
    A--B--C--D--E origin/topicA
    #############################

At this point you have your local topicA, and also origin has a copy of topicA:

    (topicA) $ git branch -a
    * topicA
    remotes/origin/topicA

You continue doing work, making more commits on your branch. Some time has passed since you branched from master, and another commit, F, has been pushed to origin/master.

    (topicA) $ git fetch # to update your local repository's knowledge of the remote
    
    #############################
    A--B--C--D--F origin/master
    A--B--C--D master
              \
               E--G--H topicA
    A--B--C--D--E origin/topicA
    #############################

At this point you want to rebase on top of origin/master to get the updates (in this case, F).

    $ git rebase origin/master
    First, rewinding head to replay your work on top of it...
    ...snip...
    
    #############################
    A--B--C--D--F origin/master
                 \
                  E'--G'--H' topicA
    A--B--C--D master
    A--B--C--D--E origin/topicA
    #############################

And then you want to push your updated topicA, with your new commits and the new commit from origin/master up to origin:

**The following assumes you have `git config.push default upstream` set. This configuration parameter limits the branch that git will attempt to push. I highly recommend you set that value as the default is to push *all* branches, which you probably do not want.**

    (topicA) $ git push
    To git@github.com:intentmedia/code.git
    ! [rejected]        topicA -&gt; topicA (non-fast-forward)
    error: failed to push some refs to 'git@github.com:krishicks/krishicks.git'
    To prevent you from losing history, non-fast-forward updates were rejected
    Merge the remote changes (e.g. 'git pull') before pushing again.  See the
    'Note about fast-forwards' section of 'git push --help' for details.

This is where trouble sets in.

First, Git tells you the push was rejected because you would have lost history. Then comes the troublesome line: "Merge the remote changes (e.g. 'git pull') before pushing again."

If you were working on master and made some commits, and someone else made some commits on master as well and pushed before you did, you would end up with the same situation as above. The push would be rejected because you don't have the commits that the other person made. Thus, if your push were to succeed their work would be lost on origin/master. This is what Git is referring to when it says "To prevent you from losing history.." The history that would be lost would be the work the other person did.

In the situation we've been building up, making commits and rebasing topicA, you're the only person committing to the branch and the history you would "lose" is the set of pre-rebase commits that you pushed to the remote originally (in this case, E). You've overwritten E with E' during the rebase, and Git doesn't want you to lose the E that's on the remote.

What you should do in this situation is `git push -f` to force-push the branch. You know you're going to lose E that's on the remote, but that's fine because you have E' on your local topicA. You intend to replace whatever is on the remote with whatever you have locally.

The problem is that it says to do a `git pull`, which will pull the remote E into your local, which you don't want. That will give you a merge commit, I:

    A--B--C--D--F origin/master
                 \
                  E'--G'--H' topicA
                           \
                            I
    A--B--C--D master      /
    A--B--C--D------------E origin/topicA


If you did a git log at this point you'd see that the merge commit I brought in E, which has the same message but a different SHA than your rebased E'.

    (topicA) $ git log --graph --oneline
    * I Merge branch 'origin/topicA' into topicA
    |
    | * E
    * | H'
    * | G'
    * | E'
    |/
    * D
    * C
    * B
    * A


So, how do you fix this? You can hard reset back to H', which gets rid of the merge commit, but **only if you didn't already make more commits after the faulty `git pull`.**

    (topicA) $ git reset --hard H' # Only if you didn't make any more commits!

If you have made commits after, with your log looking like this:

    (topicA) $ git log --graph --oneline
    * K
    * J
    * I Merge branch 'origin/topicA' into topicA
    |
    | * E
    * | H'
    * | G'
    * | E'
    |/
    * D
    * C
    * B
    * A

You need to use the two-argument form of [git rebase --onto](https://pivotallabs.com/users/khicks/blog/articles/2118-git-rebase-onto "git rebase --onto"):

    (topicA) $ git rebase --onto H' J~1

That will get rid of the merge commit, leaving you with:

    (topicA) $ git log --graph --oneline
    * K
    * J
    * H'
    * G'
    * E'
    * D
    * C
    * B
    * A

And now you can `git push -f`. The [docs on git-push](http://linux.die.net/man/1/git-push "docs on git-push") (or `git push --help`) do give you a better explanation than the message when the push is rejected, in the section NOTE ABOUT FAST-FORWARDS.

A simple rule about `git pull` is to not ever use it unless you're on master and have made no commits that put you ahead of origin/master, which you can easily tell with:

    (master) $ git fetch
    (master) $ git log @{u}..

or 

    (master) $ git fetch
    (master) $ git status
    # On branch master
    nothing to commit (working directory clean)

If the result from `git log @{u}` is empty or you don't get "# Your branch is ahead of 'origin/master' by  commit(s)" message after `git status`, you're OK to `git pull`. In no other case do you need to, or should you, `git pull`.

I generally recommend always working on a topic branch and keeping master clean to avoid accidentally running `git push -f` on master, and to enforce the idea that after you fetch, you're rebasing on top of origin/master directly instead of doing `git pull --rebase` while on master, which hides the fact that you're rebasing on top of origin/master.
