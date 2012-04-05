---
layout: post
title: "Backup, backup, backup"
category: tech
tags: [bash, SM Framework, backup]
---
{% include JB/setup %}
*[VPS]: Virtual Private Server
Backup is something you always wish you had, when you have had a system failure. Sometimes you have a backup, but no way to restore it quickly. If done right backup can be a godsend, but backups are not just for system failures.

During some spring cleaning when I moved to a new VPS recently I ended up needing my backup as I had not gotten round to move everything. But my backup/archive turned out not to be that recent. This however gave me an excuse to play around with the [SM Framework](https://sm.beginrescueend.com/), a shell scripting abstraction devised by [Wayne E. Seguin](https://twitter.com/#!/wayneeseguin) and [Michal Papis](https://twitter.com/#!/mpapis).

<!--more-->

<aside markdown="1" class="right span2 well">
I have a VPS at [Host Europe](http://www.hosteurope.de/), which btw. is an awesome German based hosting firm. They provide a service where you can upgrade your VPS for free, and when you upgrade from an older series to a newer series you get 7 days as a transfer period. 

During these 7 days you have access to two VPSs, your current and your future VPS. You are in charge of moving everything to the new VPS yourself. This is great if you want to change something in your production setup.
</aside>

But why?
--------

The reason for giving the SM Framework a go was because I personally find sh scripting a pain to read and write. SM provides a tonne of abstractions that make it easier to follow what the script is doing.

Initially I had some problems getting the SM Framework up and running, this was mainly due to the lack of updated documentation, or rather; The framework was undergoing a name change, from bdsm to SM Framework, and the site did not really reflect the changes, and a lot of the pages were missing. Luckily Michal Papis was at hand on the #beginrescueend irc channel on freenode and patiently answered my questions and helped me get SM up and running. 

Michal Papis had actually made a bdsm extension called [sm_backup](https://github.com/mpapis/sm_backup) that covered a lot of standard backup stuff, such as shorthand functions for using mysqldump, rsync data and file rotation. I was however not able to get it to work on the newer version of the SM framework (0.10.2). Papis did offer to look into fixing the extension, but said he did not actively use it. 

Since my needs were quite basic there were no reason to try and rush the extension update, and I therefore went about and dabbled with creating my own set of functions whilst looking closely, and trying to learn from the functions in sm_backup.

Documentation
-------------

As mentioned the documentation at the time of writing is a bit sparse, but one of the things I can recommend is to install the `apidoc` extension. 

    sm ext install apidoc

With the apidoc installed you can now run:

    sm apidoc paths create

Which will output:

    # path(s) module api is loaded with the line 'api/paths' in shell/includes.
    
    # Now we will create a path
    path create /tmp/paths/remove
    
    # Now let's checkout the path and it's contents,
    
    ls -l /tmp/paths/
    total 4
    drwxr-xr-x 2 markus markus 4096 2012-03-24 19:37 remove
    
    # Cleanup after ourselves
    path remove /tmp/paths

The `sm apidoc` is the little [HHGTTG](http://en.wikipedia.org/wiki/The_Hitchhiker's_Guide_to_the_Galaxy) of the SM framework, although it does still contain some _Add an example_ type of entries.

The power of SM
----------------

Using SM to create higher level functions is quite nice. This next example is a function that handles creation and entering a backup directory:

{% highlight ruby %}
# usage:
#   backup_dir directory
# ensures that the given directory exists and sets it as target for backups
function backup_dir(){
  echo "Backup directory $1"
  path exists $1 || path create $1
  path enter $1
}
{% endhighlight %}

Yes the same sh equivalent is not impossible to create, but being able to read the script afterwards is simply fantastic.

### Backing up mysql

The simple answer is just use `mysqldump` and be done with it, but wrapping it up in a function can make it much simpler to work with it.

    # usage:
    #   dump_mysql [db_name] [mysql_opts] [backup_file]
    # db_name defaults to $NAME
    # db_params defaults to '-ubackup'
    # backup_file defaults to '$db_name'_db-
    function dump_mysql() {
      local db_name=${1:-$NAME}
      local mysql_opts=${2:--ubackup}
      local backup_file=${3:-$db_name\_db-}
      local file="$backup_file$(today).sql.gz"
      
      log step "Dumping database to $file"
      mysqldump $mysql_opts $db_name | gzip -c > $file
      if file exists $file
      then
        log step success
      else
        log step fail
      fi
    }

This function adds defaults that I find useful, e.g. figure out the backup file name based on input, but still allow you to define it if necessary.

The log function is fantastic, and combined with log step it makes it easy to generate sane console output that change based on whether or not a function succeeds.

### The rest

Now this post is heading in the direction of being overpopulated with code examples, so to keep it a bit more tidy I will just add my backup.sh file at the [bottom of this post](#files).

Putting it together
-------------------

The final concrete backup script ends up looking like this:

    #!/usr/bin/env sm
    
    includes "api/filesystem"
    includes "api/paths"
    
    . ./functions/backup.sh
    
    backup_dir "db_backup"
    dump_mysql "nice_db"
    rotate "nice_db"

### Just add CRON

All that is left is to add this script to CRON on the server I wish to backup. And of cause add another script that uses rsync to retrieve the backups.

To use the SM framework from CRON you will have to set your CRON path, first find out what your current path contains:

    echo $PATH

Then add this string to your CRON file, `crontab -e` as:

    PATH=THAT_INSANELY_LONG_PATH

Not using bash
--------------

Another challenge I had was that just the day before I decided to use the SM framework I had changed my shell to [zsh](http://www.zsh.org/). The default SM installer sets up a lot of stuff for you, such as adding SM to `/etc/profile.d/` which bash includes in its environment setup. A newly installed zsh however does not, as not to impose any preferences onto you. So after countless questions back and forth with a very patient Michal Papis I got it working.

I ended up just sourcing SM in my `~/.zshrc` file, this is perhaps not the ideal place, but it works for now:

    #load sm
    . /etc/profile.d/sm.sh


Ahh now safe, no longer sorry
-----------------------------

All in all, using the SM framework has probably taken longer than to just crank out a standard shell script, but the framework definitely has some potential. And if you embrace it fully and create your own extension etc. then the re-usability will be awesome.

But now my files are safe again, my database is being backuped and all that remains would be to run a restore firedrill, but given the simplicity of my setup that wont be necessary, I can live with being offline for a day.

Files {#files}
-----

* [backup.sh](/files/backup.sh) - functions to use in a backup script.
