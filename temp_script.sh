#!/bin/bash
convert -size 1024x1024 xc:#4285F4 -fill white -draw "rectangle 400,400 624,624" -fill #FFFFFF -pointsize 300 -gravity center -annotate 0 "DT" assets/images/app_icon.png
