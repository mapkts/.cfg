#!/bin/bash
set -e

INSTALL_DIR=/mnt

netup() {
    ip link

    read -r -p "enter the wireless card you want to use (default: wlan0): " interface

    if [[ -z "$interface" ]]; then
        interface="wlan0"
    fi

    ip link set $interface up

    if [ $? != 0 ]; then
        rfkill unblock wifi
        if [$? != 0 ]; then
            echo "your wireless card is hard-blocked, use the hardware button to unblock it and then retry." >&2
            exit 1
        fi
        ip link set $interface up
    fi

    ip link

    iwctl station $interface scan
    iwctl station $interface get-networks

    read -r -p "enter the name of the wifi network you want to connect: " wifi

    iwctl station $interface connect $wifi

    pacman -Syyy
}

boostrap() {
    pacstrap "$INSTALL_DIR" base base-devel linux linux-firmware vim
    genfstab -U "$INSTALL_DIR" >> "$INSTALL_DIR"/etc/fstab

    echo "Boostrap succeeded, run: arch-chroot $INSTALL_DIR"
}

makeswap() {
    dd if=/dev/zero of=/swapfile bs=2048 count=1048576 status=progress
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap defaults 0 0" >> /etc/fstab
}

rootinit() {
    read -r -p "enter a hostname: " $hostname

    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    hwclock --systohc

    sed -i 's/^#\(en_US\.UTF-8 .*\)$/\1/g' /etc/locale.gen
    sed -i 's/^#\(zh_CN\.UTF-8 .*\)$/\1/g' /etc/locale.gen
    locale-gen
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf

    echo "$hostname" > /etc/hostname

    {
        echo "127.0.0.1  localhost"
        echo "::1  localhost"
        echo "127.0.1.1  $hostname.localdomain $hostname"
    } >> /etc/hosts

    echo 'COMPRESSXZ=(xz -c -z -0 -)' >> /etc/makepkg.conf

    echo "set root password:"
    passwd
}

wifiinit() {
    sudo systemctl enable --now NetworkManager

    nmcli device wifi list

    read -r -p "wifi name/ssid: " ssid
    read -r -p "wifi password: " passwd

    nmcli device wifi connect $ssid password $passwd
}

wifi() {
    echo ""
    echo "#######################################"
    echo "              Wifi Actions             "
    echo "#######################################"
    echo ""
    echo "1) scan"
    echo "2) connect"
    echo "3) add"
    echo "4) add hidden"
    echo "5) show"
    echo "6) off"
    echo ""
    echo "see nmcli --help for more network actions."
    echo ""
    read -r -p "action to run: " action

    case $action in
        1|scan)
            nmcli device wifi list
            ;;
        2|connect)
            read -r -p "connect to network: " ssid
            nmcli connection up $ssid
            ;;
        3|add)
            read -r -p "wifi name/ssid: " ssid
            read -r -p "wifi password: " passwd
            nmcli device wifi connect $ssid password $passwd
            ;;
        4|"add hidden"|"add_hidden")
            read -r -p "wifi name/ssid: " ssid
            read -r -p "wifi password: " passwd
            nmcli device wifi connect $ssid password $passwd hidden yes
            ;;
        5|show)
            nmcli connection show
            ;;
        6|off)
            nmcli radio wifi off
            ;;
    esac
}

xorg() {
    if [ $# != 1 ]; then
        echo "Usage: $(basename "$0") x <intel | amd>" >&2
        exit 1
    fi
    driver="$1"

    sudo pacman --noconfirm -S xorg xorg-xinit
    case "$driver" in
        intel)
            sudo pacman --noconfirm -S xf86-video-intel
            ;;
        amd)
            sudo pacman --noconfirm -S xf86-video-amdgpu
            ;;
        *)
            echo "unrecognized graphics driver" >&2
            exit 1
            ;;
    esac
}

pkgs() {
    sudo pacman --noconfirm -S \
        grub efibootmgr \
        networkmanager network-manager-applet \
        dialog wpa_supplicant \
        os-prober mtools dosfstools \
        zsh sudo \
        alsa-utils pulseaudio pulseaudio-alsa pavucontrol\
        light \
        aspell aspell-en hunspell hunspell-en_US \
        nodejs npm rustup go go-tools \
        python python2 python-pip python2-pip python-gpgme \
        iputils inetutils whois bind-tools dhcpcd \
        xf86-input-libinput \
        cups \
        shellcheck \
        pdftk \
        cronie openssh openssl sshfs sshuttle gnupg tmux nfs-utils enscript \
        docker espeak ffmpeg jq ripgrep youtube-dl fzf \
        iotop htop linux-tools pkgfile pwgen pv strace tig time tree valgrind \
        git vim s3cmd colordiff curl wget ctags darkhttpd pass rsync \
        wireshark-cli wireshark-qt \
        archlinuxcn-keyring \

    sudo pkgfile --update

    # Install pynvim or you will have a hard time with <tab> while using ultisnips with neovim.
    sudo pip install pynvim && sudo pip2 install pynvim
}

xpkgs() {
    sudo pacman --noconfirm -S \
        xterm \
        alacritty \
        bspwm sxhkd \
        xclip \
        ranger \
        sxiv \
        rofi \
        xsane \
        xbindkeys \
        libnotify \
        kmix \
        dunst \
        i3lock \
        mpv \
        nitrogen \
        numlockx \
        xdotool \
        trayer \
        freerdp \
        gmrun \
        firefox \
        wine wine-wechat \
        noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
        wqy-microhei wqy-bitmapfont wqy-microhei-lite \
        adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts
}

yayinit() {
    cd /tmp || exit 1
    if [ ! -d yay ]; then
        git clone https://aur.archlinux.org/yay
    fi
    cd yay || exit 1
    makepkg -fsi --noconfirm
}

yaypkgs() {
    yay --noconfirm -S \
        neovim-nightly-bin vim-plug-git \
        polybar ulauncher nitrogen psensor \
        slock-git scrot\
        ngrok \
        par \
        zsh-autosuggestions \
        zsh-completions \
        zsh-syntax-highlighting \
        zsh-fast-syntax-highlighting-git
}

yayxpkgs() {
    yay --noconfirm -S \
        dzen2-xft-xpm-xinerama-git \
        google-chrome \
        obs-studio \
        dropbox \
        mirage \
        idesk \
        gkrellm \
        gkleds \
        gkrellsun \
        gkrellweather \
        nerd-fonts-hack \
        ttf-oxygen \
        ttf-dejavu \
        ttf-fira-mono \
        ttf-mononoki-git \
        ttf-roboto \
        ttf-ubuntu-font-family \
        faenza-icon-theme
}

userinit() {
    read -r -p "Enter username (default: mapkts): " $uname
    useradd -m -G wheel "$uname"

    echo "set user password"
    passwd "$uname"

    echo "make sure '%wheel ALL=(ALL) ALL' is in sudoers"
    sleep 3
    EDITOR=vim visudo
}

grubinit() {
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
    grub-mkconfig -o /boot/grub/grub.cfg
}

userconf() {
    # adjust system time
    # 
    # https://wiki.archlinux.org/title/System_time
    sudo timedatectl set-timezone "Asia/Shanghai"
    sudo timedatectl set-local-rtc true
    sudo timedatectl set-ntp true

    # diable bell
    # 
    # https://wiki.archlinux.org/title/PC_speaker
    echo "" | sudo tee -a /etc/inputrc 1>/dev/null
    echo "# do not bell on tab-completion" | sudo tee -a /etc/inputrc 1>/dev/null
    echo "set bell-style none" | sudo tee -a /etc/inputrc 1>/dev/null
}

clashproxy() {
    cd "$HOME" || exit 1
    mkdir -p bin/clash && cd bin/clash

    read -r -p "input your username: (default: mapkts)? " $uname

    if [[ -z "$uname" ]]; then
        uname="mapkts"
    fi

    read -r -p "download which version (default: v1.6.0)? " $clashv

    if [[ -z "$clashv" ]]; then
        clashv="v1.6.0"
    fi

    https_proxy="" wget -O clash.gz "https://github.com/Dreamacro/clash/releases/download/$clashv/clash-linux-amd64-$clashv.gz"
    gunzip "clash.gz"
    sudo chmod +x clash
    ./clash -v

    clashservice=/lib/systemd/system/clash@.service

    sudo rm -f $clashservice && sudo touch $clashservice

    read -r -p "url to get config.yml: " clashc

    if [[ -z "$clashc" ]]; then
        echo "url cannot be empty!"
        exit 1
    fi

    http_proxy="" https_proxy="" wget -O config.yml "$clashc"


    {
        echo '[Unit]'
        echo 'Description=A rule based proxy in Go for %i.'
        echo 'After=network.target'
        echo ''
        echo '[Service]'
        echo 'Type=simple'
        echo 'User=%i'
        echo 'Restart=on-abort'
        echo "ExecStart=$HOME/bin/clash/clash -f $HOME/bin/clash/config.yml"
        echo ''
        echo '[Install]'
        echo 'WantedBy=multi-user.target'
    } | sudo tee -a /lib/systemd/system/clash@.service 1>/dev/null

    sudo systemctl daemon-reload
    sudo systemctl enable --now "clash@$uname"
    systemctl status "clash@$uname"
}

rustup() {
    rustup toolchain install nightly
    rustup toolchain install stable

    CARGO_TARGET_DIR="" yay -Sy rust-analyzer-git
    cargo install typos-cli
}

fonts() {
    cd $HOME || exit 1

	echo -e "\n[*] Installing fonts..."
	if [[ -d ".local/share/fonts" ]]; then
		cp -rf .cfg/fonts/* ".local/share/fonts"
	else
		mkdir -p ".local/share/fonts"
		cp -rf .cfg/fonts/* ".local/share/fonts"
	fi
}

mountwinfs() {
    read -r -p "windows partitions is NOT in fstab? [Y/n]: " exists
    case $exists in
        Y)
            echo "" | sudo tee -a /etc/fstab 1>/dev/null
            echo "# /dev/nvme0n1p3 & /dev/nvme0n1p4 (Windows partitions)" | sudo tee -a /etc/fstab 1>/dev/null
            echo "# See https://wiki.archlinux.org/title/NTFS-3G for details." | sudo tee -a /etc/fstab 1>/dev/null
            echo "/dev/nvme0n1p3  /mnt/c  ntfs-3g uid=mapkts,gid=wheel,dmask=022,fmask=133 0 0" | sudo tee -a /etc/fstab 1>/dev/null
            echo "/dev/nvme0n1p4  /mnt/d  ntfs-3g uid=mapkts,gid=wheel,dmask=022,fmask=133 0 0" | sudo tee -a /etc/fstab 1>/dev/null
            echo "windows partitions is successfully mounted."
            ;;
        n)
            echo "windows partition is already mounted, exiting.."
            ;;
        *)
            echo "error: unrecognized option: $exist" 1>&2
            ;;
    esac
}

fcitx() {
    sudo pacman -S --noconfirm fcitx5 fcitx5-chinese-addons fcitx5-qt fcitx5-gtk fcitx5-config-qt
    yay -S --noconfirm fcitx5-pinyin-zhwiki fcitx5-material-color
    
    cd $HOME || exit 1
    if [ ! -f ~/.pam_enviroment ]; then
        touch ~/.pam_enviroment   
    fi
        
    fcitx5 &

    # autostart (use bspwmrc instead)
    # sudo cp -f /usr/share/applications/fcitx5.desktop /etc/xdg/autostart/
}

keycode() {
    xev | grep -A2 --line-buffered '^KeyRelease' | sed -n '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'
}

winfonts() {
    cwd=pwd
    read -r -p "please enter the mount point of windows system (default: /mnt/c): " mountpoint

    if [ -z "$mountpoint" ]; then
        $mountpoint=/mnt/c/
    fi
    
    if [ -d "$mountpoint/Windows/Fonts" ]; then
        sudo mkdir -p /usr/share/fonts/winfonts/
        sudo cp -f $mountpoint/Windows/Fonts/* /usr/share/fonts/winfonts/
        cd /usr/share/fonts/winfonts/
        sudo rm -f *.fon
        sudo mkfontscale
        sudo mkfontdir
        fc-cache -fv
        cd $cwd
    else
        echo "error: directory $mountpoint/Windows/Fonts is not existed" 1>&2
        exit 1
    fi
}

nobeep() {
    sudo rmmod pcspkr 2>/dev/null || true

    # blacklist the `pcspkr` kernel module.
    cmd="blacklist pcspkr"
    file="/etc/modprobe.d/nobeep.conf"

    # if the file doesn't exist or it exists but the cmd string is not in the file, 
    # we echo the cmd # string into it.
    if [ ! -f "$file" ] || [ $(grep -c "$cmd" "$file") -eq 0 ]; then
        echo "$cmd" | sudo tee -a "$file" 1>/dev/null
    fi

    echo "reboot your computer to check if 'pcspkr' module has been disabled."
}

# _lnsf /absolute/path/to/TARGET /absolute/path/to/SOURCE
_lnsf() {
    if [ ! -f "$1" ]; then
        echo "error: $1 is not a file" 1>&2
        exit 1
    fi

    if [ -f "$2" ]; then
        filename=$(basename "$2")
        echo "found local config file ("$2"), backing up..."
        install "$2" ~/.cfg/backups/$filename
        rm "$2"
    fi

    ln -sf "$1" "$2"
}

# _lndf /absolute/path/to/TARGET /absolute/path/to/SOURCE
_lndf() {
    if [ ! -f "$1" ]; then
        echo "error: $1 is not a file" 1>&2
        exit 1
    fi

    if [ -f "$2" ]; then
        filename=$(basename "$2")
        echo "found local config file ("$2"), backing up..."
        install "$2" ~/.cfg/backups/$filename
        rm "$2"
    fi

    ln -f "$1" "$2"
}

# _lnsd /absolute/path/to/TARGET /absolute/path/to/SOURCE
_lnsd() {
    mkdir -p "$2" || exit 1

    if [ ! -d "$1" ]; then
        echo "error: $1 is not a directory" 1>&2
        exit 1
    fi

    isEmpty=0
    ls "$2"/* >/dev/null 2>&1 || isEmpty=1

    if [ $isEmpty -eq 0 ]; then
        basedir=$(basename "$2")
        echo "found local config files at "$2", backing up..."
        if [ ! -d ~/.cfg/backups/"$basedir" ]; then
            mkdir -p ~/.cfg/backups/"$basedir"
        fi
        install "$2"/* ~/.cfg/backups/"$basedir"
    fi
    
    ln -sf "$1"/* "$2"
}

# _lnhd /absolute/path/to/TARGET /absolute/path/to/SOURCE
_lnhd() {
    mkdir -p "$2" || exit 1

    if [ ! -d "$1" ]; then
        echo "error: $1 is not a directory" 1>&2
        exit 1
    fi

    isEmpty=0
    ls "$2"/* >/dev/null 2>&1 || isEmpty=1

    if [ $isEmpty -eq 0 ]; then
        basedir=$(basename "$2")
        echo "found local config files at "$2", backing up..."
        if [ ! -d ~/.cfg/backups/"$basedir" ]; then
            mkdir -p ~/.cfg/backups/"$basedir"
        fi
        install "$2"/* ~/.cfg/backups/"$basedir"
    fi
    
    ln -f "$1"/* "$2"
}

configs() {
    cd $HOME || exit 1

    # Download configs
    if [ -d ".cfg" ]; then
        read -r -p "Found local .cfg directory. Use it? [Y/n] " uselocal

        case $uselocal in 
            Y)
                ;;
            n)
                read -r -p "Remove local .cfg and clone from remote? [Y/n] " $rac
                case $rac in
                    [Y])
                        rm -r .cfg
                        git clone https://github.com/mapkts/.cfg.git
                        ;;
                    [n])
                        ;;
                    [*])
                        echo "error: unrecognized option" >&2
                        exit 1
                        ;;
                esac
                ;;
            *)
                echo "error: unrecognized option" >&2
                exit 1
                ;;
        esac
    else
        git clone https://github.com/mapkts/.cfg.git
    fi

    _lnsf ~/.cfg/archup.sh ~/archup.sh
    _lnsf ~/.cfg/.vimrc ~/.vimrc
    _lnsf ~/.cfg/arch/.pam_environment ~/.pam_environment
    _lnsf ~/.cfg/arch/.xinitrc ~/.xinitrc
    _lnsf ~/.cfg/arch/.xprofile ~/.xprofile
    _lnsf ~/.cfg/arch/.Xmodmap ~/.Xmodmap
    _lnsf ~/.cfg/arch/.Xresources ~/.Xresources
    _lnsf ~/.cfg/arch/.bashrc ~/.bashrc
    _lnsf ~/.cfg/arch/.gitconfig ~/.gitconfig
    _lnsf ~/.cfg/arch/chromium-flags.conf ~/.config/chromium-flags.conf
    _lnsf ~/.cfg/arch/chromium-flags.conf ~/.config/chrome-flags.conf

    _lnsd ~/.cfg/arch/nvim ~/.config/nvim
    _lnsd ~/.cfg/arch/alacritty ~/.config/alacritty
    _lnsd ~/.cfg/arch/bspwm ~/.config/bspwm
    _lnsd ~/.cfg/arch/sxhkd ~/.config/sxhkd
    _lnsd ~/.cfg/arch/polybar ~/.config/polybar
    _lnsd ~/.cfg/arch/dunst ~/.config/dunst

    # ulauncher configs must be linked hard
    _lnhd ~/.cfg/arch/ulauncher ~/.config/ulauncher
}

echo ""
echo "#######################################"
echo "            Archup Commands            "
echo "#######################################"
echo ""
echo "1) netup         2) bootstrap"
echo "3) rootinit      4) wifiinit"
echo "5) xorg          6) pkgs           7) xpkgs"
echo "8) userinit      9) grubinit"
echo "10) yayinit      11) yaypkgs       12) yayxpkgs"
echo "13) userconf     14) clashproxy    15) rustup"
echo "16) configs      17) fonts         18) keycode"
echo "19) wifi         20) mountwinfs    21) fcitx"
echo "22) winfonts     23) nobeep"
read -r -p "command to run: " cmd

case $cmd in
    1  |netup) netup ;;
    2  |boostrap) bootstrap ;;
    3  |rootinit) rootinit ;;
    4  |wifiinit) wifiinit ;;
    5  |xorg) xorg ;;
    6  |pkgs) pkgs ;;
    7  |xpkgs) xpkgs ;;
    8  |userinit) userinit ;;
    9  |grubinit) grubinit ;;
    10 |yayinit) yayinit ;;
    11 |yaypkgs) yaypkgs ;;
    12 |yayxpkgs) yayxpkgs ;;
    13 |userconf) userconf ;;
    14 |clashproxy) clashproxy ;;
    15 |rustup) rustup ;;
    16 |configs) configs ;;
    17 |fonts) fonts ;;
    18 |keycode) keycode ;;
    19 |wifi) wifi ;;
    20 |mountwinfs) mountwinfs ;;
    21 |fcitx) fcitx ;;
    22 |winfonts) winfonts ;;
    23 |nobeep) nobeep ;;
    24 |_lns_ff) _lns_ff "$@" ;;
    *)
        echo "error: unrecognized command" >&2
        exit 1
        ;;
esac
