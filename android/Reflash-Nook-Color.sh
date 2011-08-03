#!/bin/sh

adb shell "mount -o remount,rw /"
adb shell "mount -o remount,rw /system"

echo Grabbing ramdisk
adb shell "mkdir /boot"
adb shell "mount /dev/block/mmcblk0p1 /boot"
adb pull /boot/uRamdisk work/uRamdisk

echo Unpacking ramdisk
cd work
mkdir disk
dd bs=1 if=uRamdisk of=disk/uRamdisk.gz skip=64
cd disk
gunzip -c uRamdisk.gz | cpio -i
rm uRamdisk.gz

echo Bringing in inferno-enabled init.rc
cp ../../init.rc-c init.rc

echo Repacking ramdisk
find . -regex "./.*"| cpio -ov -H newc | gzip > ../repacked-ramdisk.gz
../../mkimage  -A ARM -T RAMDisk -n Image -d ../repacked-ramdisk.gz ../uRamdisk
cd ..
rm repacked-ramdisk.gz

echo Pushing inferno-c.sh to device
adb push ../inferno-c.sh /system/bin/inferno-c.sh
adb push uRamdisk /boot/uRamdisk
adb shell reboot

