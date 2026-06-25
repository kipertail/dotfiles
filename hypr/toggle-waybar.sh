#!/bin/bash

# Проверяем, запущен ли waybar
if pgrep -x "waybar" > /dev/null; then
    # Если запущен - убиваем
    pkill waybar
else
    # Если не запущен - запускаем
    waybar &
fi
