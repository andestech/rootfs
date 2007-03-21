#!/bin/tcsh
tar zxf ramdisk.tgz >& rootfs_build.log
cp ../busybox1/busybox ./disk/bin/ >>& rootfs_build.log
./e2fsimage -v -f ramdisk.img -d disk -s 8192 >>& rootfs_build.log
cp ramdisk.img ../../ >>& rootfs_build.log
