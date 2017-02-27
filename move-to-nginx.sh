#!/bin/bash
# This script copies hexo public folder
# to /var/www/hexo_blog

cp -r ~/blog/public/* /var/www/hexo_blog/
echo -e "\e[92m--> Files copied to /var/www/hexo_blog/"
