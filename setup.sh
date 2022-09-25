#!/bin/bash

pacman -S  sfdisk
cfdisk /dev/sda
cfdisk /dev/sdb
mkfs.fat -F32 /dev/sda1
mkfs.btrfs /dev/sda2
mkfs.btrfs --force /dev/sdb1
mount /dev/sda2 /mnt
mkdir -p /mnt/boot/EFI
mount /dev/sda1 /mnt/boot/EFI
mount /dev/sdb1 /mnt/home
pacstrap /mnt base linux-zen linux-zen-headers linux-firmware base-devel btrfs-progs
genfstab -U /mnt >> /mnt/etc/fstab

#CHROOT SHIZ
chroot /mnt /bin/bash <<"EOT"
ln -sf /usr/share/zoneinfo/ASIA/KOLKATA /etc/localtime
hwclock --systohc
printf "[multilib]\nInclude = /etc/pacman.d/mirrorlist"
pacman  --noconfirm -Syu 
pacman --noconfirm -S nano qtile git networkmanager xorg polybar lightdm xf86-video-intel grub efibootmgr dosfstools os-prober mtools 
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf
echo "prometheus" >> /etc/hostname
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
cd /tmp/yay
makepkg -si
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=MACHING --recheck
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager lightdm

echo "SET ROOT PASSWD"
passwd
useradd -m sai0-0 -G wheel,audio,video,optical,storage
echo "SET USER PASSWD"
passwd $sai0-0
exit
EOT



