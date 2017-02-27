---
title: Ubuntu 16.04 Server Setup
tags:
  - Ubuntu
  - Ubuntu 16.04 Server
  - Getting Started
  - Security
  - Swap Space
categories:
  - Tutorial
date: 2017-01-28 00:20:23
---

![Ubuntu 16.04 Server Setup](https://furkankarakoyunlu.com/images/ubuntu_server_setup.jpg)

## Introduction
When you create a new server, there are some configurations you need to make in order to increase security and usability of your server.
In this tutorial I'm going to use Ubuntu 16.04 for my server.

## Login
To log into server, you will need to know the root password and public IP address of your server.
```
$ ssh root@server-IP
```
Accept the warning about host authenticity. Than change the root password for security reasons. After that update the system.
```
$ apt-get update && apt-get -y upgrade
```

## Create a new user
Again for the security reasons you need to create a non-root sudo user. To make this, first create a new user.
```
$ adduser lahmacun
```
This example creates new user called `lahmacun`. Sometimes you need to do administrative tasks. To avoid log in and log out to root account we can setup root privileges to our non-root user. Now you will be able to run commands with administrative privileges by putting the `sudo` in front of each command. In order to do that we need to add our user to sudo group. As root run this command:
```
$ usermod -aG sudo lahmacun
```

## Security
### SSH Modifications
We want our server is to be secure. Now we are going to change default port of ssh, which is `22`, to some suitable port like 1729. And disable root login from ssh.
```
$ sudo vi /etc/ssh/sshd_config
```
You can see the `Port 22` line. Change 22 to 1729. `Port 1729` And in authentication section change `PermitRootLogin yes` to `PermitRootLogin no`.
Now you changed ssh port to 1729 and disabled root login from ssh.
To enable new settings, you need to reload ssh.
```
$ sudo systemctl reload ssh
```
Now you can login your server by typing like this:
```
$ ssh -p1729 lahmacun@server-IP
```

### Firewall
You can use UFW to set up basic firewall very easily. We need to make sure that firewall allows SSH connections from the port we just set up. (Mine is 1729) You can allow this by typing:
```
$ sudo ufw allow 1729
```
Than you can enable the firewall by typing:
```
$ sudo ufw enable
```
Type `y` when it asks a question about current connections.
You can see allowed ports by typing:
```
$ sudo ufw status
```
```
Status: active

To                         Action      From
--                         ------      ----
OpenSSH                    ALLOW       Anywhere
1729                       ALLOW       Anywhere
1729 (v6)                  ALLOW       Anywhere (v6)
```
Some applications can register their profiles to UFW. This allows to manage applications in UFW by name. To see available apps, type:
```
$ sudo ufw app list
```
```
Available applications:
  OpenSSH
```
You can just type `ufw allow OpenSSH` instead `ufw allow 22`

If you install additional services, you will need to adjust firewall settings to accept traffic.

## Usability
### Swap Space
Swap is an area on hard drive which can be used as temporarily data storage. It will be used when there is no longer enough space in RAM. Keep in mind that the information written to disk will be much more slower than RAM. (Nowadays SSD storages can speedup this process but it has negative effect on the hardware lifespan.)

Overall, having swap space is a good safety measurement against `out-of-memory` exceptions.

To check whether if the system already has the swap space.
```
$ sudo swapon --show
```
If you don't get back any output, your system doesn't have swap space. You can verify it by typing:
```
$ free -h
```
```
        total        used        free      shared  buff/cache   available
Mem:     488M         49M        117M        2.7M        321M        403M
Swap:      0B          0B          0B
```
On the swap row it shows `0B`.

In order to decide the volume of swap space, we need to check available space on the hard drive by typing:
```
$ df -h
```
```
Filesystem      Size  Used Avail Use% Mounted on
udev            236M     0  236M   0% /dev
tmpfs            49M  5.6M   44M  12% /run
/dev/vda1        20G  3.6G   16G  19% /
tmpfs           245M     0  245M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           245M     0  245M   0% /sys/fs/cgroup
tmpfs            49M     0   49M   0% /run/user/1000
```
As you can see on `/dev/vda1` I have `16G` free space.
Now we are going to create `1G` swap space in our root directory `/`.
You can adjust the space according to your RAM size. It generally equals with the RAM size or double the RAM size.
```
$ sudo fallocate -l 1G /swapfile
```
Verify the swap space:
```
$ ls -lh /swapfile
```
```
-rw-r--r-- 1 root root 1.0G Jan 28 1:14 /swapfile
```
You can see that the swap space is added.

Now we need to enable this space. First we will make the file only accessible by root:
```
$ sudo chmod 600 /swapfile
```
you can verify it by typing `ls -lh /swapfile` and than mark the file as swap space:
```
$ sudo mkswap /swapfile
```
```
Setting up swapspace version 1, size = 1024 MiB (1073737728 bytes)
no label, UUID=13564270-e4e4-11e6-bf01-fe55135034f3
```
After marked the swap file, you can enable it:
```
$ sudo swapon /swapfile
```
To verify the swap space is available, type
```
$ sudo swapon --show
```
```
NAME      TYPE SIZE USED PRIO
/swapfile file   1G   1M   -1
```
Swap space successfully added.

warning!
If you are using SSD, using swap will be shorten your hardware life.

#### Making Swap Permanent
Above changes have enabled the swap space only for the current session. If you reboot the server swap space will not available.
We can make it permanent by adding it to `/etc/fstab`. First backup the fstab file in case anything goes wrong.
```
$ cp /etc/fstab /etc/fstab.backup
```
Now open `fstab` file
```
$ sudo vi /etc/fstab
```
At the end of the file add this line:
```
/swapfile none swap sw 0 0
```
Than save the file and exit and type this command:
```
$ sudo tee -a /etc/fstab
```

#### Configuring Swap
You can improve system's performance when dealing with swap.

##### Swappiness Property
The `swappiness` parameter configures how often your system swaps data out of RAM to the swap space. This value is between 0 and 100 (represents a percentage)

If the value close to zero, that means the system will not use the swap unless its absolutely necessary. Note that interactions with the swap are take longer time than interactions with RAM. So higher swappiness values can cause significant performance reduction.

If the value close to 100, that means the system try to put more data into swap and keep more RAM space free. Depending your application type, maybe it can be useful.

To check your current swappiness value:
```
$ cat /proc/sys/vm/swappiness
```
```
60
```
For a server the swappiness value needs to closer to 0. (for the performance)

You can set swappiness to 10 by typing:
```
$ sudo sysctl vm.swappiness=10
```
```
vm.swappiness = 10
```
To make this configuration permanent add a line to `/etc/sysctl.conf`
```
$ sudo vi /etc/sysctl.conf
```
at the bottom of the file add this line:
```
vm.swappiness=10
```

##### Cache Pressure Setting
This setting configures how much the system will choose to cache some information. Basically its accessing data from the filesystem and it costs much. So its nice to cache some information.

You can see the current value by typing:
```
$ cat /proc/sys/vm/vfs_cache_pressure
```
```
100
```
At this value, the system will remove information from the cache too quickly. We can set it to more suitable value like 50.
```
$ sudo sysctl vm.vfs_cache_pressure=50
```
```
vm.vfs_cache_pressure = 50
```
Again to make this configuration permanent add a line to `/etc/sysctl.conf`
```
$ sudo vi /etc/sysctl.conf
```
at the bottom of the file add this line:
```
vm.vfs_cache_pressure=50
```
When you are done save and exit the file.

### ZSH
{% blockquote Wikipedia https://en.wikipedia.org/wiki/Z_shell Z shell %}
The Z shell (zsh) is a Unix shell that can be used as an interactive login shell and as a powerful command interpreter for shell scripting. Zsh is an extended Bourne shell with a large number of improvements, including some features of bash, ksh, and tcsh.
{% endblockquote %}

In my personal use I prefer zsh with [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH) framework installed.

To install zsh:
```
$ sudo apt-get install zsh
```

To install oh-my-zsh via curl:
```
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```
or via wget
```
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
```
You can configure its theme and other settings according to your desires. For available themes you can look [here](https://github.com/robbyrussell/oh-my-zsh/tree/master/themes).
Check out [<i class="fa fa-github" aria-hidden="true"></i>](https://github.com/robbyrussell/oh-my-zsh) repo of oh-my-zsh.

## Conclusion
That's it! These are the initial steps when I'm configuring a new server.

