# furkankarakoyunlu.com
This repo contains source files of [furkankarakoyunlu.com](https://furkankarakoyunlu.com)

To create a new post and publish it:
* `$ cd ~/blog`
* `$ hexo new <title>`
* The new post will be in drafts folder. Add content inside.
* After content is added type `hexo publish <title>`
* The post will be moved in posts folder.
* Now you can run `./auto-publish.sh` This script will *generate* the static pages, *deploy* them to github and *moves* public folder contents to `/var/www/hexo_blog`
* Finally, dont forget to add folder contents to github.
