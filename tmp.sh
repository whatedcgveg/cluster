#!/bin/bash

# 定义参数检查
paras=$@
function checkPara(){
    local p=$1
    for i in $paras; do if [[ $i == $p ]]; then return; fi; done
    false
}

# 设定区域
REGION=ng
checkPara 'au' && REGION=au-syd # Sydney, Australia
checkPara 'uk' && REGION=eu-gb # London, England
checkPara 'de' && REGION=eu-de # Frankfurt, Germany


# 安装 Bluemix cli
sh <(curl -fsSL https://clis.ng.bluemix.net/install/linux)

# 禁止上传用户使用情况
bluemix config --usage-stats-collect false

# 安装 kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# 安装 Bluemix 插件
bx plugin install container-service -r Bluemix

# 初始化
#echo -e -n "\n请输入用户名："
#read USERNAME
#echo -n '请输入密码：'
#read -s PASSWD
#echo -e '\n'
#(echo 1; echo no) | bx login -a https://api.${REGION}.bluemix.net -u $USERNAME -p $PASSWD
bx login -a https://api.${REGION}.bluemix.net
(echo 1; echo 1) | bx target --cf
bx cs init
$(bx cs cluster-config $(bx cs clusters | grep 'normal' | awk '{print $1}') | grep 'export')
PPW=$(openssl rand -base64 12 | md5sum | head -c12)
SPW=$(openssl rand -base64 12 | md5sum | head -c12)
AKN=del_$(openssl rand -base64 12 | md5sum | head -c5)
AK=$(bx iam api-key-create $AKN | tail -1 | awk '{print $3}' | base64)
