# -*- mode: ruby -*-
# vi: set ft=ruby :

# replace with that (see https://github.com/systemd/systemd/issues/21862)
### echo -e "[Service]\nExecStart=\n$LINE\n" | SYSTEMD_EDITOR=tee systemctl edit getty@tty1.service


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
  config.vm.provision "shell", path: "provisioning.sh"

end
