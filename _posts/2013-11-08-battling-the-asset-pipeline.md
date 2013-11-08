---
layout: post
title: "Battling the asset pipeline"
category: code
tags: [rails, asset pipeline]
---
{% include JB/setup %}

About half a year ago I had to update a rails 3.1 application to 3.2.
With the upgrade my [Sass](http://sass-lang.com/) and [CoffeScript](http://coffeescript.org/) auto-compilation ended up being botched.

This prompted me to change to the asset pipeline, which in itself proved to be a bit like [yak shaving](http://imgur.com/t0XHtgJ), fixing one thing only to have a new bug appear.

<!--more-->

One of my primary resources for enabling the asset pipeline was Ryan Bats excellent rails cast about [upgrading to 3.1](http://asciicasts.com/episodes/282-upgrading-to-rails-3-1).
It helps you get a basic asset pipeline setup.

The standard asset pipeline configuration in rails only covers `application.js` and `application.css`, and I needed to add a couple of extra files.
One way to do this is to add them to the `config.assets.precompile` array.
 
    ['main.css', 'editor.js', "indgang.js"].each do |asset|
      config.assets.precompile << asset
    end

The problem is that in development mode the asset pipeline is turned off, and Rails serves the assets directly.
This means you will not discover the error until deploying to production, where Rails throws a nasty "asset not pre-compiled" exception.

## Images and Sass

Another small problem I faced was that images included from Sass was not showing up.
This was fixed by moving the images to `app/assets/images` and using the `image-url` Sass helper.

    .some-class
      image-url('bord-top.gif')

It will refer to the correct image path for images placed in `app/assets/images`.
