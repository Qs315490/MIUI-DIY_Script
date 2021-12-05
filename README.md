# 目前已实现
- [x] 去除data强制加密
- [ ] 破解卡mi
- [x] 自定义精简应用列表
- [ ] 内置Magisk 23.0 (在 `附加其他刷机包` 中实现)
- [ ] 附加其他刷机包

# 测试设备
ROM：miui_CEPHEUS_V12.5.6.0.RFACNXM_5d1239a6d1_11.0.zip  
Phone：XiaoMi 9 (cepheus)  
OS：Kali Linux on VMWare

# 使用方法
```bash
# 安装依赖
sudo apt install brotli zip unzip android-sdk-libsparse-utils
git clone https://github.com/Qs315490/MIUI12.5-DIY_Script --depth=1
cd MIUI12.5-DIY_Script
# 移动数据包到当前目录，并改名为 rom.zip
mv /path/to/rom rom.zip
# 开始运行脚本
./start.sh
```

# 关于tools文件夹下的文件
这些文件来源自网络，部分文件可能会侵犯到某些开源协议。