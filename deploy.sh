#!/bin/bash

if [[ 0 == $UID ]]; then
    echo -e "当前用户是root用户，进入安装流程"
    sleep 3
else
    echo -e "当前用户不是root用户，请用 sudo su 命令切换到root用户后重新执行脚本"
    exit 1    
fi

apt update && apt upgrade -y && apt autoremove -y

if [[ -f /usr/local/bin/xray ]]; then
    echo -e "正在更新"
    bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) --beta
    echo -e "更新完成"
    read -p "需要重启后，更新才能生效，是否现在重启 ? [Y/n] :" yn
    [[ -z "${yn}" ]] && yn="y"
    if [[ $yn == [Yy] ]]; then
    	echo -e "重启中..."
	reboot
    fi
    exit 0
fi

apt install -y iputils-ping
read -rp "请输入你的域名信息(eg:www.google.com):" domain
domain_ip=$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
echo -e "${OK} ${GreenBG} 正在获取 公网ip 信息，请耐心等待 ${Font}"
local_ip=$(curl -s https://ipinfo.io/ip)
echo -e "域名dns解析IP：${domain_ip}"
echo -e "本机IP: ${local_ip}"
sleep 2
if [[ $(echo "${local_ip}" | tr '.' '+' | bc) -eq $(echo "${domain_ip}" | tr '.' '+' | bc) ]]; then
    echo -e "${OK} ${GreenBG} 域名dns解析IP 与 本机IP 匹配 ${Font}"
    sleep 2
else
    echo -e "${Error} ${RedBG} 请确保域名添加了正确的 A 记录，否则将无法正常使用 V2ray ${Font}"
    echo -e "${Error} ${RedBG} 域名dns解析IP 与 本机IP 不匹配 是否继续安装？（y/n）${Font}" && read -r install
    case $install in
    [yY][eE][sS] | [yY])
        echo -e "${GreenBG} 继续安装 ${Font}"
        sleep 2
        ;;
    *)
        echo -e "${RedBG} 安装终止 ${Font}"
        exit 2
    ;;
    esac
fi

apt install -y uuid-runtime tzdata cron socat unzip
timedatectl set-timezone Asia/Shanghai

read -p "请输入UUID（default:random）:" UUID
[[ -z ${UUID} ]] && UUID=$(uuidgen -n @dns -N ${domain} -s)

bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh) --beta
rm /usr/local/etc/xray/config.json
wget https://raw.githubusercontent.com/ActiveIce/xuewaiyu/master/config.json -O /usr/local/etc/xray/config.json
sed -i "s/00000000-0000-0000-0000-000000000000/${UUID}/" /usr/local/etc/xray/config.json
curl https://get.acme.sh | sh
/root/.acme.sh/acme.sh --issue -d ${domain} --standalone
/root/.acme.sh/acme.sh --install-cert -d ${domain} --key-file /usr/local/etc/xray/key.pem --fullchain-file /usr/local/etc/xray/fullchain.pem --reloadcmd "chmod 644 /usr/local/etc/xray/*.pem && systemctl restart xray"
systemctl enable xray

sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_retries2/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_slow_start_after_idle/d' /etc/sysctl.conf
sed -i '/fs.file-max/d' /etc/sysctl.conf
sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf <<EOF
net.core.default_qdisc = fq_pie
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_retries2 = 8
net.ipv4.tcp_slow_start_after_idle = 0
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
EOF
sysctl -p

echo -e "安装完成"

exit 0
