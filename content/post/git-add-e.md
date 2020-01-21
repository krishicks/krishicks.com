---
title: "git add -e"
date: "2012-05-21"
comments: true
categories:
  - development
tags:
  - git
summary: It's like add -p with as much context as you want.
---
`git add -e` is like `git add -p`, except instead of adding things at the hunk level, you edit the entire patch at once.

Or, in other words, whereas `git add -p` will show you each hunk for every file and ask what you want to do for each of them, `git add -e` will show you the entire patch and allow you to edit it at will. I used this trick to recently split apart one massive commit into 28 smaller, digestible ones.

Say you've replaced a line containing "baz" with one containing "bar". When you `git add -e`, you'll be presented with a diff like so:

    foo
    - baz
    + bar

From here you can decide, actually, you don't want to delete baz, you just want to add bar. And you want to add it above baz.

From this spot you can just change the minus to a space, making that line context for the diff. Then you can move the line that adds bar above baz, with this result:

    foo
    + bar
    baz

After saving and closing the editor you'll be able to look at the result of your work in the index with `git diff --cached`:

    foo
    + bar
    baz

And the line you made into context remains in your working directory, which you can see with `git diff`:

    foo
    bar
    -baz

But what if you end up modifying the diff in a way that makes it a patch that doesn't apply? Git's got you covered there.

Let's say that when you moved bar above baz, after removing the minus from baz, you added an extra line on accident, making the patch invalid:

    foo

    + bar
    baz

When you save and close the editor Git will tell you of the problem:

    error: patch failed: &lt;some_filename&gt;:1
    error: file.txt: patch does not apply
    fatal: Could not apply '.git/ADD_EDIT.patch'


In which case you'll be able to attempt the `add -e` again, as Git will not have made any changes to the working directory or index at this point.

In some cases Git will attempt to apply the patch and give you the option of retrying the add, re-opening the editor with the modified .git/ADD_EDIT.patch if you choose to retry. If you don't choose to retry, Git will delete .git/ADD_EDIT.patch.

In addition to editing the patch wholesale via `git add -e`, you can also choose <em>during `git add -p`</em> to edit a particular hunk manually by choosing 'e' to edit it instead of simply adding it via 'a'. You can also add a file glob to the end of `add -e` as you would any other command to limit the size of the patch you're about to edit.
