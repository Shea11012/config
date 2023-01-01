#/!bin/bash

hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
wslip=$(hostname -i | awk '{print $1}')
port=7890

PROXY_HTTP="http://${hostip}:${port}"

set_proxy(){
  export http_proxy="${PROXY_HTTP}"
  export HTTP_PROXY="${PROXY_HTTP}"

  export https_proxy="${PROXY_HTTP}"
  export HTTPS_PROXY="${PROXY_HTTP}"
}

unset_proxy(){
    unset http_proxy
    unset HTTP_PROXY
    unset https_proxy
    unset HTTPS_PROXY
}

test_proxy(){
    echo "Host ip: ${hostip}"
    echo "WSL ip: ${wslip}"
    echo "proxy: ${PROXY_HTTP}"
}

if [ "$1" = "set" ]; then
    set_proxy
elif [ "$1" = "unset" ]; then
    unset_proxy
elif [ "$1" = "test" ]; then
    test_proxy
else
    echo "unsupported arg"
fi
