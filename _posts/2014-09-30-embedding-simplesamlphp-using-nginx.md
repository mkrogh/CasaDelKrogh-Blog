---
layout: post
title: "Embedding simpleSAMLphp using nginx"
category: code
tags: [php, simpleSAMLphp, integration, nginx]
---
{% include JB/setup %}

I recently had to embed [simpleSAMLphp](https://simplesamlphp.org/) into another application, in order to provide SAML2 federate login. 
Well embed might be the wrong term, perhaps mount describes it better.

As my web server of choice these days is nginx I wanted to use it rather than apache.
This posed a couple of problems, so I decided to document my endeavour, mostly because I have been through this process once before and it turns out my memory is not really that good.

<!--more-->

The exact premise in this case is an integration of federate login for [vanilla forums](http://vanillaforums.org/), I will try to make a follow up post on how I achieved the integration when I’m done.
My environment in this case is a [vagrant box](https://www.vagrantup.com/) running ubuntu 14.04.

##Installation 

Install nginx and php5.

    sudo apt-get install nginx php5-fpm

Download simpleSAMLphp from https://simplesamlphp.org/download and extract it where you want it.

### Configuration

Start by configuring the simpleSAMLphp by following the [Installation](https://simplesamlphp.org/docs/stable/simplesamlphp-install) and [SP guide](https://simplesamlphp.org/docs/stable/simplesamlphp-sp).

Next up is configuration of the nginx server directive.
To get it out of the way here is a condensed version of the server configuration.

    server {
      listen 8080 default_server;
      listen [::]:8080 default_server ipv6only=on;
      server_name localhost;
    
      root /home/vagrant/vanilla;
      index index.php index.html index.htm;
    
      location / {
        try_files $uri $uri/ =404;
      }

      location  /simplesaml {
        alias /home/vagrant/simplesaml/www/;
        location ~ \.php(/|$) {
          fastcgi_split_path_info ^(.+?\.php)(/.+)$;
          fastcgi_param PATH_INFO $fastcgi_path_info;
          fastcgi_pass unix:/var/run/php5-fpm.sock;
          fastcgi_index index.php;
          include fastcgi_params;
        }
      }
    
      location ~ \.php(/|$) {
        #… same as above
      }
    }

So multiple things are rather important here, lets look at it line by line.

     location /simplesaml {

You can choose any location you want, but if you change it you must tell simplesaml this in `config/config.php`, look for the `baseurlpath` entry.

     alias /home/vagrant/simplesaml/www/;

Alias allows you to change where nginx will serve the requests from, it will handle the "removal" of `/simplesaml` from the request url.

      location ~ \.php(/|$) {

A regex location to handle php request (all urls containing .php/ or .php).
This is needed because alias would otherwise not be carried on into the default php

     fastcgi_split_path_info ^(.+?\.php)(/.+)$;

This one is quite **important** to make simpleSAMLphp work correctly. The default ubuntu/debian nginx php configuration will use a greedy regex that will make for some entertaining bugs that make metadata exchange unusable.

     fastcgi_param PATH_INFO $fastcgi_path_info;

Another addition that is not part of the default nginx configuration example. In short set the server environment variable `PATH_INFO` to the extracted path info.

     fastcgi_pass unix:/var/run/php5-fpm.sock;
     fastcgi_index index.php;
     include fastcgi_params; 

Delegate the request to fpm via fastcgi.

With all this done you should now have a simpleSAMLphp instance running "inside" your site.
For testing I can recommend the default Feide OpenIdP, it will serve you well until you are ready for integration with your desired IdPs.

## The missing bits

I have not yet looked into if this setup is configured correctly in terms of security, and access rights.
So beware of this, after all you are doing authentication :)

If you have any questions hit me up on twitter, I might or might not be abele to help.

