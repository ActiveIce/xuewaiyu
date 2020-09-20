#!/bin/bash
echo -e "test start"

cat > config.json <<EOF
{
  "inbounds": [{
    "port": 10808, 
    "listen": "127.0.0.1",
    "protocol": "vmess",
    "settings": {
      "clients": [{
        "id": "00000000-0000-0000-0000-000000000000", 
        "alterId": 0
      }]
    }, 
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "/test"
      }
    }
  }], 
  "outbounds": [{
    "protocol": "freedom"
  }]
}
EOF

cat > haproxy.cfg <<EOF
global
    daemon
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
    ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets
    
defaults
    mode http
    maxconn 100000
    timeout client          60s
    timeout connect          1s
    timeout server           5s
    timeout tunnel        3600s

frontend https
    bind *:10800
    http-response set-header Strict-Transport-Security max-age=63072000
    default_backend ws

backend ws
    server ws 127.0.0.1:10808 allow-0rtt
EOF

chmod +x ./core/v2ray ./core/v2ctl ./haproxy/haproxy
./core/v2ray -config config.json & ./haproxy/haproxy -Ws -f haproxy.cfg -D
if [[ "$(curl -L -s http://127.0.0.1:10800/test)" == "Bad Request" ]]; then
    echo -e "test passed"
    exit 0
else
    echo -e "test failed"
    exit 1    
fi
