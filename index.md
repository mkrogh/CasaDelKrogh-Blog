---
layout: page
title: CasaDelKrogh
tagline: Home of Markus Krogh
---
{% include JB/setup %}

<dl class="posts">
  {% for post in site.posts %}
    <dt><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></dt>
    <dd>{{ post.content | page_fold: post.url }}</dd>
  {% endfor %}
</dl>

