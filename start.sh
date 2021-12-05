#!/bin/bash

# 要精简的app列表
del_app=(
	BookmarkProvider # 安卓自带浏览器书签(非MIUI浏览器，卸载无影响)
)
del_privapp=(
	CallLogBackup # 自带通话记录备份(与小米云同步无关，卸载无影响)
)
del_dataapp=(
	MiDrive # 小米云盘
	SmartTravel # 智能出行
	SoundRecorder # 录音机
	ThirdAppAssistant # 三方应用异常分析
)

WORK_DIR="/tmp/miui12.5_diy"

export PATH=$PATH:`pwd`/tools/
# 检查命令是否存在
com_find(){
	type $1 >/dev/null 2>&1 || { 
		echo "命令 $1 不存在" 
		exit 1
	}
}

# 检查目录是否存在
mk_dir(){
	if [ ! -d $1 ];then
		mkdir $1
	fi
}

# 解压镜像并挂载
img_ex(){
	# 解压br
	com_find brotli
	if [ -f $WORK_DIR/$1.new.dat.br ];then
		if [ -f $WORK_DIR/$1.new.dat ];then
			rm -f $WORK_DIR/$1.new.dat
		fi
		echo "$1.new.dat.br -> $1.new.dat"
		brotli -d $WORK_DIR/$1.new.dat.br
	fi
	# 解压dat
	com_find sdat2img.py
	if [ -f $WORK_DIR/$1.transfer.list ] || [ -f $WORK_DIR/$1.new.dat ];then
		if [ -f $WORK_DIR/$1.img ];then
			rm -f $WORK_DIR/$1.img
		fi
		echo "$1.new.dat -> $1.img"
		sdat2img.py $WORK_DIR/$1.transfer.list $WORK_DIR/$1.new.dat $WORK_DIR/$1.img > /dev/null
	fi
	# 挂载
	if [ -f $WORK_DIR/$1.img ];then
		mk_dir $WORK_DIR/$1_img
		echo "挂载 $1 分区"
		sudo mount $WORK_DIR/$1.img $WORK_DIR/$1_img
	fi
}

# 压缩镜像
img_comp(){
	com_find img2simg
	rm -rf $WORK_DIR/$1_img
	# 压缩 img 为 simg
	if [ -f $WORK_DIR/$1.img ];then
		com_find img2simg
		echo "$1.img -> $1.simg"
		img2simg $WORK_DIR/$1.img $WORK_DIR/$1.simg
		rm -f $WORK_DIR/$1.img
	fi
	com_find img2sdat.py
	# 压缩 simg 为 sdat
	if [ -f $WORK_DIR/$1.simg ];then
		if [ -f $WORK_DIR/$1.new.dat ];then
			rm -f $WORK_DIR/$1.new.dat
		fi
		if [ -f $WORK_DIR/$1.transfer.list ];then
			rm -f $WORK_DIR/$1.transfer.list
		fi
		if [ -f $WORK_DIR/$1.patch.dat ];then
			rm -f $WORK_DIR/$1.patch.dat
		fi
		echo "$1.simg -> $1.new.dat"
		img2sdat.py $WORK_DIR/$1.simg -o $WORK_DIR -v 4 -p $1 > /dev/null
		rm $WORK_DIR/$1.simg
	fi
	# 压缩 sdat 为 br
	com_find brotli
	if [ -f $WORK_DIR/$1.new.dat ];then
	echo "$1.new.dat -> $1.new.dat.br"
		brotli -q 6 -j -f $WORK_DIR/$1.new.dat
	fi
}

# 删除app文件夹 rm_app 相对system/下的路径 文件夹名称
rm_app(){
	local del=(`echo $*`)
	unset del[0]
	for i in ${del[*]}
	do
		sudo rm -rf $WORK_DIR/system_img/system/$1/$i
	done
}

# 解压文件
com_find unzip
unzip -o rom.zip -d $WORK_DIR/

# 挂载system
img_ex system

# 卸载自带APP
echo "删除 app"
rm_app app ${del_app[*]}
rm_app priv-app ${del_privapp[*]}
rm_app data-app ${del_dataapp[*]}

# 去除卡米 （失败，无法理解工具的参数）
# mk_dir $WORK_DIR/services
# cp $WORK_DIR/system_img/system/framework/oat/arm64/services.odex .
# cp $WORK_DIR/system_img/system/framework/oat/arm64/services.vdex .
# com_find java
# java -jar tools/baksmali-2.5.2.jar disassemble $WORK_DIR/services/services.odex -d $WORK_DIR/system_img/system/framework/

echo "取消挂载 system 分区"
sudo umount $WORK_DIR/system_img
img_comp system

# 挂载vendor
img_ex vendor

# 去除data强制加密
echo "去除data强制加密"
sudo sed -i 's/fileencryption=ice/encryptable=ice/g' $WORK_DIR/vendor_img/etc/fstab.qcom

echo "取消挂载 vendor 分区"
sudo umount $WORK_DIR/vendor_img
img_comp vendor

# 打包
echo "$WORK_DIR/ -> rom_out.zip"
com_find zip
shell_DIR=`pwd`
cd $WORK_DIR
zip -r $shell_DIR/rom_out.zip *