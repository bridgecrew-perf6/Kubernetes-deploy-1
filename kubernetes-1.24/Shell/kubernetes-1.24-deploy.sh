#! /bin/bash
# author: Chris Wang

# 获取主机名
# hostnamectl  | awk -F ":" '/Static hostname/{print $2}'
# hostname

# 获取所要操作的主机的列表
# sed -n '3,$p' /etc/hosts | awk '{print $NF}'
HOSTLIST=$(sed -n '3,$p' /etc/hosts | awk '{print $NF}')

# 关闭SELINUX/swap/firewalld
for host in $(echo ${HOSTLIST}); do
    echo -e "Disable SELINUX on \033[33m ${host} \033[0m"
    ssh ${host} "cp /etc/selinux/config /etc/selinux/config.bak"
    # sed '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
    ssh ${host} "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"
    ssh ${host} "setenforce 0"
    echo -e 'Disable SELINUX on ${host} \033[32m done \033[0m'

    echo "Disable swap on ${host}"
    ssh ${host} "swapoff -a"
    ssh ${host} "sed -i '/swap/s/^/#/' /etc/fstab"
    echo "Disable swap on ${host} done"

    echo "Disable firewalld on ${host}"
    ssh ${host} "systemctl stop firewalld"
    ssh ${host} "systemctl disable firewalld"
    echo "Disable firewalld on ${host} done"
done

# 生成k8s.conf文件
cat > k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# 修改内核参数
for host in $(echo ${HOSTLIST});do
    # 加载br_netfilter模块
    echo -e "Load br_netfilter module on\033[33m ${host} \033[0m\033[35m start \033[0m"
    ssh ${host} "modprobe br_netfilter"
    ssh ${host} "lsmod |grep br_netfilter &> /dev/null;if [ \$? -eq 0 ];then echo -e '\033[32m br_netfilter module loaded \033[0m';else echo -e '\033[31m br_netfilter module load failed \033[0m';fi"
    echo "Modify kernel parameters on ${host} start"

    scp k8s.conf root@${host}:/etc/sysctl.d/k8s.conf &> /dev/null
    ssh ${host} "sysctl -p /etc/sysctl.d/k8s.conf &> /dev/null"
    echo "Modify kernel parameters on ${host} success"
done

# 配置yum源
echo "=============Configure yum source on start============="
curl -o CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
for host in $(echo ${HOSTLIST});do
    echo -e "Configure yum source on \033[33m ${host} \033[0m"
    ssh ${host} "mkdir -p /etc/yum.repos.d/bak && mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak"
    scp CentOS-Base.repo root@${host}:/etc/yum.repos.d/CentOS-Base.repo &> /dev/null
    ssh ${host} "yum clean all &> /dev/null"
    ssh ${host} "yum makecache fast &> /dev/null"
    echo -e "Configure yum source on \033[33m ${host} \033[0m\033[32m success \033[0m"
done

# 配置时间同步
echo "=============Configure time sync start ============="
for host in $(echo ${HOSTLIST});do
    echo -e "Configure time sync on \033[33m ${host} \033[0m"
    ssh ${host} "yum install -y chrony"
    ssh ${host} "sed -i '/^pool /a\server ntp.aliyun.com iburst' /etc/chrony.conf"
    ssh ${host} "sed -i '/^pool /s/^\(.*\)$/# \1/g' /etc/chrony.conf"
    ssh ${host} "systemctl enable --now chronyd &> /dev/null"
    echo -e " \033[32m Print chronyc sources -v Result \033[0m"
    ssh ${host} "chronyc sources -v; if [ \$? -eq 0 ];then echo -e '\033[32m Print chronyc sources -v success \033[0m';else echo -e '\033[31m Print chronyc sources -v failed \033[0m' ; echo 'restarted chronyd service'; systemctl restart chronyd && chronyc sources -v;fi "
    # 修改时区
    echo "Set TimeZone"
    ssh ${host} "timedatectl set-timezone Asia/Shanghai"
    echo -e "Configure time sync on \033[33m ${host} \033[0m\033[32m success \033[0m"
done

# 配置iptables
echo "=============Configure iptables start ============="
for host in $(echo ${HOSTLIST});do
    echo -e "Configure iptables on \033[33m ${host} \033[0m"
    ssh ${host} "yum -y install iptables-services &> /dev/null"
    ssh ${host} "systemctl stop firewalld"
    ssh ${host} "systemctl disable firewalld"
    ssh ${host} "systemctl stop iptables"
    ssh ${host} "systemctl disable iptables"
    echo -e "Configure iptables on \033[33m ${host} \033[0m\033[32m success \033[0m"

# 配置ipvs
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
for host in $(${HOSTLIST});do
    scp ipvs.modules root@${host}:/etc/sysconfig/modules/ipvs.modules &> /dev/null
    ssh ${host} "chmod 755 /etc/sysconfig/modules/ipvs.modules; bash /etc/sysconfig/modules/ipvs.modules; if []"
done

