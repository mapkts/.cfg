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
	swapon /swapfile
	echo "/swapfile none swap defaults 0 0" >> /etc/fstab
}

rootinit() {
	if [ $# != 1 ]; then
		echo "Usage: $(basename "$0") rootinit <hostname>" >&2
		exit 1
	fi
	hostname="$1"

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
	systemctl enable --now NetworkManager

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

	pacman --noconfirm -S xorg xorg-xinit
	case "$driver" in
		intel)
			pacman --noconfirm -S xf86-video-intel
			;;
		amd)
			pacman --noconfirm -S xf86-video-amdgpu
			;;
		*)
			echo "unrecognized graphics driver" >&2
			exit 1
			;;
	esac
}

pkgs() {
	pacman --noconfirm -S \
		zsh \
		sudo \
		alsa-utils \
		aspell aspell-en hunspell hunspell-en_US \
		python python-pip python-setuptools python-virtualenv bpython \
		python2 python2-pip python2-setuptools python2-virtualenv bpython2 \
		flake8 \
		go go-tools \
		rustup \
		grub efibootmgr \
		iputils inetutils whois bind-tools dhcpcd \
		cups \
		shellcheck \
		pdftk \
		cronie openssh openssl sshfs sshuttle gnupg tmux nfs-utils enscript \
		docker espeak ffmpeg jq ripgrep youtube-dl fzf \
		iotop htop linux-tools pkgfile pwgen pv strace tig time tree valgrind \
		git s3cmd colordiff curl wget ctags darkhttpd pass rsync
	pkgfile --update
}

xpkgs() {
	pacman --noconfirm -S \
		xterm \
		alacritty alacritty-terminfo \
		k3b konversation konsole dolphin okular \
		qt5 qt5ct oxygen oxygen-icons \
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
		brother-dcp7065dn \
		brscan4 \
		ngrok \
		par \
		vim-fzf-git vim-go-git vim-ledger-git vim-plug-git \
		vim-renamer-git vim-syntastic-git vim-toml-git \
		zsh-autosuggestions \
		zsh-completions \
		zsh-syntax-highlighting \
		zsh-fast-syntax-highlighting-git \
		dict-wn
}

userinit() {
	useradd -m -G wheel mapkts
	
	echo "set user password"
	passwd mapkts

	echo "make sure '%wheel ALL=(ALL) ALL' is in sudoers"
	sleep 3
	EDITOR=vim visudo
}

grubinit() {
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
	grub-mkconfig -o /boot/grub/grub.cfg
}

case "$1" in
  netup) shift ; netup "$@" ;;
  bootstrap) shift ; bootstrap "$@" ;;
  rootinit) shift ; rootinit "$@" ;;
  wifiinit) shift ; wifiinit "$@" ;;
  xorg) shift ; xorg "$@" ;;
  pkgs) shift ; pkgs "$@" ;;
  xpkgs) shift ; xpkgs "$@" ;;
  userinit) shift ; userinit "$@" ;;
  grubinit) shift ; grubinit "$@" ;;
  yayinit) shift ; yayinit "$@" ;;
  yaypkgs) shift ; yaypkgs "$@" ;;
  yayxpkgs) shift ; yayxpkgs "$@" ;;
  *)
    echo "unrecognized command" >&2
    echo "Usage: ./archup.sh [netup | bootstrap | rootinit arch | wifiinit | xorg | pkgs | xpkgs | userinit | grubinit | yayinit | yaypkgs | yayxpkgs ]"
    exit 1
    ;;
esac
