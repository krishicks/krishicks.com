---
title: "git reset -p"
date: "2012-05-16"
categories:
  - development
tags:
  - git
summary: When you only want to reset _some_ of a commit.
---

I've been using `git reset -p` a lot recently and I think it makes sense to clarify what it is that it does because when I first started using it I found it a little confusing.

I sometimes realize that an earlier commit contains some change that I don't want, so I want to remove it from the commit. This also works when not rebasing, so for simplicity I'll use an example where the commit to be modified is already HEAD. Previously I would have done:

    git reset HEAD~1
    git add -p
    git commit -C <treeish>
    git checkout .
    
Or, in English:

* take off the HEAD commit, adding it to the working directory
* add back the parts you want to keep
* make a new commit using the message from what used to be the HEAD commit
* throw away the changes you didn't want

With git reset -p this process is a little different. Here's what it looks like:

    git reset -p HEAD~1
    git commit --amend -C HEAD
    git checkout .
    
Again, in English:

* apply to the index the negations of certain parts of the HEAD commit
* amend the HEAD commit with the negations
* throw away the changes you don't want

How does this work?

In the second example you added `-p` to the `reset` command. This will reset only parts of the original commit, leaving it intact otherwise. That's worth stating a different way: When you `reset -p`, <strong>the original commit remains unchanged</strong>. The only changes are made to your working directory and index.

The trick is to know what you're doing when you're saying "y" to a hunk git presents to you for resetting. Say you added a line to the commit originally:

    foo
    + bar
    baz
    
But you want to get rid of it. When you git reset -p, git will ask you:

    foo
    - bar
    baz

Apply this hunk to index [y,n,q,a,d,/,e,?]?
    
If you say 'y', Git will apply that hunk to the index. What you also get, however, is the original hunk (that added "bar") in your working directory.

To summarize, your working directory will have:

    foo
    + bar
    baz
    
While the index has:

    foo
    - bar
    baz
    
While the commit (unchanged, remember) has:
    foo
    + bar
    baz
    
You now have a chance to tell git what you want to do, without having done anything to the original commit yet. In the example above, you wanted to get rid of the addition of the "bar" line. To do that, you want to take what's in the index (the negation of the addition of "bar") and apply it to the commit, making it go away:

    git commit --amend -C HEAD
    
Then you still have in your working directory the adding of "bar", which in this case you just want to get rid of, so:

    git checkout .
    
I like using `reset -p` because it makes it really easy to make small changes to a commit, removing something I added or putting back something I deleted.

`reset -p` allows you to more easily get a grip on the changes you've made and the ones you're about to make. It also makes much better use of Git, in that you can do even more interesting operations when in the resulting state, which I won't go into now as to avoid information overload.

And there you have it.

