ipvsadm -A -t 192.168.1.108:80 -s rr
ipvsadm -a -t 192.168.1.108:80 -r 192.168.1.106 -g
ipvsadm -a -t 192.168.1.108:80 -r 192.168.1.107 -g