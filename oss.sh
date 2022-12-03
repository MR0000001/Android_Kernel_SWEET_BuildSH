#!/bin/bash
#
# Script For Building Android arm64 Kernel
#
# Copyright (C) 2021-2022 RooGhz720 <rooghz720@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Setup colour for the script
yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
green='\e[0;32m'

# Deleting out "kernel complied" and zip "anykernel" from an old compilation
echo -e "$green << cleanup >> \n $white"

rm -rf out
rm -rf zip
rm -rf error.log

echo -e "$green << setup dirs >> \n $white"

# With that setup , the script will set dirs and few important thinks

MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi
 
# MIUI = High Dimens
# OSS = Low Dimens

git config --global user.email "RooGhz720@gmail.com"
git config --global user.name "RooGhz720"

export CHATID API_BOT TYPE_KERNEL tg_sticker

# Configuration

if [ "TYPE_KERNEL" == Ganteng ];
then
git revert 5e35eea50ec8b148a7544a9db0dafabff42132de --no-edit
echo "Switching to OSS Version"
else
git cherry-pick 5e35eea50ec8b148a7544a9db0dafabff42132de
git cherry-pick --skip
fi

# Kernel build release tag
VARIANT="$TYPE"
TYPE="OSS"
DEVICE="Redmi note 10 pro"
KERNEL_NAME="AGHISNA"
DEFCONFIG="sweet_defconfig"
AnyKernel="https://github.com/RooGhz720/Anykernel3"
AnyKernelbranch="master"
HOSST="MyLabs"
USEER="aghisna"

# setup telegram env
export TGL=$(date +"%d-%m-%Y")
export BOT_MSG_URL="https://api.telegram.org/bot$API_BOT/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$API_BOT/sendDocument"


function tg_sticker() {
    curl -s -X POST "https://api.telegram.org/bot$API_BOT/sendSticker" \
        -d sticker="CAACAgUAAxkBAAE9T_9f4UfHZAPwGba5Nyf2Vo1gvcs23wAC6QUAAvjGxQofnl0w8S9XxB4E" \
        -d chat_id=$chat_id
}

tg_post_msg() {
        curl -s -X POST "$BOT_MSG_URL" -d chat_id="$2" \
        -d "parse_mode=html" \
        -d text="$1"
}

tg_post_build() {
        #Post MD5Checksum alongwith for easeness
        MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)

        #Show the Checksum alongwith caption
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="$3 build finished in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds | <b>MD5 Checksum : </b><code>$MD5CHECK</code> | Build Oleh @RooGhz720"
}

tg_error() {
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="$3Failed to build , check <code>error.log</code>"
}

# clang stuff
		echo -e "$green << cloning clang >> \n $white"
		git clone --depth=1 https://gitlab.com/Panchajanya1999/azure-clang.git "$HOME"/clang

	export PATH="$HOME/clang/bin:$PATH"
	export KBUILD_COMPILER_STRING=$("$HOME"/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')

# Setup build process

build_kernel() {
Start=$(date +"%s")

	make -j$(nproc --all) O=out \
                              ARCH=arm64 \
                              LLVM=1 \
                              LLVM_IAS=1 \
                              AR=llvm-ar \
                              NM=llvm-nm \
                              LD=ld.lld \
                              OBJCOPY=llvm-objcopy \
                              OBJDUMP=llvm-objdump \
                              STRIP=llvm-strip \
                              CC=clang \
                              CROSS_COMPILE=aarch64-linux-gnu- \
                              CROSS_COMPILE_ARM32=arm-linux-gnueabi-  2>&1 | tee error.log

End=$(date +"%s")
Diff=$(($End - $Start))
}

# Let's start
echo -e "$green << doing pre-compilation process >> \n $white"
export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64

export KBUILD_BUILD_HOST="$HOSST"
export KBUILD_BUILD_USER="$USEER"

mkdir -p out

make O=out clean && make O=out mrproper
make "$DEFCONFIG" O=out

echo -e "$yellow << compiling the kernel >> \n $white"
tg_post_msg "Compile Kernel sedang berlangsung untuk $DEVICE $VARIANT" "$CHATID"

build_kernel || error=true

DATE=$(date +"%Y%m%d-%H%M%S")
KERVER=$(make kernelversion)

export IMG="$MY_DIR"/out/arch/arm64/boot/Image.gz-dtb
export dtbo="$MY_DIR"/out/arch/arm64/boot/dtbo.img
export dtb="$MY_DIR"/out/arch/arm64/boot/dtb.img

        if [ -f "$IMG" ]; then
                echo -e "$green << selesai dalam $(($Diff / 60)) menit and $(($Diff % 60)) detik >> \n $white"
        else
                echo -e "$red << Gagal dalam membangun kernel!!! , cek kembali kode anda >>$white"
                tg_post_msg "kernel GAGAL di bangun. uploading log"
                tg_error "error.log" "$CHATID"
                tg_post_msg "done" "$CHATID"
                rm -rf out
                rm -rf testing.log
                rm -rf error.log
                exit 1
        fi

        if [ -f "$IMG" ]; then
                echo -e "$green << cloning AnyKernel from your repo >> \n $white"
                git clone --depth=1 "$AnyKernel" --single-branch -b "$AnyKernelbranch" zip
                echo -e "$yellow << making kernel zip >> \n $white"
                cp -r "$IMG" zip/
                cp -r "$dtbo" zip/
                cp -r "$dtb" zip/
                cd zip
                export ZIP="$KERNEL_NAME"-"$TYPE"-"$TGL"
                zip -r9 "$ZIP" * -x .git README.md LICENSE *placeholder
                curl -sLo zipsigner-3.0.jar https://github.com/Magisk-Modules-Repo/zipsigner/raw/master/bin/zipsigner-3.0-dexed.jar
                java -jar zipsigner-3.0.jar "$ZIP".zip "$ZIP"-signed.zip
                tg_post_msg "Kernel berhasil di buat. uploading..." "$CHATID"
                tg_post_build "$ZIP"-signed.zip "$CHATID"
                tg_post_msg "$tg_sticker" "$CHATID"
                cd ..
                rm -rf error.log
                rm -rf out
                rm -rf zip
                rm -rf testing.log
                exit
        fi
