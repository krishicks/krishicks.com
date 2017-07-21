---
title: "Phone Interviews are Useless"
date: "2014-05-23"
comments: true
categories:
  - interviews
---

*See discussion about this post on [Hacker News](https://news.ycombinator.com/item?id=9111310).*

Yesterday, I did a coding challenge-based phone interview. When it ended, I had a mini retrospective with myself, and thought about what went well, and what didn't go well.

Mostly, it didn't go well.

<!--more-->

I dislike coding challenges, and interviews that are based around them. As soon as the coding challenge begins, my heartrate jumps and my stress levels rise. It's like being put on stage.

Often, when doing a coding challenge, I make silly mistakes and find myself forgetting to use idioms. It's only after the interview is over and I've relaxed a bit that I realize what my errors were and where I deviated from how I'd write code normally, and rewrite the code to my usual standard. But at that point the interview's over, and I've already lost.

I'm similarly bad at whiteboard coding. I don't ever do it outside of interviews, and I rarely do interviews. I avoided interviewing at Twitter for a long time because I was sure I wouldn't get through the interview process, which I knew to consist of both a phone interview and whiteboard coding. After a couple of my friends joined and I had a chat with an engineering manager there, I figured I'd give it a shot. If anything, it'd be practice for interviewing, which I'm terrible at.

I didn't get past the phone interview.

Most of the reason I'm so bad at coding challenge-based phone interviews and whiteboard coding is I have very low confidence in them as effective tools for interviewing.

Coding challenges done over the phone will select for people who are good at doing coding challenges over the phone.

It's probably the case that people who use coding challenges over the phone as a tool for interviewing feel differently than me about them. This was illustrated when I had the aforementioned chat with the engineering manager at Twitter. He applied the same low value to coding challenges as me, but knew he'd have to go through them to get the job. So he bought and read “Cracking the Coding Interview” to fill his developer toolbox with tools he doesn't usually use, and wouldn't expect to use in the position he was interviewing for, because the interview process expected it of him. He jumped through the hoops because everyone else jumped through the same hoops, and doing that particular bit of acrobatics was what everyone else wanted from their new hires. Sure, someone might be a great developer in their own right, but *can they jump through the hoops?*

At Pivotal, the gating portion of the interview is done differently from any other place I've interviewed at. The interview begins with, instead of a coding challenge, a TDD challenge: the interviewee is presented with a few failing tests for a reasonably simple problem, sitting side by side (*pairing*) with the interviewer in a typical work environment. The interviewee explains what kind of code they'd write to pass each test, and the interviewer does the typing. When all the tests pass, the interviewee gets to add new tests of their own, since there are certain tests that are missing (by design). This system allows the candidate to get a good idea of what they'd be doing day-to-day (pairing, TDD) in a realistic work environment. It also allows the interviewer to get a better idea of how the candidate approaches problem-solving.

When I was interviewing for my replacement at DaisyBill, I opted for a similar approach. I took an actual production feature I developed, copied a subset of the tests I wrote for the feature, and left a shell of the implementation for the interviewee to use as a starting point. This made for a repeatable, real-world-based, effective interview.

For more reading on effective interview processes, I recommend reading about [Project-Based Interviews](http://ejohn.org/blog/project-based-interviews) and [The GitHub Hiring Experience](https://github.com/blog/1269-the-github-hiring-experience).
