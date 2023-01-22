# My interpretation of a virtual machine to run Freetz-NG builds on

- you don't want to/you can't run docker on your bare metal? Here comes a minimal virtual machine that acts as a wrapper. 
- only ~200 MB in size (download the OVA from the [release page](https://github.com/pfichtner/pfichtner-freetz-vagrantbox/releases))
  - contains only the things necessary to run docker
  - Uses https://github.com/pfichtner/pfichtner-freetz for build related things (checkout/clone/configuration/build)
  - The docker image gets downloaded automatically as soon it's needed which will result in another ~500 MB that gets downloaded (once until it's forced to update) and results in ~1.5 GB disc space in the virtual machine. 
  - If [Freetz-NG's PREREQUISITES](https://github.com/Freetz-NG/freetz-ng/blob/master/docs/PREREQUISITES.md) are updated the docker image gets updated as well and can be pulled (the docker image contains everything that is needed to build the actual Freetz-NG). 
  - So there's (hopefully) nothing more to do to update the docker image. 
- Comes with a [TUI](https://en.wikipedia.org/wiki/Text-based_user_interface) for configuring/building/cleaning Freetz-NG as well for doing simple maintenance tasks. 
- Autologins the "builduser" user on tty1
- Does start the [TUI](https://en.wikipedia.org/wiki/Text-based_user_interface) on "builduser" logins
- "builduser" comes without a password set

# Usage example

## How this virtual machine welcomes you on tty1
<img alt="Virtual machine startup" src="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/pfichtner-freetzg-buildsystem-screen0.gif" width="640" height="480"/>

## Clone the repo, do menuconfig and start make
<a href="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/initial-clone-menuconfig-start-build.html"><img src="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/initial-clone-menuconfig-start-build.png" /></a>

## Tweak the build system
<a href="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/tweak-tool.html/"><img src="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/tweak-tool.png" /></a>

## The initial docker pull that will run the first time automatically
<a href="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/initial-pull.html/"><img src="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/initial-pull.png" /></a>

# Artifacts
What does the OVA contains? 
- Linux base image (currently alpine linux, based on vagrant so it comes with a "vagrant" user)
- `/usr/bin/freetz-menu` a [TUI](https://en.wikipedia.org/wiki/Text-based_user_interface) to easily do the builds and to tweak the virtual machine (see screenshots/screencasts)
- `/usr/bin/run-inside-docker` command to run commands in the docker container, freetz-menu takes use of it for all "make" calls as well for the git clone/pull. 
- `/usr/bin/docker-shell` a login replacement that could be used to directly get caught inside the docker container instead of the virtual machine (currently not used). If you want to take use of it replace a user's login shell by `/usr/bin/docker-shell`
- A "builduser" that get's logged in on machine startup on tty1
- Autostart of freetz-menu on "builduser" login

# Security remarks
- The box is based on a [(alpine) vagrant box](https://app.vagrantup.com/generic/boxes/alpine38) so there's a default user named vagrant (with password vagrant) as well as the default root passsword vagrant. 

# What could be done furthermore
- Possibility to update "freetz-menu" etc. as well
- Tweak entry to set language/locale/keyboard
- Machine could be still more minimalistic e.g. when 
  - based on [barge-os](https://github.com/bargees/barge-os): still not minimalistic, unknown how to extends with additional packages
  - directly based on [buildroot](https://buildroot.org/): long running build process, much low-level-know-how needed
  - build using [linuxkit](https://github.com/linuxkit/linuxkit): hard to extends additional packages like `newt` (would have to build containers for each)
  - build using [tinycorelinux](http://www.tinycorelinux.net/): Based on buildroot/busybox, very small, can be extended by debian packages! Runs InMem only?
