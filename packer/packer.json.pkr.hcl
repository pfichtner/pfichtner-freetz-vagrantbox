# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source

variable "http_proxy" {
  type = string
  default = env("http_proxy")
}
variable "https_proxy" {
  type = string
  default = env("https_proxy")
}

source "virtualbox-iso" "autogenerated_1" {
  boot_command           = ["<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait>", "<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait>", "<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait>", "<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait>", "<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait>", "<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait>", "<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait>", "<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait>", "<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait>", "<tab><tab><tab><tab><tab><tab><tab><tab><tab><tab><wait>", "c<wait2>", "set gfxpayload=keep<enter><wait2>", "linux /casper/vmlinuz <wait2>", "autoinstall quiet fsck.mode=skip <wait2>", "net.ifnames=0 biosdevname=0 systemd.unified_cgroup_hierarchy=0 <wait2>", "ds=\"nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\" <wait2>", "---<enter><wait2>", "initrd /casper/initrd<enter><wait5>", "boot<enter>"]
  boot_wait              = "1s"
  cpus                   = 2
  disk_size              = 131072
  guest_os_type          = "Ubuntu_64"
  headless               = true
  http_content = {
    "/user-data" = templatefile("http/user-data.pkrtpl", { http_proxy = "${var.http_proxy}", https_proxy = "${var.https_proxy}"})
    "/meta-data"  = file("http/meta-data")
  }
  iso_checksum           = "874452797430a94ca240c95d8503035aa145bd03ef7d84f9b23b78f3c5099aed"
  iso_url                = "http://releases.ubuntu.com/22.10/ubuntu-22.10-live-server-amd64.iso"
  memory                 = 1024
  shutdown_command       = "sudo shutdown -h now"
  ssh_password           = "vagrant"
  ssh_port               = 22
  ssh_read_write_timeout = "600s"
  ssh_timeout            = "120m"
  ssh_username           = "vagrant"
  vboxmanage             = [["modifyvm", "{{ .Name }}", "--cpu-profile", "host"]]
  vrdp_bind_address      = "0.0.0.0"
  vrdp_port_min          = 5900
  vrdp_port_max          = 6000
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.virtualbox-iso.autogenerated_1"]

  provisioner "shell" {
    inline = ["sleep 30", "sudo apt-get update", "sudo apt-get -y install docker.io", "sudo usermod -aG docker vagrant"]
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    script          = "../provisioning.sh"
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    compression_level   = 9
    output              = "output-vagrant/package.box"
    provider_override   = "virtualbox"
  }
}
