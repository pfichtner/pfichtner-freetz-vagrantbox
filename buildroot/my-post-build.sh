#!/bin/bash

board/pc/post-build.sh
sed -i 's/set timeout.*/set timeout="0"/' "$TARGET_DIR/boot/grub/grub.cfg"
