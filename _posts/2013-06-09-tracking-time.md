---
layout: post
title: "Tracking time"
category: code 
tags: [JS, punch-clock, coding, require.js]
---
{% include JB/setup %}

In response to recent rule changes at work, and my desire to take a crack at using requirejs for something usefull, I have created a simple punch-clock javascript app that can help me track time spent.

There are a lot of apps out there to track time, and a lot of them are quite nice, but "not invented here" has not been coined in vain. 
Due to the relative low complexity of the problem I decided to DIY it and created [punch-clock](http://punch-clock.boundless.dk).

<!--more-->

Motivation
----------

Recently at work we have been instructed to register our over and under time.
Previously we have had a "rule" that it was up to ourselves to keep track of our time, as long as we did not exceed two work days. 
It has worked fine and generally been pleasant, but as AAU have begun to centralize all IT resources, a set of ground rules have been laid out.

Unfortunately that means I now have to report my over/under time. 
One of the things I am notoriously bad at is time calculations, but then I can "create an app for that"&trade;

Enter punch-clock
-----------------

{% image_right punch-clock/punch_clock.png %}
Punch clock is a simple check-in, check-out app that calculates the time spent. 
When a check-in is created it will keep the duration up to date as time passes. Finally when checking out it will display start and stop time, and the duration. 

At the moment it stores check-in/outs in the browsers local storage. 
This means you can check-in, close the page/browser and return later to check-out/see progress.

That is all the app supports by now, I know quite simple, that is what is nice about it.

Approach
--------

I decided to use [require.js](http://requirejs.org/) to allow me to modularize my code, then I added [jasmine](http://pivotal.github.io/jasmine/) for testing, and decided on using [moment.js](http://momentjs.com/) for time manipulation.

The source files are split up into somewhat simple modules.
I have created models, services, presenters, views and more.
This gives a natural belonging of each module and makes it easier to approach.

Punch-clock is structured as a Model-View-NotReallyAnyControllersButSomeServicesAndObservers. 
This means that the views handles both changing the DOM and DOM interactions.
Views listens/observes/subscribes to service and model events and updates the DOM accordingly.

Each time a new check-in is added the service emits an event, which the different views respond to buy updating.
This makes the views very flexible, and encourages splitting up views into small modules that only handle one thing.
I have the following views:

<dl>
  <dt>Check-in</dt>
  <dd>Handles check-in/out buttons.</dd>
  <dt>Status</dt>
  <dd>Updates the main textual status.</dd>
  <dt>Cleanup</dt>
  <dd>Handles cleanup button and count.</dd>
</dl>

Even the local storage backed is created by wrapping the simple service and listening on changes on both the service and the individual model objects.
When a change occurs it simply serializes the entire simple service to JSON and stores it.

Testing
-------

At the time I started writing code for punch-clock I was reading [clean code](http://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882) by Uncle Bob.
But I must admit that my models are a hideous blend of data-structures and real objects. 
This however lead me to take a hard look at my code and pushed me to try to structure my code to make it testable.

Normally when I write code most of my view code tends not to be testable, in this little app I have tried to remedy that.
So far all my views has tests, and adding new tests are quite simple.
One might simply disregard this as punch-clock being a rather simple app, which is true, but surprisingly DOM interactions can be made quite testable, with a little work.

In general the views can take a DOM-node which they will use instead of the page DOM. 
This means that in tests you can create a simple DOM structure and check it for changes the view should have performed.
Furthermore you do not have to worry about cleaning up the page DOM after a test has run.

    var $test, service;
    var view;
    beforeEach(function(){
      $test = DomCreator("div h2.punch-clock");
      service = TimeSpanService.create();
      view = StatusView.create(service, $test); 
    });

The above code is an example of how the DOM can be "mocked" you can then check it for changes:

    it("updates status when adding time spans", function(){
      expect($test.textContent).toEqual("");
      service.addNew();
      expect($test.textContent).toContain("Check-in at");
    });

Finally using jasmine you can mock out time dependencies, which allows you to test timeout functions.

    it("should update accordingly", function(){
      service.addNew();
      var before = $test.textContent;

      //Move start 3min back in time :D
      service.first().start().subtract(3, "minutes");

      jasmine.Clock.tick(30001);
      expect($test.textContent).not.toEqual(before);
    });

Yep I am aware of that nasty change the time hack that does not obey the [Law of Demeter](http://en.wikipedia.org/wiki/Law_of_Demeter).

The future
----------

Right now punch-clock is quite basic.
It supports my basic needs, but there are some immediate functions I would like to add:

1. History - the ability to see previous check-ins.
2. Check-in url paramter - allow you to bookmark a auto check-in so you can add it to your startup pages on your work machine.
3. Edit - edit check-ins
4. Categories - or tags e.g. work, training etc.
5. Delete - delete individual check-ins 
6. Save to web-service - e.g. simple backend, gists, google drive.
7. Check-in on multiple devices using a unique indentifier.. email?

There is probably a lot of other things that makes sense to add, or not to add.

The source can be found at: [github](https://github.com/mkrogh/punch-clock), and the app is running at [punch-clock](http://punch-clock.boundless.dk/).

