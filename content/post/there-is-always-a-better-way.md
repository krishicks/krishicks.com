---
layout: post
title: "There is Always a Better Way"
date: "2016-11-05"
categories:
  - development
---
I got into software development because of a single idea: there is always a better way.

I was working at a title insurance company in the US during the housing boom of 2007. I was hired as a temp to do data entry for the calculation of fees associated with purchasing [title insurance](https://en.wikipedia.org/wiki/Title_insurance). It was a straightforward job, with one incredible hindrance: everyone was using adding machines, which is a fancy desktop calculator that prints out a receipt as you enter calculations.

<!--more-->

I found the usage of the adding machines remarkable because we were all sitting in front of computers with Microsoft Excel installed on them.

I knew of Excel but had no use for it before I joined the company, so I went along with using the adding machine at first. After seeing how unreliable and slow they were, I decided to teach myself enough Excel to have it do the title insurance fee calculations for me.

Excel was a *better way* to do these calculations: more reliable, repeatable, and less error-prone. Create a cell or cells with formulas once, and just change the house purchase price to see the new result. No intermediate calculations required, and certainly none done by hand. No double-checking of receipt paper. Just copy and paste the result from Excel into the appropriate textfield in the browser.

After doing this for a while my supervisor took note: my error rate was greatly reduced, and I was able to do more work as well. He wondered if I would be interested in working on implementing some "macro" software they'd bought, which was meant to be able to do what I'd done in Excel, automating the calculating of the fees, but to go a step further and put result into the browser, as well.

It had a simple scripting language that allowed you to drive the mouse pointer, having it click around the desktop, or within a specific application. After learning the very basic scripting language and trying to repeat what I'd done in Excel, I found it not to be powerful enough to reliably enter the values directly into the browser. The scripting language and its ability to do calculations was too poor. I went back to using Excel.

The idea of automating the entire workflow was very attractive, and stuck with me. Copying and pasting things from Excel into Internet Explorer had its drawbacks, and was also not fast enough. My experience with the macro software showed me there was a better way.

I'd been having conversations with a friend of mine for months, maybe years at that point, about getting into software development. The problem was I didn't know where to start. I had bought a variety of software books on topics such as HTML/CSS, Java, and C, but couldn't translate what they were teaching into something I could use. The issue then was that I didn't have a problem to solve, or didn't have the ability to identify problems that could be solved with software.

At my title insurance data entry job I now had a problem that I saw could be solved with software: calculate the fees and enter them into the browser as quickly and reliably as possible, with the least amount of intervention from me.

I began looking into learning VBA, with the idea that I could learn enough of it to get the calculations from Excel into IE6, which appeared to be possible. In searching for things related to "automating the web browser", I came across a Ruby testing library called [WATIR](https://watir.github.io). WATIR allows you to write  Ruby to drive a web browser. Once I discovered WATIR, I had both a problem to solve and the means to do it.

The rest, as they say, is history.

I taught myself enough Ruby to write a full replacement of the macro software, which I then used to completely automate my job. What used to take 13-15 minutes to do unreliably now took 10-12 seconds, reliably. The only thing that made it that slow and variable was the webpage load times.

After a year and a half at the title insurance company, I left to become a real programmer. I wasn't learning fast enough at that point. Joining ThoughtWorks was a better way to learn.

Perhaps this idea, that there is always a better way, is also useful to you. I used it for figuring out how to do data entry better, and now I use it when becoming better at writing software. 

The only caveat that I would add is that while there often is a better way, there is a point of diminishing returns. Being able to recognize when what you've got is *good enough* is important.
