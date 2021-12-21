#!/bin/bash
# Copyright (C) 2019 The Raphielscape Company LLC.
#
# Licensed under the Raphielscape Public License, Version 1.b (the "License");
# you may not use this file except in compliance with the License.
#
# CI Runner Script for Generation of blobs

# We need this directive
# shellcheck disable=1090

build_env() {
    echo "Build Dependencies Installed....."
    CURR_DIR=$(pwd)
}

rom() {
    echo "Preparing to fetch firmware....."
    python3 get_rom.py
    unzip rom.zip -d miui > /dev/null 2>&1
    cd miui
}

dec_brotli() {
    echo "Decompressing brotli....."
    brotli --decompress system.new.dat.br
    brotli --decompress vendor.new.dat.br
}

sdatimg() {
    echo "Converting to img....."
    curl -sLo sdat2img.py https://raw.githubusercontent.com/xpirt/sdat2img/master/sdat2img.py
    python3 sdat2img.py system.transfer.list system.new.dat > /dev/null 2>&1
    python3 sdat2img.py vendor.transfer.list vendor.new.dat vendor.img > /dev/null 2>&1
}

extract() {
    echo "Extracting the img's....."
    mkdir system
    mkdir vendor
    7z x system.img -y -osystem > /dev/null 2>&1
    7z x vendor.img -y -ovendor > /dev/null 2>&1
    cd $CURR_DIR
}

build_conf() {
    mkdir repo && cd repo
    git config --global user.email "rasuen27@gmail.com"
    git config --global user.name "_.rasend"
}

init_repo() {
    echo "Cloning vendor repo and its deps......."
    git clone https://github.com/PixelExperience/vendor_aosp --depth=1 vendor/aosp > /dev/null 2>&1
    git clone https://github.com/LineageOS/android_prebuilts_tools-lineage --depth=1 prebuilts/tools-custom > /dev/null 2>&1
}

dt() {
    echo "Cloning device tree......."
    git clone https://github.com/rasenss/android_device_xiaomi_ginkgo -b 12 device/xiaomi/ginkgo > /dev/null 2>&1
    git clone https://github.com/rasenss/android_vendor_xiaomi_ginkgo -b arrow-12.0 vendor/xiaomi/ginkgo > /dev/null 2>&1
    cd device/xiaomi/ginkgo
}

gen_blob() {
    bash extract-files.sh $CURR_DIR/miui
    echo "Blobs Generated!"
}

ginkgo_patches() {
    git clone https://rasenss:${API_KEY}@github.com/rasenss/patches.git patches > /dev/null 2>&1
    cp patches/patch.sh $CURR_DIR/repo/vendor/xiaomi/ginkgo/patch.sh
}

push_vendor() {
    cd $CURR_DIR/repo/vendor/xiaomi/ginkgo
    git remote rm origin
    git remote add origin https://rasenss:${API_KEY}@github.com/rasenss/android_vendor_xiaomi_ginkgo.git
    # Patch my stuff
    bash patch.sh && rm patch.sh
    # For Dyneteve only
    git add .
    git commit -m "ginkgo: Re-gen blobs from MIUI $(cat /tmp/version)" --signoff
    git checkout -B arrow-12.0
    git push origin arrow-12.0
    echo "Job Successful!"
}

build_env
rom
dec_brotli
sdatimg
extract
build_conf
init_repo
dt
gen_blob
violet_patches
push_vendor
