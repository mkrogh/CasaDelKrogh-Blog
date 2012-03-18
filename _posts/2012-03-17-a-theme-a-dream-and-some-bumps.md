---
layout: post
title: "A theme, a dream and some bumps"
category: tech
tags: [jekyll, design]
---
{% include JB/setup %}

So after a days work or so the theme is coming along, as mentioned before the theme is based on [Twitter Bootstrap](http://twitter.github.com/bootstrap/). The background image still needs some work, but my GIMP skills seems to have rusted a bit.

However I must say the responsive design extension to bootstrap is quite nice. (Why has it not been named *adaptive design* rather than *responsive design*?)

<!--more-->

I have also added some sweet sweet Haml and Sass support. The Sass support was possible to implement via a Jekyll Converter, Haml however ended up as a `rake haml` task. The reason behind the rake task is the way Jekyll handles the `_` folders, it does not process these folders, and it makes most sense to place my haml files in the theme folder.

The Sass converter is mostly based on a gist I found https://gist.github.com/960150. To enable Sass partials I had to specify my full theme path, however I am quite sure it is possible to derive it from the `_config.yml` or the Jekyll configuration. Also the Sass files have to start with a *YAML Front Matter* block in order to be processed automagically.

Other than than I have made a couple of small liquid filters, a read-more filter that triggers on `<!--more-->` and a simple `or` filter, which could be seen as an attempt to make a simple *default to a piece of text* if `nil` or empty.

<p><span class="label label-info">Update</span> Hmm it seems like my nice Sass trick makes Jekyll believe that my css file is a page :(</p> 
