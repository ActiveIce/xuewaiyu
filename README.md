# 穴外语


### Deploy & Update

``` bash
sudo su
bash <(curl -L -s https://raw.githubusercontent.com/ActiveIce/xuewaiyu/master/deploy.sh)
```

### WSL install
``` bash
sudo su
export https_proxy=http://$(cat /etc/resolv.conf | grep nameserver | sed 's/nameserver //'):10809
bash <(curl -L -s https://raw.githubusercontent.com/ActiveIce/xuewaiyu/master/deploy_wsl.sh)
```

### Download

https://raw.githubusercontent.com/ActiveIce/xuewaiyu/master/sing-box.exe
