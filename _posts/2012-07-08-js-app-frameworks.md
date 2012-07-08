---
layout: post
title: "JS app frameworks"
category: code
tags: [JS, development, testing, jasmine, ember.js, backbone.js, spine.js]
---
{% include JB/setup %}

In order to brush off my JS skills a bit I want to build a small HTML5 app, for mobile and desktop use.
As not to start from scratch I poked around in the toolbox for frameworks to use.

I take a 10.000 km overview of [ember.js](http://emberjs.com/), [backbone.js](http://backbonejs.org/), and [spine.js](http://spinejs.com/) for the core app development, and try to decide which testing framework to use.

<!--more-->

Testing
-------

The first thing I took a look at after chiseling out the idea was which testing framework to use.
The reason for that is that my normal approach to coding often end up a bit unwieldy, and for this App I wanted to do a bit of TDD/BDD (Test driven development/Behavior driven development).

I have used [QUint](http://docs.jquery.com/QUnit), the jQuery unit testing framework before, and it is a nice unit testing framework.
When I write ruby code I have grown fond of [Rspec](http://rspec.info/) which is a BDD style testing framework. 
Therefore I have had an eye at the [Jasmine](http://pivotal.github.com/jasmine/) testing framework for some time.

These are the only two testing frameworks I have chosen to look at, I am sure there are a lot of other brilliant frameworks, but these two fit my needs.

### QUnit

A simple, well documented, unit testing framework used to keep the jQuery code working. 
Instead of showing off some tests here it is way easier to point to the [official documentation](http://docs.jquery.com/QUnit#Using_QUnit), which as stated is more than enough to get started.

Tests run in a dedicated HTML page that outputs a nice overview of the test results.

### Jasmine

As mentioned Jasmine has a lot of similarity to Rspec, it allows you to describe and test features as a set of test cases.
Again the documentation of this testing framework is ace, allowing me to just point at it and be done with it [jasmine example](http://pivotal.github.com/jasmine/).

The most irritating thing about jasmine is that it was not very straight forward where the distributable could be downloaded, but then again I could just have read the entire introduction.
The download link is at the way bottom, and includes a nice template for getting up and running.

Just like QUnit the tests can be run from a dedicated HTML page, which is nice e.g. for testing in multiple browsers.

### Choosing a testing framework

I have ended up choosing Jasmine as it resembles Rspec. 
Only time will tell if it is a good choice or if I end up backtracking.

JavaScript framework
------------

After choosing a testing framework I set out to find a suitable JS framework.
I have mostly rolled my own MVC up until now, but I am a great fan of building on top of other peoples work, as it often means you can focus on the functionality rather than the nuts and bolts/stitching of the App.

So I feel like it is time to to bring in the cavalry, but when you are somewhat used to looking under the hood you get a bit picky.
I have played around with Backbone.js before and liked many of the things it enables you to do, and the freedom you get.
I have also had my eye on ember.js for some time, and the vision of spine.js has had me intrigued.

There are other frameworks out there, e.g. [angular.js](http://angularjs.org/) by some Googler's, but I have chosen to look at these three frameworks because they fit my idea of how a JS framework should be.

### Backbone.js

Backbone.js is a bare bone lightweight MVC framework developed as a part of the DocumentCloud project.
It clocks in at 5.6kb minified which is impressive, it does however require Undersocore.js which adds 4kb, json2 (1kb), and for DOM manipulation jQuery (32kb) or Zepto (8.4kb). 
I will probably end up including jQuery anyway, so excluding that payload the Backbone.js setup clocks in at about 11kb, which is very impressive.

Backbone.js provides base methods for creating Models, Collections, Controllers, Views and more. 
It leaves it up to you how to connect the dots, but it also gives you a lot of documentation and a healthy community to get you up and running.

### Ember.js

Ember.js was created by Tom Dale and Yehuda Katz as a reboot of SproutCore done from the ground up with focus on removing developer frustrations.
On a slight side note Katz is one of the core Rails guys, who did a lot of work on the Rails 3.

With this pedigree it should prove to be an interesting framework, and on the face of it, it is.
Ember.js comes with auto-updating views, meaning that when your models are updated all the relevant views will be re-rendered.
This is a cool feature, it does however force you to use handlebars, the Ember.js template language, which is fine. 
Handlebars is a mustache based template language designed to be potent and leverage template caching.

All in all Ember.js is sporting some nice features. 
The big drawback is the documentation, which is either out of date or simply missing, and often out of sync with the current implementation.

### Spine.js

As far as I remember Spine.js was created as a Backbone.js done right. 
It sports a lot of philosophy and pattern ideas. 
One being that the interface must be non-blocking, which is bold and brave, but nice to see.

Spine.js projects are encouraged to follow a Rails like layout, and comes with a set of node.js tools that makes project creation easy.
It encourages developing using coffeescript, which is somewhat awesome, but has its limitations.

Spine.js also have fairly good documentation along with some screen casts. 
The hem development server seems nice, allowing you to make proper integration testing right from your dev machine, without having to setup a server.

### Choosing a JS framework

I chose ember.js because I like Handlebars, and some of the ideas behind the framework.
However after fiddling around, trying to do even simple tasks such as setting up a new model I became increasingly frustrated with the inconsistency of the documentation.

The front page sports a quick sweet siren song example, but no other pinpointers.
The documentation page does not show how to use the `DS.Model` (datasource), and the API contains absolutely nothing of value to beginners.

The boilerplate start you can download contains no scaffolding what so ever, not even a simple Hello person app.
If it just contained a simple app with a model, controller and a view you would probably be able to get going fairly quickly.

This lack of a best practice guideline makes me a sad panda, and it means I will probably make the first prototype using Backbone.js. 
I am however adamant that I will return to ember.js at some point, perhaps redo the app in ember.js at a later time.
