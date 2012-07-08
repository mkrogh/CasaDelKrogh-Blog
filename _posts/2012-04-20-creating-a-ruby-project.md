---
layout: post
title: "Creating a ruby project"
category: code
tags: [ruby, bundler, rspec]
---
{% include JB/setup %}

Setting up a new project is not necessarily something one does every day. 
The process always include some hoops and loops, along with spying on the previous projects one has created. 
Well at least thats how it is for me, at work however we keep some information on project initialization in a wiki. 
But as a single person a wiki feels like overkill, and it is often a lot less likely to be found by and help other people.

<!--more-->

I have started a few ruby projects so far, and I have become a great fan of [bundler](http://gembundler.com/) mostly due to the rails development I have been doing.
With bundler, dependency management becomes a breeze, just as it should be. 
Starting a new project using bundler means running:

    bundle init

This creates a nice `Gemfile` in your project ready to add your external gems, but more much more than this it allows you to use `Bundler.require(:default)`. With that awesome bit of code your local `lib/` dir will be required. This means you can concentrate on writing awesome code, instead of fighting with linking it together. 

In short a typical project main file, preferably called `{project-name}.rb`, would look like this, where `{project-name}` is the name of your project:

    require "rubygems"
    require "bundler/setup"
    
    Bundler.require(:default)
    require "{project-name}"

To make this main file work you will need to create the folder `lib/` and add another `{project-name}.rb` file.

Go ahead and test it
--------------------

Really, you should make some test cases. Some people like TDD red-green testing, others like to write test cases when the functionality is present. Any which way you like to test is fine by me, personally I always end up mixing red-green testing and follow up testing. The most important thing is to actually add tests!

I have grown fond of [Rspec](http://rspec.info/) lately, and find its DSL awesome. Therefore we shall look at how to add a some Rspec test cases to a new project. Start by adding `gem "rspec"` to the `Gemfile`.

... To be continued (sorry, forgot I started writing this post, I might return to it later).
