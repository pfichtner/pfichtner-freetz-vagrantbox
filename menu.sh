#!/bin/bash

IMAGE="pfichtner/freetz:22.04"
GH_REPO="https://github.com/Freetz-NG/freetz-ng.git"
LOCAL_REPO=$(basename -s '.git' "$GH_REPO")
USERNAME=builduser
AUTOSTART_FILE="$(getent passwd $USERNAME | cut -f 6 -d':')/.bash_login"
AUTOLOGIN_FILE="/etc/systemd/system/getty@tty1.service.d/override.conf"
THIS_FILE=$(readlink -f "$0")

CLONE_REPO="Clone Freetz-NG repo"
PULL_REPO="Update Freetz-NG repo"
MAKE_CONFIG="Call menuconfig"
MAKE="Call make"

CONFIGURATION="Configuration"
EXIT="Exit"


configSubMenu() {
	DOCKER_PULL="Update internal build system"
	SET_PASSWD="Set password for $USERNAME"
	NO_AUTOSTART="Disable script autostart"
	YES_AUTOSTART="Enable script autostart"
	NO_AUTOLOGIN="Disable autologin"
	YES_AUTOLOGIN="Enable autologin"

hasTextBlock() {
	echo "$1" | patch --dry-run -d'/' -NRE -p0 >/dev/null
}

autoLoginTextBlock() {
LINE=`sed -n 's/^ExecStart=-\\/sbin\\/agetty /&--autologin '$USERNAME' /p' /etc/systemd/system/getty.target.wants/getty@tty1.service`
cat <<EOF
--- /dev/null   1970-01-01 00:00:00.000000000 +0000
+++ /etc/systemd/system/getty@tty1.service.d/override.conf      1970-01-01 00:00:00.000000000 +0000
@@ -0,0 +1,3 @@
+[Service]
+ExecStart=
+$LINE
EOF
}

while :; do
	value=()
	value+=("$DOCKER_PULL" "Checks docker hub for update of the internal docker image.")
	# [ "$(sudo passwd --status $USERNAME | cut -d' ' -f2)" = 'NP' ] && value+=("$SET_PASSWD" "$USERNAME has no password, you can set one.")
	value+=("$SET_PASSWD" "set or update the password for $USERNAME.")
	([ -r "$AUTOSTART_FILE" ] && grep -q "$THIS_FILE" "$AUTOSTART_FILE") && value+=("$NO_AUTOSTART" "Disables this script's autostart on login.") || value+=("$YES_AUTOSTART" "Enables this script's autostart on login.")
	hasTextBlock "$(autoLoginTextBlock)" && value+=("$NO_AUTOLOGIN" "Disables the autologin on virtual console 1.") || value+=("$YES_AUTOLOGIN" "Enables the autologin on virtual console 1.")
	CHOICE=$(whiptail --title "Freetz-NG build config menu" --menu "Choose an option" 15 98 6 "${value[@]}" 3>&1 1>&2 2>&3)
	[ "$?" -eq 0 ] || return

	case $CHOICE in
		"$DOCKER_PULL")
			docker pull "$IMAGE"
		;;
		"$SET_PASSWD")
		PASSWORD1=$(whiptail --passwordbox "please enter your secret password" 8 78 --title "password dialog" 3>&1 1>&2 2>&3)
		[ "$?" == 0 ] && PASSWORD2=$(whiptail --passwordbox "please reenter your secret password" 8 78 --title "password dialog" 3>&1 1>&2 2>&3)
		[ "$?" == 0 ] && passwd << EOD
${PASSWORD1}
${PASSWORD2}
EOD
		;;
		"$YES_AUTOLOGIN")
			sudo mkdir -p $(dirname "$AUTOLOGIN_FILE")
			autoLoginTextBlock | sudo patch -d'/' -N -p0 >/dev/null
		;;
		"$NO_AUTOLOGIN")
			autoLoginTextBlock | sudo patch -d'/' -NRE -p0 >/dev/null
		;;
                "$YES_AUTOSTART")
			echo "[ -x $THIS_FILE ] && $THIS_FILE" | sudo tee -a "$AUTOSTART_FILE"
                ;;
                "$NO_AUTOSTART")
                       sudo sed -i "\|^\[ -x $THIS_FILE \] && $THIS_FILE$|d" "$AUTOSTART_FILE" && [ ! -s "$AUTOSTART_FILE" ]  && sudo rm "$AUTOSTART_FILE"
                ;;

	esac
done
}



while :; do
	value=()
	[ -d "$LOCAL_REPO" ] || value+=("$CLONE_REPO" "Creates a new clone of the Freetz-NG github repository.")
	[ -d "$LOCAL_REPO" ] && value+=("$PULL_REPO" "Updates the local Freetz-NG clone.")
	[ -d "$LOCAL_REPO" ] && value+=("$MAKE_CONFIG" "Configure the firmware (\"make menuconfig\").")
	[ -r "$LOCAL_REPO/.config" ] && value+=("$MAKE" "Build the firmware (\"make\").")
	value+=("$CONFIGURATION" "Config/Tweak this tool.")

	CHOICE=$(whiptail --title "Freetz-NG build menu" --menu "Choose an option" 15 98 6 "${value[@]}" 3>&1 1>&2 2>&3)
	[ "$?" -eq 0 ] || exit

	case $CHOICE in
		"$CLONE_REPO")
			umask 0022 && git clone "$GH_REPO" "$LOCAL_REPO"
		;;
		"$PULL_REPO")
			(cd "$LOCAL_REPO" && git pull)
		;;
		"$MAKE_CONFIG")
			(cd "$LOCAL_REPO" && freetz-make menuconfig)
		;;
		"$MAKE")
			(cd "$LOCAL_REPO" && freetz-make)
		;;
		"$DOCKER_PULL")
			docker pull "$IMAGE"
		;;
		"$CONFIGURATION")
			configSubMenu
		;;
	esac
done

