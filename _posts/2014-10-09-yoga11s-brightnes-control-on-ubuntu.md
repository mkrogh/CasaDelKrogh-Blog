---
layout: post
title: "Yoga11S brightnes control on ubuntu"
category: 
tags: [ubuntu, laptop]
---
{% include JB/setup %}

After reinstalling my Yoga 11S laptop yet again I ran into the lovely problem with the brightness control. (Hint: It does not work out of the box)
Luckily the internet came to the rescue, but not with all the info put together, so here goes.

<!--more-->

It is really just 4 simple steps (that sounds like a clickbait article).

1. Change `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"` to `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi_backlight=vendor"` in `/etc/default/grub`.
2. Run `sudo update-grub`
3. Blacklist the ideapad_laptop in modprobe by adding `blacklist ideapad_laptop` to your `/etc/modprobe.d/blacklist.conf` file.
4. Restart ;)

Thats all there is to it. 
Most of the information is taken from [this Ask Ubuntu answer](http://askubuntu.com/a/304762).
The only information that I needed to dig up was the location of the grub config file, that I found in [another Ask Ubuntu answer](http://askubuntu.com/questions/128463/how-to-control-brightness).

