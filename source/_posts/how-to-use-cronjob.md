---
title: How to Use Cron Job?
tags:
  - Cron
  - Automate tasks
  - Background tasks
  - System tools
categories:
  - Tutorial
date: 2017-03-02 16:56:21
---

![Cron Job Banner](https://furkankarakoyunlu.com/images/cron_job.jpg)
## Introduction
The standard way of automating tasks in background on Unix-like system is to use cron jobs. It's useful for scheduling tasks on your server or local machine. Our little friend, "cron" is a program (daemon) that runs in the background and allows us to schedule and run commands or scripts.

If you are using Unix-like operating system, most likely "cron" is already installed on your system.

## Basic Usage
If you want to run a command or script daily, hourly, monthly or weekly, just put your script on one of these folders: `/etc/cron.daily`, `/etc/cron.hourly`, `/etc/cron.monthly`, `/etc/cron.weekly`.

## Advanced Usage
If the basic usage is not enough for you, you can add more specific tasks by using cron syntax.

You can specify tasks for instance, twice a month, every 10 minutes, every 8th minute on the hour, ...

### Syntax
Here is an explanation:
```
* * * * * command-to-execute
│ │ │ │ │
│ │ │ │ └──── day of week (0 - 6) (SUN - SAT)
│ │ │ └────── month (1 - 12) (JAN - DEC)
│ │ └──────── day of month (1 - 31)
│ └────────── hour (0 - 23)
└──────────── minute (0 - 59)
```

Now lets create a simple cron job. Type this to your terminal:
```
$ crontab -e
```
If this is the first time that you are running this command it will ask you the editor you want:
```                                                               
no crontab for spootrick - using an empty one

Select an editor.  To change later, run 'select-editor'.
  1. /bin/ed
  2. /bin/nano        <---- easiest
  3. /usr/bin/vim.basic
  4. /usr/bin/vim.tiny

Choose 1-4 [2]: 3
```
I'm continuing with vim. This will bring up a vim editor. Now we can type our schedule and command for each one on new line.

When a cron job gets executed, the user's e-mail adress will get an e-mail of the output unless it's directed into a log file or `/dev/null`. If you want to get e-mails you can specify the `MAILTO` section in script. It will look like this:
```
SHELL=/bin/bash
MAILTO=”furkankarakoyunlu@gmail.com”
# This will executed for every 30 minute
30 * * * * echo ‘Hello’
```

If you don't want e-mails, it will look like this:
```
30 * * * * echo ‘Hello‘ >> /var/log/myCronLogFile.log
```
This will log the output to `/var/log/myCronLogFile.log`

If you want to pipe into empty location, it will look like this:
```
30 * * * * echo ‘Hello‘ >> /dev/null 2>&1
```

If I give an example of a real life scenario, I'm using [Let's Encrypt](https://letsencrypt.org/) certificate for my website's SSL. Let's Encrypt certificates are valid for 90 days. I'm using cron job to renew my certificate automatically. Let's Encrypt has a renew command for certificate, so I'm using it like this:
```
30 1 * * 1 /usr/bin/letsencrypt renew >> /var/log/le-renew.log
35 1 * * 1 /bin/systemctl reload nginx
```
This cron job will execute `letsencrypt-auto renew` command on every Monday at 1:30 am and reload Nginx at 1:35 am. (5 min delay for renewed certificate)

### Checking Existing Cron Jobs
To view your cron entries you can type:
```
$ crontab -l
```
For root crontab:
```
$ sudo crontab -l
```
If you are superuser you can look at other users cron entries:
```
root$ crontab -u username -l
```

## Useful Tips
| Schedule        | Command       |
| ----------------|---------------|
|`0 * * * * /path/script.sh`| Run script hourly|
|`0 0 * * * /path/script.sh`| Run script daily|
|`0 0 * * 0 /path/script.sh`| Run script weekly|
|`0 0 1 * * /path/script.sh`| Run script monthly|
|`0 0 1 1 * /path/script.sh`| Run script yearly|
| `* * * * * /path/script.sh`| Run script every minute |
|`*/4 * * * * /path/script.sh`| Run script every 15 minutes|
| `0 1 * * 1-5 /path/script.sh`| Run script on workdays on 1AM|
|`0 0,11 * * * /path/script.sh`| Run script on 0AM and 11AM|
|`*/4 2-6 * * * /path/script.sh`| Run script every 15 minutes between 2AM and 6AM|
|`30 0 * * * /path/script.sh >> /var/log/o.log`| Log output to file|

For more information you can look [CronHowto](https://help.ubuntu.com/community/CronHowto) or `man` pages.
## Conclusion
Cron is a powerful tool when you need to automate processes. Understanding how to use it will save you time for other jobs.

