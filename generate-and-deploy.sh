#!/bin/bash
# This script generates hexo static data 
# and deploys it to the github

hexo generate && hexo deploy
echo -e  "\e[92m--> Hexo generate and deploy complete"
