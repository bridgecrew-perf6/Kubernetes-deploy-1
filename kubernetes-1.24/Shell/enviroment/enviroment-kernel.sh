###
 # @Description: Setting Kernel parameters
 # @Author: Chris.Wang
 # @Date: 2022-04-11 20:48:27
 # @LastEditTime: 2022-04-11 21:05:24
 # @email: wtchhb@163.com
 # @LastEditors:  
### 

# Create k8s.conf file about kernel parameters
cat > k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Setting Kernel parameters for all nodes
for host in $(echo ${HOSTLIST});do
    # load br_netfilter module
    echo -e "Load br_netfilter module on\033[33m ${host} \033[0m\033[35m start \033[0m"
    ssh ${host} "modprobe br_netfilter"
    ssh ${host} "lsmod |grep br_netfilter &> /dev/null;if [ \$? -eq 0 ];then echo -e '\033[32m br_netfilter module loaded \033[0m';else echo -e '\033[31m br_netfilter module load failed \033[0m';fi"
    echo "Modify kernel parameters on ${host} start"

    scp k8s.conf root@${host}:/etc/sysctl.d/k8s.conf &> /dev/null
    ssh ${host} "sysctl -p /etc/sysctl.d/k8s.conf &> /dev/null"
    echo "Modify kernel parameters on ${host} success"
done
