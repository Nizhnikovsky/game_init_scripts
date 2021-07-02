#!/bin/bash

branchname=${1}
servername=${2}
username="minecraft"
password="qwerty89*"
reponame="LinuxGSM"
rootdir="/home/${username}"
lgsmdir="${rootdir}/${servername}/lgsm"
configdir="${lgsmdir}/config-default/config-lgsm"
dependenciesscript="install_server_dependencies.sh"

fn_fetch_repo_from_git(){
        branch=${1}
        echo branch
	git clone -b ${branch} "https://github.com/Nizhnikovsky/LinuxGSM.git"
}


fn_install_dependencies(){
	confdir=${1}
	servername=${2}
	dependenciesscript=${3}
	cd ${confdir}/${servername} && ./${dependenciesscript}
}
ostype="$(awk -F "=" '/^NAME/ {gsub("\"","");print $2}' /etc/os-release)"

if [[ $ostype == *"Ubuntu"* ]]; then
     sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt install git -y
fi

if [[ $ostype == *"CentOS"* ]]; then
	yum install epel-release
	yum update -y && yum install git -y
fi

if [[ $ostype == *"Debian"* ]]; then
     sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt install git -y
fi

sudo useradd -m ${username}

usermod --password ${password} ${username}

cd /home/${username} && fn_fetch_repo_from_git ${branchname}

mv ${reponame} ${servername} && chown -R ${username}:${username} ${servername}/

fn_install_dependencies ${configdir} ${servername} ${dependenciesscript}

shservername=$(echo ${servername} | awk '{ print substr( $0, 1, length($0)-6 ) }')

su -c "cd /home/${username}/${servername} && ./linuxgsm.sh ${shservername} ./${servername} auto-install" -m "${username}"







