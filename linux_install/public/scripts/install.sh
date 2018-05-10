#! bin/bash
## Set password for root user
passwd

## Installing basic stuff

# Installing bootloader video drivers, display server
pacman -S mesa xf86-video-intel xorg-server xorg-util-macros xorg-xinit

# Installing essential terminal utilities
pacman -S bash-completion vim git

# Installing bootloader
pacman -S grub os-prober

# Installing bluetool, network managers
pacman -S networkmanager network-manager-applet blueman

# Installing fonts, It does matters a lot
pacman -S ttf-ubuntu-font-family noto-fonts ttf-dejavu ttf-liberation

# Installing theme and icons
pacman -S numix-gtk-theme papirus-icon-theme gtk-engine-murrine

# Installing other utilities
pacman -S shotwell gimp pulseaudio rofi sysstat bc xarchiver xdg-user-dirs gvfs gvfs-mtp gvfs-smb tlp tlp-rdw gnome-disk-utility gnome-system-monitor jdk10-openjdk zip unzip slock gnome-keyring neofetch

# Updating pacman.conf for adding archlinux.fr repo to install yaourt.
cat << EOF >> /etc/pacman.conf

[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/$arch

EOF

# installing yaourt
pacman -Syu yaourt

# System configuration, like hostname, locale, etc
echo ThinkPad > /etc/hostname
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
vim /etc/locale.gen 
locale-gen
cat << EOF >> /etc/locale.conf
LANG=en_US.UTF-8
EOF

# Configuring user nilesh
useradd -m -G wheel nilesh
usermod -c "Nilesh" nilesh
passwd nilesh
cat << EOF >> /etc/sudoer

%wheel ALL=(ALL) ALL 

EOF

# Running some commands as system user.
# ATM, xfwm4-git is much better than stable version.
su nilesh -c "yaourt xfwm4-git google-chrome ttf-ms-fonts; cat << EOF >> /home/nilesh/.xinitrc
startxfce4
EOF
"

# Instaling Desktop environment
pacman -S xfce4 xfce4-goodies

# Enable TLP
systemctl enable tlp.service tlp-sleep.service 

# Enable NetworkManager
systemctl enable lightdm.service NetworkManager.service NetworkManager-wait-online.service

# Create a service for slock to support locking while using suspend
cat << EOF >> /etc/systemd/system/slock@.service
[Unit]
Description=Lock X session using slock for user %i
Before=sleep.target

[Service]
User=%i
Environment=DISPLAY=:0
ExecStartPre=/usr/bin/xset dpms force suspend
ExecStart=/usr/bin/slock

[Install]
WantedBy=sleep.target
EOF

# Enable lock while suspending system using slock.
systemctl enable slock@nilesh.service

# Install grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
