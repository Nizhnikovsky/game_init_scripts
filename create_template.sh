#!/bin/bash

gittoken=${1}
branchname=${2}
servername=${3}
username=${4}
userpassword=${5}
reponame="LinuxGSM"
rootdir="/home/${username}"
lgsmdir="${rootdir}/${servername}/lgsm"
configdir="${lgsmdir}/config-default/config-lgsm"
dependenciesscript="install_server_dependencies.sh"
mapdir="${rootdir}/${servername}/maps"
serverfiles="${rootdir}/${servername}/serverfiles"

fn_fetch_repo_from_git(){
        gittoken=${1}
        branch=${2}
        if [ !$gittoken ]; then
           echo "Git Token is required for cloning repo!!"
           exit 0
        fi
        
    git clone -b ${branch} "https://${gittoken}@github.com/Nizhnikovsky/LinuxGSMFork.git"
}

fn_add_maps()
{
   serverfiles=${1}
   mapdir=${2}
   
   lsl=`cd ${mapdir} && ls -1`

   for map_name in $lsl
   do
      unzip -o ${mapdir}/${map_name} -d ${serverfiles}/world/
   done

}


fn_install_dependencies(){
    confdir=${1}
    servername=${2}
    dependenciesscript=${3}
    cd ${confdir}/${servername} && ./${dependenciesscript}
}

#Check OS to install git and update packages
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

#Create new user non root for starting and creating gameserver
sudo useradd -m ${username}

if [${userpassword}]; then
     usermod --password ${userpassword} ${username}
fi


#Get Linux GSM repo from GitHub
cd /home/${username} && fn_fetch_repo_from_git ${gittoken} ${branchname}

#Rename repo according to servername and change owher
mv ${reponame} ${servername} && chown -R ${username}:${username} ${servername}/                                                                           

#Install dependencies for game server
fn_install_dependencies ${configdir} ${servername} ${dependenciesscript}

#Install game server as non root user
shservername=$(echo ${servername} | awk '{ print substr( $0, 1, length($0)-6 ) }')
su -c "cd /home/${username}/${servername} && ./linuxgsm.sh ${shservername} && ./${servername} auto-install" -m "${username}"

#Add maps to gameserver maps directory
fn_add_maps ${serverfiles} ${mapdir}
chown -R ${username}:${username} ${serverfiles}/maps


