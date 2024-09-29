#!/bin/bash

KERNEL_VER=$(make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 kernelrelease)
OUTPUT_DIR="output"
MODULES_DIR="out-modules/lib/modules/${KERNEL_VER}"

# Create output directory
mkdir -p $OUTPUT_DIR

cp kernel.img $OUTPUT_DIR
cp resource.img $OUTPUT_DIR
cp -r $MODULES_DIR $OUTPUT_DIR/modules

tar -czvf nanopi_m6.tar.gz -C $OUTPUT_DIR .

echo "Packageing done: nanopi_m6.tar.gz"