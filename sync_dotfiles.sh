#!/bin/sh

# bspwm
mkdir bspwm &> /dev/null; cp ~/.config/bspwm/bspwmrc ./bspwm/
# sxhkd
mkdir sxhkd &> /dev/null; cp ~/.config/sxhkd/sxhkdrc ./sxhkd/
# kitty
mkdir kitty &> /dev/null; cp ~/.config/kitty/kitty.conf ./kitty/
# dunst
mkdir dunst &> /dev/null; cp ~/.config/dunst/dunstrc ./dunst/
# rofi
mkdir rofi &> /dev/null; cp ~/.config/rofi/config.rasi ./rofi/
# polybar
mkdir polybar &> /dev/null; cp ~/.config/polybar/config ./polybar/
mkdir polybar &> /dev/null; cp ~/.config/polybar/launch.sh ./polybar/
# zsh
cp ~/.zshrc .
# background image
cp ~/.bg.png .
