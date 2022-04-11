###
 # @Description: Setting iptables ipvs
 # @Author: Chris.Wang
 # @Date: 2022-04-11 20:48:27
 # @LastEditTime: 2022-04-11 21:51:50
 # @email: wtchhb@163.com
 # @LastEditors:  
### 

echo -e "=============Setting iptables ipvs============="
# create ipvs.modules file
cat > ipvs.modules << EOF
modprobe -- ip_vs
modprobe -- ip_vs_lc
modprobe -- ip_vs_wlc
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_lblc
modprobe -- ip_vs_lblcr
modprobe -- ip_vs_dh
modprobe -- ip_vs_sh
modprobe -- ip_vs_nq
modprobe -- ip_vs_sed
modprobe -- ip_vs_ftp
modprobe -- nf_conntrack
EOF

for host in $(echo ${HOSTLIST});do
    echo -e "Setting iptables on \033[33m ${host} \033[0m"
    ssh ${host} "yum install iptables-services ipvsadm ipset -y  &> /dev/null && systemctl stop firewalld && systemctl disable firewalld; iptables -F"
    echo -e "Setting ipvs on \033[33m ${host} \033[0m\033[32m done \033[0m"
    # scp ipvs.modules to host
    scp ipvs.modules ${host}:/etc/sysconfig/modules/ipvs.modules
    ssh ${host} "chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep ip_vs && \
    if [$? -eq 0];then echo -e 'Setting ipvs on ${host} \033[32m done \033[0m';else echo -e 'Setting ipvs on ${host} \033[31m failed \033[0m' || exit 1;fi"
done
