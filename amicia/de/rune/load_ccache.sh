#!/usr/bin/env bash

cd $WORKDIR
mkdir -p ~/.config/rclone
echo "$RCLONECONFIG_DRIVE" > ~/.config/rclone/rclone.conf
nano ~/.config/rclone/rclone.conf
name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
device=$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
grep _jasmine_sprout $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=jasmine_sprout
grep _laurel_sprout $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=laurel_sprout
grep _GM8_sprout $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=GM8_sprout
grep _maple_dsds $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=maple_dsds
rclone copy --drive-chunk-size 256M --stats 1s aghisna:ccache/$name_rom/$device/ccache.tar.gz $WORKDIR -P
tar xzf ccache.tar.gz
rm -rf ccache.tar.gz
exit 1

