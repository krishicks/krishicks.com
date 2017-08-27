---
title: "The Case Against Non-Technical PMs of Technical Projects"
date: "2017-08-27"
---
## What is a PM?

In [agile software development](https://en.wikipedia.org/wiki/Agile_software_development) there exists a role called Project Manager (PM). The person in this role is charged with understanding the needs of and empathizing with their stakeholders and the end users of their product(s). The PM converts the needs of stakeholders and desires of end users into units of work that can be executed by the engineering team.

These units of work ("user stories" in agile parlance) are written and prioritized by the PM. The PM includes both the reason for the feature and what it means to successfully complete the feature ("acceptance criteria") when writing the user story. These user stories may be new features or bug fixes for existing features.

The PM is the final arbiter on the work done by the engineering team; they accept or reject the work done by the engineering team as a complete solution for a particular user story.

An effective PM is able to take the stakeholders' needs into account and translate those into stories which are understandable by the engineering team. The stories should effectively convey the need for the feature or what the bug is that needs to be fixed, and clearly describe the acceptance criteria.

An effective PM is able to see the faults or room for improvement in their product and come up with ways to improve it. They are intimately familiar with the product and understand how their end users use it, and what the experience of different kinds of users of their product ("personas") is like. Optimally, they are themselves users of the product and can use that experience to improve the product.

The PM is also someone who interacts with the stakeholders and end users so that the engineering team doesn't have to. They shield engineering from any internal politics relating to the product as much as possible, delivering only a feature narrative for engineering to execute on.

## What is a technical PM?

A technical PM is defined as one that comes from a technical or engineering background. A technical PM may have previously been an engineer on the team they are now the PM of.

## How non-technical PMs fail technical projects

It has been my experience that non-technical PMs routinely fail to deliver when tasked with being the PM of a technical project. In multiple cases I have seen someone from the engineering team take up the slack from the non-technical PM, taking over those duties that the non-technical PM is unable to perform.

This behavior is toxic: it leads to a PM who maintains a lack of knowledge about the product, who cannot be a champion or steward of it because they do not understand it, and who cannot propery empathize with either stakeholders or end users.

The person who is actually doing the work is not invited to the meetings with stakeholders, therefore _also_ cannot properly empathize with the stakeholders, and must divine stakeholder needs via poorly-written stories from the actual PM. This extra work done by engineering to make up for the lack of a technical PM is also not accounted for except by in reduced velocity of the team.

Additionally, the non-technical PM doesn't understand what it means to accept a technical feature as being complete as they don't have a basis of understanding of the feature. This leads to more engineering time being used to explain the feature to the PM, which is precisely backwards.

## Case history

In one case, I was part of a team for a technical project that had as its main product a complex CLI on the order of `git`; a product which, through its complexity and breadth, was ill-understood by all but the most frequent users of it.

It was clear to me that the PM had basically abdicated all duties to one of the engineers on the project. The PM, not having a good understanding of how the product worked or who it was for or how they wanted it to work wasn't able to perform acceptance on new features or bug fixes without help from the engineering team. It was also clear that when certain features the stakeholders wanted were described to PM, the PM had a complete lack of understanding of the feature beyond a general concept, and therefore was unable to deliver user stories that properly conveyed the need for the feature, or what it was. This, again, was slack taken up by the aforementioned engineer.

In another case, I was the engineer that ended up taking the slack up for a non-technical PM. I ended up having to rewrite stories that didn't make sense, either because the original stories asked for things that weren't deliverable features or because the acceptance criteria was vague and not verifiable. I was the one that had to then explain features to the PM, and how to perform acceptance on them. I was also the source of original ideas for how to advance the product and the sole engineer that executed them.

## Advice

While there may be a technical project that benefits from a non-technical PM, I have yet to experience that in almost a decade of agile software development.

I have had plenty of good experiences with non-technical PMs on projects that were targeted to non-technical end-users, and plenty of good experiences with technical PMs on projects that were targeted to technical end-users.

For technical projects, I maintain that only a technical PM can truly empathize with both stakeholders and end users of technical products, and deliver quality products without siphoning off effort from the engineering team.

The cost both in wasted engineering time and in burned out engineers that have to do extra work is nothing to sniff at.
