#!/bin/bash

cat <<'EOF' >/usr/bin/run-in-docker
#!/bin/sh
IMAGE="pfichtner/freetz"
docker run -e TERM -it --rm -w "$PWD" -e BUILD_USER="$USER" -e BUILD_USER_UID=$(id -u) -e BUILD_USER_HOME="$HOME" -v "$HOME":"$HOME" "$IMAGE" "$@"
EOF
chmod +x /usr/bin/run-in-docker

cat <<'EOF' >/usr/bin/freetz-make
#!/bin/sh
run-in-docker make "$@"
EOF
chmod +x /usr/bin/freetz-make

cat <<'EOM' >/usr/bin/freetz-menu
#!/bin/bash

hasCommand() {
	command -v "$1" >/dev/null 2>/dev/null
}

getUserHome() {
	hasCommand getent && getent passwd "$1" | cut -f 6 -d':' || cat /etc/passwd | grep "^$1:" | cut -f 6 -d':'
}

IMAGE="pfichtner/freetz"
GH_REPO="https://github.com/Freetz-NG/freetz-ng.git"
LOCAL_REPO=$(basename "$GH_REPO" '.git')
USERNAME=builduser
AUTOSTART_FILE="$(getUserHome $USERNAME)/.bash_login"
AUTOLOGIN_FILE="/etc/systemd/system/getty@tty1.service.d/override.conf"
THIS_FILE=$(readlink -f "$0")

CLONE_REPO="Clone Freetz-NG repo"
PULL_REPO="Update Freetz-NG repo"
MAKE_CONFIG="Call menuconfig"
MAKE="Call make"
MAKE_CLEAN="Call make clean"
MAKE_DISTCLEAN="Call make distclean"
CONFIGURATION="Configuration"
POWEROFF="Poweroff"

pressAnyKey() {
	echo; read -n 1 -p "Press Enter to continue..." && clear
}

hasTextBlock() {
	[ -r "$1" ] && grep -Fq "$2" "$1"
}

autoLoginTextBlock() {
LINE=`sed -n 's/^ExecStart=-\\/sbin\\/agetty /&--autologin '$USERNAME' /p' /etc/systemd/system/getty.target.wants/getty@tty1.service`
cat <<EOF
[Service]
ExecStart=
$LINE
EOF
}

isAutoLoginEnabled() {
	if [ -r "/etc/inittab" ]; then
		grep -q "agetty --skip-login --nonewline --noissue --autologin $USERNAME --noclear" /etc/inittab
	else
		hasTextBlock "$AUTOLOGIN_FILE" "$(autoLoginTextBlock)"
	fi
}

enableAutoLogin() {
    isAutoLoginEnabled && return
    if [ -r "/etc/inittab" ]; then
	    sudo sed -i '/^tty1::respawn:\/sbin\/getty 38400 tty1$/s/getty/agetty --skip-login --nonewline --noissue --autologin '$USERNAME' --noclear/' /etc/inittab
    else
	    sudo mkdir -p $(dirname "$AUTOLOGIN_FILE")
	    MULTILINE_STRING=$(autoLoginTextBlock)
	    echo "$MULTILINE_STRING" | sudo tee -a "$AUTOLOGIN_FILE" >/dev/null
    fi
}

disableAutoLogin() {
    isAutoLoginEnabled || return
    if [ -r "/etc/inittab" ]; then
	    sudo sed -i '/^tty1::respawn:\/sbin\/agetty --skip-login --nonewline --noissue --autologin '$USERNAME' --noclear 38400 tty1$/s/agetty --skip-login --nonewline --noissue --autologin builduser --noclear/getty/' /etc/inittab
    else
	    REMAINING=$(awk 'FNR==NR{a[$0];next} !($0 in a)' <(autoLoginTextBlock) <(cat "$AUTOLOGIN_FILE"))
	    [ -n "$REMAINING" ] && echo "$REMAINING" | sudo tee "$AUTOLOGIN_FILE" >/dev/null || (sudo rm "$AUTOLOGIN_FILE" && sudo rmdir --ignore-fail-on-non-empty -p $(dirname "$AUTOLOGIN_FILE"))
    fi
}

isAutostartEnabled() {
    ([ -r "$AUTOSTART_FILE" ] && grep -q "^\[ -x $THIS_FILE \] && $THIS_FILE$" "$AUTOSTART_FILE")
}

enableAutostart() {
    isAutostartEnabled || echo "[ -x $THIS_FILE ] && $THIS_FILE" | sudo tee -a "$AUTOSTART_FILE" >/dev/null
    [ -r "$AUTOSTART_FILE" ] && sudo chown builduser "$AUTOSTART_FILE"
}

disableAutostart() {
    isAutostartEnabled && sudo sed -i "\|^\[ -x $THIS_FILE \] && $THIS_FILE$|d" "$AUTOSTART_FILE" && [ ! -s "$AUTOSTART_FILE" ]  && sudo rm "$AUTOSTART_FILE"
}


configSubMenu() {
	UPDATE_SYSTEM="Update linux system"
	DOCKER_PULL="Update internal build system"
	SET_PASSWD="Set password for $USERNAME"
	NO_AUTOSTART="Disable script autostart"
	YES_AUTOSTART="Enable script autostart"
	NO_AUTOLOGIN="Disable autologin"
	YES_AUTOLOGIN="Enable autologin"
	while :; do
	    value=()
	    value+=("$UPDATE_SYSTEM" "Updates the linux distribution.")
	    value+=("$DOCKER_PULL" "Checks docker hub for update of the internal docker image.")
	    # [ "$(sudo passwd --status $USERNAME | cut -d' ' -f2)" = 'NP' ] && value+=("$SET_PASSWD" "$USERNAME has no password, you can set one.")
	    value+=("$SET_PASSWD" "set or update the password for $USERNAME.")
	    isAutostartEnabled && value+=("$NO_AUTOSTART" "Disables this script's autostart on login.") || value+=("$YES_AUTOSTART" "Enables this script's autostart on login.")
	    isAutoLoginEnabled && value+=("$NO_AUTOLOGIN" "Disables the autologin on virtual console 1.") || value+=("$YES_AUTOLOGIN" "Enables the autologin on virtual console 1.")
	    CHOICE=$(whiptail --title "Freetz-NG build config menu" --menu "Build Config Menu" 15 98 6 "${value[@]}" 3>&1 1>&2 2>&3)
	    [ "$?" -eq 0 ] || return

	    case $CHOICE in
		    "$UPDATE_SYSTEM")
			    sudo apk update && sudo apk upgrade
			    pressAnyKey
		    ;;
		    "$DOCKER_PULL")
			    docker pull "$IMAGE"
			    pressAnyKey
		    ;;
		    "$SET_PASSWD")
		    PASSWORD1=$(whiptail --passwordbox "please enter your secret password" 8 78 --title "password dialog" 3>&1 1>&2 2>&3)
		    [ "$?" == 0 ] && PASSWORD2=$(whiptail --passwordbox "please reenter your secret password" 8 78 --title "password dialog" 3>&1 1>&2 2>&3)
		    [ "$?" == 0 ] && sudo passwd "$USERNAME" << EOD
${PASSWORD1}
${PASSWORD2}
EOD
		    ;;
		    "$YES_AUTOLOGIN")
			    enableAutoLogin
		    ;;
		    "$NO_AUTOLOGIN")
			    disableAutoLogin
		    ;;
		    "$YES_AUTOSTART")
			    enableAutostart
		    ;;
		    "$NO_AUTOSTART")
			    disableAutostart
		    ;;

	    esac
    done
}

mainChoice() {
    case "$1" in
	    "$CLONE_REPO")
		    run-in-docker git clone "$GH_REPO" "$LOCAL_REPO"
		    pressAnyKey
	    ;;
	    "$PULL_REPO")
		    run-in-docker bash -c "cd $LOCAL_REPO && git pull"
		    pressAnyKey
	    ;;
	    "$MAKE_CONFIG")
		    (cd "$LOCAL_REPO" && run-in-docker make menuconfig)
	    ;;
	    "$MAKE")
		    (cd "$LOCAL_REPO" && run-in-docker make)
		    pressAnyKey
	    ;;
	    "$MAKE_CLEAN")
		    (cd "$LOCAL_REPO" && run-in-docker make clean)
		    pressAnyKey
	    ;;
	    "$MAKE_DISTCLEAN")
		    (cd "$LOCAL_REPO" && run-in-docker make distclean)
		    pressAnyKey
	    ;;
	    "$DOCKER_PULL")
		    docker pull "$IMAGE"
		    pressAnyKey

	    ;;
	    "$CONFIGURATION")
		    configSubMenu
	    ;;
            "$POWEROFF")
		    sudo poweroff
    esac
}

main() {
    while :; do
	    value=()
	    [ -d "$LOCAL_REPO" ] || value+=("$CLONE_REPO" "Creates a new clone of the Freetz-NG github repository.")
	    [ -d "$LOCAL_REPO" ] && value+=("$PULL_REPO" "Updates the local Freetz-NG clone.")
	    [ -d "$LOCAL_REPO" ] && value+=("$MAKE_CONFIG" "Configure the firmware (\"make menuconfig\").")
	    [ -r "$LOCAL_REPO/.config" ] && value+=("$MAKE" "Build the firmware (\"make\").")
	    [ -d "$LOCAL_REPO" ] && value+=("$MAKE_CLEAN" "Remove unpacked images and some cache files (\"make clean\").")
	    [ -d "$LOCAL_REPO" ] && value+=("$MAKE_DISTCLEAN" "Clean everything except the download directory (\"make distclean\").")
	    value+=("$CONFIGURATION" "Config/Tweak this tool.")
	    value+=("$POWEROFF" "Shutdown this machine.")

	    CHOICE=$(whiptail --title "Freetz-NG build menu" --menu "Main Menu" 15 98 7 "${value[@]}" 3>&1 1>&2 2>&3)
	    [ "$?" -eq 0 ] || exit
	    mainChoice "$CHOICE"
    done
}

[ $# -eq 0 ] && main || "$1"
EOM
chmod +x /usr/bin/freetz-menu

cat <<'EOF' >/usr/bin/docker-shell
#!/bin/sh
run-in-docker /bin/bash -l
EOF
chmod +x /usr/bin/docker-shell

# shell could be also the /bin/docker-shell which gives a login shell directly in the docker container
command -v useradd && useradd -m -G sudo,docker -s /bin/bash builduser || (adduser -D -s /bin/bash builduser && addgroup builduser docker && chmod 755 /home/builduser)

DEFAULT_USER=$(basename /etc/sudoers.d/*)
if [ -r "/etc/sudoers.d/$DEFAULT_USER" ]; then
	cp -a /etc/sudoers.d/$DEFAULT_USER /etc/sudoers.d/builduser && sed -i "s/$DEFAULT_USER/builduser/g" /etc/sudoers.d/builduser
else
	usermod -aG sudo builduser
fi
passwd -d builduser

/usr/bin/freetz-menu enableAutostart
/usr/bin/freetz-menu enableAutoLogin

