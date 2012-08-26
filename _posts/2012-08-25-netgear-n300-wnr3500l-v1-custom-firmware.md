---
layout: post
title: "Netgear N300 WNR3500L v1 custom firmware"
category: hardware 
tags: [router, firmware]
---
{% include JB/setup %}

For years I have had a Netgear N300 router which has served me well, but it has been lacking several features, one of which is local DNS entries.

After a recent firmware update it had become somewhat unstable, dropping the internet connection, thus requireing a manual restart at times.

I therefore decided that I wanted to change to a custom firmware, and the choice landed on the tomato firmware. 
This post will try to recount the journey of upgrading my router.

<!--more-->

Another reason for this post is that I could not find any coherent account on how to do firmware upgrades of my "open-source" N300 router.
All the resources were scattered and the one step by step guide I found did not explain everything.

Choosing a firmware
-------------------

There are several router firmwares out there, but not all are prepared to run on the WNR3500l. 
I found a list on myopenrouter that lists the currently "supported" [firmwares](http://www.myopenrouter.com/download/list?sort=date&cat=44).

Given that the only firmwares that seemed to be regualarly update are [DD-WRT](http://www.dd-wrt.com/) and [tomato](http://www.polarcloud.com/tomato). 
Reading a bit about the two I found that people seems to praise how simple, yet powerfull, tomato is, and I found the DD-WRT documentation to be somewhat confusing.


One foot in front of the other
------------------------------

This is the steps I went through to change the firmware of my Netgear N300 WNR3500lv1 router. 

1.  Save your router configuration, and note down any port forwarding you have setup. (The backup file is in a binary format, so you cannot read the values from that.)

2.  Since this is guide starts with a stock router running the original firmware we need to start with the DD-WRT firmware and update from that. Download [Special DD-WRT Firmware for initial flashing](http://www.myopenrouter.com/download/18896/NETGEAR-WNR3500L-DD-WRT-Firmware-Special-File-for-Initial-Flashing/)

3.  Go to Router Upgrade and upgrade to the DD-WRT firmware
    
    * Wait for the upgrade to finish
    * Wait just a bit more make sure the upgrade has finished

4. Power off the router. Then use a pen to push the *restore factory setting* button. While keeping it pressed down, power on the router, and keep pressing the restore button for 30 seconds.

5. This should make your router boot properly and you should now be back on the interwebs.

6. Download the firmware you want to upgrade to, I choose the [tomato firmware](http://www.myopenrouter.com/download/list?cat=50).
    
    * I had to rename the firmware file from `.trx` to `.bin` which is the DD-WRT update extension.

7. Go to [http://192.168.1.1/](http://192.168.1.1/) and find administration -> Firmware upgrade. Upgrade to your desired firmware
    
    * As a quick sidenote, dd-wrt actually looked nice, but I had choosen to give tomato a spin.

8. Wait for the upgrade to funish, it should end up with a continue button. Clicking it will propt you with a password popup for "DD-WRT", ignore this.

9. Power off the router. Then use a pen to push the *restore factory setting* button. While keeping it pressed down, power on the router, and keep pressing the restore button for 30 seconds.

10. Now you should be able to login to your router, except toastman (the guy who packages the tomato firmware) decided that turning off the dhcp server was an awsome idea. So just enable it under basic -> network

11. To ensure everything is dandy please go to [http://192.168.1.1/admin-config.asp](http://192.168.1.1/admin-config.asp) and choose *Erase all data in NVRAM memory (thorough)* under the  *Restore Default Configuration* section.

11. Enjoy your newly flashed router, and happy configuration :D

Troubleshooting:
----------------

How to see the version of my n300 router? Scroll down in the menu to the knowledge base link, this link contains the router version, mine was [http://support.netgear.com/product/WNR3500Lv1](http://support.netgear.com/product/WNR3500Lv), so a version 1 WNR3500l router.

Future improvements..
---------------------

The short ammount of time I spent in dd-wrt was actually not that bad, depending on the stability of the tomato firmware I might jump back to DD-WRT. I found it more visually pleasing than tomato and especially the stock firmware.
