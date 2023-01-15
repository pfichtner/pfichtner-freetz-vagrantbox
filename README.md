# My interpretation of a virtual machine to run Freetz-NG builds

- only 200 MB in size
  - contains only the things necessary to run docker
  - Uses https://github.com/pfichtner/pfichtner-freetz for build related things (checkout/clone/configuration/build)
  - The docker image gets downloaded automatically as soon it's needed which will result in another ~500 MB that gets downloaded (once until it's forced to update) and results in ~1.5 GB disc space in the virtual machine. 
  - If [Freetz-NG's PREREQUISITES](https://github.com/Freetz-NG/freetz-ng/blob/master/docs/PREREQUISITES.md) change the docker image gets updated and can be pulled (the docker image contains everything that is needed to build actual Freetz-NG). 
  - So there's (hopefully) nothing more to do to update the docker image. 
- Comes with a [TUI](https://en.wikipedia.org/wiki/Text-based_user_interface) for doing simple maintenance tasks as well for configuring/building/cleaning FreetNG. 
- Autologins the "builduser" user on tty1
- Does start the TUI on "builduser" logins
- "builduser" comes without a password set

# Usage example
## How this virtual machine welcomes you on tty1
[![tty1]([{image-url}](http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/tty1.png))]([{video-url}](http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/pfichtner-freetzg-buildsystem-screen0.webm) "Virtual machine startup")

## Clone the repo, do menuconfig and start make
<a href="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/initial-clone-menuconfig-start-build.html"><img src="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/initial-clone-menuconfig-start-build.png" /></a>

## Tweak the build system
<a href="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/tweak-tool.html/"><img src="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/tweak-tool.png" /></a>

## The initial docker pull that will run the first time automatically
<a href="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/initial-pull.html/"><img src="http://pfichtner.github.io/pfichtner-freetz-vagrantbox-asciinema/initial-pull.png" /></a>

# Security remarks
- The box is based on a [(alpine) vagrant box](https://app.vagrantup.com/generic/boxes/alpine38) so there's a default user named vagrant (with password vagrant) as well as the default root passsword vagrant. 

# What could be done furthermore
- Possibility to update "freetz-menu" etc. as well
- Machine could be still more minimalistic e.g. when based on [barge-os](https://github.com/bargees/barge-os) or even directl on [buildroot](https://buildroot.org/)
