---
layout: post
title: "SimpleSAMLphp and Vanilla jsConnect"
category: code
tags: [php, forum, simpleSAMLphp, integration]
---
{% include JB/setup %}

Recently I have been looking into setting up a forum that uses a federated SAML login for authentication.
When you say forum these days, your choices are kind of limited to a myriad of PHP solutions.
There are a lot of solutions out there, with classics such as phpBB, simple machines 2, and myBB.
Then there are "newcomers" such as vanilla forums, and even discourse.
Granted discourse it is more of a community tool than a forum, and it not written in PHP.

Normally I have had a tendency to roll my own forum software when I need the functionality.
In this case though this would be a bit of an overkill, especially since it doesn’t need to interact with anything.
Except for a SAML based login.

<!--more-->

After looking at some different solutions, I ended up with [vanilla forums](http://www.vanillaforums.org/). 
It seems like a decent forum, and it has some fresh takes on how a forum should work.
The deciding factor however was that it allows 3rd party login integration using something called jsConnect.

[Vanilla jsConnect](http://blog.vanillaforums.com/help/vanilla-jsconnect-single-signon-on/) is a single signon plugin for vanilla forums. 
In short it uses jsonp to achieve single signon by exchanging user information, and signs it with a shared key.

### Integrating SimpleSAMLphp and vanilla forums
The first step is to setup both SimpleSAMLphp and vanilla forums. 
See my previous article on setting up [SimpleSAMLphp on nginx](/code/2014/09/30/embedding-simplesamlphp-using-nginx/).

Next you need to make a jsConnect page, the good folks at vanilla forums has made it easy if you are doing [PHP/Ruby/Java/.NET](http://blog.vanillaforums.com/help/vanilla-jsconnect-single-signon-on/#libraries), so you only need to gather the user data, and focus on integrating with the single signon solution. 

Let us start with the directory layout.

    simpleSAMLphp/www
    |-- jsConnectPHP
    |   |-- functions.jsconnect.php
    |   |-- index.php -not really used
    |   |-- jsconnect.php
    |   |-- login.php
    |   `-- README.md

As you can see I just cloned the jsConnectPHP project into my simpleSAMLphp www folder.

### Exchanging user data

The first file we will work with is `jsconnect.php`. Which is used for exchanging user data.

{% gist https://gist.github.com/mkrogh/58afbaa55056ebe214b7.js?file=jsconnect.php %}

- Start by including simpleSAMLphp as a library, and add the jsConnect php helper.
- Setup clientID and the shared secret (you can either make your own secret, or let the jsConnect plugin in vanilla forums generate it).
- Login with SimpleSAMLphp, using a specific service provider configuration.
- Get the attributes, and map them  to the user object.
- Use the `WriteJsConnect` function to sign and output the object.

And that is actually all it takes for doing the attribute exchange, simple and effective.

### Providing a seamless login experience

Now in order to make it enjoyable to use the forum, we need to provide a login page.
It should do the following: 

- Log the user into the single signon.
- Trigger the attribute exchange via jsConnect.
- Return the user to the page they started out from.

{% gist https://gist.github.com/mkrogh/58afbaa55056ebe214b7.js?file=login.php %}

The only interesting thing here is `redirectURL`, since it looks at the referal and extracts the page page where we came from.
Other than that it just saves the referal url, logs the user in, and redirects the user to the constructed url.

### Configuring jsConnect

Last thing to do is to configure the jsConnect plugin in vanilla forums.
Start by downloading and installing it from [http://vanillaforums.org/addon/jsconnect-plugin](http://vanillaforums.org/addon/jsconnect-plugin).

Then enable it from the dashboard (click the cogs -> Dashboard -> Plugins). 
After enabling it you should have a jsConnect option in the user menu.

![jsConnect configuration](https://www.dropbox.com/s/3klhdcvy9nwr467/Screenshot%202014-10-06%2011.02.26.png?dl=1)

Just add the urls for your `jsconnect.php` and `login.php` pages, either releative or absolute.

You can choose to make the connection default. If you do this and set the the registration method to connect, then you only allow users from the jsConnect sources to be created.

Please note that in this I'm using `sha256` since `sha1` is considered [insecure as of 1st of January 2014](http://csrc.nist.gov/publications/nistpubs/800-131A/sp800-131A.pdf).

### What is next?

This is just about all there is to adding single signon via SAML to vanilla forums.
Right now I do not have any thing that seems to be missing, but perhaps my login page needs some error handling.
