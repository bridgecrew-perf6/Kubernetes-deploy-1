###
 # @Description: main script
 # @Author: Chris.Wang
 # @Date: 2022-04-11 20:48:27
 # @LastEditTime: 2022-04-11 21:32:53
 # @email: wtchhb@163.com
 # @LastEditors:  
### 

# Get Host List from /etc/hosts
# sed -n '3,$p' /etc/hosts | awk '{print $NF}'

# Setting Enviroment Variables
export HOSTLIST=$(sed -n '3,$p' /etc/hosts | awk '{print $NF}')
export NODE_HOST=$(sed -n '6,$p' /etc/hosts | awk '{print $NF}')
