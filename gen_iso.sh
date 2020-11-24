#!/bin/bash

# =============================
# 需要设置变量
# =============================

installed_packages=
iso_path=
iso_label=
iso_name=

# 安装工具
yum install -y createrepo mkisofs isomd5sum

# installed_packages 是安装包时的包保存目录
mkdir -p ${installed_packages}

# 安装包时加参数 --downloaddir=${installed_packages},
# 如 yum install -y vim --downloaddir=${installed_packages}

# /dev/cdrom 是安装盘或ISO文件，可以在虚拟机设置中勾选已连接即可
mount /dev/cdrom /media

# iso_path 是准备做ISO镜像的路径
mkdir -p ${iso_path}

# 复制镜像文件
cp -ar /media/* ${iso_path}
cp -f /media/.discinfo ${iso_path}
cp -f /media/.treeinfo ${iso_path}

# 复制已安装的包
cp -f ${installed_packages}"/*" ${iso_path}"/Packages"

# 重新生成依赖
files=`find /root/wsiso/repodata -name *-comps.xml`
for file in ${files[@]}
do
    createrepo -g ${file} ${iso_path}
done

# 修改 ks.cfg
# 
# - 其中的 package_name 是自定义安装的包的名称
#   可以使用命令 rpm -qai | grep XXX 来查看
# 
cat > ${iso_path}"/isolinux/ks.cfg" <<EOF
#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=ens33 --onboot=off --ipv6=auto --no-activate
network  --hostname=localhost.localdomain

# Root password
rootpw --iscrypted $6$O.sPXTrKF2zziUqv$xKEBI9syjTP2HLAFdoxh0mOyp3ftQx5SOBoeOin6rfcgthNiCuvLL9dKNGYdW0uCGTTPmimF85G8S0in4Tbin.
# System services
services --disabled="chronyd"
# System timezone
timezone Asia/Shanghai --isUtc --nontp
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda
autopart --type=lvm
# Partition clearing information
clearpart --none --initlabel

%packages
@^minimal
@core
kexec-tools

${package_name}

%end

# post script
%post

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
EOF

# 修改启动文件 
# iso_label 为新镜像的标签
sed -i "/menu default/d" ${iso_path}"/isolinux/isolinux.cfg"
sed -i "s/append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\\\x207\\\x20x86_64 quiet/append initrd=initrd.img inst.stage2=hd:LABEL=${iso_label} inst.ks=hd:LABEL=${iso_label}:\/isolinux\/ks.cfg/g" ${iso_path}"/isolinux/isolinux.cfg"
sed -i "s/linuxefi \/images\/pxeboot\/vmlinuz inst.stage2=hd:LABEL=CentOS\\\x207\\\x20x86_64 quiet/linuxefi \/images\/pxeboot\/vmlinuz inst.stage2=hd:LABEL=${iso_label} inst.ks=hd:LABEL=${iso_label}:\/isolinux\/ks.cfg/g" ${iso_path}"/EFI/BOOT/grub.cfg"

# 生成ISO镜像文件
# - iso_name 为镜像文件名称
# - -b 和 -c 的值不能使用绝对路径
cd ${iso_path}
mkisofs -o ${iso_name} -input-charset utf-8 -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -R -J -v -T -joliet-long -V ${iso_label} ${iso_path}
cd -

# 计算md5
mv ${iso_path}"/iso_name" ~
implantisomd5 ~/${iso_name}
