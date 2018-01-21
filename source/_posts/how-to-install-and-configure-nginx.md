---
title: How to Install Nginx?
tags:
  - nginx
  - web server
  - initial nginx installation
  - nginx configuration
categories:
  - Tutorial
date: 2018-01-21 18:20:47
---

# How to install and configure NGINX

## Introduction
Nginx is one of the most used web servers in the world. Nginx is responsible for hosting some of the largest web sites on the internet. In most case it is more resource friendly than the Apache. It can be used both as web server and reverse proxy.

In this guide, I will show how to install Nginx on Ubuntu 16.04 server.

## Prerequisites
* [Ubuntu 16.04 server setup](https://www.furkankarakoyunlu.com/ubuntu-server-setup/)
* Non-root user with `sudo` privileges

## 1) Install Nginx
Ubuntu default repositories includes nginx, so installation will be pretty straight forward.
```
$ sudo apt-get install nginx
```

## 2) Setting up Firewall
We need to configure our firewall to access the service. While installing nginx, it registers itself as a service to `ufw`.

Lets check `ufw` app list by typing
```
$ sudo ufw app list
```
You should get a return like this:
```
Available applications:
  Nginx Full
  Nginx HTTP
  Nginx HTTPS
  OpenSSH
```
As we can see, there are 3 rule profiles added to `ufw` for nginx.
* The *Nginx Full* is for port 80 (unencrypted traffic) and port 443 (TLS/SSL encrypted traffic).
* The *Nginx HTTP* is for port 80
* The *Nginx HTTPS* is for port 443.

For the security purposes, it's important that you enable the most restrictive profile that you will use.

In this guide I will continue with unencrypted traffic which is port 80.

We can enable it by typing
```
$ sudo ufw allow 'Nginx HTTP'
```
We can check the rule if it's properly added
```
$ sudo ufw status
```
The return will be like this
```
Status: active

To                         Action      From
--                         ------      ----
Nginx HTTP                 ALLOW       Anywhere
Nginx HTTP (v6)            ALLOW       Anywhere (v6)
```

## 3) Checking the WebServer
At the end of the installation process, nginx will be running on our server. We can check it with `systemd` to make sure the nginx service is running.
```
$ systemctl status nginx
```
The output will be like this:
```
● nginx.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2017-07-24 18:30:39 UTC; 30min ago
 Main PID: 2941 (nginx)
   CGroup: /system.slice/nginx.service
           ├─2941 nginx: master process /usr/sbin/nginx -g daemon on; master_process on
           └─2942 nginx: worker process
```

Also you can check nginx from your web browser. Enter your servers IP adress to the address bar:
```
http://your-server-ip-address
```
You should see the nginx welcome page.
![Nginx welcome page image](https://furkankarakoyunlu.com/images/nginx-welcome-msg.png)

## 4) Managing Nginx Process with systemd
There are some basic management commands:

These are pretty straight forward
```
$ sudo systemctl stop nginx

$ sudo systemctl start nginx

$ sudo systemctl restart nginx

$ sudo systemctl reload nginx

$ sudo systemctl disable nginx

$ sudo systemctl enable nginx
```

## 5) Getting Know the Nginx Files and Directories
### Web Server Content
`/var/www/html` The content of the actual web page. This location can be changed with nginx configuration files.

### Server Config Files
* `/etc/nginx/nginx.conf` Main nginx configuration files.
* `/etc/nginx/sites-enabled/` For every site enabled "server blocks" stored here. This files are created by linking configuration files found in `sites-available` directory.
* `/etc/nginx/sites-available/` For every site "server blocks" stored here. Nginx will use these files only if they are linked to the `sites-enabled` directory
* `/etc/nginx/snippets` This directory contains small configuration files.

### Server Log Files
* `/var/log/nginx/access.log` By default every request to the web server is recorded into this log file. You can disable it.
* `/var/log/nginx/error.log` Any kind of error will recorded into this log file.

## Conclusion
Now you have a fully functioning Nginx setup. You can start serving your files with millions of people.

