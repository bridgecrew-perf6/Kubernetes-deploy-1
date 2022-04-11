###
 # @Description: setting yum and installing soft
 # @Author: Chris.Wang
 # @Date: 2022-04-11 20:48:27
 # @LastEditTime: 2022-04-11 21:11:23
 # @email: wtchhb@163.com
 # @LastEditors:  
### 

# setting yum
echo "=============Configure yum source============="
curl -o CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
for host in $(echo ${HOSTLIST});do
    echo -e "Configure yum source on \033[33m ${host} \033[0m"
    ssh ${host} "mkdir -p /etc/yum.repos.d/bak && mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak"
    scp CentOS-Base.repo root@${host}:/etc/yum.repos.d/CentOS-Base.repo &> /dev/null
    ssh ${host} "yum clean all &> /dev/null"
    ssh ${host} "yum makecache fast &> /dev/null"
    echo -e "Configure yum source on \033[33m ${host} \033[0m\033[32m success \033[0m"
done
echo "=============Install soft============="
for host in $(echo ${HOSTLIST});do
    echo -e "Install soft on \033[33m ${host} \033[0m"
    ssh ${host} yum install wget vim make gcc gcc-c++ ipvsadm telnet net-tools -y &> /dev/null
    echo -e "Install soft on \033[33m ${host} \033[0m\033[32m success \033[0m"
done