#!/bin/sh

hostip=$(cat /etc/resolv.conf | grep 'nameserver' | awk '{print $2}')
wslip=$(hostname -I)
httpPort=7890
socks5Port=7890

PROXY_HTTP="http://${hostip}:${httpPort}"
PROXY_SCOKS5="socks5://${hostip}:${socks5Port}"

set_proxy(){
	export http_proxy="${PROXY_HTTP}"
	export HTTP_PROXY="${PROXY_HTTP}"

	export https_proxy="${PROXY_HTTP}"
	export HTTPS_PROXY="${PROXY_HTTP}"

	export ALL_PROXY="${PROXY_SCOKS5}"
	export all_proxy="${PROXY_SCOKS5}"
}

unset_proxy(){
	unset http_proxy
	unset HTTP_PROXY
	unset https_proxy
	unset HTTPS_PROXY
	unset all_proxy
	unset ALL_PROXY
}

test_setting(){
	echo "Host ip:"${hostip}
	echo "WSL ip:"${wslip}
	echo "http proxy":${http_proxy}
	echo "socks5 proxy:"${all_proxy}
}

if [ "$1" = "set" ]
then
	set_proxy
elif [ "$1" = "unset" ]
then
	unset_proxy
elif [ "$1" = "test" ]
then
	test_setting
fi
