My interpretation of a virtual machine to run Freetz-NG builds

- only 200 MB in size
  - contains only the things necesarry to run docker
  - Uses https://github.com/pfichtner/pfichtner-freetz for build related things (checkout/clone/configuration/build)
  - If [Freetz-NG's PREREQUISITES](https://github.com/Freetz-NG/freetz-ng/blob/master/docs/PREREQUISITES.md) change the docker image gets updated and can be pulled (the docker image contains everything that is needed to build actual Freetz-NG). 
  - So there's nothing more to do to update the docker image. 
- Comes with a [TUI](https://en.wikipedia.org/wiki/Text-based_user_interface) for doing simple maintenance tasks as well for configuring/building/cleaning FreetNG. 
- Autologins the "builduser" user on tty1
- Does start the TUI on "builduser" logins
- "builduser" comes without a password set

Security remarks
- The box is based on a [(alpine) vagrant box](https://app.vagrantup.com/generic/boxes/alpine312) so there's a default user named vagrant (with password vagrant) as well as the default root passsword vagrant. 

What could be done
- Machine could be based on [barge-os](https://github.com/bargees/barge-os) or even directl on [buildroot](https://buildroot.org/)
