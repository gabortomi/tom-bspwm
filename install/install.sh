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

Parted() {
    parted --script "$dev" "$1"
}

dd if=/dev/zero of="$dev" bs=512 count=1
Parted "mklabel gpt"
Parted "mkpart primary fat32 1MiB 513MiB"
Parted "mkpart primary ext4 513MiB 100%"
Parted "set 1 boot on"
mkfs.fat -F32 "$gpt_part"
mkfs.ext4 -F "$root_part"
mount "$root_part" /mnt
mkdir -p /mnt/boot/efi
mount "$gpt_part" /mnt/boot/efi
touch /mnt/swapfile
dd if=/dev/zero of=/mnt/swapfile bs=1M count="${swap_space}"
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile
swapfile="yes"

arch_chroot() {
    arch-chroot /mnt /bin/bash -c "${1}"
}



pacman -S --needed --noconfirm reflector

reflector --verbose -l 20 -p https --sort rate --save /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux linux-firmware git

arch_chroot "mkdir -p /mnt/mnt/etc/skel"
arch_chroot "https://github.com/gabortomi/tom-bspwm.git /mnt/mnt/etc/skel/"
arch_chroot "cp -rfT /mnt/mnt/etc/skel/ /etc/skel/"

genfstab -p /mnt >> /mnt/etc/fstab

cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
echo "" >> /mnt/etc/pacman.conf;echo "[multilib]" >> /mnt/etc/pacman.conf;echo "Include = /etc/pacman.d/mirrorlist" >> /mnt/etc/pacman.conf

arch_chroot "pacman -Syy"

touch .passwd
echo -e "$rootpass1\n$rootpass2" > .passwd
arch_chroot "passwd root" < .passwd >/dev/null
rm .passwd
    
arch_chroot "useradd -m -g users -G adm,lp,wheel,power,audio,video -s /bin/bash $user_name"
touch .passwd
echo -e "$userpass1\n$userpass2" > .passwd
arch_chroot "passwd $user_name" < .passwd >/dev/null
rm .passwd

echo "hu_HU.UTF-8 UTF-8" >> /mnt/etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch_chroot "locale-gen"
export LANG=hu_HU.UTF-8

echo "KEYMAP=\"hu""  > /mnt/etc/vconsole.conf

arch_chroot "ln -s /usr/share/zoneinfo/Europe/Budapest /etc/localtime"
arch_chroot "hwclock --systohc --utc"
arch_chroot "echo Archbook > /etc/hostname"
echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers

arch_chroot "pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit xorg-twm alsa-utils pulseaudio pulseaudio-alsa xf86-input-libinput networkmanager xdg-user-dirs xdg-utils gvfs gvfs-mtp man-db neofetch "

arch_chroot "cd /home/${user_name} ; su ${user_name} -c 'git clone https://aur.archlinux.org/yay-bin' ; cd yay-bin ; su ${user_name} -c 'makepkg' ; pacman -U yay-bin*x86_64* --noconfirm ; cd .. ; rm -rf yay-bin"

processor=$(lspci -n | awk -F " " '{print $2 $3}' | grep ^"06" | awk -F ":" '{print $2}' | sed -n  '1p')

if [ "$processor" = "8086" ]
then
    pacstrap /mnt intel-ucode
elif [ "$processor" = "1022" ]
then
    pacstrap /mnt amd-ucode
fi

pacstrap /mnt xf86-video-intel libva-intel-driver lib32-mesa

arch_chroot "systemctl enable NetworkManager"

pacstrap /mnt grub efibootmgr
arch_chroot "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archbook --recheck"
arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"

arch_chroot "mkinitcpio -p linux"

umount -R /mnt

shutdown -r now
