# NanoPi-R2S-OpenWrt
 使用 Github Actions 在线编译 NanoPi-R2S 固件

[![Openwrt From QiuSimons](https://github.com/msylgj/R2S-OpenWrt/workflows/Openwrt%20From%20QiuSimons/badge.svg)](https://github.com/msylgj/R2S-OpenWrt/actions?query=workflow%3A%22Openwrt+From+QiuSimons%22)

## 发布地址
[点我下载](https://github.com/msylgj/R2S-OpenWrt/releases)

## 更新说明
[经常会忘记写的更新说明](https://github.com/msylgj/R2S-OpenWrt/blob/master/CHANGELOG.md)

## 说明
* Fork自QiuSimons大神的纯原生OP版本,个人根据**完全私人**口味进行了一定修改,建议去源库了解更多
    - [QiuSimons/R2S-OpenWrt](https://github.com/project-openwrt/R2S-OpenWrt)
* ipv4: 192.168.2.1
* username: root
* password: password
* 官方源,原汁原味非杂交
* 添加Flow Offload/SFE(只能二选一,默认开启SFE)+Full Cone Nat+BBR
* **1.608Ghz超频** 感谢QiuSimons大佬的辛苦付出和测试
* 没有上传文件的app,没啥用去掉了 scp和sftp都支持
* 无usb-wifi支持
* 原生OP内置升级可用,固件重置可用
* 支持SSD1306驱动的12864(0.96英寸)和12832(0.91英寸)OLED屏幕

## 官方源+1608OC测试版问题汇总
* 网口灯lan口(中间那个)黄色灯不闪
* 前面sys灯固件引导期间闪 启动完成之后不闪了
* oled屏幕不工作
* 首页温度无法显示

## 插件清单
- AdGuardHome
- ChinaDns-ng
- SmartDns
- Transmission
- BearDropper（群里NateLol大佬开发的ssh防护）
- oled-app（还是NateLol开发的oled屏幕支持app）
- ddns
- wol网络唤醒
- samba4
- frps(注意是服务端)
- kms
- **r-Plus
- sqm-qos

## 升级方法
* 原生OP内置升级,可选保留配置
* 刷写或升级后遇到任何问题，可以尝试ssh进路由器，输入fuck，回车后等待重启，或可解决(来自QiuSimons)

## 特别感谢（排名不分先后）
* [QiuSimons/R2S-OpenWrt](https://github.com/project-openwrt/R2S-OpenWrt)
* [fanck0605/nanopi-r2s](https://github.com/fanck0605/nanopi-r2s)
* [klever1988/nanopi-openwrt](https://github.com/klever1988/nanopi-openwrt)
* [lsl330/R2S-SCRIPTS](https://github.com/lsl330/R2S-SCRIPTS)
* [quintuschu/Openwrt-R2S](https://github.com/quintuschu/Openwrt-R2S)
* [songchenwen/nanopi-r2s-opkg-feeds](https://nanopi-r2s-opkg-feeds.songchenwen.com/packages)
* [soffchen/NanoPi-R2S](https://github.com/soffchen/NanoPi-R2S)
* [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
* [friendlyarm/friendlywrt](https://github.com/friendlyarm/friendlywrt)
