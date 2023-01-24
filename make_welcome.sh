#!/bin/bash

# 1) Install imagemagic pack:
#  apt install imagemagic
# 2) Download free font Corsiva at http://sharefonts.net to ~/.fonts/
# 3) Update database:
#  fc-cache -f -v
# 4) List of the available fonts:
#  identify -list font

convert -fill white -font Corsiva -pointsize 100 -gravity center -annotate 0 'Welcome!\n\nThis is a start picture.\n\nSend command <Refresh>\n(<Ctrl-R> in Firefox)\nor reload the page by another method\nto view next picture...\n\nEnjoj!' welcome.jpg 0welcome.jpg

