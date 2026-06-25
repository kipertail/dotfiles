#!/bin/bash

# Делаем скриншот текущего экрана в файл
grim /tmp/lockscreen.png

# Запускаем hyprlock с передачей нужных переменных
export CUSTOM_DATE="$(date "+%B %A %d")"
hyprlock
