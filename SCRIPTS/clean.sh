#!/bin/bash
cd openwrt/bin/targets/rockchip/armv8
rm -rf `ls | grep -v "squashfs"`
gzip -d *.gz
gzip *.img
exit 0