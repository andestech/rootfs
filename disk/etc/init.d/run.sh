#!/bin/sh
export hostname0=
export mnt_path0=
export hostname1=
export mnt_path1=
export auto=
dmesg > dmesg_boot.log
echo $(grep Machine /dmesg_boot.log| sed 's/^.*Andes //g') > platform.log
drvs="FTGPIO010 faraday-rtc FTMAC100 ftsdc010 ADS7846 40x30 ftssp010"
linux_ver=`uname -r`
test -e lib/modules/$linux_ver/kernel/drivers/gpio/gpio-ftgpio010.ko && \
{
	insmod lib/modules/$linux_ver/kernel/drivers/gpio/gpio-ftgpio010.ko
	if [ "$auto" == "1" ]; then
		rmmod gpio-ftgpio010
		insmod lib/modules/$linux_ver/kernel/drivers/gpio/gpio-ftgpio010.ko
	fi
}
test -e lib/modules/$linux_ver/kernel/drivers/net/ethernet/faraday/ftmac100.ko && \
{
	insmod lib/modules/$linux_ver/kernel/drivers/net/ethernet/faraday/ftmac100.ko
	if [ "$auto" == "1" ]; then
		rmmod ftmac100
		insmod lib/modules/$linux_ver/kernel/drivers/net/ethernet/faraday/ftmac100.ko
	fi
}
test -e lib/modules/$linux_ver/kernel/drivers/mmc/host/ftsdc010.ko && \
{
	insmod lib/modules/$linux_ver/kernel/drivers/mmc/core/mmc_core.ko
	insmod lib/modules/$linux_ver/kernel/drivers/mmc/card/mmc_block.ko
	insmod lib/modules/$linux_ver/kernel/drivers/mmc/host/ftsdc010.ko
	if [ "$auto" == "1" ]; then
		rmmod ftsdc010
		rmmod mmc_block
		rmmod mmc_core
		insmod lib/modules/$linux_ver/kernel/drivers/mmc/core/mmc_core.ko
		insmod lib/modules/$linux_ver/kernel/drivers/mmc/card/mmc_block.ko
		insmod lib/modules/$linux_ver/kernel/drivers/mmc/host/ftsdc010.ko
	fi
}
test -e lib/modules/$linux_ver/kernel/drivers/input/touchscreen/cpe_ts/cpe_ts.ko && \
{
	insmod lib/modules/$linux_ver/kernel/drivers/input/touchscreen/cpe_ts/cpe_ts.ko
	if [ "$auto" == "1" ]; then
		rmmod cpe_ts
		insmod lib/modules/$linux_ver/kernel/drivers/input/touchscreen/cpe_ts/cpe_ts.ko
	fi
}
test -e lib/modules/$linux_ver/kernel/drivers/video/FTLCDC100/faradayfb-main.ko && \
{
	insmod lib/modules/$linux_ver/kernel/drivers/video/cfbcopyarea.ko
	insmod lib/modules/$linux_ver/kernel/drivers/video/cfbfillrect.ko
	insmod lib/modules/$linux_ver/kernel/drivers/video/cfbimgblt.ko
	insmod lib/modules/$linux_ver/kernel/drivers/video/FTLCDC100/faradayfb-main.ko
}
test -e lib/modules/$linux_ver/kernel/sound/nds32/snd-ftssp010.ko && \
{
	insmod lib/modules/$linux_ver/kernel/sound/nds32/snd-ftssp010.ko
	if [ "$auto" == "1" ]; then
		rmmod snd_ftssp010
		insmod lib/modules/$linux_ver/kernel/sound/nds32/snd-ftssp010.ko
	fi
}
test -e lib/modules/$linux_ver/kernel/drivers/watchdog/ftwdt010_wdt.ko && \
{
	insmod lib/modules/$linux_ver/kernel/drivers/watchdog/ftwdt010_wdt.ko
	if [ "$auto" == "1" ]; then
		rmmod ftwdt010_wdt
		insmod lib/modules/$linux_ver/kernel/drivers/watchdog/ftwdt010_wdt.ko
	fi
}
test -e lib/modules/$linux_ver/kernel/drivers/rtc/rtc-ftrtc010.ko
if [ "$?" == "0" -a "$auto" == "1" ]; then
	insmod lib/modules/$linux_ver/kernel/drivers/rtc/rtc-ftrtc010.ko
else
	exit 1
fi

#for i in $drvs
#do
#drv=$(dmesg | grep "$i")
#if [ "$?" == "1" ]; then
#	echo "$i NOT exist"
#	exit
#fi
#done

#exit

test -z $hostname1
if [ "$?" == "1" ]; then
	echo "mount hastname1 = $hostname1"
	mount -t nfs -o nolock,rsize=1024,wsize=1024 $hostname1:$mnt_path1 mnt
else
	echo "mount hastname0 = $hostname0"
	mount -t nfs -o nolock,rsize=1024,wsize=1024 $hostname0:$mnt_path0 mnt
fi

if [ "$?" != "0" ]; then
	echo "mount mnt fail"
	exit 1
fi
lsmod 2>&1 | tee mnt/log/lsmod.log
cp dmesg_boot.log mnt/log/
mount /dev/mmcblk0p1 /tmp
if [ "$?" != "0" ]; then
	echo "mount tmp fail"
	exit 1
fi

cd
cd mnt
dmesg > log/dmesg_run.log
sh test_drivers.sh
