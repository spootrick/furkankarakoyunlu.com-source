#!/bin/bash
# This script generates hexo data and publishes it automatically

/bin/bash /home/spootrick/blog/generate-and-deploy.sh      # generate and deploy 
/bin/bash /home/spootrick/blog/move-to-nginx.sh            # copy to /var/www/hexo_blog 
