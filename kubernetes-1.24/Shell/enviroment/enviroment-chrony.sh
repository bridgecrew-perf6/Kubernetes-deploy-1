###
 # @Description: Setting Chrony Service
 # @Author: Chris.Wang
 # @Date: 2022-04-11 20:48:27
 # @LastEditTime: 2022-04-11 21:19:42
 # @email: wtchhb@163.com
 # @LastEditors:  
### 

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