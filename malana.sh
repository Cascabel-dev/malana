#/bin/bash

#Basic Dependency resolution
sudo zypper in -y dialog curl wget

#Main Menu
MAINMENU=$(dialog --stdout --title "Malana" --menu "Select entries by pressing Enter." 15 50 9  \
"1" "Disable UUID Counting" \
"2" "Zypper Configuration" \
"3" "Flatpak" \
"4" "Software Installation" \
"5" "Multimedia" \
"6" "Fonts" \
"7" "Disable Radios")

case $MAINMENU in 
	1)
		#Disable UUID Counting
		dialog --title "Malana" --yesno "Delete anonymous UUID string for counting?\nNote: This will set up a cronjob to perform this action on each reboot." 10 40
		UUID=$?
		if [ $UUID -eq 0 ]; then
			sudo rm /var/lib/zypp/AnonymousUniqueId
			sudo zypper in -y cron 
			sudo systemctl enable cron.service
			sudo echo "@reboot rm /var/lib/zypp/AnonymousUniqueId" >> /etc/crontab
		else
		    break
		fi
	exec "$0"
	;;
	2)
		# Zypper Configuration
		dialog --title "Malana" --yes-label "Configure" --no-label "Menu" --yesno "Configure Zypper with recommended Settings?\n\nThis enables parallel downloads, GPG signature checking for both packages and repositories, and sets Zypper to install only required packages." 10 50
		ZYPPER=$?
		if [ $ZYPPER -eq 0 ]; then
			sed 's/# download.max_concurrent_connections.*/download.max_concurrent_connections = 20/;s/# repo_gpgcheck.*/repo_gpgcheck = on/;s/# pkg_gpgcheck.*/pkg_gpgcheck =  on/;s/# solver.onlyRequires.*/solver.onlyRequires = true/' /etc/zypp/zypp.conf
		else
		  break
		fi

		# Repo Configuration 
		dialog --title "Malana" --yes-label "Configure" --no-label "Menu" --yesno "Configure Zypper with recommended repositories?\n\nThis will clear currently enabled and/or added repositories and enable the official OSS, Non-OSS, Update, and Fonts repositories." 10 50
		REPOS=$?
		if [ $REPOS -eq 0 ]; then
			sudo zypper rr * && sudo zypper rm /etc/zypp/repos.d/*
			sudo zypper ar -f http://download.opensuse.org/tumbleweed/repo/oss/ oss && sudo zypper ar -f http://download.opensuse.org/tumbleweed/repo/non-oss/ non-oss && sudo zypper ar -f http://download.opensuse.org/update/tumbleweed/ update && sudo zypper ar -f http://download.opensuse.org/repositories/M17N:/fonts/openSUSE_Tumbleweed fonts
		else
		  break
		fi
	exec "$0"
	;;
	3)
		# Flatpak
		dialog --title "Malana" --colors --yes-label "Enable" --no-label "Menu" --yesno "Would you like to enable Flatpak?\n\n\Zb\Z6(This is required to install all packages marked with \"(FP)\" in the package installation step.)" 10 50
		FLATPAK=$?
		if [ $FLATPAK -eq 0 ]; then
			sudo zypper in -y flatpak
			sleep 1
			flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
			sudo flatpak update -y
			flatpak update -y
		else
		  break
		fi
	exec "$0"
	;;
	4)
		# Software Installation
		sudo rm /tmp/packagelist
		touch /tmp/packagelist
		PROGRAMS=$(dialog --stdout --ok-label "Install Selected" --no-label "Menu" --title "Malana" --checklist "Select the software that you would like to install." 15 50 12 \
		"Alacritty" "Terminal" "OFF" \
		"Audacity" "Utilities" "OFF" \
		"Bitwarden" "Password Manager" "OFF" \
		"Bleachbit" "Utilities" "OFF" \
		"Brave" "Internet" "OFF" \
		"Chromium" "Internet" "OFF" \
		"Discord" "Communication" "OFF" \
		"Element" "Communication" "OFF" \
		"Evolution" "Communication" "OFF" \
		"Firefox" "Internet" "OFF" \
		"GIMP" "Utilities" "OFF" \
		"GNOME Boxes" "Virtualization" "OFF" \
		"GParted" "Utilities" "OFF" \
		"Handbrake" "FP Utilities" "OFF" \
		"Heroic" "Gaming" "OFF" \
		"Htop" "Utilities" "OFF" \
		"Kdenlive" "Utilities" "OFF" \
		"KeePass" "Password Manager" "OFF" \
		"KeePassXC" "Password Manager" "OFF" \
		"LibreOffice" "Productivity" "OFF" \
		"Lutris" "Gaming" "OFF" \
		"MPV" "Utilities" "OFF" \
		"Mullvad Browser" "FP Internet" "OFF" \
		"OBS" "FP Utilities" "OFF" \
		"OpenShot" "Utilities" "OFF" \
		"OpenSnitch" "Firewall" "OFF" \
		"Portmaster" "Firewall" "OFF" \
		"Signal" "Communication" "OFF" \
		"Slack" "FP Communication" "OFF" \
		"Spotify" "FP Music" "OFF" \
		"Steam" "Gaming" "OFF" \
		"Sublime Text" "Code" "OFF" \
		"Terminator" "Terminal" "OFF" \
		"Thunderbird" "Communication" "OFF" \
		"Tidal" "Music" "OFF" \
		"Timeshift" "Utilities" "OFF" \
		"VeraCrypt" "Utilities" "OFF" \
		"VirtualBox" "Virtualization" "OFF" \
		"Visual Studio Code" "Code" "OFF" \
		"VLC" "Utilities" "OFF" \
		"VSCodium" "FP Code" "OFF" \
		"WINE" "Gaming" "OFF" \
		"ZSH" "Shell" "OFF")

		case "$PROGRAMS" in
			*"Sublime Text"*)
				sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
				sudo zypper addrepo -g -f https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
				echo "sublime-text" >> /tmp/packagelist
			;;&
			*"Visual Studio Code"*)
				sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
				sudo zypper addrepo https://packages.microsoft.com/yumrepos/vscode vscode
				echo "code" >> /tmp/packagelist
			;;&
			*"VSCodium"*)
				flatpak --user install flathub com.vscodium.codium -y
			;;&
			*"Discord"*) 
				echo "discord" >> /tmp/packagelist 
			;;&
			*"Element"*) 
				echo "element-desktop" >> /tmp/packagelist 
			;;&
			*"Evolution"*) 
				echo "evolution" >> /tmp/packagelist 
			;;&
			*"Signal"*)
				sudo zypper addrepo https://download.opensuse.org/repositories/network:im:signal/openSUSE_Tumbleweed/network:im:signal.repo
				echo "signal-desktop" >> /tmp/packagelist
			;;&
			*"Slack"*)
				flatpak --user install flathub com.slack.Slack -y
			;;&
			*"Thunderbird"*)
				echo "MozillaThunderbird" >> /tmp/packagelist
			;;&
			*"Heroic"*)
				HEROICVER=$(https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/v2.9.1/heroic-2.9.1.x86_64.rpm)
				curl -s -L $HEROICVER -o /tmp/heroic.rpm
				echo "/tmp/heroic.rpm" >> /tmp/packagelist
			;;&
			*"Lutris"*)
				echo "lutris" >> /tmp/packagelist
			;;&
			*"Steam"*)
				echo "steam" >> /tmp/packagelist
			;;&
			*"WINE"*)
				echo "wine wine-gecko wine-mono" >> /tmp/packagelist
			;;&
			*"Brave"*)
				sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
				sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
				echo "brave-browser" >> /tmp/packagelist

			;;&
			*"Chromium"*)
				echo "chromium" >> /tmp/packagelist
			;;&
			*"Firefox"*)
				echo "MozillaFirefox" >> /tmp/packagelist
			;;&
			*"Mullvad Browser"*)
				flatpak --user install flathub net.mullvad.MullvadBrowser -y
			;;&
			*"Spotify"*)
				flatpak --user install flathub com.spotify.Client -y
			;;&
			*"Tidal"*)
				TIDALVER=$(wget -O- -q https://api.github.com/repos/Mastermindzh/tidal-hifi/releases | grep -o "https://.*tidal-hifi-.*.x86_64.rpm" | head -n 1)
				curl -s -L $TIDALVER -o /tmp/tidalhifi.rpm
				echo "/tmp/tidalhifi.rpm" >> /tmp/packagelist
			;;&
			*"KeePass"*)
				echo "keepass" >> /tmp/packagelist
			;;&
			*"KeePassXC"*)
				echo "keepassxc" >> /tmp/packagelist
			;;&
			*"LibreOffice"*)
				echo "libreoffice" >> /tmp/packagelist
			;;&
			*"ZSH"*)
				echo "zsh" >> /tmp/packagelist
			;;&
			*"Alacritty"*)
				echo "alacritty" >> /tmp/packagelist
			;;&
			*"Terminator"*)
				echo "terminator" >> /tmp/packagelist
			;;&
			*"Audacity"*)
				echo "audacity" >> /tmp/packagelist
			;;&
			*"Bleachbit"*)
				echo "bleachbit" >> /tmp/packagelist
			;;&
			*"GIMP"*)
				echo "gimp" >> /tmp/packagelist
			;;&
			*"GParted"*)
				echo "gparted" >> /tmp/packagelist
			;;&
			*"Handbrake"*)
				flatpak --user install flathub fr.handbrake.ghb -y
			;;&
			*"Htop"*)
				echo "htop" >> /tmp/packagelist
			;;&
			*"Kdenlive"*)
				echo "kdenlive" >> /tmp/packagelist
			;;&
			*"MPV"*)
				echo "mpv" >> /tmp/packagelist
			;;&
			*"OBS"*)
				flatpak --user install flathub com.obsproject.Studio -y
			;;&
			*"OpenShot"*)
				echo "openshot-qt" >> /tmp/packagelist
			;;&
			*"Timeshift"*)
				echo "timeshift" >> /tmp/packagelist
			;;&
			*"VeraCrypt"*)
				opi veracrypt -n
			;;&
			*"VLC"*)
				echo "vlc" >> /tmp/packagelist
			;;&
			*"GNOME Boxes"*)
				echo "gnome-boxes" >> /tmp/packagelist
			;;&
			*"VirtualBox"*)
				echo "virtualbox" >> /tmp/packagelist
			;;&
			*"OpenSnitch"*)
				OSB=$(wget -O- -q https://github.com/evilsocket/opensnitch/releases | grep -o "https://.*opensnitch-.*.x86_64.rpm" | head -n 1)
				OSUI=$(wget -O- -q https://github.com/evilsocket/opensnitch/releases | grep -o "https://.*opensnitch-ui.*.noarch.rpm" | head -n 1)
				curl -s -L $OSB -o /tmp/opensnitch.rpm
				curl -s -L $OSUI -o /tmp/opensnitchui.rpm
				echo "/tmp/opensnitch.rpm" >> /tmp/packagelist
				echo "/tmp/opensnitchui.rpm" >> /tmp/packagelist
				pip3 install grpcio-tools
				pip3 install unicode_slugify
			;;&
			*"Portmaster"*)
				curl -L https://updates.safing.io/latest/linux_amd64/packages/portmaster-installer.rpm -o /tmp/portmaster.rpm
				echo "/tmp/portmaster.rpm" >> /tmp/packagelist
			;;&
			*) ;;
		esac
		sleep 1
		sudo zypper refresh
		sudo zypper --no-gpg-checks in -y $(cat /tmp/packagelist)
		sudo rm /tmp/packagelist
		#Nvidia Drivers
		lspci | grep -i nvidia && dialog --title "Malana" --colors --yes-label "Install" --no-label "Menu" --yesno "Install proprietary drivers for NVidia GPUs?" 10 50
		NVIDIA=$?
		if [ $NVIDIA -eq 0 ]; then
			sudo zypper addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed NVIDIA
			sudo zypper in -y nvidia-video-G06 nvidia-gl-G06
		else
		  break
		fi
	exec "$0"
	;;
	5)
		# Multimedia
		dialog --title "Malana" --colors --yes-label "Install" --no-label "Menu" --yesno "Install multimedia codecs?\n\nThis will enable the Packman essential repository and install multimedia packages." 10 50
		MULTIMEDIA=$?
		if [ $MULTIMEDIA -eq 0 ]; then
			sudo zypper ar -cfp 90 https://ftp.fau.de/packman/suse/openSUSE_Tumbleweed/Essentials packman-essentials
			sudo zypper refresh
			sudo zypper dup -y --from packman-essentials --allow-vendor-change
			sudo zypper in -y libdvdcss2 ffmpeg lame gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-good-extra gstreamer-plugins-bad gstreamer-plugins-bad-orig-addon gstreamer-plugins-ugly gstreamer-plugins-ugly-orig-addon gstreamer-plugins-libav dvdauthor07
		else
		  break
		fi
	exec "$0"
	;;
	6)
		# Fonts
		dialog --title "Malana" --colors --yes-label "Install" --no-label "Menu" --yesno "Install fonts?\n\nThis will install Microsoft and TrueType fonts." 10 50
		FONTS=$?
		if [ $FONTS -eq 0 ]; then
			sudo zypper in -y fetchmsttfonts lato-fonts
		else
		  break
		fi
	exec "$0"
	;;
	7)
		# Disable Repos
		dialog --title "Malana" --colors --yes-label "Block" --no-label "Menu" --yesno "Disable wireless radios?\n\nThis will break WiFi/Bluetooth connectivity." 10 50
		RADIOS=$?
		if [ $RADIOS -eq 0 ]; then
			sudo rfkill block all
		else
		  break
		fi
	exec "$0"
	;;
esac
