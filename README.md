# 学外语

[![auto build engine](https://github.com/ActiveIce/xuewaiyu/workflows/auto%20build%20engine/badge.svg)](https://github.com/ActiveIce/xuewaiyu/actions)

### 服务器端部署

``` bash
sudo su
curl -L -s https://raw.githubusercontent.com/ActiveIce/xuewaiyu/master/deploy.sh | bash
```

### 客户端下载

[Windows](https://raw.githubusercontent.com/ActiveIce/xuewaiyu/master/xwy-windows.zip)

[Android](https://raw.githubusercontent.com/ActiveIce/xuewaiyu/master/xwy-android.apk)

#### 若Windows端运行失败请下载安装

[.NET Framework 4.8 Runtime 安装包](https://download.visualstudio.microsoft.com/download/pr/014120d7-d689-4305-befd-3cb711108212/0fd66638cde16859462a6243a4629a50/ndp48-x86-x64-allos-enu.exe)

[.NET Framework 4.8 中文语言包](https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/00751a26db33223ca3f9a8b20a7be95c/ndp48-x86-x64-allos-chs.exe)

### 更新证书或者重新部署之前删除相关文件夹

``` bash
sudo rm -r /usr/bin/v2ray 
sudo rm -r /usr/sbin/haproxy
```
