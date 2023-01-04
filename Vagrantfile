# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<-SCRIPT
cat <<'EOF' >/usr/bin/run-in-docker
#!/bin/sh
IMAGE="pfichtner/freetz"
docker run -e TERM -it --rm -e BUILD_USER="$USER" -e BUILD_USER_UID=$(id -u) -e BUILD_USER_HOME="$BUILD_USER_HOME" -v "$HOME":"$BUILD_USER_HOME" "$IMAGE" "$@"
EOF
chmod +x /usr/bin/run-in-docker

cat <<'EOF' >/usr/bin/freetz-make
#!/bin/sh
run-in-docker make "$@"
EOF
chmod +x /usr/bin/freetz-make

cat <<'EOF' >/usr/bin/freetz-menu
# TODO ADD FILE HERE
chmod +x /usr/bin/freetz-menu

cat <<'EOF' >/usr/bin/docker-shell
#!/bin/sh
run-in-docker /bin/bash -l
EOF
chmod +x /usr/bin/docker-shell

#useradd -m -G sudo,docker -s /bin/docker-shell builduser
useradd -m -G sudo,docker -s /bin/bash builduser
passwd -d builduser
AUTOSTART_FILE="$(getent passwd builduser | cut -f 6 -d':')/.bash_login"
echo "freetz-menu" >>"$AUTOSTART_FILE
chown builduser "$AUTOSTART_FILE"

LINE=`sed -n 's/^ExecStart=-\\/sbin\\/agetty /&--autologin builduser /p' /etc/systemd/system/getty.target.wants/getty@tty1.service`
cat <<EOF >/etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
$LINE
EOF

SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  config.vm.provision "docker"
  config.vm.provision "shell", inline: $script

end
