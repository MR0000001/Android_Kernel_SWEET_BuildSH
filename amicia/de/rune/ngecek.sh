#!/bin/bash

echo "maaf skrip saya bajak salam hangat buat kalian :))"

# green
msg() {
    echo -e "\e[1;32m$*\e[0m"
}
# red
msg1() {
    echo -e "\e[1;31m$*\e[0m"
}
# yellow
msg2() {
    echo -e "\e[1;33m$*\e[0m"
}
# purple
msg3() {
    echo -e "\e[1;35m$*\e[0m"
}

name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
device=$(grep lunch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
branch_name=$(grep init $CIRRUS_WORKING_DIR/build.sh | awk -F "-b " '{print $2}' | awk '{print $1}')
grep _jasmine_sprout $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=jasmine_sprout
grep _laurel_sprout $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=laurel_sprout
grep _GM8_sprout $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=GM8_sprout
grep _maple_dsds $CIRRUS_WORKING_DIR/build.sh > /dev/null && device=maple_dsds

echo ""
msg2 "Cek Keamanan"
AUTHOR=$(cd $CIRRUS_WORKING_DIR && git log --pretty=format:'%an' -1)
msg3 $AUTHOR
if [[ $AUTHOR == NFSDev™ ]]; then
    echo "==============================="
    msg OK
    echo "==============================="
elif [[ $AUTHOR == FinixDev™ ]]; then
    echo "==============================="
    msg OK
    echo "==============================="
elif [[ $AUTHOR == c3eru ]]; then
    echo "==============================="
    msg OK
    echo "==============================="
elif [[ $AUTHOR == zacky ]]; then
    echo "==============================="
    msg OK
    echo "==============================="
elif [[ $AUTHOR == IQ7 ]]; then
    echo "==============================="
    msg OK
    echo "==============================="
elif [[ $AUTHOR == ryanzsz ]]; then
    echo "==============================="
    msg OK
    echo "==============================="
elif [[ $AUTHOR == RooGhz720 ]]; then
    echo "==============================="
    msg OK
    echo "==============================="
else
    echo "==============================="
    msg1 maaf anda tidak di izinkan
    echo "==============================="
    exit 1
fi
echo ""
echo ""
msg2 "Building Rom Information"
echo "==============================="
msg "Rom Name = $name_rom"
msg "Branch = $branch_name"
msg "Devices = $device"
echo "==============================="
echo ""
if [[ "$CIRRUS_USER_PERMISSION" == "admin" ]]; then
    echo "==============================="
    msg Anda adalah admin, Anda bebas melakukan apa saja.
    echo "==============================="
fi
if [[ "$CIRRUS_USER_PERMISSION" == "write" ]]; then
    echo "==============================="
    msg2 Anda adalah user dengan izin menulis saja, Mungkin tindakan anda sedikit di batasi.
    echo "==============================="
fi
if [[ $CIRRUS_COMMIT_MESSAGE == "Update build_rom.sh" ]]; then
   echo "==============================="
   msg2 Tulis lah nama commit nya, Males bener.
   echo "==============================="
   exit 1
fi
if [[ $BRANCH != $device-* ]]; then
   echo "==============================="
   msg2 Tolong gunakan branch codename device-blablabla.
   echo "==============================="
   exit 1
fi
if [ -z "$CIRRUS_PR" ]; then
   echo "==============================="
   msg Builder By Team
   echo "==============================="
else
   echo "==============================="
   msg1 Maaf, Pull Request di tolak.
   echo "==============================="
   exit 1
fi
echo "$credentials" > ~/.git-credentials
git config --global credential.helper store --file=~/.git-credentials
echo ""
msg2 "🔐 Notes"
echo "==============================="
msg3 "Untuk bisa menjadi bagian dari Team kami,
Anda bisa hubungi admin dalam grup telegram kami pada link di bawah ini:"
msg https://t.me/cri_grup
echo ""
msg2 "CR: NFS-Project"
echo "==============================="

