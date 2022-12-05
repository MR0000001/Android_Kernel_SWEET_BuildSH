#!/usr/bin/env bash

set -e
name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
device=$(grep lunch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
grep _jasmine_sprout $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=jasmine_sprout
grep _laurel_sprout $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=laurel_sprout
grep _GM8_sprout $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=GM8_sprout
grep _maple_dsds $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=maple_dsds
command=$(tail $CIRRUS_WORKING_DIR/build.sh -n +$(expr $(grep '# build rom' $CIRRUS_WORKING_DIR/build.sh -n | cut -f1 -d:) - 1)| head -n -1 | grep -v '# end')
cd $WORKDIR/rom/$name_rom
export ALLOW_MISSING_DEPENDENCIES=true
export PATH="/usr/lib/ccache:$PATH"
export CCACHE_DIR=$WORKDIR/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
export CCACHE_COMPRESS=true
which ccache
ccache -M 20
ccache -z
wget https://raw.githubusercontent.com/RooGhz720/RooGhz720/main/amicia/de/rune/config -O $CIRRUS_WORKING_DIR/config
bash -c "$command" || true
bash -c "$(curl -sL https://raw.githubusercontent.com/RooGhz720/RooGhz720/main/amicia/de/rune/check_build.sh)"

