#!/bin/bash
#set -e
###############################################################################
# Author	:	Tamas Gabor
###############################################################################


#touch /mnt/swapfile
#dd if=/dev/zero of=/mnt/swapfile bs=1M count=${swaps}
#chmod 600 /mnt/swapfile
#mkswap /mnt/swapfile
#swapon /mnt/swapfile  

pacman -S --needed --noconfirm reflector

reflector --verbose -l 20 -p https --sort rate --save /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux linux-firmware git



func_install() {
	if pacman -Qi $1 &> /dev/null; then
		tput setaf 2
  		echo "###############################################################################"
  		echo "################## The package "$1" is already installed"
      	echo "###############################################################################"
      	echo
		tput sgr0
	else
    	tput setaf 3
    	echo "###############################################################################"
    	echo "##################  Installing package "  $1
    	echo "###############################################################################"
    	echo
    	tput sgr0
    	sudo pacman -S --noconfirm --needed $1
    fi
}

list=(
xdo
feh
sutils-git
xtitle-git
polybar
pulseaudio
pulseaudio-alsa
)

count=0

for name in "${list[@]}" ; do
	count=$[count+1]
	tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
	func_install $name
done

###############################################################################

tput setaf 6;echo "################################################################"
echo "Copying all files and folders from /etc/skel to ~"
echo "################################################################"
echo;tput sgr0
cp -Rf ~/.config ~/.config-backup-$(date +%Y.%m.%d-%H.%M.%S)
cp -arf /etc/skel/. ~

tput setaf 5;echo "################################################################"
echo "Enabling lightdm as display manager"
echo "################################################################"
echo;tput sgr0
sudo systemctl enable lightdm.service -f

tput setaf 7;echo "################################################################"
echo "You now have a very minimal functional desktop"
echo "################################################################"
echo;tput sgr0

tput setaf 11;
echo "################################################################"
echo "Reboot your system"
echo "################################################################"
echo;tput sgr0
