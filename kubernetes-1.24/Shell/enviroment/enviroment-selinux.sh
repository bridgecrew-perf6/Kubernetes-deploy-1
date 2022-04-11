###
 # @Description: Close SELinux and firewall and Swap
 # @Author: Chris.Wang
 # @Date: 2022-04-11 20:48:27
 # @LastEditTime: 2022-04-11 21:17:00
 # @email: wtchhb@163.com
 # @LastEditors:  
### 

# Get Hostname
# hostnamectl  | awk -F ":" '/Static hostname/{print $2}'
# hostname

# Get Host List from /etc/hosts
# sed -n '3,$p' /etc/hosts | awk '{print $NF}'

# Setting Environment Variables
export HOSTLIST=$(sed -n '3,$p' /etc/hosts | awk '{print $NF}')

# Close SELinux and Firewall and Swap
echo "=============Close selinux and firewall============="
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