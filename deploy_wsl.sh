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

wget https://raw.githubusercontent.com/ActiveIce/xuewaiyu/master/sing-box -O /usr/local/bin/sing-box
chmod +x /usr/local/bin/sing-box
wget https://raw.githubusercontent.com/SagerNet/sing-box/dev-next/release/local/sing-box.service -O /etc/systemd/system/sing-box.service
mkdir -p /usr/local/etc/sing-box
mkdir -p /var/lib/sing-box
IP=$(cat /etc/resolv.conf | grep nameserver | sed 's/nameserver //')
cat > /usr/local/etc/sing-box/config.json << EOF
{
  "inbounds": [
    {
      "type": "http",
      "listen": "127.0.0.1",
      "listen_port": 10809
    }
  ],
  "outbounds": [
    {
      "type": "http",
      "server": "${IP}",
      "server_port": 10809
    }
  ]
}
EOF

cat >> /root/.bashrc << EOF
export HTTPS_PROXY="http://127.0.0.1:10809"
export HTTP_PROXY="http://127.0.0.1:10809"
export http_proxy="http://127.0.0.1:10809"
export https_proxy="http://127.0.0.1:10809"
EOF

systemctl daemon-reload
systemctl enable sing-box
systemctl start sing-box

exit 0
