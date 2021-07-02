#!/bin/bash

branchname=${1}
servername=${2}
username="minecraft"
password="qwerty89*"
reponame="LinuxGSM"
rootdir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
lgsmdir="${rootdir}/lgsm"
configdir="${lgsmdir}/config-lgsm"
dependenciesscript="install_server_dependencies.sh"

fn_fetch_repo_from_git(){
	git clone -b ${1} "https://github.com/GameServerManagers/LinuxGSM/"
}


fn_install_dependencies(){
	confdir=${1}
	servername=${2}
	dependenciesscript=${3}
	cd ${confdir}/${servername} && ./${dependenciesscript}
}
ostype="$(awk -F "=" '/^NAME/ {gsub("\"","");print $2}' /etc/os-release)"

if [[ "$ostype" == "Ubuntu" ]]; then
     sudo apt-get update && sudo apt-get upgrade sudo apt instal git non-interactive
fi

if [ ${ostype}  == "CentOS" ]; then
	yum install epel-release
	yum update && yum install git
fi

if [ ${ostype}  == "Debian" ]; then
     sudo apt-get update && sudo apt-get upgrade sudo apt instal git non-interactive
fi

sudo useradd -m ${username}
usermod --password ${password} ${username}

cd /home/${username} && fn_fetch_repo_from_git ${branchname}

mv ${reponame} ${servername}

fn_install_dependencies ${configdir} ${servername} ${dependenciesscript}
su - ${username}
cd /home/${servername} && ./linuxgsm install ${servername}
./${servername} autoinstall






