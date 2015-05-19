---
title: "git rebase --onto"
date: "2012-05-28"
categories:
  - development
tags:
  - git
---

Have you ever dug into the `git rebase` documentation and noticed there's a three-argument form of it?

<!--more-->

First, let's look at the two-argument form, and build up to the three-argument form.

## The two-argument form of git rebase --onto

Say there's a commit C made on master that made a change to a configuration parameter that, it turns out, wasn't actually necessary, so that commit needs to go. For the purposes of this demonstration, commits D and E don't rely upon the changes made in C. &#40;If D or E did rely on C, you'd end up with a conflict to resolve, which you'd be able to do at that point.&#41;

    A--B--C--D--E master


One way to get rid of the offending commit would be to do an interactive rebase, deleting the line that has commit C on it:

    git rebase -i C~1
    delete the line containing commit C
    save and close the editor

A quicker way is to use the two-argument `git rebase --onto`, as going interactive just to delete a commit &#40;or commits&#41; is a little overkill, and considerably slower to do.

`git rebase --onto` takes a new base commit &#40;which the manpage for git-rebase calls newbase&#41; and an old base commit &#40;oldbase&#41; to use for the rebase operation.

So, what we want to do is tell Git to make commit B the newbase of commit D, making C go away. This looks like:

    git rebase --onto B C

But usually I like to talk about the commits I care about rather than the ones I don't &#40;in this case, I care about B and D, but not C&#41;, so instead of the previous command I use a backreference from D:

    git rebase --onto B D~1

This means that everything in the range from B &#40;non-inclusive&#41; to D~1 &#40;inclusive&#41; *will be removed*.

`git rebase --onto` allows you to, in a non-interactive way, change the base of a commit, or *rebase* it. If you think about the commits as each having a **base**, or **parent** commit, you can see how you might be able to change the base of any commit to be another commit. In doing so, you remove everything that used to be in between the oldbase and the newbase.

It's also good to know that it works exactly the same way as if you were to have done an interactive rebase and deleted the commit. Should a conflict arise while performing the rebase, Git will still pause and allow you to resolve the conflict before continuing.

I've also used the two-argument form when fixing a mistake: I had a branch from master, topicA, with some commits that I wanted to change via interactive rebase:

    A--B master
        \
         C--D--E topicA

But when I rebased, I went back too far, and rewrote a commit that I had gotten from master:

    A--B' master
        \
         C'--D'--E' topicA

&#40;Note that there was no change to the master branch here, just to topicA.&#41;

What did I do to fix this situation? Well, I can't fix this via interactive rebase. I can, however, fix it via `git rebase --onto`:

    git rebase --onto master C'~1


Or, in other words: Replace the oldbase C'~1 with the newbase, master &#40;which is HEAD of master, or B&#41;.

It's a handy undo mechanism.

If you forget to give the two-argument form of --onto its second argument, such as:

    git rebase --onto master


..it will be the same as doing:

    git reset --hard master

**You probably don't want this.**

Why is this? The second argument &#40;the oldbase&#41; is required if you want a range of commits to be applied on top of master. Without it, you haven't supplied a range of commits to be applied on top of master, so HEAD of the branch gets reset to the HEAD of master.

What that means is any commits you have on your branch will be removed from the branch, and the branch will resemble master at that point. These commits are still in Git until garbage collection happens, accessible via the reflog &#40;`git reflog`&#41;.

# Part Two:

## The three-argument form of git rebase --onto

Say there is a branch 'topicA' that diverges from master at some point:

    A--B--C--D--E master
        \
         F--G--H topicA


Let's also say that someone else has branched from topicA to create topicB, and added more commits:

    A--B--C--D--E master
        \
         F--G--H topicA
                \
                 I--J--K--L--M topicB


This is an example of a real-world case I came across, where topicA had only a couple very large commits that were hard to digest and could have been split into many smaller commits. topicB was created as a continuation of the work done on topicA.

I checked out my own local copy of topicA, and through much interactive rebasing and prodigious use of `git add -e`, I was able to split topicA into smaller commits, making topicC:

    A--B--C--D--E master
       |         \
       |          F--G--H topicA
       |                 \
       |                  I--J--K--L--M topicB
       |
       N--O--P--Q--R--S--T--U--V--W topicC


I talked with the person that made topicA and we agreed that my branch topicC should take the place of topicA. But what to do about the work that was done on topicB?

The operation that we wanted to do is: make topicC the new base of topicB, cutting it at the point topicB diverged from topicA, which looks like:

    A--B--C--D--E master
       |         \
       |          F--G--H topicA
       |                 \
       |                  I--J--K--L--M topicB
       |
       N--O--P--Q--R--S--T--U--V--W--I'--J'--K'--L'--M' topicC


The five commits from topicB &#40;I through M&#41;, get played on top of topicC, starting from where topicB diverged from topicA, to create I', J', K', L', and M'.

The command to do this is:

    git rebase --onto topicC topicA topicB

Where topicC is the newbase, topicA is the oldbase, and topicB is the reference for what HEAD of topicC will become.
