---
layout: post
title: "Treasures on rails"
category: code
tags: [rails, ruby, fun]
---
{% include JB/setup %}

In my spare time I am the chairman of a netparty society called [Nanolaug](http://www.nanolaug.dk). 
Twice a year we organize a Netparty for about 80 people.
Normally we have 2-3 combos and every now and then a fun-combo.

For a recent party I decided to host a fun-combo consisting of a digital [treasure hunt](https://treasure.nanolaug.dk). 

<!--more-->

The idea came after participating in [The Camp](http://thecamp.dk "Danish only") 2012, where ptrf hosted a digital treasurehunt.
The goal was to collect the most gold (md5 sums) by solving differnt puzzles, most having something to do with computer science.
To find the puzzles you had to look for clues hidden on different webpages.
The treasure hunt from the camp was inspired by the [the pwnies](http://treasure.pwnies.dk) site (it was actually a clone of it). 

As mentioned I decided to host a treasure hunt, but I chose to make it a bit simpler.
Mostly because people participating in a netparty are not that proficient in crackmes, decrypting, and general programming language obscurity.

The case
--------

A simple digital treasure hunt consists of gold and maps.
I chose to represent gold and maps as a sha1 sum in hex, to differentiate between the two I chose to reperesent them as:

- `GOLD-7b07fa2a6abcb72f56543e5fc9f4946ea15cf5bc-END`
- `MAP-945fa9bc3027d7025e3de4a72fcfe7077bfbfaf9-END`

Maps are used to find different puzzles, and locate more gold.
They consist of a title, some text and of cause a sha1sum(key).
Some maps are hidden within the pages and the resources (css, js, etc). 

Gold is finite and can be registered in a "bank account", or rater it can be claimed. 
The more gold you have claimed the higher your score will be on the central score board.

To spice it up a bit I added the possiblity to create a series of questions. 
Each correct answer is rewarded with a pice of gold and a new question (if there are anymore).
Answers to questions are implemented as regular expresseions, which allows you to accept multiple answers as correct.

Manage it
---------

In order to manage it all I created a simple CRUD interface protected by omniauth.
As something new I decided to make a mailer that sends me (the admin) a mail when someone without access tries to log into the manager interface. 
This way I did not have to make an explicit signup procedure, see: [https://gist.github.com/mkrogh/3995995](https://gist.github.com/mkrogh/3995995)


The end
-------

There probably was an end to this post but I ended up beeing to drunk to write it, or I ran out of power on the laptop.
