#!/bin/bash

if [[ 0 == $UID ]]; then
    echo -e "当前用户是root用户，进入安装流程"
    sleep 3
else
    echo -e "当前用户不是root用户，请用 sudo su 命令切换到root用户后重新执行脚本"
    exit 1
fi

apt update && apt upgrade -y && apt autoremove -y

if [ -f /usr/local/bin/sing-box ]; then
    echo -e "正在更新"
    rm /usr/local/bin/sing-box
    wget https://raw.githubusercontent.com/ActiveIce/xuewaiyu/master/sing-box -O /usr/local/bin/sing-box
    chmod +x /usr/local/bin/sing-box
    systemctl restart sing-box
    echo -e "更新完成"
    exit 0
fi

systemctl stop snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl disable snap.amazon-ssm-agent.amazon-ssm-agent.service
#curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#echo "deb https://packages.cloud.google.com/apt google-cloud-ops-agent-jammy-all main" > /etc/apt/sources.list.d/google-cloud-ops-agent.list
#apt update && apt install -y google-cloud-ops-agent

read -p "请输入domain(eg:www.google.com):" domain
read -p "请输入UUID（default:random）:" UUID
[[ -z ${UUID} ]] && UUID=$(cat /proc/sys/kernel/random/uuid)

wget https://raw.githubusercontent.com/ActiveIce/xuewaiyu/master/sing-box -O /usr/local/bin/sing-box
chmod +x /usr/local/bin/sing-box
wget https://raw.githubusercontent.com/SagerNet/sing-box/dev-next/release/local/sing-box.service -O /etc/systemd/system/sing-box.service
mkdir -p /usr/local/etc/sing-box
mkdir -p /var/lib/sing-box
cat > /usr/local/etc/sing-box/config.json << EOF
{
  "log": {
    "level": "info"
  },
  "inbounds": [
    {
      "type": "hysteria2",
      "listen": "::",
      "listen_port": 443,
      "users": [
        {
          "password": "${UUID}"
        }
      ],
      "ignore_client_bandwidth": true,
      "tls": {
        "enabled": true,
        "server_name": "${domain}",
        "alpn": ["h3", "h2", "http/1.1"],
        "acme": {
          "domain": ["${domain}"],
          "email": "admin@${domain}"
        }
      }
    },
    {
      "type": "anytls",
      "listen": "::",
      "listen_port": 443,
      "users": [
        {
          "password": "${UUID}"
        }
      ],
      "tls": {
        "enabled": true,
        "server_name": "${domain}",
        "alpn": ["h3", "h2", "http/1.1"],
        "acme": {
          "domain": ["${domain}"],
          "email": "admin@${domain}"
        }
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct-out"
    }
  ],
  "route": {
    "rule_set": [
      {
        "type": "remote",
        "tag": "geosite-openai",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-openai.srs",
        "download_detour": "direct-out"
      }
    ],
    "rules": [
      {
        "rule_set": [
          "geosite-openai"
        ],
        "outbound": "warp"
      }
    ]
  }
}
EOF

systemctl daemon-reload
systemctl enable sing-box
systemctl start sing-box

sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
sysctl -p

echo -e ${UUID}
echo -e "安装完成"

exit 0
