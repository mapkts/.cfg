export QT_AUTO_SCREEN_SCALE_FACTOR=1

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

exec bspwm 2>~/.bspwm.err

[[ -f ~/.Xresources ]] && xrdb -merge -I $HOME ~/.Xresources

[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
