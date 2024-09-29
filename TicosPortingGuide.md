# 部署说明

## 编译

1. 编译工具
参考：
`https://wiki.friendlyelec.com/wiki/index.php/NanoPi_M6`
获得 toolchain/11.3-aarch64

`export PATH=/opt/FriendlyARM/toolchain/11.3-aarch64/bin:$PATH`

2. 编译
```
touch .scmversion
make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 nanopi6_linux_defconfig
# 如果需要手动配置
# make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 menuconfig
# Start building kernel
make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 nanopi6-images -j$(nproc)
# Start building kernel modules
mkdir -p out-modules && rm -rf out-modules/*
make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 INSTALL_MOD_PATH="$PWD/out-modules" modules -j$(nproc)
make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 INSTALL_MOD_PATH="$PWD/out-modules" modules_install
KERNEL_VER=$(make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 kernelrelease)
[ ! -f "$PWD/out-modules/lib/modules/${KERNEL_VER}/modules.dep" ] && depmod -b $PWD/out-modules -E Module.symvers -F System.map -w ${KERNEL_VER}
(cd $PWD/out-modules && find . -name \*.ko | xargs aarch64-linux-strip --strip-unneeded)
```

3. 部署
```
将编译生成的 kernel.img 和 resource.img 拷贝至目标设备。
将编译生成的 out-modules/lib/modules/${KERNEL_VER} 拷贝至目标设备 /lib/modules/${KERNEL_VER}。
在设备端执行
sudo dd if=resource.img of=/dev/mmcblk2p4 bs=1M
sudo dd if=kernel.img of=/dev/mmcblk2p5 bs=1M
```

4. 配置
在目标设备执行
echo -e "\ng_ether" | sudo tee -a /etc/modules > /dev/null

sudo nano /etc/rc.local
加入（在 exit 0 之前）：

modprobe g_ether
ip addr add 192.168.7.1/24 dev usb0
ip link set usb0 up

前面两步可以通过调用 `package.sh` 完成打包，然后将 output 下的打包文件和 deploy.sh 文件拷贝至 U 盘，在目标设备执行 `sudo deploy.sh` 即可。

5. 重启
sudo reboot