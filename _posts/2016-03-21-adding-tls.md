---
layout: post
title: "Adding TLS"
category: 
tags: [https, tls]
---
{% include JB/setup %}

I just added TLS to the blog, since I was renewing another certificate. The last couple of years I have deployed quite a few certificates, and this post is really just a simple link collection.

<!--more-->

CSR all the way
---------------

When getting a certificate please generate a certificate signing request (CSR). This way you keep you private key private, locally on your server or machine.

[DigiCert](https://www.digicert.com/easy-csr/openssl.htm) has a nice tool that helps you generate a CSR.
Although the tool is nice you will probably need to add `-sha256` to the options. Another thing to be aware of is special characters in e.g. an `A/S` you need to escape it as `A\/S`.

Another way is to do it interactively by only supplying openssl with:

    openssl req -new -sha256 -newkey rsa:2048 -nodes -keyout www_casadelkrogh_dk.key -out www_casadelkrogh_dk.csr

[SSL shopper](https://www.sslshopper.com/article-most-common-openssl-commands.html) has a nice overview of useful openssl commands.


Verify your CSR
---------------

Before sending off your CSR you should verify the information in it:

    openssl req -text -noout -verify -in www_casadelkrogh_dk.csr

Checklist:

- The information
- Check the `CN` matches the desired domain
- Check that the Signature Algorithm is sha256

Choosing a CA
-------------

Next you need to choose your certificate authority (CA).
I have used [StartSSL](https://www.startssl.com/Account) for a number of years now, primarily because they are free, and verifying your domain is done via mail (sent to the host/post/webmaster of the domain).

Another solution is using [Let's Encrypt](https://letsencrypt.org), there are plenty of guides out there for that :)


Intermediate certificates
-------------------------

When you get your certifcate from your CA you will probably get an intermediate certificate as well. 

The order to add certificates (and the key if using e.g. HA proxy) is from most private to most public.

    cat www_casadelkrogh_dk.crt intermediate.pem > www_casadelkrogh_dk-bundle.crt

These days StartSSL actually bundles the certificate for you, which is neat.

Configuring ngix
----------------

There have been a suite of bugs and vunerabilities with regards to SSL and cipher suites, such as [Heartbleed](http://heartbleed.com), [Logjam](https://weakdh.org) and BEAST.

A nice resource for configuring your server is [https://cipherli.st/](https://cipherli.st/) by [Remy van Elst](https://raymii.org/) and [Juerd](https://tnx.nl/).
It contains configuration examples and cipher lists that are up to date.

However be aware that turning on `Strict-Transport-Security` means that you will always need to run https, since browsers will refuse to use normal http for your site.

Another resource for ciphers to use is the [Mozilla wiki](https://wiki.mozilla.org/Security/Server_Side_TLSi#Recommended_configurations), which is also nice.

Personally my nginx config consists of a share config:

    #ssl_base.conf
    # Conf from https://cipherli.st
    ssl_prefer_server_ciphers on;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_session_cache shared:SSL:10m;
    ssl_ecdh_curve secp384r1;
    ssl_dhparam /etc/ssl/dhparams.pem;

Then I have the following config: 

    server {
      listen 80;
      server_name www.casadelkrogh.dk casadelkrogh.dk;
      rewrite ^(.*) https://$host$1 permanent;
    }
    
    server {
      listen 443;
      server_name www.casadelkrogh.dk casadelkrogh.dk;

      include ssl_base.conf;
      ssl_certificate /etc/ssl/certs/www.casadelkrogh.dk_bundle.crt;
      ssl_certificate_key /etc/ssl/certs/www_casadelkrogh_dk.key;
    
      # other conf...
    }


Check your setup
----------------

Now you see that it works in your browser and all should be dandy. Even so please check if the rest of the internet agrees with you :)

[SSL labs](https://ssllabs.com/ssltest/) has a nice tool for checking if you have setup https properly, even if it is rather slow.

Another alternative that is oftent faster is [https://ssldecoder.org](https://ssldecoder.org), which is made by the same person as [https://cipherli.st](https://cipherli.st).
