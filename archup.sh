#!/bin/bash
set -e

INSTALL_DIR=/mnt

netup() {
	ip link

	read -r -p "Choose the wireless card you want to use (default: wlan0): " interface

	if [[ -z "$interface" ]]; then
		interface="wlan0"
	fi

	ip link set $interface up

	if [ $? != 0 ]; then
		rfkill unblock wifi
		if [$? != 0 ]; then
			echo "Your wireless card is hard-blocked, use the hardware button to unblock it."
			exit 1
		fi
		ip link set $interface up
	fi

	ip link

	iwctl station $interface scan
	iwctl station $interface get-networks

	read -r -p "Input the name of the wifi network you want to connect: " wifi

	iwctl station $interface connect $wifi

	pacman -Syyy
}

boostrap() {
	pacstrap "$INSTALL_DIR" base base-devel linux linux-firmware vim
	genfstab -U "$INSTALL_DIR" >> "$INSTALL_DIR"/etc/fstab

	echo "boostrap succeeded. Type arch-chroot $INSTALL_DIR to switch to newly-installed system." 
}

makeswap() {
	dd if=/dev/zero of=/swapfile bs=2048 count=1048576 status=progress
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo "/swapfile none swap defaults 0 0" >> /etc/fstab
}

rootinit() {
	read -r -p "Choose the hostname you want to use: " $hostname

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

	read -r -p "wifi ssid: " ssid
	read -r -p "wifi password: " passwd
	
	nmcli device wifi connect $ssid password $passwd
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
		alsa-utils pulseaudio pulseaudio-alsa pavucontrol \
		aspell aspell-en hunspell hunspell-en_US \
		nodejs npm rustup go go-tools \
		iputils inetutils whois bind-tools dhcpcd \
		cups \
		shellcheck \
		pdftk \
		cronie openssh openssl sshfs sshuttle gnupg tmux nfs-utils enscript \
		docker espeak ffmpeg jq ripgrep youtube-dl fzf \
		iotop htop linux-tools pkgfile pwgen pv strace tig time tree valgrind \
		git s3cmd colordiff curl wget ctags darkhttpd pass rsync \
		neovim wireshark-cli wireshark-qt
	sudo pkgfile --update
}

xpkgs() {
	sudo pacman --noconfirm -S \
		xterm \
		alacritty \
		xsane \
		xbindkeys \
		libnotify \
		kmix \
		dunst \
		i3lock \
		mpv \
		nitrogen \
		numlockx \
		xclip \
		xdotool \
		trayer \
		freerdp \
		gmrun \
		noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
		firefox
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
		ngrok \
		par \
		vim-plug-git \
		zsh-autosuggestions \
		zsh-completions \
		zsh-syntax-highlighting \
		zsh-fast-syntax-highlighting-git
}

yayxpkgs() {
	yay --noconfirm -S \
		dzen2-xft-xpm-xinerama-git \
		google-chrome \
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
		ttf-ubuntu-font-family
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
    
    yay -Sy rust-analyzer-git
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
echo "13) userconf     14) clashproxy"
echo ""
read -r -p "command to run: " cmd

case $cmd in
  1) netup ;;
  2) bootstrap ;;
  3) rootinit ;;
  4) wifiinit ;;
  5) xorg ;;
  6) pkgs ;;
  7) xpkgs ;;
  8) userinit ;;
  9) grubinit ;;
  10) yayinit ;;
  11) yaypkgs ;;
  12) yayxpkgs ;;
  13) yayxpkgs ;;
  14) clashproxy ;;
  *)
    echo "unrecognized command" >&2
    exit 1
    ;;
esac
