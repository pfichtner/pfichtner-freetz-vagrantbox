#!/bin/bash

IMAGE="pfichtner/freetz:22.04"
GH_REPO="https://github.com/Freetz-NG/freetz-ng.git"
LOCAL_REPO=$(basename -s '.git' "$GH_REPO")
AUTOSTART_FILE="$HOME/.bash_login"
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
	SET_PASSWD="Set password for builduser"
	NO_AUTOSTART="Disable script autostart"
	NO_AUTOLOGIN="Disable autologin"

while :; do
	value=()
	value+=("$DOCKER_PULL" "Checks docker hub for update of the internal docker image.")
	# [ "$(sudo passwd --status builduser | cut -d' ' -f2)" = 'NP' ] && value+=("$SET_PASSWD" "builduser has no password, you can set one.")
	value+=("$SET_PASSWD" "set or update the password for builduser.")
	[ -r "$AUTOSTART_FILE" ] && grep "$THIS_FILE" "$AUTOSTART_FILE" && value+=("$NO_AUTOSTART" "Disables this script's autostart on login.")
	[ -e "$AUTOLOGIN_FILE" ] && value+=("$NO_AUTOLOGIN" "Disables the autologin on virtual console 1.")

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
		"$NO_AUTOSTART")
			sed -i "/^$THIS_FILE\$/d" "$AUTOSTART_FILE" && [ ! -s "$AUTOSTART_FILE" ]  && rm "$AUTOSTART_FILE"
		;;
		"$NO_AUTOLOGIN")
			sudo rm -f "$AUTOLOGIN_FILE"
		;;
	esac
done
}

while :; do
	value=()
	[ -d "$LOCAL_REPO" ] || value+=("$CLONE_REPO" "Creates a new clone of the Freetz-NG github repository.")
	[ -d "$LOCAL_REPO" ] && value+=("$PULL_REPO" "Updates the local Freetz-NG clone.")
	[ -d "$LOCAL_REPO" ] && value+=("$MAKE_CONFIG" "cd into the checkout directory an calls \"make menuconfig\".")
	[ -r "$LOCAL_REPO/.config" ] && value+=("$MAKE" "cd into the checkout directory an calls \"make\".")
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

