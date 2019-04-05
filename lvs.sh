#!/bin/bash
#########################################
#
#             实现lvs-dr
#
#########################################
 
 
#
# 调度器上要执行的内容
# @param
#
director() {
    local network_name=$1
    local vip=$2
    local rs1=$3
    local rs2=$4
     
    if [ -z "$network_name" ]; then
        echo "error: network_name can not empty";exit
    fi
    if [ -z "$vip" ]; then
        echo "error: vip can not empty";exit
    fi
    if [ -z "$rs1" ] || [ -z "rs2" ]; then
        echo "error: rs1 and rs2 can not empty";exit
    fi
     
    ifconfig $network_name:0 $vip/32 broadcast $vip up
    route add -host $vip dev $network_name:0
     
    ipvsadm -A -t $vip:80 -s rr
    ipvsadm -a -t $vip:80 -r $rs1 -g
    ipvsadm -a -t $vip:80 -r $rs2 -g
     
    # ifconfig
    # route -n
    # ipvsadm -L -n
}
 
 
#
# real server 上要执行的命令
# @param
#
realserver() {
    local vip=$1
    if [ -z "$vip" ];then
        echo "vip can not empty";exit
    fi
    echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
    echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
     
    ifconfig lo:0 $vip/32 broadcast $vip up
}
 
 
#
# 帮助信息
# @param
#
usage() {
cat <<EOF
    real server execute:
      -r vip
      example: 
        lvs.sh -r 192.168.1.108
 
    director execute:
      -d network_name vip
      example: 
        lvs.sh -d ens160 192.168.1.108 192.168.1.106 192.168.1.107
EOF
}
 
 
if [ -z "$1" ];then
    usage
fi
 
 
while [ -n "$1" ]
do
    case "$1" in
    --realserver|-r)
        VIP=$2
        realserver $2
        shift 2
    ;;
    --director|-d)
        director $2 $3 $4 $5
        shift 5
    ;;
    --help|-h)
        usage
        break
    ;;
    esac
done

