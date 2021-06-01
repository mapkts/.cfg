exec bspwm 2>~/.bspwm.err

export QT_AUTO_SCREEN_SCALE_FACTOR=1

[[ -f ~/.Xresources ]] && xrdb -merge -I $HOME ~/.Xresources

xset -b
