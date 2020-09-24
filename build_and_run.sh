#!/bin/bash
cd build

nasm ../bootloader/bootloader.asm     -f bin -o bootloader.img
nasm ../bootloader/secondloader.asm   -f bin -o secondloader.img

cat bootloader.img    > final.img
cat secondloader.img >> final.img
cat ../res/zz.raw    >> final.img

qemu-system-i386 -drive file=final.img,format=raw,index=0,if=floppy
